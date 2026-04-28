import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const GEMINI_MODEL = 'gemini-1.5-flash'

// ==================== IP-BASED RATE LIMITER ====================
// In-memory store: IP → array of request timestamps (last 60 seconds)
// Resets on every cold start (per-instance), sufficient for MVP anti-abuse
const ipRequestLog = new Map<string, number[]>()
const IP_WINDOW_MS = 60_000      // 1 minute
const IP_MAX_REQUESTS = 10        // max 10 req/min per IP

function checkIpRateLimit(ip: string): boolean {
  const now = Date.now()
  const timestamps = ipRequestLog.get(ip) ?? []
  const recent = timestamps.filter(t => now - t < IP_WINDOW_MS)
  if (recent.length >= IP_MAX_REQUESTS) return false
  recent.push(now)
  ipRequestLog.set(ip, recent)
  // Cleanup old entries periodically
  if (ipRequestLog.size > 1000) {
    for (const [k, v] of ipRequestLog) {
      ipRequestLog.set(k, v.filter(t => now - t < IP_WINDOW_MS))
    }
  }
  return true
}

// ==================== SAFETY FILTER ====================
const BLOCKED_PATTERNS = [
  /violence|pertarungan|pertempuran|membunuh|combat/i,
  /adult|konten dewasa|18\+|seks/i,
  /gambling|judol|kasino|lotre/i,
  /drug|narkoba|heroin|cocaine|weed|ganja/i,
  /suicide|bunuh diri|melukai diri|self.?harm/i,
  /hate|kelompok|rasis|diskriminasi/i,
  /weapon|bom|senjata|pistol|pedang/i,
  /phishing|scam|penipuan/i,
]

const INJECTION_PATTERNS = [
  /ignore previous instructions/i,
  /ignore all previous/i,
  /you are now/i,
  /disregard previous/i,
  /system prompt/i,
]

const FLAG_KEYWORDS = [
  { pattern: /personal info|data diri|alamat rumah|sekolah|umur/i, reason: 'personal_info' },
  { pattern: /violent|kekerasan|blood|darah/i, reason: 'violent_content' },
  { pattern: /inappropriate|tidak pantas/i, reason: 'inappropriate_topic' },
]

class SafetyFilter {
  isSafe(input: string): boolean {
    for (const pattern of BLOCKED_PATTERNS) {
      if (pattern.test(input)) return false
    }
    for (const pattern of INJECTION_PATTERNS) {
      if (pattern.test(input)) return false
    }
    if (input.length > 5000) return false
    return true
  }

  getFlagReason(input: string): string | null {
    for (const { pattern, reason } of FLAG_KEYWORDS) {
      if (pattern.test(input)) return reason
    }
    for (const pattern of BLOCKED_PATTERNS) {
      if (pattern.test(input)) return 'blocked_content'
    }
    for (const pattern of INJECTION_PATTERNS) {
      if (pattern.test(input)) return 'prompt_injection'
    }
    return null
  }

  isOutputSafe(output: string): boolean {
    for (const pattern of BLOCKED_PATTERNS) {
      if (pattern.test(output)) return false
    }
    if (output.length > 10000) return false
    return true
  }
}

// ==================== PROMPT TEMPLATES ====================
function getAgeGroup(age: number): number {
  if (age <= 5) return 0
  if (age <= 9) return 1
  if (age <= 12) return 2
  return 3
}

