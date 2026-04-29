-- Family Reward Box — parent-defined rewards for children
CREATE TABLE IF NOT EXISTS reward_boxes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES parent_profiles(id) ON DELETE CASCADE,
    child_id UUID REFERENCES child_profiles(id) ON DELETE CASCADE,
    target_stars INTEGER NOT NULL CHECK (target_stars > 0),
    reward_description TEXT NOT NULL,
    expires_at DATE NOT NULL,
    is_claimed BOOLEAN NOT NULL DEFAULT FALSE,
    claimed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE reward_boxes ENABLE ROW LEVEL SECURITY;

-- Parent can manage their own reward boxes
CREATE POLICY "parents manage own reward_boxes"
  ON reward_boxes FOR ALL
  USING (parent_id = auth.uid());

-- Child app can read reward boxes targeting them (for progress display)
CREATE POLICY "children read own reward_boxes"
  ON reward_boxes FOR SELECT
  USING (
    child_id IN (
      SELECT id FROM child_profiles WHERE parent_id = auth.uid()
    )
    OR child_id IS NULL
  );