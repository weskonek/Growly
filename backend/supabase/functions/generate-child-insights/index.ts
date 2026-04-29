import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ==================== TYPES ====================
interface ChildData {
  id: string
  name: string
  birthDate: string
  ageGroup: number
}

interface ScreenTimeDay {
  date: string
  totalMinutes: number
  appBreakdown: Record<string, number>
}

interface InsightResult {
  text: string
  type: 'ai_generated' | 'rule_based'
  cached: boolean
}

// ==================== SAFETY ====================
const BLOCKED_PATTERNS = [
  /violence|pertarungan|pertempuran|membunuh/i,
  /adult|konten dewasa|18\+|seks/i,
  /drug|narkoba|heroin|cocaine|ganja/i,
  /suicide|bunuh diri|melukai diri|self.?harm/i,
]

function isSafe(text: string): boolean {
  for (const pattern of BLOCKED_PATTERNS) {
    if (pattern.test(text)) return false
  }
  return true
}

// ==================== RULE-BASED INSIGHTS (FALLBACK) ====================
function buildRuleBasedInsight(
  childName: string,
  avgDailyMin: number,
  totalLearningSessions: number,
  completedLessons: number,
  appBreakdown: Record<string, number>,
): string {
  const entertainmentKeys = ['youtube', 'game', 'tiktok', 'instagram', 'play']
  const entertainmentMin = Object.entries(appBreakdown)
    .filter(([key]) => entertainmentKeys.some(k => key.includes(k)))
    .reduce((sum, [, v]) => sum + v, 0)

  const parts: string[] = []

  if (avgDailyMin > 240) {
    parts.push(
      `${childName} rata-rata menghabiskan ${(avgDailyMin / 60).toFixed(1)} jam/hari di depan layar — cukup tinggi. ` +
      `Pertimbangkan untuk membatasi waktu bermain agar tetap seimbang.`
    )
  } else if (avgDailyMin > 0 && avgDailyMin <= 120) {
    parts.push(
      `${childName} memiliki waktu layar yang sehat — rata-rata ${(avgDailyMin / 60).toFixed(1)} jam/hari. ` +
      `Bagus untuk tumbuh kembang!`
    )
  }

  if (totalLearningSessions === 0) {
    parts.push(`${childName} belum memiliki sesi belajar tercatat. Dorong untuk mulai belajar hari ini!`)
  } else if (totalLearningSessions > 0) {
    parts.push(`${childName} sudah aktif belajar dengan ${totalLearningSessions} sesi dalam 7 hari terakhir. Semangat!`)
  }

  if (completedLessons > 0) {
    parts.push(`${completedLessons} materi telah diselesaikan. Hebat, ${childName}!`)
  }

  if (avgDailyMin > 0 && entertainmentMin > avgDailyMin * 0.7) {
    parts.push(`Tampak sebagian besar waktu dihabiskan untuk hiburan. Dorong juga kegiatan belajar dan kreativitas.`)
  }

  return parts.length > 0
    ? parts.join(' ')
    : `${childName} belum memiliki data aktivitas yang cukup untuk生成 insight.`
}

// ==================== DATA FETCHING ====================
async function fetchChildData(supabase: ReturnType<typeof createClient>, childId: string): Promise<ChildData | null> {
  const { data, error } = await supabase
    .from('child_profiles')
    .select('id, name, birth_date, age_group')
    .eq('id', childId)
    .eq('is_active', true)
    .single()

  if (error || !data) return null
  return {
    id: data.id,
    name: data.name,
    birthDate: data.birth_date,
    ageGroup: data.age_group,
  }
}

async function fetchScreenTime7Days(
  supabase: ReturnType<typeof createClient>,
  childId: string,
): Promise<ScreenTimeDay[]> {
  const days: ScreenTimeDay[] = []
  const now = new Date()

  for (let i = 0; i < 7; i++) {
    const date = new Date(now)
    date.setDate(date.getDate() - i)
    const dateStr = date.toISOString().split('T')[0]
    const startOfDay = `${dateStr}T00:00:00`
    const endOfDay = `${dateStr}T23:59:59`

    const { data } = await supabase
      .from('screen_time_records')
      .select('duration_minutes, app_package')
      .eq('child_id', childId)
      .gte('date', startOfDay)
      .lte('date', endOfDay)

    const breakdown: Record<string, number> = {}
    let totalMinutes = 0
    for (const row of data ?? []) {
      const pkg = row.app_package ?? 'unknown'
      breakdown[pkg] = (breakdown[pkg] ?? 0) + (row.duration_minutes ?? 0)
      totalMinutes += row.duration_minutes ?? 0
    }

    days.push({ date: dateStr, totalMinutes, appBreakdown: breakdown })
  }

  return days
}

