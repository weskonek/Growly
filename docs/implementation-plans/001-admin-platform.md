# Growly Admin Platform — Implementation Plan

## Status: Draft
## Target: Next.js + Supabase + Vercel

---

## Summary

Plan ini membuat admin dashboard untuk Growly platform yang terpisah dari parent_app/child_app yang sudah ada. Admin dashboard akan digunakan untuk:
- User management (parents & children)
- AI content moderation (prioritas tinggi karena target anak-anak)
- Analytics (screen time, learning progress)
- Audit & compliance (COPPA)

---

## Verifikasi Schema Existing

### Schema yang sudah ada (00001_initial_schema.sql)

| Tabel | Kolom Relevan | Status |
|-------|---------------|--------|
| `parent_profiles` | id, name, email, created_at, last_login_at | ✅ Ready |
| `child_profiles` | id, parent_id, name, age_group, birth_date | ✅ Ready |
| `ai_tutor_sessions` | id, child_id, flagged, flag_reason, mode | ✅ Ready |
| `ai_tutor_messages` | id, session_id, role, content, created_at | ✅ Ready |
| `screen_time_records` | child_id, duration_minutes, date, app_name | ✅ Ready |
| `learning_progress` | child_id, subject, completed, score | ✅ Ready |
| `learning_sessions` | child_id, started_at, duration_minutes | ✅ Ready |
| `audit_logs` | id, user_id, action, table_name, created_at | ✅ Ready |
| `badges` | child_id, badge_type, name, earned_at | ✅ Ready |
| `reward_systems` | child_id, current_streak, total_stars | ✅ Ready |

### Gap Analysis

| Fitur Plan | Status | Catatan |
|------------|--------|---------|
| `admin_users` table | ❌ Missing | Perlu migration baru |
| AI moderation queue | ✅ Ada kolom flagged | Perlu UI |
| Screen time analytics | ✅ Ada data | Perlu agregasi query |
| COPPA deletion | ✅ Ada audit_logs | Perlu server action |

---

## Struktur Folder

```
apps/
├── parent_app/        (existing)
├── child_app/         (existing)
└── admin_web/         ← NEW
      ├── src/
      │     ├── app/              (Next.js App Router)
      │     │     ├── (auth)/
      │     │     │     ├── login/
      │     │     │     └── page.tsx
      │     │     ├── (dashboard)/
      │     │     │     ├── layout.tsx
      │     │     │     ├── dashboard/
      │     │     │     ├── users/
      │     │     │     ├── children/
      │     │     │     ├── ai-moderation/
      │     │     │     ├── screen-time/
      │     │     │     ├── learning/
      │     │     │     └── audit-logs/
      │     │     └── api/
      │     ├── components/
      │     │     ├── ui/              (Radix primitives)
      │     │     ├── dashboard/
      │     │     ├── moderation/
      │     │     └── analytics/
      │     ├── lib/
      │     │     ├── supabase/
      │     │     │     ├── client.ts
      │     │     │     ├── admin.ts    ← Bypass RLS
      │     │     │     └── server.ts
      │     │     ├── auth.ts
      │     │     └── utils.ts
      │     ├── types/
      │     │     └── index.ts
      │     └── actions/              (Server Actions)
      │           ├── users.ts
      │           ├── moderation.ts
      │           └── analytics.ts
      ├── public/
      ├── middleware.ts
      ├── next.config.ts
      └── package.json
```

---

## Phase 1 — Foundation (Week 1)

### 1.1 Setup Project

```bash
cd apps
npx create-next-app@latest admin_web \
  --typescript --tailwind --app --src-dir --eslint --no-import-alias

cd admin_web
npm install @supabase/supabase-js @supabase/ssr
npm install recharts date-fns lucide-react clsx tailwind-merge
npm install @radix-ui/react-dialog @radix-ui/react-tabs @radix-ui/react-dropdown-menu
npm install @radix-ui/react-select @radix-ui/react-slot
npm install sonner  # toast notifications
```

### 1.2 Migration: admin_users Table

