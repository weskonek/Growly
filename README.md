# 🌱 Growly

> **AI-Powered Digital Growth Platform for Kids & Teens**
>
> Mengubah screen time menjadi growth time — parental control + AI tutor adaptif untuk anak usia 2 tahun sampai SMA.

---

## 🏗️ Struktur Monorepo

```
Growly/
├── apps/
│   ├── parent_app/          # Flutter app — kontrol orang tua & dashboard
│   ├── child_app/           # Flutter app — safe launcher, belajar, AI tutor, hadiah
│   └── admin_web/           # Next.js — admin dashboard (users, children, analytics)
├── packages/
│   ├── growly_core/         # Shared models, repositories, providers
│   ├── growly_ui_kit/       # Shared design system & components
│   ├── growly_ai_tutor/     # AI tutor logic & prompt templates
│   └── growly_parental_control/  # Parental control native bridges
├── backend/
│   └── supabase/
│       ├── migrations/      # SQL schema + RLS policies
│       └── functions/        # Supabase Edge Functions (Deno/TypeScript)
├── docs/
│   ├── architecture.md
│   ├── db_schema.md
│   └── api_contracts.md
└── scripts/                 # Dev tooling & CI helpers
```

## 🚀 Tech Stack

| Layer | Tech |
|-------|------|
| Mobile App | Flutter 3.x (monorepo, Melos) |
| State Management | Riverpod 2.x (AsyncNotifier, FutureProvider) |
| Navigation | GoRouter (ShellRoute for bottom nav) |
| Backend | Supabase (Postgres, Auth, Storage, Realtime) |
| Edge Functions | Deno/TypeScript (Supabase Edge Functions) |
| AI | Google Gemini (via `ai-tutor` edge function) |
| Admin Web | Next.js 14 + Tailwind CSS + Recharts |
| Database | PostgreSQL with Row Level Security (RLS) |

## 📱 App Targets

### Parent App
- **Auth** — login, register, forgot password → Supabase Auth
- **Dashboard** — live stats (screen time, sessions, badges), AI risk warnings, realtime via Supabase Postgres Changes
- **Children** — CRUD (add/edit/delete soft-delete), pull-to-refresh, child detail page
- **Parental Control** — per-child: screen time slider, app lock, school mode, safe mode, location tracker
- **Settings** — profile editing, PIN lock toggle, subscription status, sign out

### Child App
- **Launcher** — PIN gate (verifies against `child_profiles.pin`), safe mode card grid
- **Learning Hub** — subject cards → lesson steps with session tracking
- **AI Tutor** — calls `ai-tutor` edge function (Gemini, hint-only pedagogy), typing indicator
- **Rewards** — streak & stars, badge grid, celebration dialog on new badge

### Admin Web
- Dashboard, Users, Children, AI Moderation, Screen Time analytics, Learning analytics, Content management, Audit Logs

## 🗄️ Database — 12 Tables

| Table | Purpose |
|-------|---------|
| `parent_profiles` | Parent name, email, phone, settings (PIN lock prefs) |
| `child_profiles` | Child name, birth_date, avatar, PIN, age_group, settings |
| `learning_progress` | Per-child per-subject completion tracking |
| `learning_sessions` | Session records with start/end timestamps |
| `screen_time_records` | Daily app-level screen time logging |
| `app_restrictions` | Per-child app allowlist, time limits, schedule JSONB |
| `schedules` | School/sleep/learning mode windows (day + time range) |
| `badges` | Earned badges per child |
| `reward_systems` | Streak, stars, unlocked badges per child |
| `ai_tutor_sessions` | Session + message history |
| `ai_tutor_messages` | Individual messages within sessions |
| `audit_logs` | All admin actions timestamped |

All tables have RLS policies — parents see only their own children, children see only their own data.

## ⚡ Edge Functions

| Function | Purpose |
|----------|---------|
| `ai-tutor` | Gemini-powered tutor (hint-only, no direct answers) |
| `ai-tutor-stream` | Streaming variant of AI tutor |
| `notifications` | FCM/APNs push notifications |
| `sync-handler` | Device sync webhook |
| `daily-report` | Nightly cron — generates `daily_reports` per child with AI insight |
| `policy-sync` | Returns app restrictions + schedules for a child (used by child app) |

## 🧩 Modul Utama

1. **Auth & Identity** — parent login/register/forgot-password, child PIN verification
2. **Parental Control Core** — app lock, screen time rules, school mode, safe mode
3. **Learning Core** — age-based curriculum, lesson engine, session tracking, rewards
4. **AI Core** — Gemini-powered tutor per age band (2–5, 6–9, 10–12, 13–18), hint-first pedagogy
5. **Analytics & Reporting** — screen time, learning time, AI risk flags, daily digest
6. **Compliance & Safety** — consent, audit logs, data retention, COPPA-like

## 🏁 Mulai Development

```bash
# Install Melos
dart pub global activate melos

# Bootstrap semua packages
melos bootstrap

# Jalankan parent app
cd apps/parent_app && flutter run

# Jalankan child app
cd apps/child_app && flutter run

# Jalankan admin web
cd apps/admin_web && npm run dev
```

### Setup Environment

```bash
# apps/parent_app/.env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# apps/child_app/.env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# apps/admin_web/.env.local
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

## 📄 Dokumentasi

- [Technical Walkthrough](WALKTHROUGH.md) — full feature walkthrough with code patterns
- [Arsitektur Sistem](docs/architecture.md)
- [Database Schema](docs/db_schema.md)
- [API Contracts](docs/api_contracts.md)

---

## 🔑 Key Patterns

### Supabase Realtime (parent dashboard)
```dart
Supabase.instance.client
  .channel('dashboard-parent-${userId}')
  .onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'screen_time_records',
    callback: (payload) => ref.invalidate(dashboardStatsProvider),
  )
  .subscribe();
```

### Child App PIN Gate
```dart
// Verify PIN against child_profiles, then populate currentChildProvider
final data = await Supabase.instance.client
    .from('child_profiles')
    .select()
    .eq('pin', pin)
    .eq('is_active', true)
    .maybeSingle();
if (data != null) onVerified(data['id']);
```

### Soft Delete
```dart
await client.from('child_profiles')
    .update({'is_active': false})
    .eq('id', childId);
```

### Repository Pattern
```dart
// Supabase query returns PostgrestList directly — no .data/.error
final List<Map<String, dynamic>> rows =
    await client.from('table').select(...);
// Use try/catch for error handling
```

---

*Built with ❤️ by PT Tekno Konek Solusi — Weskonek*
