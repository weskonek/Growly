import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { BookOpen } from 'lucide-react'
import { MetricsCard } from '@/components/dashboard/metrics-card'

export default function ContentPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Content Management</h1>
        <p className="text-muted-foreground">
          Manage learning content and courses for children
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>📚 Courses</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col items-center justify-center py-16 text-center">
            <BookOpen className="h-12 w-12 text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">Content Management</h3>
            <p className="text-muted-foreground text-sm max-w-sm">
              Connect the <code>courses</code> table to enable course creation and management.
              This feature will be available once the table is added to the database schema.
            </p>
            <Badge variant="secondary" className="mt-4">
              Coming Soon
            </Badge>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
