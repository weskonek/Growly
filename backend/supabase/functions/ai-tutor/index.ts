import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from 'https://esm.sh/@supabase/supabase-js@2'
import { GeminiClient } from './gemini.ts'
import { buildSystemPrompt, buildUserPrompt, validateContentSafety } from './prompts.ts'
import { SafetyFilter } from './safety.ts'

const GEMINI_MODEL = 'gemini-1.5-flash'

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Authorization check
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create Supabase client with service role (for logging)
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Parse request body
    const { childId, question, mode = 'general', sessionId } = await req.json()

    if (!childId || !question) {
      return new Response(
        JSON.stringify({ error: 'Missing childId or question' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate input content safety
    const safetyFilter = new SafetyFilter()
    if (!safetyFilter.isSafe(question)) {
      // Log flagged interaction
      await logAiSession(supabase, childId, question, '', mode, true, 'Unsafe input detected')
      return new Response(
        JSON.stringify({
          content: 'Hmm, itu topik yang menarik! Tapi Growly lebih suka menjawab pertanyaan tentang belajar. Coba tanyakan sesuatu tentang pelajaran ya! 📚',
          type: 'redirect',
          metadata: { flagged: true }
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get child profile
    const { data: child, error: childError } = await supabase
      .from('child_profiles')
      .select('id, name, birth_date, age_group, settings')
      .eq('id', childId)
      .single()

    if (childError || !child) {
      return new Response(
        JSON.stringify({ error: 'Child profile not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Calculate age from birth_date
    const birthDate = new Date(child.birth_date)
    const age = Math.floor((Date.now() - birthDate.getTime()) / (365.25 * 24 * 60 * 60 * 1000))

    // Build prompts
    const systemPrompt = buildSystemPrompt(age, mode)
    const userPrompt = buildUserPrompt(question, child.name, age)

    // Call Gemini API
    const gemini = new GeminiClient(Deno.env.get('GEMINI_API_KEY')!)
    const startTime = Date.now()

    const response = await gemini.generateContent({
      contents: [{
        role: 'user',
        parts: [{ text: `${systemPrompt}\n\n${userPrompt}` }]
      }],
      generationConfig: {
        temperature: 0.8,
        maxOutputTokens: 1024,
      }
    })

    const responseTime = Date.now() - startTime
    const aiContent = response.candidates?.[0]?.content?.parts?.[0]?.text || ''
    const usage = response.usageMetadata || {}

    // Validate output content safety
    if (!safetyFilter.isOutputSafe(aiContent)) {
      await logAiSession(supabase, childId, question, aiContent, mode, true, 'Unsafe output detected')
      return new Response(
        JSON.stringify({
          content: 'Maaf, Growly sedang confused nih. Coba tanyakan dengan cara berbeda ya! 🔄',
          type: 'error',
          metadata: { flagged: true }
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Log successful interaction
    await logAiSession(
      supabase,
      childId,
      question,
      aiContent,
      mode,
      false,
      null,
      responseTime,
      usage.totalTokenCount || 0,
      sessionId
    )

    // Return response
    return new Response(
      JSON.stringify({
        content: aiContent,
        type: mode,
        metadata: {
          childAge: age,
          childAgeGroup: child.age_group,
          model: GEMINI_MODEL,
          responseTimeMs: responseTime,
          tokensUsed: usage.totalTokenCount || 0,
          timestamp: new Date().toISOString()
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('AI Tutor error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', message: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

async function logAiSession(
  supabase: any,
  childId: string,
  prompt: string,
  response: string,
  mode: string,
  flagged: boolean,
  flagReason: string | null,
  responseTimeMs?: number,
  tokensUsed?: number,
  sessionId?: string
) {
  try {
    // Create session if no sessionId provided
    let actualSessionId = sessionId

    if (!actualSessionId) {
      const { data: newSession } = await supabase
        .from('ai_tutor_sessions')
        .insert({
          child_id: childId,
          mode,
          prompt,
          response,
          response_time_ms: responseTimeMs,
          tokens_used: tokensUsed,
          flagged,
          flag_reason: flagReason
        })
        .select('id')
        .single()

      actualSessionId = newSession?.id
    } else {
      // Insert message to existing session
      await supabase
        .from('ai_tutor_messages')
        .insert({
          session_id: sessionId,
          role: 'user',
          content: prompt
        })

      await supabase
        .from('ai_tutor_messages')
        .insert({
          session_id: sessionId,
          role: 'assistant',
          content: response
        })
    }
  } catch (error) {
    console.error('Failed to log AI session:', error)
  }
}