function buildSystemPrompt(age: number, mode: string): string {
  const ageGroup = getAgeGroup(age)
  let agePrompt = ''

  switch (ageGroup) {
    case 0:
      agePrompt = 'Kalimat sangat pendek (2-4 kata). Pertanyaan ya/tidak. Pujian berlebihan: "LUAR BIASAAAA!"'
      break
    case 1:
      agePrompt = 'Kalimat pendek (5-8 kata). Contoh visual. "Kerja bagus!", "Pintar!"'
      break
    case 2:
      agePrompt = 'Penjelasan detail tapi sederhana. Konteks "mengapa" dan "bagaimana".'
      break
    case 3:
      agePrompt = 'Bahasa formal tapi ramah. Penjelasan mendalam. Partner belajar.'
      break
  }

  let modePrompt = ''
  switch (mode) {
    case 'story':
      modePrompt = 'MODE CERITA: Ceritakan cerita interaktif, akhiri dengan pertanyaan comprehension.'
      break
    case 'math':
      modePrompt = 'MODE MATEMATIKA: Ajarkan KONSEP, BUKAN jawaban. Berikan hint, bukan solusi.'
      break
    case 'homework':
      modePrompt = 'MODE TUGAS: JANGAN langsung jawaban. Ajukan pertanyaan Socratic.'
      break
    default:
      modePrompt = 'MODE UMUM: Ramah, suportif, positif.'
  }

  return `Kamu AI tutor "Growly" 🤖 untuk anak Indonesia.

PERSONALITAS: Ramah, suportif, penuh semangat, banyak emoji, pujian untuk usaha.

${agePrompt}

${modePrompt}

KEAMANAN:
- JANGAN topik dewasa, kekerasan, politik, agama
- JANGAN minta info pribadi
- JANGAN bandingkan dengan anak lain
- Topik tidak pantas → "Growly lebih suka membantu belajar 📚"
`
}

function buildUserPrompt(question: string, childName: string, age: number): string {
  return `${childName} (${age} tahun) bertanya:\n"${question}"\n\nBerikan respons sesuai usia, bahasa Indonesia sederhana, ramah, dengan emoji.`
}

// ==================== GEMINI CLIENT ====================
interface GeminiResponse {
  content: string
  tokensUsed: number
}

async function callGemini(apiKey: string, systemPrompt: string, userPrompt: string): Promise<GeminiResponse> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ role: 'user', parts: [{ text: `${systemPrompt}\n\n${userPrompt}` }] }],
      generationConfig: { temperature: 0.8, maxOutputTokens: 1024 },
      safetySettings: [
        { category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT', threshold: 'BLOCK_LOW_AND_ABOVE' },
        { category: 'HARM_CATEGORY_HATE_SPEECH', threshold: 'BLOCK_LOW_AND_ABOVE' },
        { category: 'HARM_CATEGORY_HARASSMENT', threshold: 'BLOCK_LOW_AND_ABOVE' },
        { category: 'HARM_CATEGORY_DANGEROUS_CONTENT', threshold: 'BLOCK_LOW_AND_ABOVE' },
      ]
    })
  })

  if (!response.ok) {
    throw new Error(`Gemini API error: ${response.status}`)
  }

  const data = await response.json()
  const content = data.candidates?.[0]?.content?.parts?.[0]?.text || ''

  // Use actual token counts from API response if available
  const usage = data.usageMetadata
  const tokensUsed = usage
    ? (usage.promptTokenCount ?? 0) + (usage.candidatesTokenCount ?? 0)
    : Math.ceil((systemPrompt.length + userPrompt.length) / 4) +
      Math.ceil(content.length / 4)

  return { content, tokensUsed }
}

