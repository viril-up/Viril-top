# Viril AI — Assistant Foundation

## Product direction

Viril AI is the in-app self-development assistant. It should:
- Explain Viril's screens, features, terminology, and workflows.
- Help users plan physical, mental, intellectual, and spiritual development.
- Create practical daily plans and suggest goals.
- Read the user's relevant Viril context when authorized.
- Execute supported app actions only through explicit, validated tools.
- Support text first, then voice input and spoken responses.

## Response style

Do not enforce a fixed 300-character limit. Prefer concise, structured, useful answers:
- Lead with the answer or next action.
- Use short paragraphs and compact lists.
- Avoid filler, repeated disclaimers, and unnecessary introductions.
- Expand when the user asks for detail or when safety/accuracy requires it.
- For plans, use clear actions with realistic scope and useful ordering.

## Architecture boundaries

- Cloudflare Worker / Workers AI: model inference, assistant instructions, intent/tool orchestration.
- Flutter app: chat UI, voice capture/playback, confirmation UI, and rendering structured assistant actions.
- Supabase: authentication, profiles, friendships, direct messages, and user data that is actually stored there.
- Never let model output directly execute arbitrary SQL, arbitrary network requests, or arbitrary app code.
- Every write action must be validated by the app/backend and require user confirmation before changing user data.
- The model must never claim an action succeeded until the application confirms success.

## Initial supported assistant capabilities

1. Explain app features using a maintained Viril product knowledge base.
2. Draft daily/weekly plans without changing user data.
3. Propose goal/task entries in a structured preview.
4. After user confirmation, call a narrow, typed action to add the proposed entries.
5. Read progress only through an authorized, read-only context/action.
6. Explain when a feature is unavailable rather than inventing its behavior.

## Tool/action contract

Future tools should be narrow and typed, for example:
- `get_today_tasks()`
- `get_progress_summary(period)`
- `propose_daily_plan(preferences)` (draft only)
- `add_daily_tasks(tasks)` (write; confirmation required)
- `add_goal(title, duration_days, steps)` (write; confirmation required)

All arguments must be schema-validated. User identity must come from the authenticated session, never from model-supplied user IDs. Enforce ownership and authorization on the server. Add idempotency protection to write operations.

## Voice rollout

Start with push-to-talk:
1. Flutter speech-to-text captures the user's utterance.
2. The transcript is sent through the same assistant API.
3. The assistant response is displayed.
4. Text-to-speech reads the response when enabled.
5. Destructive or account-affecting actions always require visible confirmation.

Do not implement always-on microphone listening in the first version.

## Repository audit findings — 2026-11-28

- The Flutter AI screen is `lib/features/ai/viril_ai_screen.dart`.
- It currently sends a `messages` array to `POST /api/chat` and expects `response`, `text`, or `output_text`.
- The current AI screen's microphone buttons only display an informational dialog; voice input/output is not implemented there yet.
- Daily tasks in `lib/core/data/viril_store.dart` are currently persisted with `SharedPreferences`.
- Long-term goals in `lib/features/goals/data/goal_store.dart` are currently persisted with `SharedPreferences`.
- Therefore, do not claim that goal/task writes are already backed by Supabase. Before implementing cross-device AI actions, reconcile the actual persistence architecture with the intended Supabase responsibility and preserve existing local user data.
- The deployed Cloudflare Worker source/configuration has not yet been located in this repository audit. Worker-side system instructions and tool routing must be implemented in the actual Worker source, not trusted to client-supplied prompts.

## Rollout and acceptance criteria

Phase 1: Product knowledge + concise assistant behavior.
- The assistant knows the current Viril product map and can explain features accurately.
- It is concise by default, with no hard character cap.
- It does not claim to execute actions.

Phase 2: Read-only context.
- It can retrieve only the signed-in user's permitted tasks/progress.
- It cannot access another user's private information.

Phase 3: Confirmed writes.
- It can propose a daily plan and show a preview.
- No task/goal is written until the user confirms.
- The UI displays the actual backend result and handles failures.

Phase 4: Voice.
- Push-to-talk speech input and optional spoken responses.
- Same authorization and confirmation rules as text.

Each phase must be tested in a Vercel Preview before merging to `main`.
