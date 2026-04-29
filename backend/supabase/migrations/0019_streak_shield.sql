-- Add streak shield support to reward_systems
ALTER TABLE reward_systems
ADD COLUMN IF NOT EXISTS streak_shields INTEGER NOT NULL DEFAULT 0;

COMMENT ON COLUMN reward_systems.streak_shields IS
  'Streak protection shields (0-3). Earned every 7-day streak milestone. Auto-consumed when child misses a day.';