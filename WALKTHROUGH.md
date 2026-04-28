# Growly — Technical Walkthrough

## Overview

Growly is an AI-powered digital growth platform for kids and teens, built as a Flutter monorepo with three apps:

- **parent_app** — Parent dashboard and parental controls
- **child_app** — Child launcher, learning hub, AI tutor, and rewards
- **admin_web** — Next.js admin dashboard

The backend is powered by Supabase (PostgreSQL + Realtime + Edge Functions + Auth).

---

## Architecture

```
apps/
├── parent_app/          # Flutter — Parent-facing app
│   └── lib/
│       ├── core/       # Router, providers
│       └── features/   # Auth, children, dashboard, parental_control, settings
├── child_app/          # Flutter — Child-facing app
│   └── lib/
│       ├── core/       # Router
│       └── features/   # Launcher, ai_tutor, learning, rewards
└── admin_web/          # Next.js — Admin web dashboard
    └── src/
        ├── app/        # Pages: dashboard, users, children, screen-time, etc.
        └── components/ # Reusable UI components
backend/
├── supabase/
│   ├── functions/      # Edge Functions (Deno/TypeScript)
│   │   ├── ai-tutor/  # Gemini-powered tutor (hint-only)
│   │   ├── daily-report/   # Nightly report generation
│   │   └── policy-sync/    # Child policy sync
│   └── migrations/    # SQL schema + RLS policies
packages/
├── growly_core/        # Shared: models, repositories, providers
├── growly_ui_kit/     # Shared UI components
├── growly_ai_tutor/   # AI tutor logic
└── growly_parental_control/  # Parental control logic
```

---

## Supabase Schema (12 Tables)

| Table | Purpose |
|-------|---------|
| `parent_profiles` | Parent name, email, phone, settings (PIN lock prefs) |
| `child_profiles` | Child name, birth_date, avatar, PIN, age_group, settings |
| `learning_progress` | Per-child, per-subject completion tracking |
| `learning_sessions` | Active session records (start/end timestamps) |
| `screen_time_records` | Daily app-level screen time logging |
| `app_restrictions` | Per-child app allowlist, time limits, schedule JSONB |
| `schedules` | School/sleep/learning mode windows (day + time range) |
| `badges` | Earned badges per child |
| `reward_systems` | Streak, stars, unlocked badges per child |
| `ai_tutor_sessions` | Session + message history for AI tutor |
| `ai_tutor_messages` | Individual messages within sessions |
| `audit_logs` | All admin actions timestamped |

All tables have RLS policies so parents see only their own children, children see only their own data.

---

## Parent App — Feature Walkthrough

### Auth Flow

**Login** (`login_page.dart`) uses `authNotifierProvider.signIn()` from `growly_core`. Shows loading state, maps `AuthException` codes to Indonesian snackbars, links to forgot password.

**Register** (`register_page.dart`) is a `ConsumerStatefulWidget`. On submit it calls `signUp()` (Supabase Auth) then upserts the profile row into `parent_profiles` with name, email, phone.

**Forgot Password** (`forgot_password_page.dart`) calls `Supabase.instance.client.auth.resetPasswordForEmail()` and shows a success message.

**Router** (`app_router.dart`) uses `authStateProvider` to redirect unauthenticated users to `/auth/login` and authenticated users away from auth routes. Bottom navigation via `MainShell` with `NavigationBar` (4 tabs: Dashboard, Anak, Kontrol, Pengaturan).

---

### Children Management

**child_providers.dart** exports:
- `childrenListProvider` (re-exported from `growly_core`) — all children for current parent
- `selectedChildDetailProvider` — `FutureProvider.family` fetching one child by ID
- `CreateChildNotifier` — inserts into `child_profiles`, auto-sets `is_active = true`
- `UpdateChildNotifier` — updates name, phone, birth_date, avatar_url
- `DeleteChildNotifier` — soft-deletes via `UPDATE ... SET is_active = false`

**Children List** (`children_list_page.dart`) watches `childrenListProvider`, shows `AsyncValue` loading/error/data states, pull-to-refresh via `RefreshIndicator`, navigates to detail.

**Add Child** (`add_child_page.dart`) has a `ConsumerStatefulWidget` form with:
- Name `TextField`
- Birth date `showDatePicker`
- Emoji avatar grid (6 emojis to choose from)
- Optional PIN `TextField`
- On submit → `CreateChildNotifier.createChild()` → `context.go('/children')`

**Child Detail** (`child_detail_page.dart`) shows all child info in an `_InfoTile` list, edit mode toggle, and a delete confirmation dialog that calls `DeleteChildNotifier`.

---

### Dashboard with Realtime

**dashboard_providers.dart** exports:
- `todayScreenTimeProvider(childId)` — sums `screen_time_records.total_minutes` for today
- `learningStatsProvider(childId)` — counts sessions and completed lessons
- `dashboardStatsProvider` — aggregates across all children (total screen time, sessions, badges, child count)
- `riskIndicatorsProvider` — rule-based: if screen time > 120 min AND learning < 30 min → shows orange risk card
- `weeklyScreenTimeProvider(childId)` — last 7 days of screen time (for charts)

