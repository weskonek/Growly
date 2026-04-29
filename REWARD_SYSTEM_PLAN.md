# Growly Reward System — Full Implementation Plan

## Context

The badge/reward system in Growly is structurally ready but disconnected from actual triggers. Badge earning logic needs to be implemented, plus several missing layers (Daily Quest, Streak Shield, Growly Store, Celebration Cards, Family Reward Box, Daily Wrap notifications).

**Current state:**
- `BadgeType` enum (8 types), `Badge` model, `RewardSystem` model — ✅ exists
- `IBadgeRepository` + `BadgeRepositoryImpl` — ✅ exists
- `completeLesson()` calls RPC `complete_lesson_reward` — ✅ exists (RPC may be deployed)
- `rewards_page.dart` — ✅ exists (has catalog bug: `unlockedIds.contains(badge['name'])` uses String against int set)
- Dashboard reads total badge count — ✅ read-only
- Parent notification on badge earned — ❌ missing
- Badge trigger logic — ❌ missing (no `awardBadge()` calls)
- Streak Shield — ❌ missing
- Daily Quest Engine — ❌ missing
- Growly Store — ❌ missing
- Celebration Card (parent) — ❌ missing
- Daily Wrap Notification Edge Function — ❌ missing
- Reward Box — ❌ missing

---

## Phase 1: Catalog Bug Fix + Tiered Badge Definitions

### 1.1 Fix `rewards_page.dart` catalog and unlock check

**File:** `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart`

The catalog uses `badge['name']` (String) but `unlockedIds` is a `Set<int>`. Fix the type matching and align catalog with `BadgeType` enum (8 types).

```dart
// Before (broken):
final unlocked = unlockedIds.contains(badge['name']); // String vs int

// After (fixed):
final unlocked = unlockedIds.contains(badge['type'] as int);

// Catalog aligned with BadgeType index:
[
  {'emoji': '🔥', 'name': 'Streak',       'type': 0},
  {'emoji': '🎓', 'name': 'Master Topik',  'type': 1},
  {'emoji': '✅', 'name': 'Target Harian', 'type': 2},
  {'emoji': '📅', 'name': 'Target Mingguan','type': 3},
  {'emoji': '⏱️', 'name': 'Jam Belajar',   'type': 4},
  {'emoji': '⭐', 'name': 'Skor Sempurna', 'type': 5},
  {'emoji': '📈', 'name': 'Konsisten',     'type': 6},
  {'emoji': '🗺️', 'name': 'Penjelajah',   'type': 7},
]
```

Also fix `BadgeType` → `BadgeTypeX` extension name conflict and update `BadgeType.displayName` to match Indonesian labels.

---

## Phase 2: Badge Trigger Engine

### 2.1 Create `badge_trigger_service.dart`

**New file:** `packages/growly_core/lib/domain/services/badge_trigger_service.dart`

Centralized service that evaluates badge conditions after every learning event. Designed to be called from child app after `completeLesson()`.

```dart
class BadgeTriggerResult {
  final List<Badge> newlyEarned;
  final String? celebrationMessage;
}

class BadgeTriggerService {
  const BadgeTriggerService();

  Future<BadgeTriggerResult> evaluate({
    required String childId,
    required int sessionStarsEarned,
    required int currentStreak,
    required int totalSessionsToday,
    required bool completedAllLessonsInTopic,
    required bool allAnswersCorrect,
    required int topicsExplored,
    required int totalHoursThisWeek,
  }) async {
    final earned = <Badge>[];
    // Check each badge type condition
    if (currentStreak >= 3 && !hasStreakBadge(childId, 3)) {
      earned.add(_streakBadge(childId, 3));
    }
    if (currentStreak >= 7 && !hasStreakBadge(childId, 7)) {
      earned.add(_streakBadge(childId, 7));
    }
    if (currentStreak >= 30 && !hasStreakBadge(childId, 30)) {
      earned.add(_streakBadge(childId, 30));
    }
    if (completedAllLessonsInTopic && !hasTopicMasterBadge(childId)) {
      earned.add(_topicMasterBadge(childId));
    }
    if (totalSessionsToday >= 1 && !hasDailyGoalBadge(childId)) {
      earned.add(_dailyGoalBadge(childId));
    }
    if (allAnswersCorrect) {
      earned.add(_perfectScoreBadge(childId));
    }
    if (topicsExplored >= 3) {
      earned.add(_explorerBadge(childId));
    }
    return BadgeTriggerResult(
      newlyEarned: earned,
      celebrationMessage: _buildCelebrationMessage(earned),
    );
  }
}
```

