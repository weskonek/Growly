import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  const { childId } = await req.json();

  if (!childId) {
    return new Response(JSON.stringify({ error: 'childId required' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
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

  return new Response(
    JSON.stringify({
      restrictions: restrictions.data ?? [],
      schedules: schedules.data ?? [],
      settings: profile.data?.settings ?? {},
      syncedAt: new Date().toISOString(),
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
});