**Dashboard Page** (`dashboard_page.dart`):
- In `initState`: sets up Supabase Realtime channel `dashboard-parent-{userId}` subscribing to `INSERT` events on `screen_time_records` and `learning_sessions`. On any insert → `ref.invalidate(dashboardStatsProvider)` for instant UI refresh
- Shows 4 stat cards: Screen Time, Sesi Belajar, Badges, Anak
- Shows risk warning cards from `riskIndicatorsProvider`
- Shows child profile cards with today's screen time
- Shows AI Insights placeholder card

---

### Parental Control

**policy_providers.dart** exports:
- `appRestrictionsProvider(childId)` — fetches from `app_restrictions` table
- `AppRestrictionsNotifier` — CRUD for app restrictions (is_allowed, time_limit, schedule_limits JSONB)
- `schedulesProvider(childId)` — fetches from `schedules` table
- `SchedulesNotifier` — CRUD for schedules (mode, day_of_week, start/end time, is_enabled)
- `screenTimeLimitProvider(childId)` — reads `daily_limit` from first restriction's schedule JSONB
- `schoolModeSchedulesProvider(childId)` — filtered to `mode = 'school'`

**Parental Control Page** (`parental_control_page.dart`) — child selector dropdown at top (auto-selects first child), 5 tiles:
1. **Batas Waktu Layar** → `/parental-control/screen-time/:childId`
2. **Kunci Aplikasi** → `/parental-control/app-lock/:childId`
3. **Mode Sekolah** → `/parental-control/school-mode/:childId`
4. **Mode Aman** → `/parental-control/safe-mode/:childId`
5. **Lokasi & Perangkat** → `/parental-control/location/:childId`

**Screen Time Page** (`screen_time_page.dart`): Slider 30–240 min with enable/disable toggle, today's usage display (red if over limit), weekly bar chart via `fl_chart`.

**App Lock Page** (`app_lock_page.dart`): ListView of restrictions with toggle switches, FAB opens bottom sheet to add new app restriction (app name + is_allowed toggle).

**School Mode Page** (`school_mode_page.dart`): ListView of schedules filtered to `mode = 'school'`, FAB opens day picker + start/end time pickers bottom sheet.

**Safe Mode Page** (`safe_mode_page.dart`): Toggle + whitelist chip grid (placeholder).

**Location Page** (`location_page.dart`): Placeholder explaining location tracking requires device permissions.

---

### Settings

**settings_providers.dart** exports:
- `parentProfileProvider` — fetches from `parent_profiles` by current auth UID
- `UpdateParentProfileNotifier` — updates name, phone, avatar_url, and `settings.pin_enabled`

**Settings Page** (`settings_page.dart`):
- Profile card with circle avatar (first letter of name), edit mode (name + phone TextFields)
- Subscription status (placeholder "Free Plan")
- PIN lock `SwitchListTile` (writes `settings.pin_enabled` to `parent_profiles`)
- Notifications, Help, Privacy ListTiles (placeholders)
- Sign out `ListTile` → `AlertDialog` confirmation → `Supabase.instance.client.auth.signOut()`

---

## Child App — Feature Walkthrough

### Launcher with PIN Gate