async function fetchLearningData(
  supabase: ReturnType<typeof createClient>,
  childId: string,
): Promise<{ sessions: number; completed: number }> {
  const sevenDaysAgo = new Date()
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

  const { data: sessions } = await supabase
    .from('learning_sessions')
    .select('id')
    .eq('child_id', childId)
    .gte('started_at', sevenDaysAgo.toISOString())

  const { data: progress } = await supabase
    .from('learning_progress')
    .select('completed')
    .eq('child_id', childId)
    .eq('completed', true)
    .gte('updated_at', sevenDaysAgo.toISOString())

  return {
    sessions: (sessions ?? []).length,
    completed: (progress ?? []).length,
  }
}

// ==================== GEMINI CALL ====================
async function generateAiInsight(
  childName: string,
  ageGroup: number,
  screenTimeDays: ScreenTimeDay[],
  learningSessions: number,
  completedLessons: number,
): Promise<string> {
  const apiKey = Deno.env.get('GEMINI_API_KEY')
  if (!apiKey) throw new Error('GEMINI_API_KEY not configured')

  const avgDailyMin = screenTimeDays.length > 0
    ? Math.round(screenTimeDays.reduce((s, d) => s + d.totalMinutes, 0) / screenTimeDays.length)
    : 0

  const topApps = Object.entries(
    screenTimeDays.reduce((acc, day) => {
      for (const [pkg, min] of Object.entries(day.appBreakdown)) {
        acc[pkg] = (acc[pkg] ?? 0) + min
      }
      return acc
    }, {} as Record<string, number>)
  )
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5)

  const ageGroupLabel = ['Batita (2-5)', 'Kanak-kanak awal (6-9)', 'Kanak-kanak akhir (10-12)', 'Remaja (13-18)'][ageGroup] ?? 'Umum'

  const systemPrompt = `Kamu "Growly Insight" — AI analyser untuk pertumbuhan anak Indonesia.

PERSONALITAS: Empati, suportif, bahasa Indonesia, ringkas (2-3 kalimat per poin), berisi ACTION ITEM konkret untuk orang tua.
FORMAT: 2-3 poin utama. Setiap poin 1 kalimat judul (bold) + 1 kalimat penjelasan + 1 action item.
TOOLS: Konteks data digital anak (waktu layar, aplikasi, sesi belajar).

KEAMANAN: Tidak boleh menyingung, membandingkan dengan anak lain, atau mendorong hal negatif.`

  const userPrompt = `Berikut data anak bernama ${childName} (usia: ${ageGroupLabel}) selama 7 hari terakhir:

WAKTU LAYAR:
- Rata-rata harian: ${avgDailyMin} menit (${(avgDailyMin / 60).toFixed(1)} jam)
- Detail per hari:
${screenTimeDays.map(d => `  ${d.date}: ${d.totalMinutes} menit`).join('\n')}
${topApps.length > 0 ? `- Aplikasi paling banyak:\n  ${topApps.map(([pkg, min]) => `${pkg} (${min} menit)`).join(', ')}` : '- Belum ada data aplikasi'}

BELAJAR:
- Sesi belajar: ${learningSessions}
- Materi selesai: ${completedLessons}

Berikan 2-3 insight prioritas untuk orang tua dalam Bahasa Indonesia, dengan action item spesifik.`

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ role: 'user', parts: [{ text: `${systemPrompt}\n\n${userPrompt}` }] }],
      generationConfig: { temperature: 0.7, maxOutputTokens: 512 },
      safetySettings: [
        { category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT', threshold: 'BLOCK_LOW_AND_ABOVE' },
        { category: 'HARM_CATEGORY_HATE_SPEECH', threshold: 'BLOCK_LOW_AND_ABOVE' },
        { category: 'HARM_CATEGORY_HARASSMENT', threshold: 'BLOCK_LOW_AND_ABOVE' },
        { category: 'HARM_CATEGORY_DANGEROUS_CONTENT', threshold: 'BLOCK_LOW_AND_ABOVE' },
      ]
    })
  })

  if (!response.ok) throw new Error(`Gemini API error: ${response.status}`)

  const data = await response.json()
  let text = data.candidates?.[0]?.content?.parts?.[0]?.text || ''

  if (!isSafe(text)) {
    text = buildRuleBasedInsight(childName, avgDailyMin, learningSessions, completedLessons, {})
  }

  return text
}

