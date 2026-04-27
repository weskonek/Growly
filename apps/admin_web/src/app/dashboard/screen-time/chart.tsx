'use client'

import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

interface ScreenTimeChartProps {
  data: Record<string, number>
}

export function ScreenTimeChart({ data }: ScreenTimeChartProps) {
  const chartData = Object.entries(data).map(([name, minutes]) => ({
    name,
    minutes: Math.round(minutes / 60), // Convert to hours
    hours: Math.round(minutes / 60),
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
          <XAxis type="number" label={{ value: 'Hours', position: 'bottom' }} />
          <YAxis
            type="category"
            dataKey="name"
            width={100}
            tick={{ fontSize: 12 }}
          />
          <Tooltip
            formatter={(value: number) => [`${value} hours`, 'Screen Time']}
            labelStyle={{ color: 'hsl(var(--foreground))' }}
          />
          <Bar
            dataKey="hours"
            fill="hsl(var(--primary))"
            radius={[0, 4, 4, 0]}
          />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
