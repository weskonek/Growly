export type AdminRole = 'superadmin' | 'admin' | 'moderator'

export interface AdminUser {
  id: string
  name: string
  email: string
  role: AdminRole
  last_login_at: string | null
  created_at: string
  updated_at: string | null
}

export interface ParentProfile {
  id: string
  name: string
  email: string
  phone: string | null
  avatar_url: string | null
  created_at: string
  last_login_at: string | null
  child_count?: number
}

export interface ChildProfile {
  id: string
  parent_id: string
  name: string
  birth_date: string
  age_group: number
  is_active: boolean
  created_at: string
  parent_profiles?: Pick<ParentProfile, 'name' | 'email'>
}

export interface AiTutorSession {
  id: string
  child_id: string
  mode: string
  prompt: string
  response: string | null
  response_time_ms: number | null
  tokens_used: number | null
  flagged: boolean
  flag_reason: string | null
  created_at: string
  child_profiles?: Pick<ChildProfile, 'id' | 'name' | 'age_group'> & {
    parent_profiles?: Pick<ParentProfile, 'name' | 'email'>
  }
  ai_tutor_messages?: AiTutorMessage[]
}

export interface AiTutorMessage {
  id: string
  session_id: string
  role: 'user' | 'assistant'
  content: string
  created_at: string
}

export interface AuditLog {
  id: string
  user_id: string | null
  child_id: string | null
  action: string
  table_name: string | null
  record_id: string | null
  old_data: Record<string, unknown> | null
  new_data: Record<string, unknown> | null
  ip_address: string | null
  user_agent: string | null
  created_at: string
}

export interface LearningProgress {
  id: string
  child_id: string
  subject: string
  topic: string
  score: number
  completed: boolean
  completed_at: string | null
  created_at: string
}

export interface LearningSession {
  id: string
  child_id: string
  subject: string
  started_at: string
  ended_at: string | null
  duration_minutes: number
  session_type: string
}

export interface ScreenTimeRecord {
  id: string
  child_id: string
  app_package: string
  app_name: string | null
  duration_minutes: number
  date: string
}

export interface DashboardMetrics {
  totalParents: number
  totalChildren: number
  activeToday: number
  flaggedSessions: number
  avgScreenTimeToday: number
}

export interface PaginationParams {
  page: number
  limit: number
}

export interface PaginatedResult<T> {
  data: T[]
  total: number
  page: number
  limit: number
  totalPages: number
}
