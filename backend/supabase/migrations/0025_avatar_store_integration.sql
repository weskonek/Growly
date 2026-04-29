-- Migration 0025: Avatar store integration
-- Adds avatar_item_id to child_profiles for store-connected avatar system

ALTER TABLE child_profiles
ADD COLUMN IF NOT EXISTS avatar_item_id UUID REFERENCES store_items(id) ON DELETE SET NULL;

-- Index for fast lookup
CREATE INDEX IF NOT EXISTS idx_child_profiles_avatar_item ON child_profiles(avatar_item_id)
  WHERE avatar_item_id IS NOT NULL;