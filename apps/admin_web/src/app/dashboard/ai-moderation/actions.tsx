'use server'

import { revalidatePath } from 'next/cache'
import { toast } from 'sonner'
import { supabaseAdmin } from '@/lib/supabase/admin'

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
      new_data: { flagged: false }
    })

    revalidatePath('/dashboard/ai-moderation')
    toast.success('Session dismissed successfully')
  } catch (error) {
    toast.error('Failed to dismiss session')
    console.error(error)
  }
}

export async function warnParentAction(sessionId: string, parentId: string) {
  try {
    await supabaseAdmin.from('audit_logs').insert({
      user_id: parentId,
      action: 'moderation_warn_parent',
      table_name: 'ai_tutor_sessions',
      record_id: sessionId,
      new_data: { warned: true }
    })

    revalidatePath('/dashboard/ai-moderation')
    toast.success('Parent notified (mock - FCM integration needed)')
  } catch (error) {
    toast.error('Failed to notify parent')
    console.error(error)
  }
}

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
      new_data: { is_active: false, blocked_by: 'admin' }
    })

    revalidatePath('/dashboard/ai-moderation')
    toast.success('Child blocked successfully')
  } catch (error) {
    toast.error('Failed to block child')
    console.error(error)
  }
}

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
      new_data: { deleted: true }
    })

    revalidatePath('/dashboard/ai-moderation')
    toast.success('Session deleted successfully')
  } catch (error) {
    toast.error('Failed to delete session')
    console.error(error)
  }
}
