# Growly Gamification Phase 2 — Design Spec

> **Date:** 2026-05-29
> **Status:** Approved — proceed to implementation

## Overview

Phase 1 established the core gamification loop (lesson → stars + streak + quest). Phase 2 expands it with three independent features:

1. **RewardBox child UI** — anak bisa klaim hadiah dari orang tua
2. **AI Tutor quest integration** — `daily_questions` quest progresses when child answers correctly
3. **Quest celebration** — visual celebration when a quest completes

All three are independent and can be built in any order.

---

## Feature A: RewardBox Child UI

### Context

`RewardBox` model, `IRewardBoxRepository`, and parent app UI are fully built. The `reward_boxes` table exists with full RLS (parents CRUD, children SELECT). The missing piece is the child app view — the kid cannot see rewards their parent has prepared for them.

### User Flow

1. Parent opens parent app → Family Rewards → "Buat Hadiah" → set target stars + description + expiry + (optional) child name
2. Child opens child app → tab "Hadiah" (rewards page) → sees a new "🎁 Hadiah dari Ortu" section above badges
3. Each reward box shows: emoji 🎁, description, progress bar (currentStars / targetStars), expiry date
4. If `currentStars >= targetStars` → "Klaim Sekarang!" button active → tap → stars deducted → success dialog → box moves to "Sudah Diklaim"
5. If `currentStars < targetStars` → button disabled with lock icon
6. Expired boxes shown with "Kedaluwarsa" badge, no action

### Architecture

- **Model**: `RewardBox` already exists in `growly_core`
- **Repository**: `IRewardBoxRepository.getRewardBoxes(parentId)` returns boxes for all children. In child app, filter by `childId` (via `verifiedChildIdProvider`) to show only boxes relevant to this child
- **Provider**: New `childRewardBoxesProvider` in `rewards_providers.dart` — watches `verifiedChildIdProvider`, calls `repo.getRewardBoxes(parentId)`, filters to boxes where `childId` matches current child OR `childId IS NULL` (bonus: all children)
- **Widget**: `RewardBoxListCard` — embedded in `rewards_page.dart` above `DailyQuestsCard`. Reuses `RewardBox` model progress getters
- **Claim flow**: `claimRewardBox(boxId)` → if `currentStars >= targetStars` → RPC deducts stars → success dialog with confetti → UI refresh

### Data Flow

```
Parent bikin hadiah (parent app) → reward_boxes table (is_claimed=false)
         ↓
Child buka tab Hadiah → childRewardBoxesProvider reads reward_boxes
         ↓
Anak klaim → claimRewardBox(boxId) → purchase_store_item RPC (bintang deduct)
         ↓
Stars berkurang → rewardSystems.total_stars updated → store/rewards UI refresh
```

### Edge Cases

- `reward_boxes` has `child_id` nullable → `NULL` means "semua anak dapat". Filter: show if `child_id == childId OR child_id IS NULL`
- Expiry: filter out expired boxes from active list, show them separately
- Already claimed: `is_claimed = true` → show "Sudah Diklaim" badge, no button
- Insufficient stars: show progress bar red/orange, lock icon on disabled button

---

## Feature B: AI Tutor Quest Integration

### Context

`daily_questions` quest in `quest_definitions` has `quest_type='answer_questions'`, `target_value=5`, `stars_reward=3`. It is a dead quest — nothing increments its progress. The AI tutor does not track answer correctness at all.

### User Flow

1. Child opens AI Tutor → asks questions or gets AI-generated exercises
2. If the response contains correct answers (teacher mode), child marks it correct
3. System tracks "correct answer count" → calls `incrementQuestProgress(childId, 'daily_questions', 1)` per correct answer
4. When count reaches 5 → `completeQuest()` is auto-called → +3⭐ bonus → quest card in rewards page updates to "Selesai"

### Integration Point

The edge function `ai-tutor` already has a `metadata` field in its response. The cleanest integration:

- Add a new field `metadata.correctAnswersCount` to the edge function response (count of questions answered correctly in the session)
- `AiTutorNotifier` or `ai_tutor_page.dart` reads this from response
- On each tutor exchange where the child receives a correct answer, call `dailyQuestRepo.incrementQuestProgress(childId, 'daily_questions', 1)`
- Track `correctAnswerCount` in a `StateProvider<int>` in the page — when it crosses 5, call `completeQuest('daily_questions')` + reset counter

### Alternative Approach (no edge function change needed)

