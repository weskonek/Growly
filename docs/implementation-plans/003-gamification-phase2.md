# Growly Gamification Phase 2 — Implementation Plan

> **For agentic workers:** Execute with superpowers:subagent-driven-development. Each task is independent — can run in parallel.

**Goal:** Build three features: RewardBox child UI, AI Tutor quest integration, Quest celebration.

**Architecture:** Feature A (RewardBox) adds a new card section to rewards_page above DailyQuestsCard. Feature B (AI Tutor) adds quest progress tracking in ai_tutor_page using StateProvider + dailyQuestRepoProvider. Feature C (Quest celebration) adds a ref.listen on dailyQuestsProvider + reusable dialog widget.

---

## Task 1: RewardBox Child UI — Providers

**Files:**
- Modify: `apps/child_app/lib/features/rewards/providers/rewards_providers.dart`

Add `childRewardBoxesProvider` that:
1. Watches `launcher.currentChildProvider.future` (same pattern as other providers in this file)
2. Gets the `ChildProfile` → reads `parentId` from it
3. Calls `repo.getRewardBoxes(parentId)` from `IRewardBoxRepository`
4. Filters result to boxes where `childId == currentChild.id OR childId IS NULL` AND `isClaimed == false`
5. Sorts: unclaimed → expired (show separately), active first

```dart
/// Active reward boxes for this child (excludes claimed)
final childRewardBoxesProvider = FutureProvider<List<RewardBox>>((ref) async {
  final child = await ref.watch(launcher.currentChildProvider.future);
  if (child == null) return [];
  final repo = ref.watch(rewardBoxRepositoryProvider);
  final (boxes, _) = await repo.getRewardBoxes(child.parentId);
  if (boxes == null) return [];

  return boxes.where((b) {
    final forThisChild = b.childId == null || b.childId == child.id;
    return forThisChild && !b.isClaimed && !b.isExpired;
  }).toList()
    ..sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
});

/// RewardBox repository provider
final rewardBoxRepositoryProvider = Provider<IRewardBoxRepository>((ref) {
  return RewardBoxRepositoryImpl();
});
```

---

## Task 2: RewardBox Child UI — Widget

**Files:**
- Create: `apps/child_app/lib/features/rewards/presentation/widgets/reward_box_list_card.dart`

Widget that:
- Shows "🎁 Hadiah dari Ortu" header
- If no boxes → "Belum ada hadiah dari ortu. Belajar terus ya! 😊"
- List of `RewardBoxCard` items — each card shows:
  - Emoji 🎁 + reward description (bold)
  - Progress bar: `currentStars / targetStars` with amber fill, grey background
  - Progress text: "12/30 ⭐"
  - Expiry date text: "Berlaku sampai 2 Juni 2026"
  - If `currentStars >= targetStars` → `ElevatedButton` "Klaim Sekarang! 🎁" (amber filled)
  - If `currentStars < targetStars` → `OutlinedButton` with lock icon "Kumpulkan dulu ⭐${targetStars - currentStars} lagi" (disabled)
- `RewardBoxCard` uses `ConsumerStatefulWidget` — on claim tap, calls `claimRewardBox()`, shows success dialog, invalidates providers
- Wrap each card in `Card` with `margin: EdgeInsets.only(bottom: 8)`

Claim flow:
```dart
Future<void> _claim(RewardBox box) async {
  final repo = ref.read(rewardBoxRepositoryProvider);
  final (result, err) = await repo.claimRewardBox(box.id);
  if (err != null || result == null) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal klaim hadiah 😢'), backgroundColor: Colors.red),
    );
    return;
  }
  ref.invalidate(childRewardBoxesProvider);
  ref.invalidate(rewardSystemProvider); // refresh star balance
  if (mounted) _showClaimSuccess(box);
}
```

Success dialog:
```dart
void _showClaimSuccess(RewardBox box) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('🎉'),
    content: Text('Hadiah "$box.rewardDescription" sudah klaim!',
      style: const TextStyle(fontSize: 16)),
    actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Yeay! 🎁'))],
  ));
}
```

---

## Task 3: RewardBox Child UI — Integrate into rewards_page

**Files:**
- Modify: `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart`

After the import additions, add `RewardBoxListCard` above `DailyQuestsCard`:
```dart
const SizedBox(height: 8),
const RewardBoxListCard(),
const SizedBox(height: 8),
const DailyQuestsCard(),
```

Add imports:
```dart
import 'package:child_app/features/rewards/presentation/widgets/reward_box_list_card.dart';
```

Verify `RewardBox` is exported from `growly_core.dart` — if not, add specific import:
```dart
import 'package:growly_core/growly_core.dart' show RewardBox, IRewardBoxRepository;
```

---

## Task 4: AI Tutor Quest Integration

**Files:**
- Modify: `apps/child_app/lib/features/ai_tutor/presentation/pages/ai_tutor_page.dart`

Read the file first. Find where assistant responses are displayed/processed. The key insight: the AI tutor page receives responses from the edge function. We need to detect when the child gets a correct answer.

