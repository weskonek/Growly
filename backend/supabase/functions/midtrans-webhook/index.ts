import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { createHmac } from 'https://deno.land/std@0.168.0/crypto/mod.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Verify Midtrans notification signature
// Midtrans sends POST with JSON body, signed with SHA512(ORDER_ID + STATUS_CODE + GROSS_AMOUNT + SERVER_KEY)
function verifyMidtransSignature(
  orderId: string,
  statusCode: string,
  grossAmount: string,
  signatureKey: string,
  expectedServerKey: string
): boolean {
  const raw = orderId + statusCode + grossAmount + expectedServerKey
  const expectedSig = createHmac('sha512', new TextEncoder().encode(expectedServerKey))
    .update(new TextEncoder().encode(raw))
    .digest('hex')
  return signatureKey === expectedSig
}

interface MidtransNotification {
  order_id: string
  status_code: string
  gross_amount: string
  transaction_status: string
  payment_type: string
  signature_key: string
  transaction_id?: string
  fraud_status?: string
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  const serverKey = Deno.env.get('MIDTRANS_SERVER_KEY')
  if (!serverKey) {
    return new Response(JSON.stringify({ error: 'Server key not configured' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  }

  let body: MidtransNotification
  try {
    body = await req.json()
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid JSON' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  }

  const { order_id, status_code, gross_amount, transaction_status, payment_type, signature_key, transaction_id } = body

  // Verify signature
  const isValid = verifyMidtransSignature(order_id, status_code, gross_amount, signature_key, serverKey)
  if (!isValid) {
    return new Response(JSON.stringify({ error: 'Invalid signature' }),
      { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Map Midtrans transaction_status to our internal state
  // https://snap-docs.midtrans.com/penjelasan-sistem-integrasi-midtrans/transaction-status
  switch (transaction_status) {
    case 'capture':
    case 'settlement': {
      // Payment succeeded — activate subscription
      const { data: pendingOrder } = await supabase
        .from('pending_orders').select('parent_id, tier').eq('order_id', order_id).single()

      if (pendingOrder) {
        // Upsert subscription
        const now = new Date()
        const periodEnd = new Date(now)
        periodEnd.setMonth(periodEnd.getMonth() + 1)

        await supabase.from('subscriptions').upsert({
          parent_id: pendingOrder.parent_id,
          tier: pendingOrder.tier,
          status: 'active',
          current_period_start: now.toISOString(),
          current_period_end: periodEnd.toISOString(),
          external_subscription_id: transaction_id,
        }, {
          onConflict: 'parent_id',
          ignoreDuplicates: false,
        })

        // Mark order complete
        await supabase.from('pending_orders')
          .update({ status: 'completed' })
          .eq('order_id', order_id)

        // Send push notification to parent
        await sendSubscriptionActivePush(supabase, pendingOrder.parent_id)
      }
      break
    }

    case 'deny':
    case 'expire':
    case 'cancel': {
      // Payment failed/cancelled
      await supabase.from('pending_orders')
        .update({ status: 'failed' })
        .eq('order_id', order_id)
      break
    }

    case 'pending': {
      // QRIS / bank transfer — waiting for payment
      await supabase.from('pending_orders')
        .update({ status: 'pending_payment' })
        .eq('order_id', order_id)
      break
    }

    case 'refund': {
      // Handle refund — downgrade to free
      await supabase.from('pending_orders')
        .update({ status: 'refunded' })
        .eq('order_id', order_id)
      break
    }
  }

  // Always return 200 to Midtrans so they don't retry
  return new Response(
    JSON.stringify({ status: 'OK' }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
})

async function sendSubscriptionActivePush(
  supabase: ReturnType<typeof createClient>,
  parentId: string
) {
  // Insert in-app notification
  await supabase.from('notifications').insert({
    parent_id: parentId,
    title: '🎉 Premium Aktif!',
    body: 'Langganan Premium Family Anda sudah aktif. Nikmati semua fitur tanpa batas!',
    type: 'subscription_reminder',
  })

  // Call FCM edge function to push to device
  // Note: This requires FCM_SERVER_KEY to be set; the notifications edge function
  // will gracefully handle the missing key.
  try {
    await fetch(`${Deno.env.get('SUPABASE_URL')}/functions/v1/notifications`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
      },
      body: JSON.stringify({
        parent_id: parentId,
        title: '🎉 Premium Aktif!',
        body: 'Langganan Premium Family Anda sudah aktif.',
        type: 'subscription_reminder',
        notification_id: crypto.randomUUID(),
      }),
    })
  } catch (_) {
    // Non-fatal: push notification will be delivered in-app via notifications page
  }
}