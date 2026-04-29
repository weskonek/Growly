import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Daily Wrap-Up notification for parents
// Scheduled to run daily at 19:00 WIB (12:00 UTC)
// Creates personalized notifications for each parent about their children's progress

interface ChildStats {
  childId: string
  childName: string
  starsEarned: number
  sessionsCompleted: number
  streak: number
  completedQuests: number
  totalQuests: number
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Get all parents with active children
    const { data: parents } = await supabase
      .from('parent_profiles')
      .select('id, name')

    if (!parents) return new Response('No parents found', { headers: corsHeaders })

    const results = []

    for (const parent of parents) {
      try {
        const stats = await getChildrenStats(supabase, parent.id)
        if (stats.length === 0) continue

        const totalStars = stats.reduce((s, c) => s + c.starsEarned, 0)
        const totalSessions = stats.reduce((s, c) => s + c.sessionsCompleted, 0)
        const maxStreak = Math.max(...stats.map(c => c.streak), 0)
        const totalQuests = stats.reduce((s, c) => s + c.totalQuests, 0)
        const completedQuests = stats.reduce((s, c) => s + c.completedQuests, 0)

        // Build notification body
        const parts: string[] = []
        for (const child of stats) {
          parts.push(`${child.childName}: ⭐${child.starsEarned} bintang, 🔥${child.streak} hari streak`)
        }

        const body = [
          `📊 Ringkasan Growly hari ini untuk ${parent.name}`,
          ``,
          ...parts,
          ``,
          `Total: ⭐${totalStars} bintang, 📚${totalSessions} sesi, 🔥${maxStreak} hari streak terbaik`,
          completedQuests > 0
            ? `✅ ${completedQuests}/${totalQuests} quest harian selesai`
            : `Ayo mulai belajar hari ini! 💪`,
        ].join('\n')

        // Insert notification
        const { error } = await supabase.from('notifications').insert({
          parent_id: parent.id,
          title: '📊 Ringkasan Harian Growly',
          body: body,
          type: 'info',
          is_read: false,
        })

        if (!error) {
          results.push({ parentId: parent.id, success: true })
        } else {
          results.push({ parentId: parent.id, success: false, error: error.message })
        }
      } catch (err) {
        results.push({ parentId: parent.id, success: false, error: String(err) })
      }
    }

    return new Response(JSON.stringify({
      processed: results.length,
      results,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    console.error('daily-wrapup error:', error)
    return new Response(JSON.stringify({ error: 'Internal server error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})

async function getChildrenStats(supabase: ReturnType<typeof createClient>, parentId: string): Promise<ChildStats[]> {
  const today = new Date().toISOString().split('T')[0]
  const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0]

  // Get active children
  const { data: children } = await supabase
    .from('child_profiles')
    .select('id, name')
    .eq('parent_id', parentId)
    .eq('is_active', true)

  if (!children || children.length === 0) return []

  const stats: ChildStats[] = []

  for (const child of children) {
    // Get stars earned today from reward_systems
    const { data: reward } = await supabase
      .from('reward_systems')
      .select('current_streak')
      .eq('child_id', child.id)
      .maybeSingle()

    // Get sessions today
    const { data: sessions } = await supabase
      .from('learning_sessions')
      .select('id')
      .gte('started_at', `${today}T00:00:00`)
      .lte('started_at', `${today}T23:59:59`)
      .eq('child_id', child.id)

    // Get completed quests today
    const { data: quests } = await supabase
      .from('daily_quests')
      .select('is_completed, stars_earned, quest_definitions(stars_reward)')
      .eq('child_id', child.id)
      .eq('quest_date', today)

    const completedQuests = quests?.filter(q => q.is_completed).length ?? 0
    const starsEarned = quests
      ?.filter(q => q.is_completed)
      .reduce((sum: number, q: any) => sum + ((q.stars_earned as number) ?? 0), 0) ?? 0

    stats.push({
      childId: child.id,
      childName: child.name,
      starsEarned,
      sessionsCompleted: (sessions?.length ?? 0),
      streak: reward?.current_streak ?? 0,
      completedQuests,
      totalQuests: quests?.length ?? 0,
    })
  }

  return stats
}