### 2.2 Connect trigger to `completeLesson()` in child app

**File:** `apps/child_app/lib/features/learning/presentation/pages/lesson_page.dart` (or wherever `_completeLesson` lives)

After `repo.completeLesson()` succeeds, call `BadgeTriggerService().evaluate(...)` and show celebration if new badges earned.

---

## Phase 3: Streak Shield

### 3.1 Add `streakShields` field to `RewardSystem` model

**File:** `packages/growly_core/lib/domain/models/badge.dart`

```dart
class RewardSystem {
  final String childId;
  final int currentStreak;
  final int longestStreak;
  final int totalStars;
  final List<String> unlockedBadges;
  final DateTime? lastActivityAt;
  final int streakShields; // NEW: 0-3 shields accumulated

  const RewardSystem({
    ...
    this.streakShields = 0,
  });

  // fromJson, toJson, copyWith updated accordingly
}
```

### 3.2 Add `streak_shields` column to DB

**New migration:** `backend/supabase/migrations/0019_streak_shield.sql`

```sql
ALTER TABLE reward_systems ADD COLUMN IF NOT EXISTS streak_shields INTEGER DEFAULT 0;
COMMENT ON COLUMN reward_systems.streak_shields IS 'Streak protection shields (0-3). One shield earned every 7-day streak. Auto-consumed when child misses a day.';
```

### 3.3 Update `BadgeRepositoryImpl` to handle shields

Add methods:
- `consumeStreakShield(childId)` — called when a day is missed
- `awardStreakShield(childId)` — called when 7-day streak milestone hit

### 3.4 Streak shield UI in child app

**File:** `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart`

Show shield count as "🛡️ × N" below streak card. When child skips a day and shield protects streak, show a gentle "🛡️ Streak Dilindungi!" message.

---

## Phase 4: Daily Quest Engine

### 4.1 Create `daily_quest_engine.dart`

**New file:** `packages/growly_core/lib/domain/services/daily_quest_engine.dart`

```dart
enum QuestType { completeSession, answerQuestions, reachStreak, exploreTopic }

class DailyQuest {
  final String id;
  final QuestType type;
  final String title;
  final String description;
  final int starsReward;
  final bool isCompleted;
  final Map<String, dynamic> metadata;
}

class DailyQuestEngine {
  List<DailyQuest> generateQuests({
    required int totalSessionsToday,
    required int questionsAnsweredToday,
    required int minutesLearnedToday,
    required int topicsExploredTotal,
  }) {
    return [
      DailyQuest(
        id: 'daily_session',
        type: QuestType.completeSession,
        title: 'Selesaikan 1 Sesi Belajar',
        description: 'Selesaikan satu sesi belajar hari ini',
        starsReward: 2,
        isCompleted: totalSessionsToday >= 1,
      ),
      DailyQuest(
        id: 'daily_questions',
        type: QuestType.answerQuestions,
        title: 'Jawab 5 Soal dengan Benar',
        description: 'Jawab 5 soal matematika dengan benar',
        starsReward: 3,
        isCompleted: questionsAnsweredToday >= 5,
      ),
      DailyQuest(
        id: 'daily_explorer',
        type: QuestType.exploreTopic,
        title: 'Coba Topik Baru',
        description: 'Mulai belajar topik yang belum pernah dicoba',
        starsReward: 2,
        isCompleted: topicsExploredTotal >= 3,
      ),
    ];
  }
}
```

### 4.2 Create `daily_quests` table migration

**New file:** `backend/supabase/migrations/0020_daily_quests.sql`

```sql
CREATE TABLE IF NOT EXISTS daily_quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
  quest_date DATE NOT NULL DEFAULT CURRENT_DATE,
  quest_id TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  stars_earned INTEGER DEFAULT 0,
  UNIQUE (child_id, quest_date, quest_id)
);
-- RLS: parent can read, child can read/update own quests
```

