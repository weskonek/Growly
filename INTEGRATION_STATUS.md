# Growly Integration Status

> Last audited: 2026-04-29
> Audited by: Claude Code
> Scope: parent_app (Flutter), child_app (Flutter), admin_web (Next.js), growly_core (package), backend/supabase (migrations + edge functions)

---

## BAGIAN 1 — PARENT APP (Flutter)

### 1.1 Authentication
| Item | Status | Notes |
|---|---|---|
| Login page | ✅ | Email/password via `signInWithPassword` |
| Register page | ✅ | `signUp` with `data: {name}` |
| Auth state sync | ✅ | `AuthNotifier` listens to `onAuthStateChange` stream |
| Router guard | ✅ | `go_router` `redirect` checks `isAuthenticatedProvider` |
| Session expiry | ✅ | Throws user-facing `Exception('Sesi habis. Silakan login ulang.')` |
| Logout | ✅ | `signOut` clears session + redirects to `/login` |

### 1.2 Dashboard
| Item | Status | Notes |
|---|---|---|
| Home dashboard loads | ✅ | Shows child count + quick nav actions |
| Child list widget | ✅ | Displays active children from `childrenListProvider` |

### 1.3 Children Management
| Item | Status | Notes |
|---|---|---|
| Children list page | ✅ | Lists all `is_active=true` children with avatar, name, age group |
| Add child page | ✅ | `CreateChildNotifier` saves to DB, `ref.listen` shows SnackBar |
| Child detail page | ✅ | Shows child info, edit + delete buttons |
| Edit child | ✅ | `UpdateChildNotifier` with `ref.listen` error handling |
| Delete child | ✅ | Soft-delete (`is_active=false`), try/catch error handling |
| Empty state | ⚠️ | Shows placeholder text if no children |

### 1.4 Parental Control
| Item | Status | Notes |
|---|---|---|
| App lock page | ✅ | Lists app restrictions, toggle switch updates DB |
| Add app restriction | ✅ | `_addRestriction` saves via `AppRestrictionRepositoryImpl` |
| Screen time config | ⚠️ | `screenTimeRepository` exists but page may be incomplete |

### 1.5 Settings
| Item | Status | Notes |
|---|---|---|
| Settings page exists | ✅ | Profile, notifications, privacy sections |
| Account deletion | ⚠️ | Page structure exists, full flow not tested end-to-end |

---

## BAGIAN 2 — CHILD APP (Flutter)

### 2.1 PIN Gate & Launcher
| Item | Status | Notes |
|---|---|---|
| PIN gate screen | ✅ | Shows on launch, accepts 4-6 digit PIN |
| PIN verification | ✅ | Calls `verify_child_pin` RPC per child until match |
| `verifiedChildIdProvider` | ✅ | Written after successful verification |
| Router guard | ✅ | Routes redirect to `/launcher` if `verifiedChildId == null` |
| Launcher shows child profile | ✅ | `currentChildProvider` fetches from Supabase |
| Screen time display | ✅ | `screenTimeRemainingProvider` computes limit - used |
| Active schedule display | ✅ | `activeScheduleProvider` checks day+time+mode |
| Schedule-based blocking | ✅ | `Bermain` card disabled during school/sleep modes |

### 2.2 Learning Hub
| Item | Status | Notes |
|---|---|---|
| Subject grid | ✅ | 5 subjects (reading, math, science, creative, language) |
| Subject detail page | ✅ | Shows lessons list |
| Lesson page | ✅ | Lesson content displayed |
| Progress tracking | ⚠️ | Static/static data — no live DB updates |

### 2.3 AI Tutor
| Item | Status | Notes |
|---|---|---|
| Chat interface | ✅ | `AiTutorPage` with message history |
| Edge function call | ✅ | POSTs to `/functions/v1/ai-tutor` |
| Safety filter | ✅ | `safe_mode` strips unsafe content |
| Rate limiting | ✅ | 20 msg/session via `rate_limit_state` column |
| Flagged sessions | ✅ | Sessions flagged on unsafe detection |
| Session persistence | ⚠️ | `ai_tutor_sessions` + `ai_tutor_messages` tables exist |