```sql
-- migration: 00006_admin_users.sql
CREATE TABLE public.admin_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    role TEXT DEFAULT 'moderator' CHECK (role IN ('superadmin', 'admin', 'moderator')),
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Service role only policy
CREATE POLICY "admin_users readable by service_role only"
    ON public.admin_users
    FOR SELECT
    USING (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "admin_users insertable by service_role only"
    ON public.admin_users
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "admin_users updatable by service_role only"
    ON public.admin_users
    FOR UPDATE
    USING (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "admin_users deletable by superadmin only"
    ON public.admin_users
    FOR DELETE
    USING (
        auth.jwt()->>'role' = 'service_role'
        AND EXISTS (
            SELECT 1 FROM public.admin_users au
            WHERE au.id = auth.uid() AND au.role = 'superadmin'
        )
    );
```

### 1.3 Supabase Admin Client

```typescript
// src/lib/supabase/admin.ts
import { createClient } from '@supabase/supabase-js'

export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)
```

### 1.4 Environment Variables

```env
# .env.local (development)
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# Whitelist admin emails (superadmin auto-created on first login)
ADMIN_ALLOWED_EMAILS=admin@growly.id,wes@example.com
```

### 1.5 Auth Middleware

```typescript
// src/middleware.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()

  // Protected routes
  const isAuthRoute = request.nextUrl.pathname.startsWith('/login')
  const isProtectedRoute = !isAuthRoute &&
    !request.nextUrl.pathname.startsWith('/_next') &&
    !request.nextUrl.pathname.startsWith('/favicon')

  if (isProtectedRoute && !user) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Check admin_users table if logged in
  if (user && !isAuthRoute) {
    const { data: adminUser } = await supabase
      .from('admin_users')
      .select('id')
      .eq('id', user.id)
      .single()

    if (!adminUser) {
      // Not an admin, redirect to login with error
      return NextResponse.redirect(
        new URL('/login?error=unauthorized', request.url)
      )
    }
  }

  return supabaseResponse
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)']
}
```

---

## Phase 2 — Core Dashboard (Week 2)

### 2.1 Dashboard Overview

**Metrics yang perlu di-query:**

| Metric | Query |
|--------|-------|
| Total Parents | `COUNT(*) FROM parent_profiles` |
| Total Children | `COUNT(*) FROM child_profiles` |
| Active Today | `COUNT(DISTINCT child_id) FROM learning_sessions WHERE DATE(started_at) = CURRENT_DATE` |
| Flagged Sessions | `COUNT(*) FROM ai_tutor_sessions WHERE flagged = TRUE` |
| Avg Screen Time | `AVG(duration_minutes) FROM screen_time_records WHERE date = CURRENT_DATE` |

### 2.2 User Management

**Server Actions:**

```typescript
// src/actions/users.ts
'use server'

import { supabaseAdmin } from '@/lib/supabase/admin'
import { revalidatePath } from 'next/cache'

export async function suspendUser(userId: string) {
  await supabaseAdmin.auth.admin.updateUser(userId, {
    ban_duration: '876600h' // permanent
  })

  await supabaseAdmin.from('audit_logs').insert({
    user_id: userId,
    action: 'admin_suspend',
    table_name: 'parent_profiles'
  })

  revalidatePath('/users')
}

export async function unsuspendUser(userId: string) {
  await supabaseAdmin.auth.admin.updateUser(userId, {
    ban_duration: 'none'
  })
  revalidatePath('/users')
}

export async function deleteUser(userId: string) {
  // CASCADE will handle child_profiles, sessions, etc.
  await supabaseAdmin.auth.admin.deleteUser(userId)

  await supabaseAdmin.from('audit_logs').insert({
    user_id: userId,
    action: 'admin_delete_user',
    table_name: 'auth.users'
  })

  revalidatePath('/users')
}

export async function getUsers(page: number = 1, limit: number = 20) {
  const offset = (page - 1) * limit

  const { data: users, count } = await supabaseAdmin
    .from('parent_profiles')
    .select('*, child_profiles(count)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1)

  return { users, total: count ?? 0 }
}
```

### 2.3 Children Management

```typescript
export async function getChildrenByParent(parentId: string) {
  const { data } = await supabaseAdmin
    .from('child_profiles')
    .select(`
      *,
      parent_profiles(name, email),
      learning_progress(count, completed),
      ai_tutor_sessions(count, flagged),
      screen_time_records(duration_minutes)
    `)
    .eq('parent_id', parentId)

  return data
}
```

---

