-- child_insights: cached AI-generated insights per child per day
CREATE TABLE IF NOT EXISTS child_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
  insight_text TEXT NOT NULL,
  insight_type TEXT DEFAULT 'ai_generated', -- 'ai_generated' | 'rule_based'
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (child_id, generated_at)
);

COMMENT ON TABLE child_insights IS 'Daily AI-generated insights for each child';

ALTER TABLE child_insights ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Parents can read own child insights"
  ON child_insights FOR SELECT
  USING (
    child_id IN (
      SELECT id FROM child_profiles WHERE parent_id = auth.uid()
    )
  );

CREATE POLICY "Service role can insert insights"
  ON child_insights FOR INSERT
  WITH CHECK (true);
