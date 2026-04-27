import { FileText } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'

export default function AuditLogsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Audit Logs</h1>
        <p className="text-muted-foreground">
          COPPA compliance and activity logs
        </p>
      </div>

      <Card>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <FileText className="h-12 w-12 text-muted-foreground mb-4" />
          <p className="text-lg font-medium">Coming Soon</p>
          <p className="text-muted-foreground">
            Audit logs viewer will be available here.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
