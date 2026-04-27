import { Users, Child, BotMessageSquare, Clock } from 'lucide-react'
import { MetricsCard } from '@/components/dashboard/metrics-card'
import { supabaseAdmin } from '@/lib/supabase/admin'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

async function getMetrics() {
  const [
    { count: totalParents },
    { count: totalChildren },
    { count: activeToday },
    { count: flaggedSessions },
    { count: aiSessionsTotal },
  ] = await Promise.all([
    supabaseAdmin.from('parent_profiles').select('*', { count: 'exact', head: true }),
    supabaseAdmin.from('child_profiles').select('*', { count: 'exact', head: true }),
    supabaseAdmin
      .from('learning_sessions')
      .select('*', { count: 'exact', head: true })
      .gte('started_at', new Date(new Date().setHours(0, 0, 0, 0)).toISOString()),
    supabaseAdmin
      .from('ai_tutor_sessions')
      .select('*', { count: 'exact', head: true })
      .eq('flagged', true),
    supabaseAdmin
      .from('ai_tutor_sessions')
      .select('*', { count: 'exact', head: true }),
  ])

  return {
    totalParents: totalParents ?? 0,
    totalChildren: totalChildren ?? 0,
    activeToday: activeToday ?? 0,
    flaggedSessions: flaggedSessions ?? 0,
    aiSessionsTotal: aiSessionsTotal ?? 0,
  }
}

async function getRecentFlaggedSessions() {
  const { data } = await supabaseAdmin
    .from('ai_tutor_sessions')
    .select(`
      id,
      flagged,
      flag_reason,
      created_at,
      mode,
      child_profiles (name, age_group)
    `)
    .eq('flagged', true)
    .order('created_at', { ascending: false })
    .limit(5)

  return data ?? []
}

async function getRecentUsers() {
  const { data } = await supabaseAdmin
    .from('parent_profiles')
    .select(`
      id,
      name,
      email,
      created_at,
      child_profiles (count)
    `)
    .order('created_at', { ascending: false })
    .limit(5)

  return data ?? []
}

export default async function DashboardPage() {
  const [metrics, flaggedSessions, recentUsers] = await Promise.all([
    getMetrics(),
    getRecentFlaggedSessions(),
    getRecentUsers(),
  ])

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">Overview of the Growly platform</p>
      </div>

      {/* Metrics Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <MetricsCard
          title="Total Parents"
          value={metrics.totalParents}
          description="Registered parent accounts"
          icon={Users}
        />
        <MetricsCard
          title="Total Children"
          value={metrics.totalChildren}
          description="Registered child profiles"
          icon={Child}
        />
        <MetricsCard
          title="Active Today"
          value={metrics.activeToday}
          description="Children with learning sessions today"
          icon={Clock}
        />
        <MetricsCard
          title="Flagged AI Sessions"
          value={metrics.flaggedSessions}
          description="Requires moderation"
          icon={BotMessageSquare}
        />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        {/* AI Moderation Queue */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="text-lg">AI Moderation Queue</CardTitle>
            <Link href="/dashboard/ai-moderation">
              <Button variant="outline" size="sm">View all</Button>
            </Link>
          </CardHeader>
          <CardContent>
            {flaggedSessions.length === 0 ? (
              <p className="text-sm text-muted-foreground">
                No flagged sessions. All clear!
              </p>
            ) : (
              <div className="space-y-4">
                {flaggedSessions.map((session) => (
                  <div
                    key={session.id}
                    className="flex items-center justify-between border-b pb-3 last:border-0 last:pb-0"
                  >
                    <div>
                      <p className="font-medium">
                        {session.child_profiles?.name ?? 'Unknown'}
                      </p>
                      <p className="text-sm text-muted-foreground">
                        {session.flag_reason ?? 'No reason'}
                      </p>
                    </div>
                    <Badge variant="warning">{session.mode}</Badge>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Recent Users */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="text-lg">Recent Users</CardTitle>
            <Link href="/dashboard/users">
              <Button variant="outline" size="sm">View all</Button>
            </Link>
          </CardHeader>
          <CardContent>
            {recentUsers.length === 0 ? (
              <p className="text-sm text-muted-foreground">No users yet</p>
            ) : (
              <div className="space-y-4">
                {recentUsers.map((user) => (
                  <div
                    key={user.id}
                    className="flex items-center justify-between border-b pb-3 last:border-0 last:pb-0"
                  >
                    <div>
                      <p className="font-medium">{user.name}</p>
                      <p className="text-sm text-muted-foreground">{user.email}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-medium">
                        {(user as { child_profiles?: { count: number }[] }).child_profiles?.[0]?.count ?? 0} children
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
