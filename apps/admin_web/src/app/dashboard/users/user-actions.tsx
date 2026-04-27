'use client'

import { Button } from '@/components/ui/button'
import { Ban, Trash2 } from 'lucide-react'
import { useState } from 'react'
import { suspendUserAction, deleteUserAction } from './actions'

export function UserActions({ userId }: { userId: string }) {
  const [loading, setLoading] = useState<string | null>(null)

  const handleSuspend = async () => {
    setLoading('suspend')
    await suspendUserAction(userId)
    setLoading(null)
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure? This will delete the user and all associated data.')) {
      return
    }
    setLoading('delete')
    await deleteUserAction(userId)
    setLoading(null)
  }

  return (
    <div className="flex items-center gap-2 justify-end">
      <Button
        variant="outline"
        size="sm"
        onClick={handleSuspend}
        disabled={loading !== null}
      >
        <Ban className="h-4 w-4" />
      </Button>
      <Button
        variant="destructive"
        size="sm"
        onClick={handleDelete}
        disabled={loading !== null}
      >
        <Trash2 className="h-4 w-4" />
      </Button>
    </div>
  )
}
