-- Durable, versioned progress snapshot used for safe first-login migration
-- and multi-device synchronization. Ownership is always derived from Supabase Auth
-- inside the Worker; the client never supplies user_id.

CREATE TABLE IF NOT EXISTS progress_snapshots (
  user_id TEXT PRIMARY KEY NOT NULL,
  snapshot_json TEXT NOT NULL CHECK (json_valid(snapshot_json)),
  revision INTEGER NOT NULL DEFAULT 1 CHECK (revision > 0),
  updated_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS progress_snapshots_updated_idx
  ON progress_snapshots(updated_at DESC);
