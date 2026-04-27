'use server'

import { revalidatePath } from 'next/cache'
import { toast } from 'sonner'
import { supabaseAdmin } from '@/lib/supabase/admin'
import { Button } from '@/components/ui/button'
import { Ban, Trash2 } from 'lucide-react'
import { useState } from 'react'

export async function suspendUserAction(userId: string) {
  try {
    await supabaseAdmin.auth.admin.updateUser(userId, {
      ban_duration: '876600h', // permanent
    })

    await supabaseAdmin.from('audit_logs').insert({
      user_id: userId,
      action: 'admin_suspend',
      table_name: 'parent_profiles'
    })

    revalidatePath('/dashboard/users')
    toast.success('User suspended successfully')
  } catch (error) {
    toast.error('Failed to suspend user')
    console.error(error)
  }
}

export async function unsuspendUserAction(userId: string) {
  try {
    await supabaseAdmin.auth.admin.updateUser(userId, {
      ban_duration: 'none'
    })

    revalidatePath('/dashboard/users')
    toast.success('User unsuspended successfully')
  } catch (error) {
    toast.error('Failed to unsuspend user')
    console.error(error)
  }
}

export async function deleteUserAction(userId: string) {
  if (!confirm('Are you sure? This will delete the user and all associated data.')) {
    return
  }

  try {
    await supabaseAdmin.auth.admin.deleteUser(userId)

    await supabaseAdmin.from('audit_logs').insert({
      user_id: userId,
      action: 'admin_delete_user',
      table_name: 'auth.users'
    })

    revalidatePath('/dashboard/users')
    toast.success('User deleted successfully')
  } catch (error) {
    toast.error('Failed to delete user')
    console.error(error)
  }
}

export function UserActions({ userId }: { userId: string }) {
  return (
    <div className="flex items-center gap-2 justify-end">
      <Button variant="outline" size="sm">
        <Ban className="h-4 w-4" />
      </Button>
      <Button variant="destructive" size="sm">
        <Trash2 className="h-4 w-4" />
      </Button>
    </div>
  )
}
