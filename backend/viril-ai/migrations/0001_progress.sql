-- Viril progress storage in Cloudflare D1.
-- user_id is the immutable Supabase Auth UUID (not the editable public display ID).
-- Every user-owned table is keyed by user_id to enforce tenant scoping in the Worker.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS user_progress (
  user_id TEXT PRIMARY KEY NOT NULL,
  xp INTEGER NOT NULL DEFAULT 0 CHECK (xp >= 0),
  vcoins INTEGER NOT NULL DEFAULT 0 CHECK (vcoins >= 0),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  revision INTEGER NOT NULL DEFAULT 1 CHECK (revision > 0)
);

CREATE TABLE IF NOT EXISTS tasks (
  user_id TEXT NOT NULL,
  id TEXT NOT NULL,
  title TEXT NOT NULL,
  domain TEXT NOT NULL DEFAULT 'Другое',
  created_at TEXT NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0 CHECK (completed IN (0, 1)),
  completed_at TEXT,
  period TEXT NOT NULL DEFAULT 'day',
  xp_reward INTEGER NOT NULL DEFAULT 5 CHECK (xp_reward >= 0),
  is_priority INTEGER NOT NULL DEFAULT 0 CHECK (is_priority IN (0, 1)),
  planned_start_at TEXT,
  planned_end_at TEXT,
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  PRIMARY KEY (user_id, id),
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS tasks_user_created_idx ON tasks(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS tasks_user_period_idx ON tasks(user_id, period, created_at DESC);

CREATE TABLE IF NOT EXISTS daily_activity (
  user_id TEXT NOT NULL,
  day_key TEXT NOT NULL,
  xp INTEGER NOT NULL DEFAULT 0 CHECK (xp >= 0),
  active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
  PRIMARY KEY (user_id, day_key),
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS journal_entries (
  user_id TEXT NOT NULL,
  id TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (user_id, id),
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS journal_user_created_idx ON journal_entries(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS gratitude_entries (
  user_id TEXT NOT NULL,
  id TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (user_id, id),
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS gratitude_user_created_idx ON gratitude_entries(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS habit_rewards (
  user_id TEXT NOT NULL,
  reward_key TEXT NOT NULL,
  PRIMARY KEY (user_id, reward_key),
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS coin_rewarded_tasks (
  user_id TEXT NOT NULL,
  task_id TEXT NOT NULL,
  PRIMARY KEY (user_id, task_id),
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS store_purchases (
  user_id TEXT NOT NULL,
  item_id TEXT NOT NULL,
  purchased_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  PRIMARY KEY (user_id, item_id),
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS goals (
  user_id TEXT NOT NULL,
  id TEXT NOT NULL,
  title TEXT NOT NULL,
  duration_days INTEGER NOT NULL CHECK (duration_days >= 0),
  started_at TEXT NOT NULL,
  is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0, 1)),
  completed_at TEXT,
  planned_start_at TEXT,
  planned_end_at TEXT,
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  PRIMARY KEY (user_id, id),
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS goals_user_updated_idx ON goals(user_id, updated_at DESC);

CREATE TABLE IF NOT EXISTS goal_steps (
  user_id TEXT NOT NULL,
  goal_id TEXT NOT NULL,
  id TEXT NOT NULL,
  title TEXT NOT NULL,
  is_done INTEGER NOT NULL DEFAULT 0 CHECK (is_done IN (0, 1)),
  PRIMARY KEY (user_id, goal_id, id),
  FOREIGN KEY (user_id, goal_id) REFERENCES goals(user_id, id) ON DELETE CASCADE
);

-- Server-side sync marker. The client never chooses the owner; Worker derives it
-- from a validated Supabase access token.
CREATE TABLE IF NOT EXISTS progress_sync_state (
  user_id TEXT PRIMARY KEY NOT NULL,
  schema_version INTEGER NOT NULL DEFAULT 1,
  last_synced_at TEXT,
  FOREIGN KEY (user_id) REFERENCES user_progress(user_id) ON DELETE CASCADE
);
