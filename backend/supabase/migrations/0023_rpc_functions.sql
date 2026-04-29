-- Migration 0023: RPC Functions + missing columns
-- Adds atomic RPC functions for quest progress, stars, and store purchases
-- Also ensures streak_shields column exists in reward_systems

-- ============================================================
-- 1. reward_systems: add streak_shields if missing
-- ============================================================
ALTER TABLE reward_systems ADD COLUMN IF NOT EXISTS streak_shields INTEGER NOT NULL DEFAULT 0;
ALTER TABLE reward_systems ADD COLUMN IF NOT EXISTS total_sessions INTEGER NOT NULL DEFAULT 0;
ALTER TABLE reward_systems ADD COLUMN IF NOT EXISTS weekly_goal_progress INTEGER NOT NULL DEFAULT 0;

-- ============================================================
-- 2. RPC: add_quest_stars — atomic stars addition with safety
-- ============================================================
CREATE OR REPLACE FUNCTION add_quest_stars(p_child_id UUID, p_stars INTEGER)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  UPDATE reward_systems
  SET total_stars = total_stars + p_stars,
      updated_at = NOW()
  WHERE child_id = p_child_id;
END;
$$;

-- ============================================================
-- 3. RPC: increment_quest_progress — upsert progress tracking
-- ============================================================
CREATE OR REPLACE FUNCTION increment_quest_progress(
  p_child_id UUID,
  p_quest_id TEXT,
  p_value INTEGER
)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO quest_progress (child_id, quest_id, current_value, target_value, updated_at)
  VALUES (p_child_id, p_quest_id, p_value, 1, NOW())
  ON CONFLICT (child_id, quest_id)
  DO UPDATE SET
    current_value = quest_progress.current_value + p_value,
    updated_at = NOW();
END;
$$;

-- ============================================================
-- 4. RPC: purchase_store_item — atomic purchase with stars deduct
-- ============================================================
CREATE OR REPLACE FUNCTION purchase_store_item(
  p_child_id UUID,
  p_item_id UUID
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  item_price INTEGER;
  child_stars INTEGER;
BEGIN
  -- Get item price
  SELECT price_stars INTO item_price
  FROM store_items
  WHERE id = p_item_id AND is_active = true;

  IF item_price IS NULL THEN
    RETURN QUERY SELECT FALSE, 'Item tidak ditemukan atau tidak aktif';
    RETURN;
  END IF;

  -- Get current stars
  SELECT COALESCE(total_stars, 0) INTO child_stars
  FROM reward_systems
  WHERE child_id = p_child_id;

  IF child_stars < item_price THEN
    RETURN QUERY SELECT FALSE, 'Bintang tidak cukup untuk membeli item ini';
    RETURN;
  END IF;

  -- Deduct stars atomically
  UPDATE reward_systems
  SET total_stars = total_stars - item_price,
      updated_at = NOW()
  WHERE child_id = p_child_id;

  -- Record purchase
  INSERT INTO child_store_purchases (child_id, item_id, stars_spent)
  VALUES (p_child_id, p_item_id, item_price)
  ON CONFLICT (child_id, item_id) DO NOTHING;

  RETURN QUERY SELECT TRUE, 'Berhasil membeli item!';
END;
$$;

-- ============================================================
-- 5. RPC: award_badge — insert badge and return notification data
-- ============================================================
CREATE OR REPLACE FUNCTION award_badge(
  p_child_id UUID,
  p_badge_type INTEGER,
  p_title TEXT,
  p_message TEXT
)
RETURNS TABLE(success BOOLEAN, is_new BOOLEAN, notification_body TEXT)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  current_badges UUID[];
  notif_body TEXT;
BEGIN
  -- Get current unlocked badges
  SELECT unlocked_badges INTO current_badges
  FROM reward_systems
  WHERE child_id = p_child_id;

  -- Check if already earned
  IF p_badge_type = ANY(current_badges) THEN
    RETURN QUERY SELECT FALSE, FALSE, NULL::TEXT;
    RETURN;
  END IF;

  -- Add badge to unlocked list
  UPDATE reward_systems
  SET unlocked_badges = array_append(unlocked_badges, p_badge_type::UUID),
      updated_at = NOW()
  WHERE child_id = p_child_id;

  notif_body := p_title || ': ' || p_message;

  RETURN QUERY SELECT TRUE, TRUE, notif_body;
END;
$$;

-- ============================================================
-- 6. RPC: update_streak — update daily streak, award shield at 7-day marks
-- ============================================================
CREATE OR REPLACE FUNCTION update_streak(p_child_id UUID)
RETURNS TABLE(current_streak INTEGER, longest_streak INTEGER, shields_earned INTEGER)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  last_activity DATE;
  today DATE := CURRENT_DATE;
  prev_streak INTEGER;
  prev_longest INTEGER;
  prev_shields INTEGER;
  new_shields INTEGER := 0;
  new_streak INTEGER := 1;
BEGIN
  -- Get current values
  SELECT current_streak, longest_streak, COALESCE(streak_shields, 0)
  INTO prev_streak, prev_longest, prev_shields
  FROM reward_systems
  WHERE child_id = p_child_id;

  -- Get last activity
  SELECT DATE(last_activity_at) INTO last_activity
  FROM reward_systems WHERE child_id = p_child_id;

  IF last_activity IS NULL THEN
    -- First activity ever
    new_streak := 1;
  ELSIF last_activity = today THEN
    -- Already active today, no change
    new_streak := prev_streak;
  ELSIF last_activity = today - 1 THEN
    -- Consecutive day, increment streak
    new_streak := prev_streak + 1;
  ELSE
    -- Streak broken, reset
    new_streak := 1;
  END IF;

  -- Award shield every 7-day streak milestone
  IF new_streak > 0 AND new_streak % 7 = 0 AND prev_streak % 7 != 0 THEN
    new_shields := 1;
  END IF;

  -- Update
  UPDATE reward_systems
  SET current_streak = new_streak,
      longest_streak = GREATEST(prev_longest, new_streak),
      streak_shields = LEAST(COALESCE(streak_shields, 0) + new_shields, 3),
      last_activity_at = NOW(),
      updated_at = NOW()
  WHERE child_id = p_child_id;

  RETURN QUERY SELECT new_streak, GREATEST(prev_longest, new_streak), new_shields;
END;
$$;