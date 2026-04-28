import '../models/badge.dart';
import '../../core/errors/failures.dart';

abstract class IBadgeRepository {
  Future<(List<Badge>?, Failure?)> getBadges(String childId);
  Future<(Badge?, Failure?)> awardBadge(Badge badge);
  Future<(RewardSystem?, Failure?)> getRewardSystem(String childId);
  Future<(RewardSystem?, Failure?)> updateRewardSystem(RewardSystem reward);
  Future<(bool, Failure?)> incrementStreak(String childId);
  Future<(bool, Failure?)> addStars(String childId, int stars);
  /// Atomically increments streak and adds stars in one DB call (idempotent per lesson).
  Future<(RewardSystem?, Failure?)> completeLesson(String childId, String lessonId, int stars);
}