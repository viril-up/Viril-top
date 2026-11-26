interface Env {
  AI: Ai;
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

const MODEL = "@cf/google/gemma-4-26b-a4b-it";
const MAX_MESSAGES = 20;
const MAX_MESSAGE_LENGTH = 8000;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
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

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    const url = new URL(request.url);
    if (request.method === "GET" && url.pathname === "/") {
      return json({ service: "Viril AI", status: "ok" });
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
