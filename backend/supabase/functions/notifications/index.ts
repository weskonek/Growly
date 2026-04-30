import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Firebase Cloud Messaging REST API endpoint
const FCM_API_URL = 'https://fcm.googleapis.com/fcm/send'

interface SendPushRequest {
  notification_id: string
  parent_id: string
  child_id?: string
  title: string
  body: string
  type: string  // 'achievement' | 'screen_time_alert' | 'subscription_reminder' | 'daily_report' | 'general'
}

interface FCMResponse {
  success_count: number
  failure_count: number
  results: Array<{ error?: string; message_id?: string }>
}

async function sendFcmPush(
  fcmToken: string,
  title: string,
  body: string,
  data: Record<string, string>,
  serverKey: string
): Promise<{ success: boolean; message_id?: string; error?: string }> {
  try {
    const resp = await fetch(FCM_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${serverKey}`,
      },
      body: JSON.stringify({
        to: fcmToken,
        notification: { title, body, sound: 'default' },
        data,
        android: {
          priority: 'high',
          notification: {
            channel_id: 'growly_alerts',
            default_vibrate_timings: true,
            default_sound: true,
          },
        },
        apns: {
          payload: {
            aps: { sound: 'default', badge: 1 },
          },
        },
      }),
    })

    if (!resp.ok) {
      const errText = await resp.text()
      return { success: false, error: `FCM HTTP ${resp.status}: ${errText}` }
    }

    const json = await resp.json() as FCMResponse
    const result = json.results?.[0]

    if (result?.error) {
      return { success: false, error: result.error }
    }

    return { success: true, message_id: result?.message_id }
  } catch (e) {
    return { success: false, error: String(e) }
  }
}

async function logNotificationSent(
  supabase: ReturnType<typeof createClient>,
  parentId: string,
  notificationId: string,
  status: 'sent' | 'failed' | 'invalid_token',
  errorMessage?: string
) {
  await supabase.from('notification_log').insert({
    parent_id: parentId,
    notification_id: notificationId,
    fcm_status: status,
    error_message: errorMessage,
  })
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  // Auth guard — only allow calls from trusted internal services
  const authHeader = req.headers.get('Authorization');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!authHeader || authHeader !== `Bearer ${serviceKey}`) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }),
      { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  }

  const serverKey = Deno.env.get('FCM_SERVER_KEY');
  if (!serverKey) {
    return new Response(
      JSON.stringify({ error: 'FCM_SERVER_KEY not configured' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  let body: SendPushRequest
  try {
    body = await req.json()
  } catch {
    return new Response(
      JSON.stringify({ error: 'Invalid JSON body' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const { notification_id, parent_id, child_id, title, body: notifBody, type } = body

  if (!parent_id || !notification_id || !title) {
    return new Response(
      JSON.stringify({ error: 'Missing required fields: parent_id, notification_id, title' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  // Create service-role client to bypass RLS
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // 1. Look up parent's FCM token
  const { data: profile, error: profileError } = await supabase
    .from('parent_profiles')
    .select('id, fcm_token, name')
    .eq('id', parent_id)
    .single()

  if (profileError || !profile?.fcm_token) {
    // No token — mark notification as failed silently (not an error)
    await logNotificationSent(supabase, parent_id, notification_id, 'invalid_token', 'No FCM token')
    return new Response(
      JSON.stringify({ sent: false, reason: 'no_fcm_token' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  // 2. Build data payload for deep linking
  const dataPayload: Record<string, string> = {
    notification_id,
    type,
    ...(child_id ? { child_id } : {}),
  }

  // Set deep-link path based on notification type
  switch (type) {
    case 'achievement':
      dataPayload['deep_link'] = child_id ? `/children/detail/${child_id}` : '/dashboard'
      break
    case 'screen_time_alert':
      dataPayload['deep_link'] = child_id ? `/children/detail/${child_id}` : '/parental-control'
      break
    case 'subscription_reminder':
      dataPayload['deep_link'] = '/settings/subscription'
      break
    case 'daily_report':
      dataPayload['deep_link'] = child_id ? `/children/detail/${child_id}` : '/dashboard'
      break
    default:
      dataPayload['deep_link'] = '/dashboard'
  }

  // 3. Send FCM push
  const result = await sendFcmPush(
    profile.fcm_token,
    title,
    notifBody,
    dataPayload,
    serverKey
  )

  // 4. Log result
  await logNotificationSent(
    supabase,
    parent_id,
    notification_id,
    result.success ? 'sent' : 'failed',
    result.error
  )

  return new Response(
    JSON.stringify({
      sent: result.success,
      message_id: result.message_id,
      error: result.error,
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
})