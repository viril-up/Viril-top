# Cloudflare D1 progress storage

This directory contains the first D1 schema for Viril's user-owned progress. It is intentionally separate from Supabase Auth, profiles, friendships, and direct messages.

## Ownership and authentication

- The canonical owner key is the Supabase Auth UUID (`auth.users.id`), not the public display ID.
- Flutter sends its current Supabase access token to the existing `viril-ai` Worker.
- The Worker validates that token against the configured Supabase Auth user endpoint before every progress operation.
- The Worker derives `user_id` from the validated user response. It must never accept a client-supplied owner ID.
- Do not expose D1 credentials, Supabase service-role keys, or Cloudflare API tokens in Flutter.

## Data covered by schema v1

- XP and V-Coin balances
- Daily and long-term tasks, completion and planned times
- Daily XP and active-day history
- Journal and gratitude entries
- Habit rewards and one-time task coin rewards
- Shop purchases
- Long-term goals and their steps
- Sync metadata

Profile identity, Google sign-in, friends and DMs remain in Supabase. Large media files do not belong in D1.

## Rollout safety

1. Create a separate D1 staging database and apply `migrations/0001_progress.sql`.
2. Add a D1 binding to the existing Worker without changing `/api/chat`.
3. Add authenticated progress endpoints and test that two different Supabase users cannot read or overwrite each other's rows.
4. Add Flutter synchronization while retaining SharedPreferences as a local cache.
5. On first authenticated sync, upload local data only if the remote account has no snapshot; otherwise download the remote snapshot. Never blindly overwrite remote progress with an empty local install.
6. Verify task edits, XP rewards, V-Coin purchases, goal steps, journal entries, sign-out/sign-in, reinstall recovery, offline retries and duplicate request handling.
7. Only then enable D1 as the primary source of truth and retain a rollback path.

Do not deploy the migration against a production database until a backup/export exists and the staging tests pass.

## Current repository findings

The current app stores task/XP/V-Coin/activity/journal/gratitude state in `VirilStore` and long-term goals in `GoalStore`, both using SharedPreferences. The existing Worker source is `src/index.ts` and currently handles `POST /api/chat` only. No D1 binding is currently configured in `wrangler.toml`.

The Cloudflare account connection available to this session currently lacks the D1 read/write and Workers script read/edit scopes. Therefore this schema is committed to a feature branch only; no Cloudflare database has been created or changed by this step.
