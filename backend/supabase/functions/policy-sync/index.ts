import { serve } from 'https://deno.land/x/sift@0.4.2/mod.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

serve(async (req) => {
  const { childId } = await req.json();

  if (!childId) {
    return Response.json({ error: 'childId required' }, { status: 400 });
  }

  const supabase = createClient(supabaseUrl, serviceKey);

  const [restrictions, schedules, profile] = await Promise.all([
    supabase
      .from('app_restrictions')
      .select('*')
      .eq('child_id', childId),

    supabase
      .from('schedules')
      .select('*')
      .eq('child_id', childId)
      .eq('is_enabled', true),

    supabase
      .from('child_profiles')
      .select('settings')
      .eq('id', childId)
      .single(),
  ]);

  return Response.json({
    restrictions: restrictions.data ?? [],
    schedules: schedules.data ?? [],
    settings: profile.data?.settings ?? {},
    syncedAt: new Date().toISOString(),
  });
});
