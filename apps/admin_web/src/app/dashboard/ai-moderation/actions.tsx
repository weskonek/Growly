'use server'

import { revalidatePath } from 'next/cache'
import { toast } from 'sonner'
import { supabaseAdmin } from '@/lib/supabase/admin'

// ============================================================
// Result types
// ============================================================
export type WarnParentResult =
  | { success: true; notificationId: string; fcmSent: boolean }
  | { success: false; error: 'no_fcm_token' | 'edge_function_error' | 'insert_failed'; message: string }

// ============================================================
// Dismiss a flagged session (mark as safe)
// ============================================================
export async function dismissFlagAction(sessionId: string) {
  try {
    await supabaseAdmin
      .from('ai_tutor_sessions')
      .update({ flagged: false, flag_reason: null })
      .eq('id', sessionId)

    await supabaseAdmin.from('audit_logs').insert({
      user_id: null,
      action: 'moderation_dismiss',
      table_name: 'ai_tutor_sessions',
      record_id: sessionId,
      new_data: { flagged: false },
    })

    revalidatePath('/dashboard/ai-moderation')
    toast.success('Session dismissed successfully')
  } catch (error) {
    toast.error('Failed to dismiss session')
    console.error(error)
  }
}

// ============================================================
// Warn parent — inserts notification, calls FCM edge function
// ============================================================
export async function warnParentAction(
  sessionId: string,
  parentId: string,
  childName: string,
  flaggedMessages: string[],
): Promise<WarnParentResult> {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

  // 1. Insert audit log (existing behaviour)
  try {
    await supabaseAdmin.from('audit_logs').insert({
      user_id: parentId,
      action: 'moderaction_warn_parent',
      table_name: 'ai_tutor_sessions',
      record_id: sessionId,
      new_data: { warned: true },
    })
  } catch (err) {
    // Non-fatal — log but continue
    console.error('[warnParent] audit_log insert failed:', err)
  }

  // 2. Build COPPA-compliant notification content
  // Title: no child name / no message content
  const title = 'Peringatan: Aktivitas AI Tutor'
  // Body: include child name (parent has right to know their own child's activity)
  // Truncate first flagged message to 100 chars max
  const firstFlaggedSnippet =
    flaggedMessages[0] && flaggedMessages[0].trim().length > 0
      ? flaggedMessages[0].trim().substring(0, 100) +
        (flaggedMessages[0].length > 100 ? '…' : '')
      : 'Pesan terdeteksi memerlukan perhatian.'
  const body = `Aktivitas AI Tutor anak Anda (${childName}) memerlukan perhatian. "${firstFlaggedSnippet}"`
  const notifType = 'general'

  // 3. Insert notification record
  const notifInsertResult = await supabaseAdmin
    .from('notifications')
    .insert({
      parent_id: parentId,
      title,
      body,
      type: notifType,
      is_sent: false,
      metadata: {
        session_id: sessionId,
        flag_reason: 'ai_moderation_warn_parent',
      },
    })
    .select('id')
    .single()

  if (notifInsertResult.error || !notifInsertResult.data) {
    console.error('[warnParent] notification insert failed:', notifInsertResult.error)
    return {
      success: false,
      error: 'insert_failed',
      message: 'Gagal menyimpan notifikasi',
    }
  }

  const notificationId = notifInsertResult.data.id

  // 4. Call notifications edge function
  const edgeFunctionUrl = `${supabaseUrl}/functions/v1/notifications`
  let fcmSent = false

  try {
    const response = await fetch(edgeFunctionUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${serviceRoleKey}`,
      },
      body: JSON.stringify({
        notification_id: notificationId,
        parent_id: parentId,
        title,
        body,
        type: notifType,
      }),
    })

    if (!response.ok) {
      const errorBody = await response.text()
      console.error('[warnParent] edge function error:', response.status, errorBody)
      return {
        success: false,
        error: 'edge_function_error',
        message: `Gagal mengirim notifikasi (${response.status})`,
      }
    }

    const result = (await response.json()) as {
      sent: boolean
      reason?: string
      error?: string
    }

    fcmSent = result.sent ?? false

    // Handle the "no FCM token registered" case as partial success
    if (result.reason === 'no_fcm_token') {
      // Update is_sent = false on the notification record
      await supabaseAdmin
        .from('notifications')
        .update({ is_sent: false })
        .eq('id', notificationId)

      return {
        success: true,
        notificationId,
        fcmSent: false,
      }
    }

    // 5. Update is_sent on the notification record
    await supabaseAdmin
      .from('notifications')
      .update({ is_sent: fcmSent })
      .eq('id', notificationId)

    if (!result.sent && result.error) {
      console.warn('[warnParent] FCM send returned false:', result.error)
    }
  } catch (err) {
    console.error('[warnParent] edge function call failed:', err)
    return {
      success: false,
      error: 'edge_function_error',
      message: 'Gagal mengirim notifikasi push',
    }
  }

  // 6. Revalidate and return
  revalidatePath('/dashboard/ai-moderation')
  return { success: true, notificationId, fcmSent }
}

// ============================================================
// Block a child profile
// ============================================================
export async function blockChildAction(childId: string) {
  try {
    await supabaseAdmin
      .from('child_profiles')
      .update({ is_active: false })
      .eq('id', childId)

    await supabaseAdmin.from('audit_logs').insert({
      child_id: childId,
      action: 'moderation_block_child',
      table_name: 'child_profiles',
      new_data: { is_active: false, blocked_by: 'admin' },
    })

    revalidatePath('/dashboard/ai-moderation')
    toast.success('Child blocked successfully')
  } catch (error) {
    toast.error('Failed to block child')
    console.error(error)
  }
}

// ============================================================
// Delete a session permanently
// ============================================================
export async function deleteSessionAction(sessionId: string) {
  try {
    await supabaseAdmin
      .from('ai_tutor_sessions')
      .delete()
      .eq('id', sessionId)

    await supabaseAdmin.from('audit_logs').insert({
      action: 'moderation_delete_session',
      table_name: 'ai_tutor_sessions',
      record_id: sessionId,
      new_data: { deleted: true },
    })

    revalidatePath('/dashboard/ai-moderation')
    toast.success('Session deleted successfully')
  } catch (error) {
    toast.error('Failed to delete session')
    console.error(error)
  }
}
