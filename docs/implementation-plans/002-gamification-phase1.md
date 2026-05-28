# Growly Gamification Phase 1 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the broken `complete_lesson_reward` RPC (critical bug) and build the Daily Quest UI in the child app, so the gamification loop is alive and kids can see/track their daily missions.

**Architecture:** Atomic RPC for lesson completion + streak update + quest auto-complete, all in one DB transaction. Daily Quests embedded in the existing `/rewards` tab (no nav change needed in Phase 1). Quest state read from `daily_quests` table seeded on first access.

**Tech Stack:** Flutter Riverpod, GoRouter, Supabase (Postgres RPC functions), GoRouter redirect pattern.

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `backend/supabase/migrations/0024_complete_lesson_reward.sql` | Create | Atomic RPC: stars + streak + quest completion |
| `packages/growly_core/lib/data/repositories/badge_repository_impl.dart` | Modify | Fix RPC name call if needed |
| `apps/child_app/lib/features/rewards/providers/rewards_providers.dart` | Modify | Add `dailyQuestsProvider`, `dailyQuestRepoProvider` |
| `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart` | Modify | Embed Daily Quest widget at top of page |
| `apps/child_app/lib/features/rewards/presentation/widgets/daily_quests_card.dart` | Create | Daily quest list card (inline in rewards) |
| `apps/child_app/lib/features/learning/presentation/pages/lesson_page.dart` | Modify | After `completeLesson()`, invalidate `dailyQuestsProvider` + increment quest progress |
| `packages/growly_core/lib/data/repositories/daily_quest_repository_impl.dart` | Modify | Add `autoCompleteLessonQuest()` method that marks `daily_session` complete |

---

## Task 1: Create `complete_lesson_reward` SQL Migration

**File:** `backend/supabase/migrations/0024_complete_lesson_reward.sql`

**Goal:** One atomic transaction that: updates `reward_systems.total_stars` (source of truth for store), calls `update_streak` for streak logic, marks `daily_session` quest complete, inserts a screen_time_record log. Returns `new_total_stars`, `new_streak`, `new_longest_streak`, `shields_remaining`, `new_quest_completed`.

```sql
-- Migration 0024: complete_lesson_reward RPC
-- Atomic: lesson stars + streak update + daily quest auto-complete
-- Called by BadgeRepositoryImpl.completeLesson() in child_app

-- 1. Ensure reward_systems row exists for child
-- 2. Update total_stars
-- 3. Call update_streak RPC to handle streak logic
-- 4. Upsert daily_session quest as completed
-- 5. Insert screen_time record
-- 6. Return results

CREATE OR REPLACE FUNCTION complete_lesson_reward(
  p_child_id UUID,
  p_stars INTEGER DEFAULT 10,
  p_lesson_id TEXT DEFAULT NULL
)
RETURNS TABLE(
  new_total_stars INTEGER,
  new_current_streak INTEGER,
  new_longest_streak INTEGER,
  shields_remaining INTEGER,
  new_quest_completed BOOLEAN
)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_today DATE := CURRENT_DATE;
  v_streak_row RECORD;
  v_quest_exists BOOLEAN;
  v_was_completed BOOLEAN := FALSE;
BEGIN
  -- Ensure reward_systems row exists
  INSERT INTO reward_systems (child_id, total_stars, current_streak, longest_streak, last_activity_at)
  VALUES (p_child_id, 0, 0, 0, NOW())
  ON CONFLICT (child_id) DO NOTHING;

  -- Update total stars (source of truth for store page)
  UPDATE reward_systems
  SET total_stars = total_stars + p_stars,
      updated_at = NOW()
  WHERE child_id = p_child_id
  RETURNING total_stars INTO new_total_stars;

  -- Update streak (reuses existing update_streak RPC logic)
  SELECT * INTO v_streak_row
  FROM update_streak(p_child_id);

  new_current_streak := v_streak_row.current_streak;
  new_longest_streak := v_streak_row.longest_streak;
  shields_remaining := v_streak_row.shields_earned;

  -- Mark daily_session quest as completed if not already
  SELECT EXISTS(
    SELECT 1 FROM daily_quests
    WHERE child_id = p_child_id AND quest_date = v_today AND quest_id = 'daily_session'
  ) INTO v_quest_exists;

  IF v_quest_exists THEN
    -- Check if already completed
    SELECT is_completed INTO v_was_completed
    FROM daily_quests
    WHERE child_id = p_child_id AND quest_date = v_today AND quest_id = 'daily_session';

    IF NOT v_was_completed THEN
      UPDATE daily_quests
      SET is_completed = TRUE,
          completed_at = NOW(),
          stars_earned = 2  -- stars_reward from quest_definitions for daily_session
      WHERE child_id = p_child_id AND quest_date = v_today AND quest_id = 'daily_session';
      new_quest_completed := TRUE;
    ELSE
      new_quest_completed := FALSE;
    END IF;
  ELSE
    -- Quest row doesn't exist yet (getTodayQuests hasn't been called today)
    -- Insert it as completed directly
    INSERT INTO daily_quests (child_id, quest_date, quest_id, is_completed, completed_at, stars_earned)
    VALUES (p_child_id, v_today, 'daily_session', TRUE, NOW(), 2)
    ON CONFLICT (child_id, quest_date, quest_id) DO UPDATE
      SET is_completed = TRUE, completed_at = NOW(), stars_earned = 2;
    new_quest_completed := TRUE;
  END IF;

  -- Log screen time (optional, safe to fail silently)
  BEGIN
    INSERT INTO screen_time_records (child_id, date, total_minutes)
    VALUES (p_child_id, v_today, 1)
    ON CONFLICT (child_id, date) DO UPDATE SET total_minutes = screen_time_records.total_minutes + 1;
  EXCEPTION WHEN OTHERS THEN
    -- table might not exist, skip silently
  END;

  RETURN NEXT;
END;
$$;
```

