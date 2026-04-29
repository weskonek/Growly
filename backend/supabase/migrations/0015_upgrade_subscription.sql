-- upgrade_subscription RPC
-- Upserts subscriptions table with new tier and returns updated row
CREATE OR REPLACE FUNCTION public.upgrade_subscription(
  p_tier TEXT,
  p_payment_method TEXT DEFAULT NULL
)
RETURNS TABLE(
  success BOOLEAN,
  message TEXT,
  tier TEXT,
  status TEXT,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ
) AS $$
DECLARE
  v_parent_id UUID;
  v_existing_id UUID;
  v_new_tier TEXT;
  v_new_status TEXT;
BEGIN
  v_parent_id := auth.uid();
  IF v_parent_id IS NULL THEN
    RETURN QUERY SELECT false, 'Tidak terautentikasi.', NULL::TEXT, NULL::TEXT, NULL::TIMESTAMPTZ, NULL::TIMESTAMPTZ;
    RETURN;
  END IF;

  -- Normalize tier name
  v_new_tier := lower(trim(p_tier));
  IF v_new_tier NOT IN ('free', 'premium_family', 'premium_ai_tutor', 'school_institution') THEN
    RETURN QUERY SELECT false, 'Tier tidak valid.', NULL::TEXT, NULL::TEXT, NULL::TIMESTAMPTZ, NULL::TIMESTAMPTZ;
    RETURN;
  END IF;

  -- Check for existing subscription
  SELECT id INTO v_existing_id
  FROM public.subscriptions
  WHERE parent_id = v_parent_id
    AND status IN ('active', 'trialing')
  LIMIT 1;

  v_new_status := CASE v_new_tier
    WHEN 'free' THEN 'active'
    ELSE 'active'
  END;

  IF v_existing_id IS NOT NULL THEN
    -- Update existing
    UPDATE public.subscriptions SET
      tier = v_new_tier,
      status = v_new_status,
      current_period_start = NOW(),
      current_period_end = NOW() + interval '30 days',
      updated_at = NOW()
    WHERE id = v_existing_id;

    RETURN QUERY SELECT
      true,
      'Langganan berhasil diupgrade ke ' || v_new_tier,
      v_new_tier,
      v_new_status,
      NOW(),
      NOW() + interval '30 days';
  ELSE
    -- Insert new
    INSERT INTO public.subscriptions (parent_id, tier, status, current_period_start, current_period_end)
    VALUES (v_parent_id, v_new_tier, v_new_status, NOW(), NOW() + interval '30 days')
    RETURNING
      true,
      'Langganan berhasil diupgrade ke ' || v_new_tier,
      tier,
      status,
      current_period_start,
      current_period_end;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;