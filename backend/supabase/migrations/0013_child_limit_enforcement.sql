-- Server-side child limit enforcement via DB trigger
-- Enforces tier-based child limit (free=2, premium_family/school=99)
-- Free-tier parents cannot add more than their limit — DB rejects it with friendly message

-- ==================== Helper function ====================
CREATE OR REPLACE FUNCTION check_child_limit()
RETURNS TRIGGER AS $$
DECLARE
  current_count INTEGER;
  child_limit INTEGER;
  tier_key TEXT;
BEGIN
  -- Skip for UPDATE of own fields (no id/parent change)
  IF TG_OP = 'UPDATE' AND OLD.id = NEW.id AND OLD.parent_id = NEW.parent_id THEN
    RETURN NEW;
  END IF;

  -- Only enforce on INSERT of new child
  IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.id != NEW.id) THEN
    -- Get active subscription tier for this parent
    SELECT s.tier INTO tier_key
    FROM subscriptions s
    WHERE s.parent_id = NEW.parent_id
      AND s.status IN ('active', 'trialing')
    LIMIT 1;

    -- Unlimited tiers — skip limit check
    IF tier_key IN ('premium_family', 'school_institution') THEN
      RETURN NEW;
    END IF;

    -- Get tier-based limit (fallback to 'free' = 2)
    child_limit := 2;

    -- Count active children for this parent
    SELECT COUNT(*) INTO current_count
    FROM child_profiles
    WHERE parent_id = NEW.parent_id AND is_active = true;

    -- Block if at limit
    IF current_count >= child_limit THEN
      RAISE EXCEPTION 'Batas anak tercapai. Akun Free hanya boleh memiliki % anak. Upgrade langganan untuk menambah lebih banyak.',
        child_limit
      USING ERRCODE = 'P0001';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==================== Trigger ====================
DROP TRIGGER IF EXISTS enforce_child_limit ON child_profiles;
CREATE TRIGGER enforce_child_limit
  BEFORE INSERT OR UPDATE ON child_profiles
  FOR EACH ROW EXECUTE FUNCTION check_child_limit();