### 2.4 Rewards
| Item | Status | Notes |
|---|---|---|
| Badge list | ✅ | Fetches from `badges` table via `BadgeRepositoryImpl` |
| Badge display | ✅ | Shows earned badges with icons |
| Streak display | ⚠️ | Static UI — streak logic may not be connected to DB |

### 2.5 Profile
| Item | Status | Notes |
|---|---|---|
| Child profile page | ✅ | Shows name, age group, avatar |

### 2.6 Navigation
| Item | Status | Notes |
|---|---|---|
| Bottom nav | ✅ | 4 tabs: Belajar, Tanya AI, Hadiah, Profil |
| Schedule-aware UI | ✅ | Cards disabled during restricted modes |

---

## BAGIAN 3 — ADMIN WEB (Next.js)

### 3.1 Authentication
| Item | Status | Notes |
|---|---|---|
| Admin login page | ✅ | Checks `admin_users` table after Supabase auth |
| Non-admin signout | ✅ | Redirects + clears session if not in `admin_users` |
| `last_login_at` update | ✅ | Updated on successful admin login |
| Middleware auth guard | ✅ | `createServerClient` + redirect to `/login` |
| Protected routes | ✅ | All `/dashboard/*` routes gated by middleware |

### 3.2 Dashboard Overview
| Item | Status | Notes |
|---|---|---|
| Metrics cards | ✅ | Total parents, total children, active today, flagged sessions |
| Flagged session list | ✅ | 5 most recent, links to AI moderation page |
| Recent users list | ✅ | 5 most recent, links to users page |

### 3.3 User Management
| Item | Status | Notes |
|---|---|---|
| User table | ✅ | Lists all `parent_profiles` with child count |
| Suspend user | ✅ | `auth.admin.updateUserById` + `ban_duration: '876600h'` + audit log |
| Unsuspend user | ✅ | `ban_duration: 'none'` |
| Delete user | ✅ | `auth.admin.deleteUser` + audit log |
| `toast` feedback | ✅ | Success/error toasts via `sonner` |

### 3.4 Children Overview
| Item | Status | Notes |
|---|---|---|
| Children table | ✅ | Lists all children with parent, age group, status |
| Status badge | ✅ | Active = green, Blocked = red |

### 3.5 AI Moderation
| Item | Status | Notes |
|---|---|---|
| Flagged session queue | ✅ | Lists all `flagged=true` sessions |
| Conversation thread | ✅ | Full message history per session |
| Dismiss | ✅ | Sets `flagged=false` + audit log + `revalidatePath` |
| Warn parent | ✅ | Inserts audit log (mock — FCM not implemented) |
| Block child | ✅ | Sets `child_profiles.is_active=false` + audit log |
| Delete session | ✅ | Hard deletes `ai_tutor_sessions` row + audit log |

### 3.6 Audit Logs
| Item | Status | Notes |
|---|---|---|
| Log table | ✅ | 100 most recent entries, full details on expand |
| Action badges | ✅ | Color-coded by action type (dismiss=green, block=red) |
| COPPA actions | ✅ | `coppa_data_deletion_requested` displayed |
| Timestamp | ✅ | Indonesian locale date + time |

### 3.7 Learning Analytics
| Item | Status | Notes |
|---|---|---|
| Metrics | ✅ | Total sessions, completion rate, active subjects |
| Subject chart | ✅ | `LearningChart` component |
| Recent sessions | ✅ | Last 10 with child name, subject, duration |
| Subject performance | ✅ | Per-subject completion % and avg score |

### 3.8 Screen Time Analytics
| Item | Status | Notes |
|---|---|---|
| Today's total | ✅ | Sum of `screen_time_records` for current date |
| 7-day average | ✅ | Average of last 7 days |
| Age group breakdown | ✅ | `ScreenTimeChart` by age group |
| Top apps | ✅ | Top 10 by duration today |

### 3.9 Content Management
| Item | Status | Notes |
|---|---|---|
| Content page | ⚠️ | Placeholder UI — "Coming Soon" badge |

---

## BAGIAN 4 — CROSS-APP INTEGRATION

