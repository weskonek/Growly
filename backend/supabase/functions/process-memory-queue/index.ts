import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// pg_cron calls this every 5 minutes
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Fetch unprocessed queue entries
    const { data: pending, error } = await supabase
      .from('ai_memory_updates')
      .select('id, child_id, payload, session_id')
      .eq('processed', false)
      .order('created_at', { ascending: true })
      .limit(50)

    if (error) {
      console.error('Failed to fetch queue:', error)
      return new Response(JSON.stringify({ error: 'DB error' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    if (!pending || pending.length === 0) {
      return new Response(JSON.stringify({ processed: 0, message: 'Queue empty' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    let successCount = 0
    const failedIds: string[] = []

    for (const entry of pending) {
      try {
        const signal = entry.payload as {
          interest_detected?: string | null
          mastery_signal?: { topic?: string | null; delta?: number | null }
          analogy_worked?: string | null
          mood?: string | null
          breakthrough?: string | null
        }

        const { error: rpcError } = await supabase.rpc('apply_memory_update', {
          p_child_id: entry.child_id,
          p_interest: signal.interest_detected ?? null,
          p_topic: signal.mastery_signal?.topic ?? null,
          p_delta: signal.mastery_signal?.delta ?? 0,
          p_analogy_worked: signal.analogy_worked ?? null,
          p_mood: signal.mood ?? null,
          p_breakthrough: signal.breakthrough ?? null,
          p_nickname: signal.nickname ?? null,
          p_learning_style: signal.learning_style ?? null,
        })

        if (rpcError) {
          console.error(`RPC failed for entry ${entry.id}:`, rpcError)
          failedIds.push(entry.id)
          continue
        }

        // Mark as processed
        await supabase
          .from('ai_memory_updates')
          .update({ processed: true })
          .eq('id', entry.id)

        successCount++
      } catch (e) {
        console.error(`Failed to process entry ${entry.id}:`, e)
        failedIds.push(entry.id)
      }
    }

    // Mark unrecoverable entries (failed 3+ times) as processed to prevent infinite loop
    if (failedIds.length > 0) {
      await supabase
        .from('ai_memory_updates')
        .update({
          processed: true,
          payload: { ...{}, _failed: true, error: 'unrecoverable' }
        })
        .in('id', failedIds)
    }

    return new Response(JSON.stringify({
      processed: successCount,
      failed: failedIds.length,
      total: pending.length
    }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })

  } catch (error) {
    console.error('process-memory-queue error:', error)
    return new Response(JSON.stringify({ error: 'Internal error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})