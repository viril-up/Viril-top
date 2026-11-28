# Cloudflare D1 progress storage

This feature branch adds an authenticated progress snapshot API to the existing `viril-ai` Worker. It is separate from Supabase Auth, profiles, friendships, and direct messages. The existing `POST /api/chat` route and Workers AI binding remain intact.

## Ownership and authentication

- The canonical owner key is the immutable Supabase Auth UUID (`auth.users.id`), not the public display ID.
- Flutter sends its current Supabase access token as a Bearer token to the Worker.
- The Worker validates that token by calling the Supabase Auth `/auth/v1/user` endpoint with the project's anon/publishable API key.
- The Worker derives `user_id` from the validated response. It never accepts a client-supplied owner ID.
- Never put a Supabase service-role key, Cloudflare API token, or D1 credential in Flutter.

## Current D1 schema

- `0001_progress.sql`: normalized progress tables for XP, V-Coin, tasks, activity, journal, gratitude, rewards, purchases, goals, goal steps, achievements, and sync state.
- `0002_progress_snapshots.sql`: versioned JSON snapshot table used by the initial safe migration and multi-device sync API.

The snapshot table preserves the complete local store payload without losing fields that may not yet have a normalized column. The normalized tables remain available for a later structured migration/query phase.

## Worker API

- `GET /api/progress`: requires `Authorization: Bearer <Supabase access token>`; returns `exists: false` when no remote snapshot exists, otherwise the snapshot and its revision.
- `PUT /api/progress`: requires the same authentication and a JSON object `{ "snapshot": { ... }, "expectedRevision": null | number }`.
- `expectedRevision: null` creates the first snapshot only. If one already exists, the Worker returns HTTP 409 rather than overwriting it.
- A positive `expectedRevision` performs a compare-and-swap update. Stale writes return HTTP 409.
- The Worker limits snapshots to 900 KB.
- The client never supplies `user_id`; ownership is derived only from the validated Supabase session.

The Worker requires these runtime variables/secrets:
- `SUPABASE_URL`: project URL, e.g. `https://<project-ref>.supabase.co`.
- `SUPABASE_ANON_KEY`: the project's anon/publishable API key (not the service-role key).

The Worker also requires a D1 binding named `DB` connected to database `viril-progress`. The binding was added in the Cloudflare dashboard, but the exact database ID still needs to be copied into `wrangler.toml` before Git-based deployments can safely manage the Worker configuration.

## App migration rules

- Keep SharedPreferences as the local cache.
- On first authenticated sync, upload local data only if the remote account has no snapshot.
- If the remote snapshot exists, download it; never replace it with an empty local install.
- Use the returned revision for subsequent compare-and-swap updates.
- Keep offline changes local until authenticated sync can be retried.
- Do not enable automatic syncing until the Flutter export/import mapping is implemented and tested.

## Separation of responsibilities

- Supabase: Google sign-in, user profiles/public IDs, friendships and direct messages.
- Cloudflare D1: user progress snapshots and, in a later phase, normalized progress records.
- Cloudflare Workers AI: Gemma inference only through the existing `/api/chat` route.

## Rollout status and safety

1. The user created the `viril-progress` D1 database in the Cloudflare dashboard and applied the initial schema through the D1 Console.
2. The D1 binding `DB` was added to the Worker Production environment; the existing `AI` binding was left untouched.
3. This branch adds the authenticated Worker API and the `0002_progress_snapshots.sql` migration. That second migration still needs to be applied in D1 Console before the API can be deployed and used.
4. Add the exact D1 database ID to `wrangler.toml`, then configure `SUPABASE_URL` and `SUPABASE_ANON_KEY` as Worker runtime values/secrets.
5. Add Flutter synchronization while retaining SharedPreferences as a local cache.
6. Test account isolation, first-login migration, revision conflicts, task edits, XP rewards, V-Coin purchases, goal steps, journal entries, sign-out/sign-in, reinstall recovery and offline retries.
7. Only then enable D1 as the primary source of truth and retain a rollback path.

Do not deploy the code until the D1 snapshot migration and Worker configuration are complete. Do not merge this branch into `main` without the user's explicit approval.