---

## Task 2: Fix `badge_repository_impl.dart` to Use Correct RPC

**File:** `packages/growly_core/lib/data/repositories/badge_repository_impl.dart`

Read the full file, then modify the `completeLesson` method. The current method calls `_client.rpc('complete_lesson_reward', params: {...})` — this is already correct, just the SQL function doesn't exist. After creating the migration, no code change is needed here, but verify the method signature matches what the new RPC returns:

- Verify `completeLesson` wraps the RPC call in try/catch (it already does — safe to fail silently)
- Verify it reads `RewardSystem` from the DB after the RPC (for the return value) — currently it doesn't use the return value, just catches errors

**No code change required** — the existing code will work once the SQL migration is deployed. Confirm by reading the file around lines 124-144.

---

## Task 3: Add Daily Quest Providers to `rewards_providers.dart`

**File:** `apps/child_app/lib/features/rewards/providers/rewards_providers.dart`

Read the file first, then add these providers at the bottom (after existing providers):

```dart
import 'package:child_app/core/router/child_router.dart' show verifiedChildIdProvider;

/// Daily quest repository provider
final dailyQuestRepoProvider = Provider<IDailyQuestRepository>((ref) {
  return DailyQuestRepositoryImpl();
});

/// Today's quests for the verified child
final dailyQuestsProvider = FutureProvider<List<DailyQuest>>((ref) async {
  final childId = ref.watch(verifiedChildIdProvider);
  if (childId == null) return [];

  final repo = ref.watch(dailyQuestRepoProvider);
  final (quests, _) = await repo.getTodayQuests(childId);
  return quests ?? [];
});

/// Progress summary: completed count / total
final dailyQuestProgressProvider = Provider<({int completed, int total})>((ref) {
  final questsAsync = ref.watch(dailyQuestsProvider);
  return questsAsync.when(
    data: (quests) {
      final completed = quests.where((q) => q.isCompleted).length;
      return (completed: completed, total: quests.length);
    },
    loading: () => (completed: 0, total: 0),
    error: (_, __) => (completed: 0, total: 0),
  );
});
```

**Note:** The import for `DailyQuestRepositoryImpl` needs to be added. Check the existing imports and add:
```dart
import 'package:growly_core/growly_core.dart';
```

---

## Task 4: Create `DailyQuestsCard` Widget

**File:** `apps/child_app/lib/features/rewards/presentation/widgets/daily_quests_card.dart`

New widget embedded in `rewards_page.dart`. Read the existing `rewards_page.dart` first to match the design system style (colors, spacing, font sizes). Then create:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import 'package:child_app/features/rewards/providers/rewards_providers.dart';