### 4.3 Create `quest_progress` table migration

**New file:** `backend/supabase/migrations/0020_daily_quests.sql` (same file)

Also create `quest_definitions` lookup table for quest metadata:
```sql
CREATE TABLE IF NOT EXISTS quest_definitions (
  quest_id TEXT PRIMARY KEY,
  quest_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  stars_reward INTEGER DEFAULT 1,
  target_value INTEGER DEFAULT 1,
  icon_emoji TEXT NOT NULL
);
```

Seed the quest definitions table with 6 quests.

---

## Phase 5: Growly Store (Stars Economy)

### 5.1 Create `store_items` model

**New file:** `packages/growly_core/lib/domain/models/store_item.dart`

```dart
enum StoreCategory { avatar, profile, badge, premium }

class StoreItem {
  final String id;
  final String name;
  final String description;
  final int priceStars;
  final StoreCategory category;
  final String emoji;
  final String? imageUrl;
  final bool isOwned;
}
```

### 5.2 Create `store_items` table migration

**New file:** `backend/supabase/migrations/0021_growly_store.sql`

```sql
CREATE TABLE IF NOT EXISTS store_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price_stars INTEGER NOT NULL,
  category TEXT NOT NULL, -- avatar, profile, badge, premium
  emoji TEXT,
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS child_store_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
  item_id UUID NOT NULL REFERENCES store_items(id),
  purchased_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (child_id, item_id)
);
```

Seed with ~15 cosmetic items across 4 categories.

### 5.3 Create child app Store page

**New file:** `apps/child_app/lib/features/store/presentation/pages/growly_store_page.dart`

- Tabs: Avatar | Profil | Premium
- Grid of items with price tags
- "Tukar" button — checks if child has enough stars
- On purchase: deduct stars, insert into `child_store_purchases`, show purchase animation

### 5.4 Add route to child app router

**File:** `apps/child_app/lib/core/router/app_router.dart`

Add `/store` route. Add store icon to launcher/home screen.

---

## Phase 6: Parent Celebration Card

### 6.1 Create `celebration_card.dart`

**New file:** `apps/parent_app/lib/features/children/presentation/widgets/celebration_card.dart`

```dart
class CelebrationCard extends StatelessWidget {
  final String childName;
  final Badge badge;
  final VoidCallback onDismiss;
  final VoidCallback onMarkCelebrated;

  // Shows Gold badge celebration with family celebration tips
  // Two buttons: "Tandai Sudah Dirayakan" (dismiss) and share options
}
```

### 6.2 Wire into parent notification system

**File:** `apps/parent_app/lib/features/notifications/presentation/pages/notifications_page.dart`

When a notification has `type: 'achievement'` and badge metadata, render `CelebrationCard` instead of regular `_NotificationTile`.

### 6.3 Trigger notification when badge earned

**File:** `backend/supabase/functions/notifications/index.ts`

Add `badge_earned` event handler. When `awardBadge()` is called (via RPC or direct insert), trigger a notification for the parent with type `achievement` and badge metadata. The edge function should be invoked after every badge insert.

---

## Phase 7: Daily Wrap Notification (Edge Function)

### 7.1 Create `daily-wrapup` Edge Function

**New file:** `backend/supabase/functions/daily-wrapup/index.ts`

Scheduled function (cron every day at 12:00 UTC / 19:00 WIB):

```typescript
// For each parent with active children:
1. Fetch today's stats: stars earned, quests completed, streak
2. Fetch AI-generated daily summary from learning data
3. Insert notification into notifications table for parent
4. Format in Indonesian, warm tone, emoji-rich
```

### 7.2 Supabase cron config

Add to `supabase/config.toml` or `supabase/functions.toml`:
```yaml
functions:
  daily-wrapup:
    schedule: "0 12 * * *"  # 12:00 UTC = 19:00 WIB
```

---

## Phase 8: Family Reward Box (Parent Feature)

### 8.1 Create `reward_box` model

**New file:** `packages/growly_core/lib/domain/models/reward_box.dart`

