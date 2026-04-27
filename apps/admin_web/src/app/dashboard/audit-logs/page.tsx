import { supabaseAdmin } from '@/lib/supabase/admin'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { FileText, Filter } from 'lucide-react'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { formatDistanceToNow, format } from 'date-fns'
import { id } from 'date-fns/locale'

interface AuditLog {
  id: string
  user_id: string | null
  child_id: string | null
  action: string
  table_name: string | null
  record_id: string | null
  old_data: Record<string, unknown> | null
  new_data: Record<string, unknown> | null
  created_at: string
}

const actionColors: Record<string, 'default' | 'warning' | 'destructive' | 'success'> = {
  ai_tutor_session: 'default',
  moderation_dismiss: 'success',
  moderation_warn_parent: 'warning',
  moderation_block_child: 'destructive',
  moderation_delete_session: 'destructive',
  admin_suspend: 'destructive',
  admin_delete_user: 'destructive',
  admin_unsuspend: 'success',
  coppa_data_deletion_requested: 'destructive',
}

const actionLabels: Record<string, string> = {
  ai_tutor_session: 'AI Session',
  moderation_dismiss: 'Dismissed',
  moderation_warn_parent: 'Warned Parent',
  moderation_block_child: 'Blocked Child',
  moderation_delete_session: 'Deleted Session',
  admin_suspend: 'Suspended',
  admin_delete_user: 'Deleted User',
  admin_unsuspend: 'Unsuspended',
  coppa_data_deletion_requested: 'COPPA Deletion',
}

async function getAuditLogs(limit: number = 100) {
  const { data } = await supabaseAdmin
    .from('audit_logs')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(limit)

  return (data as AuditLog[]) ?? []
}

export default async function AuditLogsPage() {
  const logs = await getAuditLogs()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Audit Logs</h1>
          <p className="text-muted-foreground">
            COPPA compliance and activity logs
          </p>
        </div>
        <Badge variant="secondary">
          <FileText className="h-4 w-4 mr-1" />
          {logs.length} entries
        </Badge>
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Timestamp</TableHead>
                <TableHead>Action</TableHead>
                <TableHead>Table</TableHead>
                <TableHead>User ID</TableHead>
                <TableHead>Details</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {logs.map((log) => (
                <TableRow key={log.id}>
                  <TableCell className="whitespace-nowrap">
                    <div className="text-sm">
                      {format(new Date(log.created_at), 'dd MMM yyyy', { locale: id })}
                    </div>
                    <div className="text-xs text-muted-foreground">
                      {format(new Date(log.created_at), 'HH:mm:ss')}
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant={actionColors[log.action] ?? 'default'}>
                      {actionLabels[log.action] ?? log.action}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-sm">{log.table_name ?? '-'}</TableCell>
                  <TableCell>
                    <code className="text-xs bg-muted px-1 py-0.5 rounded">
                      {log.user_id ? `${log.user_id.slice(0, 8)}...` : '-'}
                    </code>
                  </TableCell>
                  <TableCell className="max-w-xs">
                    {log.new_data ? (
                      <details className="cursor-pointer">
                        <summary className="text-sm text-muted-foreground hover:text-foreground">
                          View details
                        </summary>
                        <pre className="mt-1 text-xs bg-muted p-2 rounded overflow-auto max-h-32">
                          {JSON.stringify(log.new_data, null, 2)}
                        </pre>
                      </details>
                    ) : (
                      <span className="text-sm text-muted-foreground">-</span>
                    )}
                  </TableCell>
                </TableRow>
              ))}
              {logs.length === 0 && (
                <TableRow>
                  <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">
                    No audit logs found
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  )
}