## Phase 3 — AI Moderation (Week 3) ⭐ Prioritas

### 3.1 Flagged Sessions Query

```typescript
// src/actions/moderation.ts
export async function getFlaggedSessions(limit: number = 50) {
  const { data } = await supabaseAdmin
    .from('ai_tutor_sessions')
    .select(`
      *,
      child_profiles(id, name, age_group, parent_profiles(name, email)),
      ai_tutor_messages(id, role, content, created_at)
    `)
    .eq('flagged', true)
    .order('created_at', { ascending: false })
    .limit(limit)

  return data
}
```

### 3.2 Moderation Actions

```typescript
export async function dismissFlag(sessionId: string) {
  await supabaseAdmin
    .from('ai_tutor_sessions')
    .update({ flagged: false, flag_reason: null })
    .eq('id', sessionId)

  await supabaseAdmin.from('audit_logs').insert({
    session_id: sessionId,
    action: 'moderation_dismiss',
    table_name: 'ai_tutor_sessions'
  })
}

export async function warnParent(parentId: string, sessionId: string) {
  // Send FCM notification via Edge Function
  const { data: fcmToken } = await supabaseAdmin
    .from('parent_profiles')
    .select('settings')
    .eq('id', parentId)
    .single()

  if (fcmToken?.settings?.fcm_token) {
    await fetch(`${process.env.SUPABASE_URL}/functions/v1/send-notification`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`
      },
      body: JSON.stringify({
        fcm_token: fcmToken.settings.fcm_token,
        title: 'Notifikasi Growly',
        body: 'AI tutor mendeteksi percakapan yang perlu perhatian Anda.'
      })
    })
  }

  await supabaseAdmin.from('audit_logs').insert({
    user_id: parentId,
    session_id: sessionId,
    action: 'moderation_warn_parent',
    table_name: 'ai_tutor_sessions'
  })
}

export async function blockChildTemporarily(childId: string, hours: number = 24) {
  await supabaseAdmin
    .from('child_profiles')
    .update({ is_active: false })
    .eq('id', childId)

  // Schedule reactivation (simple approach - use pg_cron for production)
  await supabaseAdmin.from('audit_logs').insert({
    child_id: childId,
    action: 'moderation_block_child',
    table_name: 'child_profiles',
    new_data: { blocked_until_hours: hours }
  })
}

