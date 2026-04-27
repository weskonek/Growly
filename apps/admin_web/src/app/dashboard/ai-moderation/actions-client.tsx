'use client'

import { Button } from '@/components/ui/button'
import {
  Check,
  Bell,
  Ban,
  Trash2,
  MoreHorizontal,
} from 'lucide-react'
import { useState } from 'react'
import {
  dismissFlagAction,
  warnParentAction,
  blockChildAction,
  deleteSessionAction,
} from './actions'

interface AiModerationActionsProps {
  sessionId: string
  parentId?: string
  childId?: string
}

export function AiModerationActions({
  sessionId,
  parentId,
  childId,
}: AiModerationActionsProps) {
  const [loading, setLoading] = useState<string | null>(null)

  const handleDismiss = async () => {
    setLoading('dismiss')
    await dismissFlagAction(sessionId)
    setLoading(null)
  }

  const handleWarn = async () => {
    if (!parentId) return
    setLoading('warn')
    await warnParentAction(sessionId, parentId)
    setLoading(null)
  }

  const handleBlock = async () => {
    if (!childId) return
    setLoading('block')
    await blockChildAction(childId)
    setLoading(null)
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this session? This action cannot be undone.')) {
      return
    }
    setLoading('delete')
    await deleteSessionAction(sessionId)
    setLoading(null)
  }

  return (
    <div className="flex items-center gap-2">
      <Button
        variant="outline"
        size="sm"
        onClick={handleDismiss}
        disabled={loading !== null}
      >
        <Check className="h-4 w-4 mr-1" />
        {loading === 'dismiss' ? 'Dismissing...' : 'Dismiss'}
      </Button>
      <Button
        variant="outline"
        size="sm"
        onClick={handleWarn}
        disabled={loading !== null || !parentId}
      >
        <Bell className="h-4 w-4 mr-1" />
        {loading === 'warn' ? 'Notifying...' : 'Warn Parent'}
      </Button>
      <Button
        variant="outline"
        size="sm"
        onClick={handleBlock}
        disabled={loading !== null || !childId}
      >
        <Ban className="h-4 w-4 mr-1" />
        {loading === 'block' ? 'Blocking...' : 'Block Child'}
      </Button>
      <Button
        variant="destructive"
        size="sm"
        onClick={handleDelete}
        disabled={loading !== null}
      >
        <Trash2 className="h-4 w-4 mr-1" />
        {loading === 'delete' ? 'Deleting...' : 'Delete'}
      </Button>
    </div>
  )
}
