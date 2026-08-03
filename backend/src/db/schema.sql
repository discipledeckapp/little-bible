CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,           -- UUID generated at sign-in
  google_sub TEXT UNIQUE,        -- Google Sign-In subject ID
  email TEXT,                    -- parent email (nullable for offline-only users)
  wants_email INTEGER DEFAULT 0,
  wants_notifications INTEGER DEFAULT 0,
  unlocked INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS child_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  profile_id TEXT NOT NULL,       -- random UUID, never a real child identifier
  story_id TEXT NOT NULL,
  status TEXT NOT NULL,           -- 'in_progress' | 'completed'
  last_scene_index INTEGER DEFAULT 0,
  completed_at TEXT,
  synced_at TEXT DEFAULT (datetime('now')),
  UNIQUE(user_id, profile_id, story_id)
);

CREATE TABLE IF NOT EXISTS verse_familiarity (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  profile_id TEXT NOT NULL,
  verse_ref TEXT NOT NULL,
  stage TEXT NOT NULL DEFAULT 'introduced',
  next_review_date TEXT,
  updated_at TEXT DEFAULT (datetime('now')),
  UNIQUE(user_id, profile_id, verse_ref)
);

CREATE TABLE IF NOT EXISTS unlock_records (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform TEXT NOT NULL,         -- 'ios' | 'android'
  transaction_id TEXT NOT NULL UNIQUE,
  product_id TEXT NOT NULL,
  validated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS content_versions (
  story_id TEXT PRIMARY KEY,
  version INTEGER NOT NULL DEFAULT 1,
  published_at TEXT DEFAULT (datetime('now'))
);