Use the `ai_tutor_sessions` table — it stores session messages. After each exchange, check if the latest assistant message contains a "✓" or "correct" marker. This is fragile. **Recommendation: use metadata from edge function** (cleaner, explicit).

### Edge Cases

- Session restart: `correctAnswerCount` resets each tutor page session (OK — `daily_questions` tracks daily, not per-session)
- If quest already completed today: `completeQuest` returns `new_quest_completed = FALSE` (idempotent safe)
- Edge function returns 0 correct answers: no call needed

---

## Feature C: Quest Celebration

### Context

`_showBadgeCelebration` already exists in `lesson_page.dart` and `rewards_page.dart` for badge unlocks. A similar dialog should fire when a quest completes.

### Design

Create a new `_showQuestCelebration` utility function in `rewards_page.dart` (or a shared widget in `rewards/presentation/widgets/`). Reuse the badge celebration pattern but with quest-specific content:

```
🎉
"Misi Selesai!"
"Jawab 5 Soal Benar — +3⭐"
"Hebat! Kamu terus belajar! 🔥"
[Hebat! 🔥]
```

Triggered by:
1. `ref.listen(dailyQuestsProvider)` in `rewards_page.dart` — when any quest transitions `isCompleted: false → true`, show celebration for that specific quest
2. `lesson_page.dart` after `_completeLesson()` — also call `_showQuestCelebration` for the `daily_session` quest

### Implementation

- Add `ref.listen(dailyQuestsProvider, ...)` in `rewards_page.dart` — track previous quest list, detect which quest just completed
- Create `_showQuestCelebration(BuildContext, DailyQuest)` method — takes the quest, shows emoji + title + stars earned
- In `lesson_page.dart`: after `completeQuest()`, call `_showQuestCelebrationForLesson()` (reuse existing `_showBadgeCelebration` style dialog)
- Celebration fires only once per quest (use a `Set<String>` of "celebrated quest IDs today" to prevent re-firing on refresh)

---

## Scope Boundaries (Phase 2)

Out of scope:
- Push notifications when parent creates a RewardBox (needs FCM edge function)
- Animated confetti on quest completion (use simple dialog for Phase 2)
- RewardBox "all children" notification flow
- AI Tutor scoring engine (AI tutor edge function returns metadata as-is)
- Daily quest auto-generation cron (already handled by `getTodayQuests()` on first access)

---

## Files to Create/Modify

| Feature | File | Action |
|---------|------|--------|
| A | `apps/child_app/lib/features/rewards/providers/rewards_providers.dart` | Add `childRewardBoxesProvider` |
| A | `apps/child_app/lib/features/rewards/presentation/widgets/reward_box_list_card.dart` | Create — RewardBox cards with claim button |
| A | `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart` | Insert `RewardBoxListCard` above `DailyQuestsCard` |
| B | `apps/child_app/lib/features/ai_tutor/presentation/pages/ai_tutor_page.dart` | Add `incrementQuestProgress` after correct answer, `StateProvider<int>` for counter |
| B | `apps/child_app/lib/features/rewards/providers/rewards_providers.dart` | Ensure `dailyQuestRepoProvider` is accessible from `ai_tutor_page.dart` |
| C | `apps/child_app/lib/features/rewards/presentation/pages/rewards_page.dart` | Add `ref.listen` on `dailyQuestsProvider` for celebration trigger |
| C | `apps/child_app/lib/features/rewards/presentation/widgets/quest_celebration_dialog.dart` | Create — reusable quest celebration dialog |
| C | `apps/child_app/lib/features/learning/presentation/pages/lesson_page.dart` | Call celebration after `completeQuest` in `_completeLesson` |
| All | `apps/child_app/lib/features/rewards/presentation/widgets/` | Ensure `widgets/` dir exists (already created in Phase 1) |

---

## Verification Checklist

- [ ] RewardBox list appears in rewards page when parent has created boxes
- [ ] Claim button active when `totalStars >= targetStars`, disabled otherwise
- [ ] Stars deducted on claim, UI refreshes automatically
- [ ] `daily_questions` progress increments when AI tutor returns correct answers
- [ ] Quest completes at 5 correct answers, +3⭐ awarded
- [ ] Quest celebration dialog appears when quest completes (both page refresh and immediate)
- [ ] Celebration does not re-fire on refresh for already-completed quests
- [ ] Flutter analyze: 0 new issues
- [ ] All 3 features independently testable