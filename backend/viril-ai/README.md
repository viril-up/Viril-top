# Viril AI Worker

Cloudflare Worker backend for the Viril AI chat.

## Current model

The Worker is configured for `@cf/google/gemma-4-26b-a4b-it` (Gemma 4, 26B total / 4B active parameters).

The older `@cf/google/gemma-2b-it-lora` model was retired by Cloudflare on 20 November 2026, so this project does not use that obsolete model ID.

## Deploy

1. In Cloudflare, create a Worker named `viril-ai`.
2. Connect this folder as the Worker source (or deploy it with Wrangler from this directory).
3. Ensure the Workers AI binding is enabled with the binding name `AI`.
4. Deploy the Worker.
5. Set the Flutter build define `VIRIL_AI_API_URL` to the deployed Worker origin, for example:
   `--dart-define=VIRIL_AI_API_URL=https://viril-ai.<your-subdomain>.workers.dev`

## API

- `GET /` — health check.
- `POST /api/chat` — accepts `{ "messages": [{ "role": "user", "content": "..." }] }` and returns `{ "response": "..." }`.

## Voice

The current Worker provides text chat only. Speech-to-text and text-to-speech need separate model/service integration and should be added after the text endpoint is deployed and tested. The Flutter UI currently labels the voice feature as not yet connected.
