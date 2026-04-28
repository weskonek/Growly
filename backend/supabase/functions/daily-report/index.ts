import { serve } from 'https://deno.land/x/sift@0.4.2/mod.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

serve(async (req) => {
  const supabase = createClient(supabaseUrl, serviceKey);

  // Run daily at 07:00 WIT = 00:00 UTC
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  const dateStr = yesterday.toISOString().split('T')[0];

  // Get all active children
  const { data: children } = await supabase
    .from('child_profiles')
    .select('id, name, parent_id')
    .eq('is_active', true);

  const reports = [];

  for (const child of children ?? []) {
    // Sum learning minutes
    const { data: sessions } = await supabase
      .from('learning_sessions')
      .select('duration_minutes')
      .eq('child_id', child.id)
      .gte('created_at', `${dateStr}T00:00:00`)
      .lte('created_at', `${dateStr}T23:59:59`);

    const learningMinutes = (sessions ?? []).reduce(
      (sum, s) => sum + (s.duration_minutes ?? 0),
      0,
    );

    // Sum screen time
    const { data: records } = await supabase
      .from('screen_time_records')
      .select('total_minutes')
      .eq('child_id', child.id)
      .gte('recorded_at', `${dateStr}T00:00:00`)
      .lte('recorded_at', `${dateStr}T23:59:59`);

    const screenTimeMinutes = (records ?? []).reduce(
      (sum, r) => sum + (r.total_minutes ?? 0),
      0,
    );

    const sessionsCount = (sessions ?? []).length;

    // Get streak
    const { data: reward } = await supabase
      .from('reward_systems')
      .select('current_streak')
      .eq('child_id', child.id)
      .single();

    const streakDays = reward?.current_streak ?? 0;

    // Generate simple AI insight
    let insight = '';
    if (learningMinutes > 60) {
      insight = `${child.name} sudah belajar ${learningMinutes} menit kemarin. Hebat! 🌟`;
    } else if (screenTimeMinutes > 180) {
      insight = `${child.name} sudah cukup lama di depan layar. Ayo dorong belajar lebih banyak! 📚`;
    } else if (sessionsCount === 0) {
      insight = `${child.name} belum belajar kemarin. Ayo mulai hari ini! 💪`;
    } else {
      insight = `${child.name} sudah ${sessionsCount} sesi belajar kemarin. Semangat! 🎉`;
    }

    reports.push({
      parent_id: child.parent_id,
      child_id: child.id,
      date: dateStr,
      learning_minutes: learningMinutes,
      screen_time_minutes: screenTimeMinutes,
      sessions_count: sessionsCount,
      streak_days: streakDays,
      ai_insight: insight,
    });
  }

  const { error } = await supabase.from('daily_reports').insert(reports);

  if (error) {
    console.error('Failed to insert daily reports:', error);
  }

  return Response.json({ success: !error, reportsCreated: reports.length });
});
