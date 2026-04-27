import { supabaseAdmin } from '@/lib/supabase/admin'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { BotMessageSquare, AlertTriangle, Check } from 'lucide-react'
import { AiModerationActions } from './actions-client'

async function getFlaggedSessions() {
  const { data } = await supabaseAdmin
    .from('ai_tutor_sessions')
    .select(`
      id,
      flagged,
      flag_reason,
      created_at,
      mode,
      tokens_used,
      response_time_ms,
      child_profiles (
        id,
        name,
        age_group,
        parent_profiles (
          id,
          name,
          email
        )
      ),
      ai_tutor_messages (
        id,
        role,
        content,
        created_at
      )
    `)
    .eq('flagged', true)
    .order('created_at', { ascending: false })
    .limit(50)

  return data ?? []
}

export default async function AIModerationPage() {
  const sessions = await getFlaggedSessions()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">AI Moderation</h1>
          <p className="text-muted-foreground">
            Review flagged AI tutor sessions
          </p>
        </div>
        <Badge variant="warning" className="text-base px-4 py-1">
          {sessions.length} pending
        </Badge>
      </div>

      {sessions.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <Check className="h-12 w-12 text-green-500 mb-4" />
            <p className="text-lg font-medium">All clear!</p>
            <p className="text-muted-foreground">
              No flagged sessions to review
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {sessions.map((session) => (
            <Card key={session.id}>
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <BotMessageSquare className="h-5 w-5 text-muted-foreground" />
                    <CardTitle className="text-base">
                      {session.child_profiles?.name ?? 'Unknown Child'}
                    </CardTitle>
                    <Badge variant="secondary">
                      Age group {session.child_profiles?.age_group ?? '?'}
                    </Badge>
                  </div>
                  <Badge variant="warning">
                    <AlertTriangle className="h-3 w-3 mr-1" />
                    {session.flag_reason ?? 'Flagged'}
                  </Badge>
                </div>
                <p className="text-sm text-muted-foreground mt-1">
                  Parent: {session.child_profiles?.parent_profiles?.name ?? 'Unknown'} ({session.child_profiles?.parent_profiles?.email ?? 'No email'})
                </p>
                <p className="text-xs text-muted-foreground">
                  Session ID: {session.id} • Mode: {session.mode} • Created: {new Date(session.created_at).toLocaleString()}
                </p>
              </CardHeader>
              <CardContent className="space-y-4">
                {/* Conversation Thread */}
                <div className="space-y-3 max-h-96 overflow-y-auto rounded-lg bg-muted/50 p-4">
                  {session.ai_tutor_messages?.map((msg) => (
                    <div
                      key={msg.id}
                      className={`flex ${
                        msg.role === 'user' ? 'justify-end' : 'justify-start'
                      }`}
                    >
                      <div
                        className={`max-w-[80%] rounded-lg px-4 py-2 ${
                          msg.role === 'user'
                            ? 'bg-blue-500 text-white'
                            : 'bg-slate-200 text-slate-900'
                        }`}
                      >
                        <p className="text-xs opacity-70 mb-1">
                          {msg.role === 'user' ? 'Child' : 'AI Tutor'}
                        </p>
                        <p className="text-sm whitespace-pre-wrap">{msg.content}</p>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Actions */}
                <div className="flex items-center justify-between pt-2 border-t">
                  <div className="text-sm text-muted-foreground">
                    {session.tokens_used && (
                      <span>{session.tokens_used} tokens • </span>
                    )}
                    {session.response_time_ms && (
                      <span>{session.response_time_ms}ms response</span>
                    )}
                  </div>
                  <AiModerationActions
                    sessionId={session.id}
                    parentId={session.child_profiles?.parent_profiles?.id}
                    childId={session.child_profiles?.id}
                  />
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  )
}