Since the current AI tutor is pure conversation (no correctness tracking), the simplest reliable approach:

1. Add a `StateProvider<int>` `correctAnswerCountProvider` initialized to 0
2. Find where the child "marks as correct" — look for any "benar" / "betul" / "correct" action in the tutor page. If none exists, add a tap-to-mark-correct button on assistant messages.
3. On each correct mark, call `ref.read(dailyQuestRepoProvider).incrementQuestProgress(childId, 'daily_questions', 1)`
4. Track count in a local counter. When it reaches 5, call `completeQuest(childId, 'daily_questions')` + show celebration + reset counter.

**Important**: Read the file first to find the exact location for integration. The `correctAnswerCount` StateProvider should live inside the page's `_AiTutorPageState`.

If the tutor page has no way to mark answers correct yet:
- Add a small "✓ Ini benar" button that appears next to AI tutor responses
- This is a simple `TextButton` with icon, appearing on each assistant message bubble
- Tapping it increments the counter

---

## Task 5: Quest Celebration — Reusable Dialog Widget

**Files:**
- Create: `apps/child_app/lib/features/rewards/presentation/widgets/quest_celebration_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:growly_core/growly_core.dart';

/// Shows a quest completion celebration dialog.
/// Usage: showQuestCelebrationDialog(context, quest);
void showQuestCelebrationDialog(BuildContext context, DailyQuest quest) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(children: [
        const Text('🎉', style: TextStyle(fontSize: 40)),
        const SizedBox(width: 12),
        Expanded(child: Text('${quest.emoji} ${quest.title}', style: const TextStyle(fontSize: 20))),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Misi selesai!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          quest.isCompleted
              ? 'Kamu mendapat ${quest.starsReward}⭐ bonus!'
              : 'Terus belajar! 🔥',
          style: TextStyle(color: Colors.amber.shade700, fontSize: 15),
        ),
      ]),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Hebat! 🔥'),
        ),
      ],
    ),
  );
}
```

---

## Task 6: Quest Celebration — Listen in rewards_page

**Files:**
- Modify: `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart`

Add a `ref.listen` on `dailyQuestsProvider` to detect when any quest completes:

```dart
// Track which quests have been celebrated today (prevent re-fire on refresh)
final _celebratedQuests = <String>{};

ref.listen(dailyQuestsProvider, (prev, next) {
  if (prev?.hasValue != true || next.hasValue != true) return;
  final prevIds = prev!.valueOrNull!.where((q) => q.isCompleted).map((q) => q.id).toSet();
  final newlyCompleted = next.valueOrNull!
      .where((q) => q.isCompleted && !prevIds.contains(q.id))
      .toList();
  for (final quest in newlyCompleted) {
    if (!_celebratedQuests.contains(quest.id)) {
      _celebratedQuests.add(quest.id);
      showQuestCelebrationDialog(context, quest);
    }
  }
});
```

Also add the import:
```dart
import 'package:child_app/features/rewards/presentation/widgets/quest_celebration_dialog.dart';
```

---

## Task 7: Quest Celebration — Trigger in lesson_page

**Files:**
- Modify: `apps/child_app/lib/features/learning/presentation/pages/lesson_page.dart`

In `_completeLesson()`, after `ref.invalidate(dailyQuestsProvider)`, add:

```dart
// Show quest celebration for daily_session completion
showQuestCelebrationDialog(
  context,
  DailyQuest(
    id: '',
    childId: childId,
    questDate: DateTime.now(),
    questId: 'daily_session',
    isCompleted: true,
    completedAt: DateTime.now(),
    starsEarned: 2,
    // These fields needed by the dialog — DailyQuest model needs updating
    title: 'Selesaikan 1 Sesi',
    description: 'Selesaikan satu sesi belajar hari ini',
    emoji: '📚',
    starsReward: 2,
    targetValue: 1,
    progress: 1.0,
  ),
);
```

**Note**: Check `DailyQuest` model — if it lacks `title`, `description`, `emoji`, `starsReward`, `targetValue`, `progress` fields needed by `showQuestCelebrationDialog`, add them. The existing `DailyQuest` model may already have them — verify before implementing.

---

## Task 8: Verify and Build

Run:
```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
```

Expected: 0 new issues (pre-existing 29 warnings are from other files).

Commit all changes.

---

## Self-Review

- [ ] `childRewardBoxesProvider` — correctly filters by childId + parentId?
- [ ] `RewardBoxListCard` — claim button disabled when stars insufficient?
- [ ] AI Tutor — `incrementQuestProgress` called after correct answer mark?
- [ ] `completeQuest('daily_questions')` called only once at threshold 5?
- [ ] Quest celebration — `_celebratedQuests` set prevents re-fire on refresh?
- [ ] `DailyQuest` model has all fields needed by `showQuestCelebrationDialog`?

## Execution Order

Tasks 1, 5 can run in parallel. Then tasks 2, 3, 4, 6, 7 can run in parallel (they touch different files). Task 8 is last.