// ==================== MAIN HANDLER ====================
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // IP-based rate limit (10 req/min per IP)
  const clientIp = req.headers.get('x-forwarded-for')?.split(',')[0]?.trim()
    ?? req.headers.get('cf-connecting-ip')
    ?? 'unknown'
  if (!checkIpRateLimit(clientIp)) {
    return new Response(JSON.stringify({
      error: 'Terlalu banyak permintaan, coba lagi dalam 1 menit 🌟'
    }), { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  }

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing authorization' }), { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Verify JWT and extract parent user
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.replace('Bearer ', '')
    )
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    const { childId, question, mode = 'general' } = await req.json()

    if (!childId || !question) {
      return new Response(JSON.stringify({ error: 'Missing childId or question' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // Fetch child ONLY if it belongs to this parent (ownership validation)
    const { data: child, error } = await supabase
      .from('child_profiles')
      .select('name, birth_date, age_group')
      .eq('id', childId)
      .eq('parent_id', user.id)
      .eq('is_active', true)
      .single()

    if (error || !child) {
      return new Response(JSON.stringify({ error: 'Child not found or access denied' }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // Enforce subscription tier — block free tier from AI tutor
    const { data: subscription } = await supabase
      .from('subscriptions')
      .select('tier, status')
      .eq('parent_id', user.id)
      .eq('status', 'active')
      .maybeSingle()

    const tier = subscription?.tier as string | undefined
    if (tier === 'free' || tier === undefined) {
      return new Response(JSON.stringify({
        error: 'AI Tutor hanya untuk paket Premium. Upgrade di menu Pengaturan! 🌟',
        type: 'tier_blocked'
      }), { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // Rate limit: max 20 requests per child per hour
    const oneHourAgo = new Date(Date.now() - 3600000).toISOString()
    const { count } = await supabase
      .from('ai_tutor_sessions')
      .select('id', { count: 'exact', head: true })
      .eq('child_id', childId)
      .gte('created_at', oneHourAgo)

    if ((count ?? 0) >= 20) {
      return new Response(JSON.stringify({
        error: 'Batas pertanyaan tercapai. Istirahat dulu ya, nanti coba lagi! 🌟',
        type: 'rate_limited'
      }), { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    const birthDate = new Date(child.birth_date)
    const age = Math.floor((Date.now() - birthDate.getTime()) / (365.25 * 24 * 60 * 60 * 1000))

    let aiContent: string
    let responseTime: number
    let tokensUsed = 0
    let shouldFlag = isInputUnsafe || flagReason !== null
    let finalFlagReason: string | null = flagReason

    if (isInputUnsafe) {
      // Log unsafe input immediately
      aiContent = 'Hmm, itu topik menarik! Tapi Growly lebih suka membantu belajar 📚 Coba tanyakan tentang pelajaran ya!'
      responseTime = 0

      await supabase.from('ai_tutor_sessions').insert({
        child_id: childId,
        mode,
        prompt: question,
        response: aiContent,
        response_time_ms: responseTime,
        tokens_used: 0,
        flagged: true,
        flag_reason: 'blocked_content'
      })

      return new Response(JSON.stringify({
        content: aiContent,
        type: 'redirect',
        metadata: { flagged: true, reason: 'blocked_content' }
      }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // Build prompts
    const systemPrompt = buildSystemPrompt(age, mode)
    const userPrompt = buildUserPrompt(question, child.name, age)

    // Call Gemini
    const startTime = Date.now()
    const apiKey = Deno.env.get('GEMINI_API_KEY')!

    try {
      const result = await callGemini(apiKey, systemPrompt, userPrompt)
      aiContent = result.content
      tokensUsed = result.tokensUsed
      responseTime = Date.now() - startTime
    } catch (geminiError) {
      console.error('Gemini API error:', geminiError)
      aiContent = 'Maaf, Growly sedang confused nih. Coba lagi sebentar ya! 🔄'
      responseTime = 0
      tokensUsed = 0
      shouldFlag = true
      finalFlagReason = 'api_error'
    }

    // Safety check output
    if (!safetyFilter.isOutputSafe(aiContent)) {
      aiContent = 'Maaf, Growly sedang confused nih. Coba tanyakan dengan cara berbeda ya! 🔄'
      shouldFlag = true
      finalFlagReason = 'unsafe_output'
    }

    // Log session to database
    await supabase.from('ai_tutor_sessions').insert({
      child_id: childId,
      mode,
      prompt: question,
      response: aiContent,
      response_time_ms: responseTime,
      tokens_used: tokensUsed,
      flagged: shouldFlag,
      flag_reason: finalFlagReason
    })

    // Log to audit_logs
    await supabase.from('audit_logs').insert({
      child_id: childId,
      action: 'ai_tutor_session',
      table_name: 'ai_tutor_sessions',
      new_data: {
        mode,
        flagged: shouldFlag,
        flag_reason: finalFlagReason,
        tokens_used: tokensUsed,
        response_time_ms: responseTime
      }
    })

    return new Response(JSON.stringify({
      content: aiContent,
      type: mode,
      metadata: {
        childAge: age,
        model: GEMINI_MODEL,
        tokensUsed,
        responseTime,
        flagged: shouldFlag,
        timestamp: new Date().toISOString()
      }
    }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })

  } catch (error) {
    console.error('AI Tutor error:', error)
    return new Response(JSON.stringify({ error: 'Internal server error' }), { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  }
})