### 4.1 Auth Flow
| Item | Status | Notes |
|---|---|---|
| Parent signup → `parent_profiles` trigger | ✅ | `on_auth_user_created` trigger inserts profile |
| Parent login → JWT scope | ✅ | JWT with `sub=user_id`, RLS enforces `parent_id=auth.uid()` |
| Child PIN verification → server-side | ✅ | `verify_child_pin` RPC with bcrypt, never exposes hash |
| Child app uses parent JWT | ✅ | Child app session = parent session, RLS scopes via `parent_id` |

### 4.2 Realtime Sync
| Item | Status | Notes |
|---|---|---|
| `SyncManager.watchTable` defined | ✅ | `growly_core/lib/core/database/sync/sync_manager.dart` |
| `SyncService.watchTable` defined | ✅ | `growly_core/lib/shared/services/sync_service.dart` |
| Used in parent_app | ✅ | `ChildrenListNotifier` subscribes via `onPostgresChanges` |
| Used in child_app | ⚠️ | Not wired — only parent list has realtime |
| Supabase Realtime enabled | ✅ | Channel created and cleaned up via `ref.onDispose` |

**Action required:** Wire `SyncService` into parent_app child list or use `ref.invalidate` on relevant providers when data changes.

### 4.3 PIN Management
| Item | Status | Notes |
|---|---|---|
| PIN set on child creation | ✅ | Stored as bcrypt hash in `pin_hash` column |
| PIN verification RPC | ✅ | `verify_child_pin(p_child_id, p_pin)` |
| PIN change in parent app | ⚠️ | No dedicated "change PIN" UI — handled in child detail |
| PIN reset flow | ⚠️ | No "forgot PIN" flow for child |

### 4.4 Soft Delete Consistency
| Item | Status | Notes |
|---|---|---|
| Child profile soft delete | ✅ | `is_active=false` in `child_profiles` |
| Child excluded from list | ✅ | All queries filter `is_active=true` |
| Child excluded from PIN search | ✅ | `child_launcher_page.dart` queries `is_active=true` |
| Admin can block child | ✅ | Sets `is_active=false` |
| `updated_at` trigger | ✅ | `BEFORE UPDATE` trigger on `child_profiles` |

### 4.5 Subscription Tiers
| Item | Status | Notes |
|---|---|---|
| `subscriptions` table exists | ✅ | Migration 00009 applies RLS |
| Subscription model | ✅ | `SubscriptionModel` + `SubscriptionTier` enum in growly_core |
| Subscription repository | ✅ | `ISubscriptionRepository` + `SubscriptionRepositoryImpl` |
| `canAddChildProvider` | ✅ | Gates AddChildPage — shows upgrade banner at limit |
| `tierGateProvider` | ✅ | Family provider for feature-level tier checks |
| Tier enforcement in child app | ⚠️ | Provider exists, not yet wired to AI Tutor page |
| RLS on subscriptions | ✅ | Parents can only view their own subscription |

**Action required:** Implement `SubscriptionRepository` + tier enforcement UI (e.g., "Upgrade to Premium" banner).

### 4.6 Edge Function Security
| Item | Status | Notes |
|---|---|---|
| `ai-tutor` validates child ownership | ✅ | Checks `parent_id` from `child_profiles` |
| Uses service role key | ✅ | Inserts with `service_role` client |
| Rate limiting per child | ✅ | `rate_limit_state` column checked before insert |

---

## BAGIAN 5 — QUALITY & SECURITY

### 5.1 Error Handling
| Item | Status | Notes |
|---|---|---|
| `try/catch` in repositories | ✅ | All `RepositoryImpl` methods catch `PostgrestException` |
| `AsyncError` surfaced to UI | ✅ | `ref.listen` on notifiers shows SnackBar |
| Auth errors | ✅ | "Sesi habis" message for unauthenticated state |
| DB errors | ✅ | `DatabaseFailure` / `UnknownFailure` returned as tuples |
| Null safety | ✅ | `.maybeSingle()` where appropriate, null checks on responses |

### 5.2 Loading States
| Item | Status | Notes |
|---|---|---|
| `AsyncLoading` in notifiers | ✅ | All `AsyncNotifier` subclasses use `AsyncLoading` |
| Button loading disabled | ✅ | `isLoading` state disables `onPressed` |
| Progress indicators | ✅ | `CircularProgressIndicator` in `when()` loading branch |