**launcher_providers.dart** exports:
- `currentChildProvider` — `FutureProvider<ChildProfile?>` (returns `null` until PIN verified)
- `launcherRestrictionsProvider` — whitelisted apps from `app_restrictions`
- `screenTimeRemainingProvider` — daily limit minus used minutes from `screen_time_records`, capped at 0
- `activeScheduleProvider` — current active schedule (today's day + time window check)
- All repository providers (`appRestrictionRepositoryProvider`, etc.)

**Launcher Page** (`child_launcher_page.dart`):
- `_PinGate` stateful widget: PIN `TextField` → queries `child_profiles.pin` → on match calls `onVerified(childId)` which triggers `ref.invalidate(currentChildProvider)`
- `_LauncherContent`: watches `screenTimeRemainingProvider` and `activeScheduleProvider`
  - Grid of 4 cards: Belajar, Tanya AI, Hadiah, Bermain
  - **Bermain** is blocked if `activeSchedule.mode == 'school'` or `sleep` (shows `SnackBar`)
- Bottom status bar: color-coded screen time (green > 30 min, orange 10–30 min, red ≤ 10 min) + status badge ("OK" / "Hampir habis" / "Habis!" / "Tutup")

---

### AI Tutor

**ai_tutor_providers.dart** exports:
- `ChatMessage` model with id, content, isAI, timestamp, mode
- `AiTutorState` with sessionId, messages list, isLoading
- `AiTutorNotifier extends AsyncNotifier<AiTutorState>`:
  - `_dio` for HTTP calls
  - `sendMessage(text, mode)` — reads child from `currentChildProvider`, adds user message to state, calls `ai-tutor` edge function with `{childId, question, mode}`, adds AI response, handles `DioException` with friendly fallback
  - `clearMessages()` — resets state
- `aiSessionHistoryProvider` — last 20 sessions from `ai_tutor_sessions` table

**AI Tutor Page** (`ai_tutor_page.dart`):
- `ConsumerStatefulWidget` with `TextEditingController` and `ScrollController`
- Hint banner at top: "Aku akan memberi petunjuk, bukan langsung jawab ya!"
- `ListView.builder` of `_ChatBubble` widgets (AI bubbles left, user bubbles right)
- Typing indicator with animated dots while `isLoading`
- Send button disabled while loading
- `onSubmitted` on TextField triggers `_send()`

---

### Learning Hub

**learning_providers.dart** exports:
- `subjectsProvider` — static list of 4 subjects (math, reading, science, creative)
- `subjectProgressProvider` — completed/total ratio from `learning_progress`
- `LearningSessionNotifier` — `startSession()` on enter, `endSession()` on leave (tracks duration + topics)
- `learningSessionProvider` — wraps the notifier

**Subject Detail Page** (`subject_detail_page.dart`): Color-coded header card, list of 3 lesson cards (intro, practice, challenge) each navigating to `/learning/subject/:id/lesson/:lessonId`.

**Lesson Page** (`lesson_page.dart`): Step-by-step with progress dots. Calls `startSession()` in `initState`, `endSession()` in `dispose()`. Next button advances steps, last step shows "Selesai!" and navigates back.

---

### Rewards

**rewards_providers.dart** exports:
- `badgesProvider` — from `badges` table, filtered to current child
- `rewardSystemProvider` — from `reward_systems` table (currentStreak, totalStars)
- `allBadgesCatalogProvider` — static catalog for locked badge display
- `badgeRepositoryProvider`

**Rewards Page** (`rewards_page.dart`):
- `ref.listen(badgesProvider)` — when badge count increases → shows `_showCelebration()` dialog
- Streak card (orange) + Stars card (amber)
- Badge grid: unlocked badges shown full opacity, locked shown `Opacity(0.4)` with grey tint

---

## Backend Edge Functions

### `daily-report/index.ts`

Runs nightly via pg_cron (or can be triggered manually). For each active child:
1. Sums `learning_sessions.duration_minutes` for yesterday
2. Sums `screen_time_records.total_minutes` for yesterday
3. Counts sessions
4. Gets `current_streak` from `reward_systems`
5. Generates rule-based `ai_insight` ("...sudah belajar 45 menit. Hebat!" / "Ayo mulai hari ini!" etc.)
6. Bulk inserts into `daily_reports` table

### `policy-sync/index.ts`

Accepts `{childId}` POST body, returns:
- `restrictions` — all rows from `app_restrictions` for that child
- `schedules` — enabled schedules for that child
- `settings` — child profile settings (safe mode, etc.)
- `syncedAt` — timestamp

Used by child app for initial load and offline policy caching.

---

## Admin Web — Pages

| Page | What it does |
|------|-------------|
| Dashboard | Metrics cards, recent activity, quick links |
| Users | Paginated parent user list with search |
| Children | Per-parent child profiles with age groups |
| AI Moderation | Flagged AI tutor messages for review |
| Screen Time | 7-day avg, by age group chart (Recharts), top apps |
| Learning | Completion rate per subject, session stats |
| Content | Placeholder — connects to `courses` table when added |
| Audit Logs | Timestamped admin action log |

---

## Key Technical Patterns

### Riverpod 2.x AsyncNotifier Pattern
```dart
class XNotifier extends AsyncNotifier<X> {
  @override
  Future<X> build() async {
    // one-time setup (optional)
    return await super.build();
  }
  Future<void> doThing() async { ... }
}
final xProvider = AsyncNotifierProvider<XNotifier, X>(() => XNotifier());
```

### Supabase Realtime
```dart
Supabase.instance.client
  .channel('name-${userId}')
  .onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'table_name',
    callback: (payload) => ref.invalidate(provider),
  )
  .subscribe();
```

### Soft Delete
```dart
await client.from('child_profiles').update({'is_active': false}).eq('id', id);
```

### Repository Pattern
```dart
// Supabase query returns PostgrestList directly (no .data/.error)
final List<Map<String, dynamic>> rows = await client.from('table').select(...);
// Use try/catch for error handling
```

### GoRouter Nested Routes
```dart
GoRoute(
  path: '/parent',
  builder: ...,
  routes: [
    GoRoute(path: 'child/:childId', builder: ...),
  ],
)
```

---

## Verification Checklist

- [ ] Create test parent account, verify profile in `parent_profiles`
- [ ] Add a child, verify row in `child_profiles`
- [ ] Insert a `screen_time_record` via SQL editor, verify dashboard updates within 3s (realtime)
- [ ] Test PIN gate on child launcher — verify correct child loads
- [ ] Send a message via child AI tutor, verify response from `ai-tutor` edge function
- [ ] Complete a lesson, verify `learning_sessions` row created
- [ ] Check a badge earned, verify celebration dialog appears
- [ ] Run `supabase functions invoke daily-report`, verify `daily_reports` rows created
- [ ] Run `supabase functions invoke policy-sync` with a child ID, verify JSON response
