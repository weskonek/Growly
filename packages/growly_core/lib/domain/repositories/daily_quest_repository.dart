import '../../core/errors/failures.dart';
import '../models/daily_quest.dart';

abstract class IDailyQuestRepository {
  /// Get today's quests for a child, generating them if not yet created.
  Future<(List<DailyQuest>?, Failure?)> getTodayQuests(String childId);

  /// Mark a quest as completed and award stars.
  Future<(DailyQuest?, Failure?)> completeQuest(String childId, String questId);

  /// Get quest progress for a specific quest.
  Future<(int currentValue, Failure?)> getQuestProgress(String childId, String questId);

  /// Increment quest progress value.
  Future<(bool, Failure?)> incrementQuestProgress(String childId, String questId, int by);
}