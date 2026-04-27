'use client'

import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts'

interface SubjectStats {
  subject: string
  total: number
  completed: number
  avgScore: number
}

interface LearningChartProps {
  data: SubjectStats[]
}

const COLORS = [
  'hsl(var(--primary))',
  'hsl(142, 76%, 36%)',  // green
  'hsl(221, 83%, 53%)',  // blue
  'hsl(280, 67%, 50%)',  // purple
  'hsl(38, 92%, 50%)',   // orange
]

const subjectLabels: Record<string, string> = {
  reading: 'Membaca',
  math: 'Matematika',
  science: 'Sains',
  creative: 'Kreativitas',
  language: 'Bahasa',
}

export function LearningChart({ data }: LearningChartProps) {
  const chartData = data.map((item) => ({
    name: subjectLabels[item.subject] ?? item.subject,
    completed: item.completed,
    remaining: item.total - item.completed,
  }))

  if (chartData.length === 0) {
    return (
      <div className="h-64 flex items-center justify-center text-muted-foreground">
        No data available
      </div>
    )
  }

  return (
    <div className="h-64">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={chartData} layout="vertical">
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis type="number" />
          <YAxis
            type="category"
            dataKey="name"
            width={80}
            tick={{ fontSize: 12 }}
          />
          <Tooltip
            labelStyle={{ color: 'hsl(var(--foreground))' }}
          />
          <Bar dataKey="completed" stackId="a" name="Completed" radius={[0, 4, 4, 0]}>
            {chartData.map((_, index) => (
              <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
            ))}
          </Bar>
          <Bar dataKey="remaining" stackId="a" name="Remaining" fill="hsl(var(--muted))" radius={[0, 4, 4, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
