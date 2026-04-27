import { supabaseAdmin } from '@/lib/supabase/admin'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Clock, TrendingUp, TrendingDown } from 'lucide-react'
import { MetricsCard } from '@/components/dashboard/metrics-card'
import { ScreenTimeChart } from './chart'

interface ScreenTimeStats {
  avgDaily: number
  totalToday: number
  byAgeGroup: Record<string, number>
}

interface WeekRecord {
  duration_minutes: number
  child_profiles: { age_group: number } | null
}

async function getScreenTimeStats(): Promise<ScreenTimeStats> {
  const today = new Date().toISOString().split('T')[0]

  // Get today's stats
  const { data: todayData } = await supabaseAdmin
    .from('screen_time_records')
    .select('duration_minutes')
    .eq('date', today)

  const totalToday = todayData?.reduce((sum, r) => sum + r.duration_minutes, 0) ?? 0

  // Get average for last 7 days
  const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
  const { data: weekData } = await supabaseAdmin
    .from('screen_time_records')
    .select(`
      duration_minutes,
      child_profiles (age_group)
    `)
    .gte('date', weekAgo)

  // Calculate by age group
  const byAgeGroup: Record<string, number> = {}
  let totalWeekMinutes = 0
  let count = 0

  ;(weekData as WeekRecord[] | null)?.forEach((record) => {
    const ageGroup = record.child_profiles?.age_group ?? -1
    const label = ['Early Childhood', 'Primary', 'Upper Primary', 'Teen'][ageGroup] ?? 'Unknown'
    byAgeGroup[label] = (byAgeGroup[label] ?? 0) + record.duration_minutes
    totalWeekMinutes += record.duration_minutes
    count++
  })

  const avgDaily = count > 0 ? Math.round(totalWeekMinutes / 7) : 0

  return { avgDaily, totalToday, byAgeGroup }
}

async function getTopApps() {
  const today = new Date().toISOString().split('T')[0]
  const { data } = await supabaseAdmin
    .from('screen_time_records')
    .select('app_name, duration_minutes')
    .eq('date', today)
    .order('duration_minutes', { ascending: false })
    .limit(10)

  return data ?? []
}

export default async function ScreenTimePage() {
  const [stats, topApps] = await Promise.all([
    getScreenTimeStats(),
    getTopApps()
  ])

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Screen Time</h1>
        <p className="text-muted-foreground">
          Screen time analytics and reports
        </p>
      </div>

      {/* Metrics */}
      <div className="grid gap-4 md:grid-cols-3">
        <MetricsCard
          title="Today's Total"
          value={`${Math.floor(stats.totalToday / 60)}h ${stats.totalToday % 60}m`}
          description="Total screen time today"
          icon={Clock}
        />
        <MetricsCard
          title="7-Day Average"
          value={`${Math.floor(stats.avgDaily / 60)}h ${stats.avgDaily % 60}m`}
          description="Average daily screen time"
          icon={TrendingUp}
        />
        <MetricsCard
          title="Children Tracked"
          value={Object.keys(stats.byAgeGroup).length}
          description="Age groups with data"
          icon={Clock}
        />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        {/* Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Screen Time by Age Group</CardTitle>
          </CardHeader>
          <CardContent>
            <ScreenTimeChart data={stats.byAgeGroup} />
          </CardContent>
        </Card>

        {/* Top Apps */}
        <Card>
          <CardHeader>
            <CardTitle>Top Apps Today</CardTitle>
          </CardHeader>
          <CardContent>
            {topApps.length === 0 ? (
              <p className="text-muted-foreground text-sm">No data for today</p>
            ) : (
              <div className="space-y-3">
                {topApps.map((app, index) => (
                  <div key={app.app_name ?? index} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-xs font-bold">
                        {index + 1}
                      </div>
                      <span className="text-sm">{app.app_name ?? 'Unknown App'}</span>
                    </div>
                    <Badge variant="secondary">
                      {Math.floor(app.duration_minutes / 60)}h {app.duration_minutes % 60}m
                    </Badge>
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