export async function deleteSession(sessionId: string) {
  // CASCADE will delete ai_tutor_messages
  await supabaseAdmin
    .from('ai_tutor_sessions')
    .delete()
    .eq('id', sessionId)

  await supabaseAdmin.from('audit_logs').insert({
    session_id: sessionId,
    action: 'moderation_delete_session',
    table_name: 'ai_tutor_sessions'
  })
}
```

---

## Phase 4 — Analytics (Week 4)

### 4.1 Screen Time Analytics

```typescript
// src/actions/analytics.ts
export async function getScreenTimeByAgeGroup(weeks: number = 8) {
  const { data } = await supabaseAdmin
    .from('screen_time_records')
    .select(`
      duration_minutes,
      date,
      child_profiles(age_group)
    `)
    .gte('date', `NOW() - INTERVAL '${weeks} weeks'::interval`)

  // Aggregate by age group and week (do in JS or use Postgres VIEW)
  const aggregated = data?.reduce((acc, record) => {
    const week = startOfWeek(record.date)
    const ageGroup = record.child_profiles.age_group
    const key = `${ageGroup}-${week}`

    if (!acc[key]) acc[key] = { ageGroup, week, total: 0, count: 0 }
    acc[key].total += record.duration_minutes
    acc[key].count++

    return acc
  }, {} as Record<string, { ageGroup: number; week: string; total: number; count: number }>)

  return Object.values(aggregated).map(item => ({
    ...item,
    avg: Math.round(item.total / item.count)
  }))
}
```

### 4.2 Learning Analytics

```typescript
export async function getLearningStats() {
  const { data: subjects } = await supabaseAdmin
    .from('learning_progress')
    .select('subject, completed, score')

  const aggregated = subjects?.reduce((acc, item) => {
    if (!acc[item.subject]) {
      acc[item.subject] = { total: 0, completed: 0, scores: [] }
    }
    acc[item.subject].total++
    if (item.completed) acc[item.subject].completed++
    if (item.score) acc[item.subject].scores.push(item.score)

    return acc
  }, {} as Record<string, { total: number; completed: number; scores: number[] }>)

  return Object.entries(aggregated).map(([subject, stats]) => ({
    subject,
    completionRate: Math.round((stats.completed / stats.total) * 100),
    avgScore: stats.scores.length
      ? Math.round(stats.scores.reduce((a, b) => a + b, 0) / stats.scores.length)
      : 0
  }))
}
```

---

## Phase 5 — Security & Compliance (Week 5)

### 5.1 Audit Log Viewer

```typescript
export async function getAuditLogs(
  filters: {
    action?: string
    userId?: string
    tableName?: string
    dateFrom?: string
    dateTo?: string
  },
  page: number = 1,
  limit: number = 50
) {
  let query = supabaseAdmin
    .from('audit_logs')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range((page - 1) * limit, page * limit - 1)

  if (filters.action) query = query.eq('action', filters.action)
  if (filters.userId) query = query.eq('user_id', filters.userId)
  if (filters.tableName) query = query.eq('table_name', filters.tableName)
  if (filters.dateFrom) query = query.gte('created_at', filters.dateFrom)
  if (filters.dateTo) query = query.lte('created_at', filters.dateTo)

  const { data, count } = await query
  return { logs: data, total: count ?? 0 }
}
```

### 5.2 COPPA Data Deletion

```typescript
export async function processDeletionRequest(email: string) {
  // Find user by email
  const { data: user } = await supabaseAdmin
    .from('parent_profiles')
    .select('id')
    .eq('email', email)
    .single()

  if (!user) {
    return { error: 'User not found' }
  }

  // Preview data that will be deleted
  const { data: children } = await supabaseAdmin
    .from('child_profiles')
    .select('id, name')
    .eq('parent_id', user.id)

  const { count: sessions } = await supabaseAdmin
    .from('learning_sessions')
    .select('*', { count: 'exact', head: true })
    .in('child_id', children?.map(c => c.id) ?? [])

  return {
    userId: user.id,
    children: children?.length ?? 0,
    sessions: sessions ?? 0,
    // ...
  }
}

export async function executeDeletion(userId: string) {
  // Log before deletion
  await supabaseAdmin.from('audit_logs').insert({
    user_id: userId,
    action: 'coppa_data_deletion_requested',
    table_name: 'auth.users'
  })

  // Delete from Supabase Auth (CASCADE handles all tables)
  await supabaseAdmin.auth.admin.deleteUser(userId)

  return { success: true }
}
```

---

## Phase 6 — Deploy ke Vercel

### Environment Variables di Vercel

```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...  # Server only!
ADMIN_ALLOWED_EMAILS=admin@growly.id
```

### next.config.ts

```typescript
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  experimental: {
    serverActions: {
      allowedOrigins: ['admin.growly.id']
    }
  }
}

export default nextConfig
```

### Vercel Project Settings

| Setting | Value |
|---------|-------|
| Root directory | `apps/admin_web` |
| Framework | Next.js |
| Build command | `npm run build` |
| Output directory | `.next` |
| Environment Variables | See above |
| Domain | `admin.growly.id` (optional custom domain) |

---

## Timeline Summary

| Phase | Fokus | Durasi |
|-------|-------|--------|
| Phase 1 | Setup, auth, DB migration | Week 1 |
| Phase 2 | Dashboard + User management | Week 2 |
| Phase 3 | AI Moderation (PRIORITAS) | Week 3 |
| Phase 4 | Analytics & charts | Week 4 |
| Phase 5 | Audit logs, COPPA tools | Week 5 |
| Phase 6 | Deploy Vercel + domain | End of Week 5 |

---

## Dependencies & Prerequisites

1. **Supabase Project** - Sudah ada (backend/supabase/)
2. **Supabase CLI** - Untuk run migrations lokal
3. **Vercel Account** - Untuk deploy
4. **Domain** - admin.growly.id (optional)

---

## Open Questions

- [ ] Apakah perlu bikin Edge Function untuk send notification dari admin?
- [ ] Bagaimana handle child login yang perlu diblokir sementara?
- [ ] Apakah perlu integration dengan email service untuk warnings?
- [ ] Report generation (PDF export)?
