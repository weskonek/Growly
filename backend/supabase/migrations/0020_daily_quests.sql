-- Daily Quest System
-- Supports per-child daily quests that reset at midnight WIB

-- Quest definitions (master data — seeded once)
CREATE TABLE IF NOT EXISTS quest_definitions (
  quest_id TEXT PRIMARY KEY,
  quest_type TEXT NOT NULL CHECK (quest_type IN ('complete_session', 'answer_questions', 'reach_streak', 'explore_topic')),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  stars_reward INTEGER NOT NULL DEFAULT 2,
  target_value INTEGER NOT NULL DEFAULT 1,
  icon_emoji TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Per-child per-day quest instance
CREATE TABLE IF NOT EXISTS daily_quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
  quest_date DATE NOT NULL DEFAULT CURRENT_DATE,
  quest_id TEXT NOT NULL REFERENCES quest_definitions(quest_id),
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  stars_earned INTEGER NOT NULL DEFAULT 0,
  UNIQUE (child_id, quest_date, quest_id)
);

-- Track quest progress across time
CREATE TABLE IF NOT EXISTS quest_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
  quest_id TEXT NOT NULL REFERENCES quest_definitions(quest_id),
  current_value INTEGER NOT NULL DEFAULT 0,
  target_value INTEGER NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (child_id, quest_id)
);

-- Seed quest definitions
INSERT INTO quest_definitions (quest_id, quest_type, title, description, stars_reward, target_value, icon_emoji)
VALUES
  ('daily_session',    'complete_session',   'Selesaikan 1 Sesi',  'Selesaikan satu sesi belajar hari ini',        2, 1, '📚'),
  ('daily_questions',  'answer_questions',   'Jawab 5 Soal Benar', 'Jawab 5 soal dengan benar hari ini',          3, 5, '✏️'),
  ('daily_streak',    'reach_streak',        'Jaga Streak',         'Belajar hari ini supaya streak tidak putus',   1, 1, '🔥'),
  ('daily_explorer',  'explore_topic',       'Coba Topik Baru',     'Mulai belajar topik yang belum pernah dicoba', 2, 1, '🗺️'),
  ('daily_master',    'complete_session',   'Kuasai Satu Topik',  'Selesaikan semua pelajaran di satu topik',    3, 1, '🎓'),
  ('daily_consistency','reach_streak',       'Tiga Hari Beruntun', 'Belajar 3 hari berturut-turut',                5, 3, '🏆')
ON CONFLICT (quest_id) DO NOTHING;

-- RLS policies
ALTER TABLE daily_quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE quest_progress ENABLE ROW LEVEL SECURITY;

-- Parent can read children's quest data
CREATE POLICY "parents read child daily_quests"
  ON daily_quests FOR SELECT
  USING ( EXISTS (
    SELECT 1 FROM parent_profiles
    WHERE id = (
      SELECT parent_id FROM child_profiles WHERE id = daily_quests.child_id
    )
    AND id = auth.uid()
  ));

-- Child app can read and update own quests
CREATE POLICY "children read own daily_quests"
  ON daily_quests FOR SELECT
  USING (child_id IN (
    SELECT id FROM child_profiles WHERE parent_id = auth.uid()
  ));

CREATE POLICY "children update own daily_quests"
  ON daily_quests FOR UPDATE
  USING (child_id IN (
    SELECT id FROM child_profiles WHERE parent_id = auth.uid()
  ));

CREATE POLICY "children insert own daily_quests"
  ON daily_quests FOR INSERT
  WITH CHECK (child_id IN (
    SELECT id FROM child_profiles WHERE parent_id = auth.uid()
  ));

CREATE POLICY "parents read child quest_progress"
  ON quest_progress FOR SELECT
  USING ( EXISTS (
    SELECT 1 FROM parent_profiles
    WHERE id = (
      SELECT parent_id FROM child_profiles WHERE id = quest_progress.child_id
    )
    AND id = auth.uid()
  ));

CREATE POLICY "children manage own quest_progress"
  ON quest_progress FOR ALL
  USING (child_id IN (
    SELECT id FROM child_profiles WHERE parent_id = auth.uid()
  ));