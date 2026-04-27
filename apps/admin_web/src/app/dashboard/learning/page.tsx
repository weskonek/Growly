import { supabaseAdmin } from '@/lib/supabase/admin'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { BookOpen, TrendingUp, Award } from 'lucide-react'
import { MetricsCard } from '@/components/dashboard/metrics-card'
import { LearningChart } from './chart'

interface SubjectStats {
  subject: string
  total: number
  completed: number
  avgScore: number
}

async function getLearningStats(): Promise<{
  totalSessions: number
  totalProgress: number
  completedCount: number
  subjects: SubjectStats[]
}> {
  const [{ count: totalSessions }, { count: totalProgress }, { data: progressData }] = await Promise.all([
    supabaseAdmin
      .from('learning_sessions')
      .select('*', { count: 'exact', head: true }),
    supabaseAdmin
      .from('learning_progress')
      .select('*', { count: 'exact', head: true }),
    supabaseAdmin
      .from('learning_progress')
      .select('subject, completed, score')
  ])

  // Aggregate by subject
  const subjectMap: Record<string, { total: number; completed: number; scores: number[] }> = {}

  progressData?.forEach((item) => {
    if (!subjectMap[item.subject]) {
      subjectMap[item.subject] = { total: 0, completed: 0, scores: [] }
    }
    subjectMap[item.subject].total++
    if (item.completed) subjectMap[item.subject].completed++
    if (item.score) subjectMap[item.subject].scores.push(item.score)
  })

  const subjects: SubjectStats[] = Object.entries(subjectMap).map(([subject, stats]) => ({
    subject,
    total: stats.total,
    completed: stats.completed,
    avgScore: stats.scores.length > 0
      ? Math.round(stats.scores.reduce((a, b) => a + b, 0) / stats.scores.length)
      : 0,
  }))

  const completedCount = subjects.reduce((sum, s) => sum + s.completed, 0)

  return {
    totalSessions: totalSessions ?? 0,
    totalProgress: totalProgress ?? 0,
    completedCount,
    subjects,
  }
}

async function getRecentSessions() {
  const { data } = await supabaseAdmin
    .from('learning_sessions')
    .select(`
      id,
      subject,
      started_at,
      duration_minutes,
      session_type,
      child_profiles (name)
    `)
    .order('started_at', { ascending: false })
    .limit(10)

  return data ?? []
}

const subjectLabels: Record<string, string> = {
  reading: '📖 Membaca',
  math: '🔢 Matematika',
  science: '🔬 Sains',
  creative: '🎨 Kreativitas',
  language: '🗣️ Bahasa',
}

export default async function LearningPage() {
  const [stats, recentSessions] = await Promise.all([
    getLearningStats(),
    getRecentSessions()
  ])

  const completionRate = stats.totalProgress > 0
    ? Math.round((stats.completedCount / stats.totalProgress) * 100)
    : 0

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Learning Analytics</h1>
        <p className="text-muted-foreground">
          Learning progress and performance metrics
        </p>
      </div>

      {/* Metrics */}
      <div className="grid gap-4 md:grid-cols-3">
        <MetricsCard
          title="Total Sessions"
          value={stats.totalSessions}
          description="Learning sessions completed"
          icon={BookOpen}
        />
        <MetricsCard
          title="Completion Rate"
          value={`${completionRate}%`}
          description={`${stats.completedCount} of ${stats.totalProgress} activities`}
          icon={TrendingUp}
        />
        <MetricsCard
          title="Active Subjects"
          value={stats.subjects.length}
          description="Subjects being learned"
          icon={Award}
        />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        {/* Subject Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Learning by Subject</CardTitle>
          </CardHeader>
          <CardContent>
            <LearningChart data={stats.subjects} />
          </CardContent>
        </Card>

        {/* Recent Sessions */}
        <Card>
          <CardHeader>
            <CardTitle>Recent Sessions</CardTitle>
          </CardHeader>
          <CardContent>
            {recentSessions.length === 0 ? (
              <p className="text-muted-foreground text-sm">No recent sessions</p>
            ) : (
              <div className="space-y-3">
                {recentSessions.map((session) => (
                  <div key={session.id} className="flex items-center justify-between border-b pb-2 last:border-0">
                    <div>
                      <p className="text-sm font-medium">
                        {subjectLabels[session.subject] ?? session.subject}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {(session.child_profiles as { name: string })?.name ?? 'Unknown'} • {session.duration_minutes} min
                      </p>
                    </div>
                    <Badge variant="secondary">{session.session_type}</Badge>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Subject Details */}
      <Card>
        <CardHeader>
          <CardTitle>Subject Performance</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {stats.subjects.map((subject) => (
              <div key={subject.subject} className="p-4 border rounded-lg">
                <div className="flex items-center justify-between mb-2">
                  <span className="font-medium">
                    {subjectLabels[subject.subject] ?? subject.subject}
                  </span>
                  <Badge variant={subject.completed > 0 ? 'success' : 'secondary'}>
                    {Math.round((subject.completed / subject.total) * 100)}%
                  </Badge>
                </div>
                <div className="text-sm text-muted-foreground">
                  <p>{subject.completed}/{subject.total} completed</p>
                  {subject.avgScore > 0 && (
                    <p>Avg Score: {subject.avgScore}</p>
                  )}
                </div>
              </div>
            ))}
            {stats.subjects.length === 0 && (
              <p className="col-span-full text-center text-muted-foreground py-8">
                No learning data yet
              </p>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