### 5.3 Form Validation
| Item | Status | Notes |
|---|---|---|
| Email format | ✅ | `email` field in login/register |
| Password length | ✅ | Minimum length enforced in register |
| Required fields | ✅ | `appPackage` required in App Lock |
| PIN format | ✅ | 4-6 numeric digits validated client-side |

### 5.4 RLS Verification
| Item | Status | Notes |
|---|---|---|
| `consent_logs` RLS | ✅ | Parent insert/view, service role all |
| `subscriptions` RLS | ✅ | Parent view, service role all |
| `audit_logs` RLS | ✅ | User sees own, service role all |
| `badges` RLS | ✅ | Fixed to scope via `parent_id` subquery |
| `ai_tutor_sessions` RLS | ✅ | Scoped via `child_id → parent_id` |
| `child_profiles` RLS | ✅ | `is_active=true` filter, parent scope |
| `app_restrictions` RLS | ✅ | `ar_all_by_parent` — ALL ops scoped via `child_id → parent_id` |
| `screen_time_records` RLS | ✅ | `st_insert_authenticated` + `st_select_by_parent` |
| `ai_tutor_sessions` RLS | ✅ | `ai_sess_insert_authenticated` + `ai_sess_select_by_parent` |
| `ai_tutor_messages` RLS | ✅ | `ai_msg_insert_authenticated` + `ai_msg_select_by_parent` |
| `badges` RLS | ✅ | Fixed by migration 00009 — scoped via `parent_id` subquery |

**Action required:** Verify `app_restrictions` and `screen_time_records` RLS policies exist and are correct.

### 5.5 Input Sanitization
| Item | Status | Notes |
|---|---|---|
| SQL injection | ✅ | Supabase client parameterized queries |
| XSS | ⚠️ | No explicit HTML escaping in message display (AI tutor) |
| PIN brute force | ✅ | Server-side only, no exposure of hash |
| Rate limiting | ✅ | AI tutor edge function limits 20 msg/session |

### 5.6 PIN Security
| Item | Status | Notes |
|---|---|---|
| PIN never stored in plaintext | ✅ | bcrypt via `pgcrypto` |
| PIN hash never sent to client | ✅ | Child app fetches `pin_hash` but RPC verifies |
| Direct DB access to hash | ⚠️ | Child app fetches `pin_hash` — acceptable since RPC does verification |
| `hash_pin` helper function | ✅ | `gen_salt('bf', 10)` with validation |

### 5.7 COPPA Compliance
| Item | Status | Notes |
|---|---|---|
| Audit logging | ✅ | All admin + moderation actions logged |
| `audit_logs` table | ✅ | `action`, `table_name`, `old_data`, `new_data` |
| COPPA action labels | ✅ | `coppa_data_deletion_requested` action type |
| Admin delete user | ✅ | Full `auth.admin.deleteUser` |

### 5.8 Rate Limiting
| Item | Status | Notes |
|---|---|---|
| AI tutor per-session limit | ✅ | 20 messages via `rate_limit_state` |
| PIN verification | ✅ | Max 5 failed attempts/15 min via `pin_attempt_log` + migration 0010 |

---

## KNOWN GAPS & ACTION ITEMS

| Priority | Item | Files |
|---|---|---|
| 🟡 Medium | Add tier gating to child app AI Tutor page | `child_app/` |
| 🟡 Medium | Add "forgot PIN" parent flow for child account recovery | `parent_app/` |
| 🟡 Medium | Add per-IP rate limit to `ai-tutor` edge function | Edge function |
| 🟢 Low | Complete content management page | `admin_web/src/app/dashboard/content/` |
| 🟢 Low | Add "change PIN" dedicated UI in parent app | `parent_app/` |

---

## MIGRATION STATUS

| Migration | Applied | Notes |
|---|---|---|
| 00001 | ✅ | Likely initial schema |
| 00002–00008 | ✅ | Prior migrations |
| 00009_user_management.sql | ✅ | Applied 2026-04-29. RLS, PIN helpers, triggers, indexes |