```dart
class RewardBox {
  final String id;
  final String parentId;
  final String? childId; // null = applies to all children
  final int targetStars;
  final String rewardDescription;
  final DateTime expiresAt;
  final bool isClaimed;
  final DateTime? claimedAt;
}
```

### 8.2 Create `reward_boxes` table migration

**New file:** `backend/supabase/migrations/0022_reward_box.sql`

```sql
CREATE TABLE IF NOT EXISTS reward_boxes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES parent_profiles(id) ON DELETE CASCADE,
  child_id UUID REFERENCES child_profiles(id) ON DELETE CASCADE,
  target_stars INTEGER NOT NULL,
  reward_description TEXT NOT NULL,
  expires_at DATE NOT NULL,
  is_claimed BOOLEAN DEFAULT FALSE,
  claimed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- RLS: parent full access, service role for cross-child
```

### 8.3 Create Reward Box UI in parent app

**New file:** `apps/parent_app/lib/features/family_rewards/presentation/pages/reward_box_page.dart`

- List of reward boxes (active, claimed, expired)
- "Tambah Reward Box" button → bottom sheet with target stars + description
- Card shows progress bar: stars collected / target stars
- When claimed: "🎉 Hadiah Di berikan!" state

### 8.4 Connect to child progress

`rewardSystemProvider` in parent app checks `reward_boxes` for active rewards and shows progress in child detail page's Activity tab.

---

## File Manifest

| Phase | File | Action |
|-------|------|--------|
| 1.1 | `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart` | Fix catalog + unlock check |
| 2.1 | `packages/growly_core/lib/domain/services/badge_trigger_service.dart` | New — badge evaluation engine |
| 2.2 | `apps/child_app/lib/features/learning/presentation/pages/lesson_page.dart` | Call trigger after `completeLesson()` |
| 3.1 | `packages/growly_core/lib/domain/models/badge.dart` | Add `streakShields` field |
| 3.2 | `backend/supabase/migrations/0019_streak_shield.sql` | New — add `streak_shields` column |
| 3.3 | `packages/growly_core/lib/data/repositories/badge_repository_impl.dart` | Add shield methods |
| 3.4 | `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart` | Show shield count UI |
| 4.1 | `packages/growly_core/lib/domain/services/daily_quest_engine.dart` | New — quest generation |
| 4.2 | `backend/supabase/migrations/0020_daily_quests.sql` | New — quests + quest_definitions tables |
| 5.1 | `packages/growly_core/lib/domain/models/store_item.dart` | New — store item model |
| 5.2 | `backend/supabase/migrations/0021_growly_store.sql` | New — store + purchases tables |
| 5.3 | `apps/child_app/lib/features/store/presentation/pages/growly_store_page.dart` | New — store page |
| 5.4 | `apps/child_app/lib/core/router/app_router.dart` | Add `/store` route |
| 6.1 | `apps/parent_app/lib/features/children/presentation/widgets/celebration_card.dart` | New — celebration widget |
| 6.2 | `apps/parent_app/lib/features/notifications/presentation/pages/notifications_page.dart` | Render celebration card |
| 6.3 | `backend/supabase/functions/notifications/index.ts` | Handle badge_earned events |
| 7.1 | `backend/supabase/functions/daily-wrapup/index.ts` | New — daily wrap Edge Function |
| 8.1 | `packages/growly_core/lib/domain/models/reward_box.dart` | New — reward box model |
| 8.2 | `backend/supabase/migrations/0022_reward_box.sql` | New — reward_boxes table |
| 8.3 | `apps/parent_app/lib/features/family_rewards/presentation/pages/reward_box_page.dart` | New — parent reward box UI |

---

## Implementation Priority

```
Week 1 (MVP):
  Phase 1 (bug fix) + Phase 2 (badge trigger) + Phase 3 (streak shield)
  → Child app gets working badge system, streak protection

Week 2 (Quest + Store):
  Phase 4 (daily quests) + Phase 5 (growly store)
  → Child app gets daily engagement loop + stars economy

Week 3 (Parent-facing):
  Phase 6 (celebration card) + Phase 7 (daily wrap) + Phase 8 (reward box)
  → Parent app gets celebration + daily summary + reward management
```