// ==================== CACHE ====================
async function getCachedInsight(
  supabase: ReturnType<typeof createClient>,
  childId: string,
): Promise<string | null> {
  const today = new Date().toISOString().split('T')[0]

  const { data } = await supabase
    .from('child_insights')
    .select('insight_text')
    .eq('child_id', childId)
    .gte('generated_at', `${today}T00:00:00`)
    .lte('generated_at', `${today}T23:59:59`)
    .maybeSingle()

  return data?.insight_text ?? null
}

async function saveInsight(
  supabase: ReturnType<typeof createClient>,
  childId: string,
  text: string,
  type: 'ai_generated' | 'rule_based',
): Promise<void> {
  await supabase.from('child_insights').insert({
    child_id: childId,
    insight_text: text,
    insight_type: type,
  })
}

// ==================== MAIN ====================
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Verify JWT
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.replace('Bearer ', ''),
    )
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Invalid token' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { childId } = await req.json()
    if (!childId) {
      return new Response(JSON.stringify({ error: 'childId is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Verify child ownership
    const child = await fetchChildData(supabase, childId)
    if (!child || child.id !== childId) {
      // Double-check via RLS
      const { data: ownership } = await supabase
        .from('child_profiles')
        .select('id')
        .eq('id', childId)
        .eq('parent_id', user.id)
        .single()

      if (!ownership) {
        return new Response(JSON.stringify({ error: 'Access denied' }), {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }

    // Check cached insight
    const cached = await getCachedInsight(supabase, childId)
    if (cached) {
      return new Response(JSON.stringify({
        text: cached,
        type: 'ai_generated',
        cached: true,
      } as InsightResult), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Check subscription tier
    const { data: subscription } = await supabase
      .from('subscriptions')
      .select('tier, status')
      .eq('parent_id', user.id)
      .eq('status', 'active')
      .maybeSingle()

    const tier = subscription?.tier as string | undefined
    const isPremium = tier && !['free'].includes(tier)

    // Gather data
    const [screenTimeDays, learningData] = await Promise.all([
      fetchScreenTime7Days(supabase, childId),
      fetchLearningData(supabase, childId),
    ])

    const avgDailyMin = screenTimeDays.length > 0
      ? Math.round(screenTimeDays.reduce((s, d) => s + d.totalMinutes, 0) / screenTimeDays.length)
      : 0

    const allBreakdown = screenTimeDays.reduce((acc, day) => {
      for (const [pkg, min] of Object.entries(day.appBreakdown)) {
        acc[pkg] = (acc[pkg] ?? 0) + min
      }
      return acc
    }, {} as Record<string, number>)

    let insightText: string
    let insightType: 'ai_generated' | 'rule_based' = 'rule_based'

    if (isPremium) {
      try {
        insightText = await generateAiInsight(
          child.name,
          child.ageGroup ?? 1,
          screenTimeDays,
          learningData.sessions,
          learningData.completed,
        )
        insightType = 'ai_generated'
      } catch (err) {
        console.error('Gemini call failed, using rule-based:', err)
        insightText = buildRuleBasedInsight(
          child.name,
          avgDailyMin,
          learningData.sessions,
          learningData.completed,
          allBreakdown,
        )
        insightType = 'rule_based'
      }
    } else {
      insightText = buildRuleBasedInsight(
        child.name,
        avgDailyMin,
        learningData.sessions,
        learningData.completed,
        allBreakdown,
      )
      insightType = 'rule_based'
    }

    // Save to cache (fire and forget)
    saveInsight(supabase, childId, insightText, insightType).catch(err => {
      console.error('Failed to save insight:', err)
    })

    return new Response(JSON.stringify({
      text: insightText,
      type: insightType,
      cached: false,
    } as InsightResult), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    console.error('generate-child-insights error:', error)
    return new Response(JSON.stringify({ error: 'Internal server error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
