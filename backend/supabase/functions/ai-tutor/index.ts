import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const GEMINI_MODEL = 'gemini-1.5-flash'

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
async function callGemini(apiKey: string, systemPrompt: string, userPrompt: string) {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ role: 'user', parts: [{ text: `${systemPrompt}\n\n${userPrompt}` }] }],
      generationConfig: { temperature: 0.8, maxOutputTokens: 1024 }
    })
  })

  if (!response.ok) {
    throw new Error(`Gemini API error: ${response.status}`)
  }

  const data = await response.json()
  return data.candidates?.[0]?.content?.parts?.[0]?.text || ''
}

// ==================== MAIN HANDLER ====================
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
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

    const { childId, question, mode = 'general' } = await req.json()

    if (!childId || !question) {
      return new Response(JSON.stringify({ error: 'Missing childId or question' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // Safety check
    const safetyFilter = new SafetyFilter()
    if (!safetyFilter.isSafe(question)) {
      return new Response(JSON.stringify({
        content: 'Hmm, itu topik menarik! Tapi Growly lebih suka membantu belajar 📚 Coba tanyakan tentang pelajaran ya!',
        type: 'redirect',
        metadata: { flagged: true }
      }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // Get child profile
    const { data: child, error } = await supabase
      .from('child_profiles')
      .select('name, birth_date, age_group')
      .eq('id', childId)
      .single()

    if (error || !child) {
      return new Response(JSON.stringify({ error: 'Child not found' }), { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    const birthDate = new Date(child.birth_date)
    const age = Math.floor((Date.now() - birthDate.getTime()) / (365.25 * 24 * 60 * 60 * 1000))

    // Build prompts
    const systemPrompt = buildSystemPrompt(age, mode)
    const userPrompt = buildUserPrompt(question, child.name, age)

    // Call Gemini
    const startTime = Date.now()
    const apiKey = Deno.env.get('GEMINI_API_KEY')!
    let aiContent = await callGemini(apiKey, systemPrompt, userPrompt)
    const responseTime = Date.now() - startTime

    // Safety check output
    if (!safetyFilter.isOutputSafe(aiContent)) {
      aiContent = 'Maaf, Growly sedang confused nih. Coba tanyakan dengan cara berbeda ya! 🔄'
    }

    // Log session
    await supabase.from('ai_tutor_sessions').insert({
      child_id: childId,
      mode,
      prompt: question,
      response: aiContent,
      response_time_ms: responseTime,
      flagged: false
    })

    return new Response(JSON.stringify({
      content: aiContent,
      type: mode,
      metadata: { childAge: age, model: GEMINI_MODEL, timestamp: new Date().toISOString() }
    }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })

  } catch (error) {
    console.error('AI Tutor error:', error)
    return new Response(JSON.stringify({ error: 'Internal server error' }), { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  }
})
