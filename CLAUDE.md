# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Growly is an AI-powered digital growth platform for kids and teens, built as a **Flutter monorepo** managed by Melos with three apps and a Supabase backend.

```
apps/
├── parent_app/          # Flutter — Parent dashboard, child management, parental controls
├── child_app/           # Flutter — Safe launcher, learning hub, AI tutor, rewards
├── admin_web/           # Next.js 14 — Admin dashboard (users, children, AI moderation, analytics)
backend/supabase/
├── migrations/          # SQL schema, RLS policies, triggers
└── functions/           # Supabase Edge Functions (Deno/TypeScript): ai-tutor, policy-sync, daily-report
packages/
├── growly_core/         # Shared models, repository interfaces, Riverpod providers
├── growly_ui_kit/       # Shared design system
├── growly_ai_tutor/     # AI tutor logic and prompt templates
└── growly_parental_control/  # Parental control native bridges
```

## Common Commands

```bash
# Bootstrap all packages (run after clone / after adding dependencies)
melos bootstrap

# Analyze all packages
melos analyze

# Run tests on all packages
melos test

# Run tests for a single package
cd apps/parent_app && flutter test

# Format all packages
melos format

# Build parent app Android APK
melos build:android:parent

# Build child app Android APK
melos build:android:child

# Deploy Supabase Edge Functions
cd backend/supabase && supabase functions deploy

# Push local DB migration to Supabase
cd backend/supabase && supabase db push

# Run parent app
cd apps/parent_app && flutter run

# Run child app
cd apps/child_app && flutter run
```

## Architecture

### State Management: Riverpod 2.x

Providers follow these patterns:
- **AsyncNotifier** — async operations with loading/error/data states
- **FutureProvider.family** — per-key async data (e.g., `childProgressProvider(childId)`)
- **FamilyAsyncNotifier** — per-key notifier with async logic (e.g., `tierGateProvider(feature)`)
- **ref.invalidate(provider)** — used to re-fetch data (e.g., after create/update)
- **ref.listen(provider, callback)** — side effects like navigation or snackbar on state change

### Navigation: GoRouter with ShellRoute

`app_router.dart` defines all routes. `MainShell` wraps all non-auth routes with a `NavigationBar` (4 tabs: Dashboard, Anak, Kontrol, Pengaturan). Auth redirect happens in the router's `redirect` callback based on `authStateChangesProvider`.

### Shared Providers in `growly_core`

`packages/growly_core/lib/shared/providers/` holds cross-app providers:
- `subscription_provider.dart` — `subscriptionProvider`, `canAddChildProvider`, `tierGateProvider`
- `child_providers.dart` — `childrenListProvider` (with Supabase realtime subscription)
- `auth_provider.dart` — `authStateChangesProvider`, `currentUserProvider`

### Repository Pattern

Supabase queries go through repository interfaces in `growly_core`. The return type is always `(T?, Failure?)` using Dart tuples. No `.data`/`.error` on Postgrest responses — just try/catch on the async call.

### Soft Delete

Records are never hard-deleted. Tables like `child_profiles` have `is_active` (and `is_deleted`) columns. RLS policies filter out deleted records automatically.

### Supabase Realtime

Dashboard-like pages subscribe to Postgres Changes channels for live updates. E.g., in `dashboard_page.dart`:
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

## Subscription Tiers

Defined in `packages/growly_core/lib/domain/models/subscription_model.dart` as `enum SubscriptionTier`:
- `free` — childLimit=2, aiTutorEnabled=false
- `premiumFamily` — childLimit=99, unlimitedChildren=true, aiTutorEnabled=true
- `premiumAiTutor` — childLimit=2, unlimitedChildren=false, aiTutorEnabled=true
- `schoolInstitution` — childLimit=99, unlimitedChildren=true, aiTutorEnabled=true

The `canAddChildProvider` in `growly_core` compares `children.length < tier.childLimit`. Server-side enforcement uses a `check_child_limit()` trigger on `child_profiles`.

## Database Migrations

Migrations live at `backend/supabase/migrations/` with sequential names (`00001_initial_schema.sql`, etc.). Apply via `supabase db push` or the Supabase Dashboard SQL editor.

## API / Edge Functions

- `ai-tutor` — Gemini-powered tutor (hint-only pedagogy), called from child_app
- `policy-sync` — Returns app restrictions + schedules for a child to the child app
- `daily-report` — Nightly cron job generating `daily_reports` per child with AI insight
- `notifications` — FCM/APNs push notifications
- `sync-handler` — Device sync webhook

## Key File Locations

| Feature | Key Files |
|---------|-----------|
| Router | `apps/parent_app/lib/core/router/app_router.dart` |
| Subscription providers | `packages/growly_core/lib/shared/providers/subscription_provider.dart` |
| Child providers | `packages/growly_core/lib/shared/providers/child_providers.dart` |
| Add child page | `apps/parent_app/lib/features/children/presentation/pages/add_child_page.dart` |
| Children list page | `apps/parent_app/lib/features/children/presentation/pages/children_list_page.dart` |
| Create child notifier | `apps/parent_app/lib/features/children/providers/child_providers.dart` |
| Settings page | `apps/parent_app/lib/features/settings/presentation/pages/settings_page.dart` |
| Child repository | `packages/growly_core/lib/data/repositories/child_repository_impl.dart` |
| Subscription repository | `packages/growly_core/lib/data/repositories/subscription_repository_impl.dart` |
| Subscription model | `packages/growly_core/lib/domain/models/subscription_model.dart` |
| Migrations | `backend/supabase/migrations/` |

## Environment Setup

Each app needs a `.env` file (not committed):

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

## Language

All user-facing text is in Indonesian (Bahasa Indonesia). Follow this convention for all new strings.
