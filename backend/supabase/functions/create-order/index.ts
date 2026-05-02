import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface CreateOrderRequest {
  parent_id: string
  tier: 'premium_family' | 'premium_ai_tutor'
  payment_method: 'bank_transfer' | 'qris' | 'ewallet'
}

interface MidtransSnapResponse {
  token: string
  redirect_url: string
}

// Maps our payment_method to Midtrans gross_amount plan
const TIER_PRICES: Record<string, number> = {
  premium_family: 99000,
  premium_ai_tutor: 49000,
}

// Maps to Midtrans payment type
const PAYMENT_TYPE_MAP: Record<string, string> = {
  bank_transfer: 'bank_transfer',
  qris: 'qris',
  ewallet: 'gopay',
}

async function createMidtransSnapToken(
  orderId: string,
  amount: number,
  paymentType: string,
  customerEmail: string,
  itemName: string
): Promise<{ token: string; redirect_url: string }> {
  const serverKey = Deno.env.get('MIDTRANS_SERVER_KEY')
  if (!serverKey) throw new Error('MIDTRANS_SERVER_KEY not set')

  // Auth header for Midtrans API
  const authHeader = 'Basic ' + btoa(`${serverKey}:`)

  const body = {
    transaction_details: {
      order_id: orderId,
      gross_amount: amount,
    },
    payment_type: paymentType,
    customer_details: {
      email: customerEmail || 'parent@growly.app',
    },
    item_details: [{
      id: `tier-${paymentType}`,
      price: amount,
      quantity: 1,
      name: itemName,
    }],
    credit_card: {
      secure: true,
    },
  }

  const resp = await fetch('https://app.midtrans.com/v2/charge', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': authHeader,
    },
    body: JSON.stringify(body),
  })

  if (!resp.ok) {
    const err = await resp.text()
    throw new Error(`Midtrans error ${resp.status}: ${err}`)
  }

  const json = await resp.json() as { status_code: string; status_message: string; redirect_url?: string; token?: string }

  if (json.status_code !== '201' && json.status_code !== '200') {
    throw new Error(json.status_message || 'Midtrans charge failed')
  }

  return {
    token: json.token || '',
    redirect_url: json.redirect_url || '',
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  let body: CreateOrderRequest
  try {
    body = await req.json()
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid JSON' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  }

  const { parent_id, tier, payment_method } = body
  if (!parent_id || !tier || !payment_method) {
    return new Response(JSON.stringify({ error: 'Missing required fields' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // 1. Get parent email for Midtrans
  const { data: profile } = await supabase
    .from('parent_profiles').select('email, name').eq('id', parent_id).single()

  // 2. Generate order ID
  const orderId = `growly-${parent_id.slice(0, 8)}-${Date.now()}`
  const amount = TIER_PRICES[tier] ?? 99000
  const paymentType = PAYMENT_TYPE_MAP[payment_method] ?? 'bank_transfer'
  const itemName = tier === 'premium_family' ? 'Premium Family — 1 Bulan' : 'Premium AI Tutor — 1 Bulan'

  let snapToken: string
  let snapRedirectUrl: string

  try {
    const snap = await createMidtransSnapToken(orderId, amount, paymentType, profile?.email, itemName)
    snapToken = snap.token
    snapRedirectUrl = snap.redirect_url
  } catch (e) {
    // If Midtrans is not configured (e.g., sandbox), return a mock for dev
    if (Deno.env.get('MIDTRANS_SERVER_KEY') === 'SB-Mid-server-dev' || !Deno.env.get('MIDTRANS_SERVER_KEY')) {
      snapToken = `mock-snap-token-${orderId}`
      snapRedirectUrl = `https://app.sandbox.midtrans.com/v2/token/mock-snap?order=${orderId}`
    } else {
      return new Response(JSON.stringify({ error: `Payment gateway error: ${e}` }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }
  }

  // 3. Store pending order in DB
  await supabase.from('pending_orders').insert({
    parent_id,
    order_id: orderId,
    tier,
    payment_method,
    amount,
    status: 'pending',
    snap_token: snapToken,
  })

  return new Response(
    JSON.stringify({ order_id: orderId, snap_token: snapToken, redirect_url: snapRedirectUrl }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
})