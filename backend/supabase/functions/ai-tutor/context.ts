import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'

export interface ChildMemory {
  nickname: string | null
  learning_style: string | null
  interests: string[]
  topic_mastery: Record<string, number>
  breakthroughs: Array<{ text: string; topic: string; date: string }>
  last_mood: string | null
  last_analogy_worked: string | null
}

export interface RecentSession {
  mode: string
  prompt: string
  created_at: string
}

export interface TodayScreenTime {
  total_minutes: number
  apps_opened: string[]
}

export interface EnrichedContext {
  memory: ChildMemory | null
  recentSessions: RecentSession[]
  todayScreenTime: TodayScreenTime | null
}

export async function loadChildContext(
  supabase: SupabaseClient,
  childId: string
): Promise<EnrichedContext> {
  const today = new Date().toISOString().split('T')[0]

  const [memoryResult, sessionsResult, screenTimeResult] = await Promise.all([
    // Layer 1: Persistent memory
    supabase
      .from('child_ai_memory')
      .select('nickname, learning_style, interests, topic_mastery, breakthroughs, last_mood, last_analogy_worked')
      .eq('child_id', childId)
      .maybeSingle(),

    // Layer 2: 5 sesi terakhir
    supabase
      .from('ai_tutor_sessions')
      .select('mode, prompt, created_at')
      .eq('child_id', childId)
      .eq('flagged', false)
      .order('created_at', { ascending: false })
      .limit(5),

    // Layer 3: Screen time hari ini
    supabase
      .from('screen_time_logs')
      .select('duration_minutes, app_package')
      .eq('child_id', childId)
      .eq('date', today),
  ])

  // Aggregate screen time
  let todayScreenTime: TodayScreenTime | null = null
  if (screenTimeResult.data && screenTimeResult.data.length > 0) {
    const rows = screenTimeResult.data as Array<{ duration_minutes: number; app_package: string }>
    const totalMin = rows.reduce((sum, r) => sum + (r.duration_minutes ?? 0), 0)
    const apps = [...new Set(rows.map(r => r.app_package).filter(Boolean))] as string[]
    todayScreenTime = { total_minutes: totalMin, apps_opened: apps }
  }

  return {
    memory: memoryResult.data ?? null,
    recentSessions: sessionsResult.data ?? [],
    todayScreenTime,
  }
}
