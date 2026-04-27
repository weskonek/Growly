import { supabaseAdmin } from '@/lib/supabase/admin'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { UserCircle } from 'lucide-react'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { formatDistanceToNow } from 'date-fns'

const ageGroupLabels: Record<number, string> = {
  0: 'Early Childhood (2-5)',
  1: 'Primary (6-9)',
  2: 'Upper Primary (10-12)',
  3: 'Teen (13-18)',
}

interface ChildWithParent {
  id: string
  name: string
  birth_date: string
  age_group: number
  is_active: boolean
  created_at: string
  parent_profiles: {
    name: string
    email: string
  } | null
}

async function getChildren(): Promise<ChildWithParent[]> {
  const { data } = await supabaseAdmin
    .from('child_profiles')
    .select(`
      id,
      name,
      birth_date,
      age_group,
      is_active,
      created_at,
      parent_profiles (name, email)
    `)
    .order('created_at', { ascending: false })

  return (data as unknown as ChildWithParent[]) ?? []
}

export default async function ChildrenPage() {
  const children = await getChildren()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Children</h1>
          <p className="text-muted-foreground">
            All child profiles across the platform
          </p>
        </div>
        <Badge variant="secondary">
          <UserCircle className="h-4 w-4 mr-1" />
          {children.length} children
        </Badge>
      </div>

      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Parent</TableHead>
                <TableHead>Age Group</TableHead>
                <TableHead>Birth Date</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Joined</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {children.map((child) => (
                <TableRow key={child.id}>
                  <TableCell className="font-medium">{child.name}</TableCell>
                  <TableCell>
                    <div>
                      <p>{child.parent_profiles?.name ?? 'Unknown'}</p>
                      <p className="text-xs text-muted-foreground">
                        {child.parent_profiles?.email ?? 'No email'}
                      </p>
                    </div>
                  </TableCell>
                  <TableCell>{ageGroupLabels[child.age_group] ?? 'Unknown'}</TableCell>
                  <TableCell>{child.birth_date}</TableCell>
                  <TableCell>
                    <Badge variant={child.is_active ? 'success' : 'destructive'}>
                      {child.is_active ? 'Active' : 'Blocked'}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    {formatDistanceToNow(new Date(child.created_at), { addSuffix: true })}
                  </TableCell>
                </TableRow>
              ))}
              {children.length === 0 && (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">
                    No children found
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
