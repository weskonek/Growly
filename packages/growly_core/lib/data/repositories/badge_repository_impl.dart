import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/badge_repository.dart';
import '../../domain/models/badge.dart';
import '../../core/errors/failures.dart';
import '../../core/database/remote/supabase_service.dart';

class BadgeRepositoryImpl implements IBadgeRepository {
  SupabaseClient get _client => SupabaseService.client;

  BadgeRepositoryImpl();

  @override
  Future<(List<Badge>?, Failure?)> getBadges(String childId) async {
    try {
      final response = await _client
          .from('badges')
          .select()
          .eq('child_id', childId)
          .order('earned_at', ascending: false);

      final badges = (response as List)
          .map((json) => Badge.fromJson(json as Map<String, dynamic>))
          .toList();

      return (badges, null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(Badge?, Failure?)> awardBadge(Badge badge) async {
    try {
      final json = badge.toJson();

      final response = await _client
          .from('badges')
          .insert(json)
          .select()
          .single();

      return (Badge.fromJson(Map<String, dynamic>.from(response)), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(RewardSystem?, Failure?)> getRewardSystem(String childId) async {
    try {
      final response = await _client
          .from('reward_systems')
          .select()
          .eq('child_id', childId)
          .maybeSingle();

      if (response == null) {
        return (RewardSystem(childId: childId), null);
      }

      return (RewardSystem.fromJson(Map<String, dynamic>.from(response)), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(RewardSystem?, Failure?)> updateRewardSystem(RewardSystem reward) async {
    try {
      final json = reward.toJson();

      final response = await _client
          .from('reward_systems')
          .upsert(json)
          .select()
          .single();

      return (RewardSystem.fromJson(Map<String, dynamic>.from(response)), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> incrementStreak(String childId) async {
    try {
      final (reward, failure) = await getRewardSystem(childId);
      if (failure != null) return (false, failure);

      final updated = reward!.copyWith(
        currentStreak: reward.currentStreak + 1,
        longestStreak: reward.currentStreak + 1 > reward.longestStreak
            ? reward.currentStreak + 1
            : reward.longestStreak,
        lastActivityAt: DateTime.now(),
      );

      await updateRewardSystem(updated);
      return (true, null);
    } catch (e) {
      return (false, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> addStars(String childId, int stars) async {
    try {
      final (reward, failure) = await getRewardSystem(childId);
      if (failure != null) return (false, failure);

      final updated = reward!.copyWith(
        totalStars: reward.totalStars + stars,
        lastActivityAt: DateTime.now(),
      );

      await updateRewardSystem(updated);
      return (true, null);
    } catch (e) {
      return (false, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(RewardSystem?, Failure?)> completeLesson(
    String childId,
    String lessonId,
    int stars,
  ) async {
    try {
      // Atomic: single DB call increments streak + stars together
      final response = await _client.rpc('complete_lesson_reward', params: {
        'p_child_id': childId,
        'p_stars': stars,
      });

      if (response == null) {
        return (null, DatabaseFailure(message: 'Failed to update reward'));
      }

      return (RewardSystem.fromJson(Map<String, dynamic>.from(response as Map)), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }
}