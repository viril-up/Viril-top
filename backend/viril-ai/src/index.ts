interface Env {
  AI: Ai;
  DB: D1Database;
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
}

interface ChatMessage {
  role: "system" | "user" | "assistant";
  content: string;
}

interface ModelResult {
  response?: unknown;
  choices?: Array<{
    message?: {
      content?: unknown;
    };
  }>;
  [key: string]: unknown;
}

interface SupabaseAuthUser {
  id?: string;
}

const MODEL = "@cf/google/gemma-4-26b-a4b-it";
const MAX_MESSAGES = 20;
const MAX_MESSAGE_LENGTH = 8000;
const MAX_PROGRESS_BYTES = 900_000;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json; charset=utf-8",
};

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: corsHeaders,
  });
}

function isChatMessage(value: unknown): value is ChatMessage {
  if (!value || typeof value !== "object") return false;
  const item = value as Record<string, unknown>;
  return (
    ["system", "user", "assistant"].includes(String(item.role)) &&
    typeof item.content === "string" &&
    item.content.length > 0 &&
    item.content.length <= MAX_MESSAGE_LENGTH
  );
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

async function authenticate(request: Request, env: Env): Promise<string | null> {
  const authorization = request.headers.get("Authorization") ?? "";
  const match = authorization.match(/^Bearer\s+(.+)$/i);
  if (!match || !env.SUPABASE_URL || !env.SUPABASE_ANON_KEY) return null;

  const response = await fetch(new URL("/auth/v1/user", env.SUPABASE_URL), {
    method: "GET",
    headers: {
      apikey: env.SUPABASE_ANON_KEY,
      Authorization: `Bearer ${match[1]}`,
    },
  });
  if (!response.ok) return null;

  const user = await response.json() as SupabaseAuthUser;
  return typeof user.id === "string" && user.id.length > 0 ? user.id : null;
}

async function handleProgress(request: Request, env: Env): Promise<Response> {
  let userId: string | null;
  try {
    userId = await authenticate(request, env);
  } catch (error) {
    console.error("Supabase token validation failed", error);
    return json({ error: "Authentication service is temporarily unavailable" }, 503);
  }
  if (!userId) return json({ error: "Authentication required" }, 401);

  if (request.method === "GET") {
    const row = await env.DB.prepare(
      "SELECT snapshot_json, revision, updated_at FROM progress_snapshots WHERE user_id = ?1",
    ).bind(userId).first<{
      snapshot_json: string;
      revision: number;
      updated_at: string;
    }>();

    if (!row) return json({ exists: false, revision: 0, snapshot: null });
    try {
      return json({
        exists: true,
        revision: row.revision,
        updatedAt: row.updated_at,
        snapshot: JSON.parse(row.snapshot_json),
      });
    } catch (error) {
      console.error("Stored progress snapshot is invalid JSON", error);
      return json({ error: "Stored progress data could not be read" }, 500);
    }
  }

  if (request.method !== "PUT") {
    return json({ error: "Method not allowed" }, 405);
  }

  const contentLength = Number(request.headers.get("Content-Length") ?? "0");
  if (contentLength > MAX_PROGRESS_BYTES) {
    return json({ error: "Progress snapshot is too large" }, 413);
  }

  let body: unknown;
  try {
    const raw = await request.text();
    if (new TextEncoder().encode(raw).byteLength > MAX_PROGRESS_BYTES) {
      return json({ error: "Progress snapshot is too large" }, 413);
    }
    body = JSON.parse(raw);
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }

  if (!isRecord(body) || !isRecord(body.snapshot)) {
    return json({ error: "snapshot must be a JSON object" }, 400);
  }

  const snapshotJson = JSON.stringify(body.snapshot);
  if (new TextEncoder().encode(snapshotJson).byteLength > MAX_PROGRESS_BYTES) {
    return json({ error: "Progress snapshot is too large" }, 413);
  }

  const expectedRevision = body.expectedRevision;
  const now = new Date().toISOString();

  if (expectedRevision === null || expectedRevision === undefined) {
    const inserted = await env.DB.prepare(
      "INSERT OR IGNORE INTO progress_snapshots (user_id, snapshot_json, revision, updated_at) VALUES (?1, ?2, 1, ?3)",
    ).bind(userId, snapshotJson, now).run();

    if (inserted.meta.changes !== 1) {
      return json({ error: "A progress snapshot already exists", conflict: true }, 409);
    }
    return json({ saved: true, revision: 1, updatedAt: now }, 201);
  }

  if (!Number.isInteger(expectedRevision) || expectedRevision < 1) {
    return json({ error: "expectedRevision must be a positive integer or null" }, 400);
  }

  const updated = await env.DB.prepare(
    "UPDATE progress_snapshots SET snapshot_json = ?1, revision = revision + 1, updated_at = ?2 WHERE user_id = ?3 AND revision = ?4",
  ).bind(snapshotJson, now, userId, expectedRevision).run();

  if (updated.meta.changes !== 1) {
    return json({ error: "Progress changed on another device; reload before saving", conflict: true }, 409);
  }
  return json({ saved: true, revision: expectedRevision + 1, updatedAt: now });
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    const url = new URL(request.url);
    if (request.method === "GET" && url.pathname === "/") {
      return json({ service: "Viril AI", status: "ok" });
    }

    if (url.pathname === "/api/progress") {
      try {
        return await handleProgress(request, env);
      } catch (error) {
        console.error("Viril progress storage failed", error);
        return json({ error: "Progress storage is temporarily unavailable" }, 500);
      }
    }

    if (request.method !== "POST" || url.pathname !== "/api/chat") {
      return json({ error: "Not found" }, 404);
    }

    let body: { messages?: unknown };
    try {
      body = await request.json() as { messages?: unknown };
    } catch {
      return json({ error: "Invalid JSON body" }, 400);
    }

    if (!Array.isArray(body.messages) || body.messages.length === 0 || body.messages.length > MAX_MESSAGES) {
      return json({ error: `messages must contain between 1 and ${MAX_MESSAGES} items` }, 400);
    }

    if (!body.messages.every(isChatMessage)) {
      return json({ error: "Each message must have a supported role and non-empty content" }, 400);
    }

    try {
      const result = await env.AI.run(MODEL, {
        messages: body.messages as ChatMessage[],
        max_tokens: 900,
        chat_template_kwargs: {
          enable_thinking: false,
        },
      });

      const output = result as ModelResult;
      const choiceContent = output.choices?.[0]?.message?.content;
      const responseText =
        typeof output.response === "string"
          ? output.response
          : typeof choiceContent === "string"
            ? choiceContent
            : "";

      if (responseText.trim().length === 0) {
        console.error("Workers AI returned no text", {
          model: MODEL,
          resultKeys: Object.keys(output),
        });
        return json({ error: "The AI model returned no text. Check the Worker logs for the model response format." }, 502);
      }

      return json({ response: responseText.trim() });
    } catch (error) {
      console.error("Viril AI inference failed", error);
      return json({ error: "AI inference is temporarily unavailable" }, 502);
    }
  },
};