class DailyQuestsCard extends ConsumerWidget {
  const DailyQuestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(dailyQuestsProvider);
    final progress = ref.watch(dailyQuestProgressProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: title + progress badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📋 Misi Harian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${progress.completed}/${progress.total}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quest list
            questsAsync.when(
              data: (quests) {
                if (quests.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada misi hari ini', style: TextStyle(color: Colors.grey)),
                  );
                }
                return Column(
                  children: [
                    for (final quest in quests) _QuestRow(quest: quest),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Gagal memuat misi: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  final DailyQuest quest;

  const _QuestRow({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Emoji
          Text(quest.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          // Title + progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        quest.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                          color: quest.isCompleted ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                    // Stars badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 2),
                          Text(
                            quest.isCompleted ? '${quest.starsReward}' : '+${quest.starsReward}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Progress bar (only show if not completed and has target > 1)
                if (!quest.isCompleted && quest.targetValue > 1)
                  LinearProgressIndicator(
                    value: quest.progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(Colors.green.shade400),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                // Completed checkmark
                if (quest.isCompleted)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Selesai', style: TextStyle(fontSize: 12, color: Colors.green)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Task 5: Integrate `DailyQuestsCard` into `rewards_page.dart`

**File:** `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart`

Read the file first. The page has three sections: streak card, stars card, badges grid. Insert `DailyQuestsCard` **before** the three cards (at the top of the scrollable content):

```dart
// In the build method's Column, add this as the first child:
child: RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(dailyQuestsProvider);
    ref.invalidate(badgesProvider);
    ref.invalidate(rewardSystemProvider);
  },
  child: ListView(
    shrinkWrap: true,
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      // NEW: Daily quests at the top
      const DailyQuestsCard(),
      const SizedBox(height: 8),
      // Existing: streak card, stars card, badges grid...
```

Add the import at the top of the file:
```dart
import 'package:child_app/features/rewards/presentation/widgets/daily_quests_card.dart';
import 'package:child_app/features/rewards/providers/rewards_providers.dart';
```

---

## Task 6: Wire Quest Invalidation in `LessonPage`

**File:** `apps/child_app/lib/features/learning/presentation/pages/lesson_page.dart`

In `_completeLesson()`, after `ref.invalidate(rewardSystemProvider)` (around line 152), add:

```dart
// Refresh daily quest progress
final dailyQuestRepo = ref.read(dailyQuestRepoProvider);
await dailyQuestRepo.completeQuest(childId, 'daily_session');
ref.invalidate(dailyQuestsProvider);
```

**Important:** Add the import for the daily quest repo provider:
```dart
import 'package:child_app/features/rewards/providers/rewards_providers.dart';
```

This ensures that after lesson completion:
1. `complete_lesson_reward` RPC marks `daily_session` completed (via `badgeRepo.completeLesson()`)
2. `dailyQuestRepo.completeQuest()` awards quest bonus stars (2 stars from `daily_session` definition)
3. `ref.invalidate(dailyQuestsProvider)` refreshes the UI

**Verify** `dailyQuestRepoProvider` is accessible from `lesson_page.dart`. The provider is defined in `rewards_providers.dart` which is in the rewards feature — cross-feature imports are normal in this codebase.

---

## Task 7: Verify Store Page Reads from `reward_systems.total_stars`

**File:** `apps/child_app/lib/features/store/presentation/pages/growly_store_page.dart`

Read the `_childRewardSystemProvider` provider (around line 38):

```dart
final _childRewardSystemProvider = FutureProvider<RewardSystem>((ref) async {
  final child = await ref.watch(_launcherChildProvider.future);
  if (child == null) return const RewardSystem(childId: '');
  final repo = ref.watch(_badgeRepoProvider);
  final (reward, _) = await repo.getRewardSystem(child.id);
  return reward ?? RewardSystem(childId: child.id);
});
```

This reads `RewardSystem` from `badgeRepo.getRewardSystem()`, which reads from `reward_systems` table. Good. But `BadgeRepositoryImpl.getRewardSystem()` needs to be verified:

**Read:** `packages/growly_core/lib/data/repositories/badge_repository_impl.dart` — find `getRewardSystem()` method.

Expected: `SELECT * FROM reward_systems WHERE child_id = $1`.

If it reads from `child_profiles.total_stars` instead, fix it to read from `reward_systems.total_stars`.

---

## Task 8: Add `DailyQuestRepositoryImpl` import to `lesson_page.dart`

**Verify** `DailyQuestRepositoryImpl` is importable from `growly_core`. The import `'package:growly_core/growly_core.dart'` is already in `lesson_page.dart`. Confirm `DailyQuestRepositoryImpl` is exported from `growly_core.dart`. If not, add the specific import:
```dart
import 'package:growly_core/growly_core.dart' show DailyQuestRepositoryImpl, IDailyQuestRepository;
```

---

## Task 9: Push Migration to Supabase

Run locally:
```bash
cd /Users/weskonek/WeskonekWeb/Growly/Growly/backend/supabase
supabase db push
```

If not linked, use Supabase CLI:
```bash
supabase link --project-id <project-id>
supabase db push
```

**Verification:** After push, run in Supabase SQL editor:
```sql
SELECT complete_lesson_reward('test-child-id', 10, 'test-lesson-id');
```
Should return a row (even for non-existent child since it creates the row).

---

## Task 10: Build Verification

**Android build:**
```bash
cd /Users/weskonek/WeskonekWeb/Growly/Growly
melos build:android:child
```

**Analyze:**
```bash
melos analyze
```

**Expected:** No errors from the new files. The `complete_lesson_reward` RPC may show a warning if called with wrong types (column mismatch) — fix SQL if needed.

---

## Self-Review Checklist

- [ ] `0024_complete_lesson_reward.sql` — does it upsert `daily_session` quest correctly?
- [ ] `badge_repository_impl.dart` — does it already call the correct RPC name?
- [ ] `dailyQuestsProvider` — uses `verifiedChildIdProvider` (PIN-gated)?
- [ ] `DailyQuestsCard` — matches style of existing `rewards_page.dart` cards?
- [ ] `lesson_page.dart` — calls `completeQuest()` and `invalidate()` after lesson completion?
- [ ] `reward_systems.total_stars` — is this the column the store reads?
- [ ] No "TBD" or placeholder in any step?
- [ ] All file paths are absolute?
- [ ] No duplicate work between tasks (e.g., both Task 3 and Task 5 creating providers)?

## Execution Order

1. Task 1 (SQL migration) — deploy first, blocks everything
2. Task 7 (store verification) — can be done in parallel with Task 1 reading
3. Task 3 (providers)
4. Task 4 (widget)
5. Task 5 (integrate into rewards page)
6. Task 6 (wire lesson page)
7. Task 9 (push migration)
8. Task 10 (build verify)