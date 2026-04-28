# Growly Integration Status

> Last audited: 2026-04-29 (4th pass)
> Audited by: Claude Code
> Scope: parent_app (Flutter), child_app (Flutter), admin_web (Next.js), growly_core (package), backend/supabase (migrations + edge functions)

---

## BAGIAN 1 — PARENT APP (Flutter)

### 1.1 Authentication
| Item | Status | Notes |
|---|---|---|
| Login page | ✅ | Email/password via `signInWithPassword` |
| Register page | ✅ | Trigger inserts name+email; register page only updates `phone` |
| Auth state sync | ✅ | `AuthNotifier` listens to `onAuthStateChange` stream |
| Router guard | ✅ | `go_router` `redirect` checks `isAuthenticatedProvider` |
| Session expiry | ✅ | Throws user-facing `Exception('Sesi habis. Silakan login ulang.')` |
| Router guard cold start flash | ✅ | `authState.isLoading` check prevents flash on cold start |
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
| Screen time config | ✅ | ScreenTimePage loads from DB via `getRestrictions`, persists via `saveRestriction` upsert |

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
| Lesson page | ✅ | Content loaded from `lessons` table via `getLesson()` |
| Progress tracking | ✅ | `subjectProgressProvider` counts completed lessons vs total per subject |
| Session tracking | ✅ | `startSession`/`endSession` via `Future.microtask` in dispose |
| Lesson completion rewards | ✅ | Atomic `completeLesson` RPC — streak + stars in single transaction, idempotent per lesson |

### 2.3 AI Tutor
| Item | Status | Notes |
|---|---|---|
| Chat interface | ✅ | `AiTutorPage` with message history |
| Edge function call | ✅ | POSTs to `/functions/v1/ai-tutor` |
| Safety filter | ✅ | `SafetyFilter` class properly instantiated and used in edge function |
| Rate limiting | ✅ | 20 msg/child/hour + IP-based 10 req/min in edge function |
| Tier gate enforcement | ✅ | Free-tier parents blocked with 403 + tier_blocked response |
| Flagged sessions | ✅ | Sessions flagged on unsafe detection |
| Session persistence | ⚠️ | `ai_tutor_sessions` + `ai_tutor_messages` tables exist |
| Tier gate UI | ✅ | Paywall screen shown when `aiTutorTierGateProvider` returns false |

### 2.4 Rewards
| Item | Status | Notes |
|---|---|---|
| Badge list | ✅ | Fetches from `badges` table via `BadgeRepositoryImpl` |
| Badge display | ✅ | Earned badges shown with icons; locked badges in catalog |
| Badge unlock stable ID | ✅ | Uses `BadgeType.index` (int) instead of name string |
| Celebration dialog | ✅ | Triggers on specific new badge type via `ref.invalidate(badgesProvider)` |
| `badgesProvider` reactivity | ✅ | Uses `ref.watch` — rebuilds when `currentChildProvider` changes |

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
| PIN change in parent app | ✅ | `set_child_pin` RPC with form validation in child detail page |
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
| Tier enforcement in child app | ✅ | `aiTutorTierGateProvider` checks subscription tier, shows paywall screen |
| Tier enforcement in edge function | ✅ | Free tier blocked with 403 before processing any request |
| RLS on subscriptions | ✅ | Parents can only view their own subscription |

### 4.6 Edge Function Security
| Item | Status | Notes |
|---|---|---|
| `ai-tutor` validates JWT | ✅ | `supabase.auth.getUser()` decodes Bearer token |
| `ai-tutor` validates child ownership | ✅ | Checks `parent_id` from `child_profiles` |
| `ai-tutor` enforces tier gate | ✅ | Blocks `free` tier with 403 + tier_blocked type |
| IP-based rate limiting | ✅ | In-memory 10 req/min per IP |
| Uses service role key | ✅ | Inserts with `service_role` client |
| Rate limiting per child | ✅ | Max 20 sessions/child/hour |

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
| `ai_tutor_sessions` RLS | ✅ | `ai_sess_insert_authenticated` + `ai_sess_select_by_parent` |
| `ai_tutor_messages` RLS | ✅ | `ai_msg_insert_authenticated` + `ai_msg_select_by_parent` |

### 5.5 Input Sanitization
| Item | Status | Notes |
|---|---|---|
| SQL injection | ✅ | Supabase client parameterized queries |
| XSS | ✅ | `dompurify` sanitizes AI tutor messages in admin view |
| PIN brute force | ✅ | Server-side only, no exposure of hash |
| Rate limiting | ✅ | AI tutor edge function limits 20 msg/session |

### 5.6 PIN Security
| Item | Status | Notes |
|---|---|---|
| PIN never stored in plaintext | ✅ | bcrypt via `pgcrypto` |
| PIN hash never sent to client | ✅ | Child app only selects `id, name` — `pin_hash` never fetched |
| PIN plaintext fallback | ✅ | Removed — verification always via `verify_child_pin` RPC |
| `hash_pin` helper function | ✅ | `gen_salt('bf', 10)` with validation |
| Router reactive redirect | ✅ | `childRouterProvider` uses `ProviderContainer` + `_VerifiedIdNotifier` (ChangeNotifier) |

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
| Per-IP rate limit AI tutor | ✅ | 10 req/min via in-memory `ipRequestLog` in ai-tutor edge function |
| AI tutor per-child limit | ✅ | 20 sessions/child/hour via `ai_tutor_sessions` count in edge function |
| PIN verification rate limit | ✅ | Max 5 failed attempts/15 min via `pin_attempt_log` + migration 0010 |

---

## KNOWN GAPS & ACTION ITEMS

| Priority | Item | Files | Status |
|---|---|---|---|
| 🟢 Low | Complete content management page | `admin_web/src/app/dashboard/content/` | Pending |
| 🟡 Medium | DB-level child limit enforcement | `child_profiles` trigger | Pre-launch |
| 🟡 Medium | Reward streak reset on day boundary | `complete_lesson_reward` RPC | Pre-launch |

---

## MIGRATION STATUS

| Migration | Applied | Notes |
|---|---|---|
| 00001 | ✅ | Likely initial schema |
| 00002–00008 | ✅ | Prior migrations |
| 00009_user_management.sql | ✅ | RLS, PIN helpers, triggers, indexes |
| 0010_pin_rate_limit.sql | ✅ | PIN brute-force rate limiting, `pin_attempt_log` table |
| 0011_learning_lessons.sql | ✅ | `lessons` table with seeded content per subject |
| 0012_atomic_reward_update.sql | ✅ | `complete_lesson_reward` RPC for atomic streak+stars |
