import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/database/remote/supabase_service.dart';
import '../../domain/models/daily_quest.dart';
import '../../domain/repositories/daily_quest_repository.dart';

class DailyQuestRepositoryImpl implements IDailyQuestRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<(List<DailyQuest>?, Failure?)> getTodayQuests(String childId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Try fetching existing quests for today
      final existing = await _client
          .from('daily_quests')
          .select('*, definition:quest_definitions(*)')
          .eq('child_id', childId)
          .eq('quest_date', today);

      final existingList = existing as List<dynamic>;

      if (existingList.isNotEmpty) {
        final quests = existingList
            .map((q) => DailyQuest.fromJson(q as Map<String, dynamic>))
            .toList();
        return (quests, null);
      }

      // Seed today's quests from definitions
      final defResponse = await _client.from('quest_definitions').select();
      final definitions = defResponse as List<dynamic>;

      if (definitions.isNotEmpty) {
        final inserts = definitions.map((def) {
          final d = def as Map<String, dynamic>;
          return {
            'child_id': childId,
            'quest_date': today,
            'quest_id': d['quest_id'],
            'is_completed': false,
            'stars_earned': 0,
          };
        }).toList();

        await _client.from('daily_quests').insert(inserts);
      }

      // Re-fetch
      final questsResponse = await _client
          .from('daily_quests')
          .select('*, definition:quest_definitions(*)')
          .eq('child_id', childId)
          .eq('quest_date', today);

      final questsList = questsResponse as List<dynamic>;
      if (questsList.isEmpty) return (null, null);

      return (questsList
          .map((q) => DailyQuest.fromJson(q as Map<String, dynamic>))
          .toList(), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(DailyQuest?, Failure?)> completeQuest(String childId, String questId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Get quest definition for stars reward
      final defResponse = await _client
          .from('quest_definitions')
          .select()
          .eq('quest_id', questId)
          .maybeSingle();

      final defMap = defResponse as Map<String, dynamic>?;
      final starsReward = (defMap?['stars_reward'] as int?) ?? 2;

      // Mark quest as completed
      final updated = await _client
          .from('daily_quests')
          .update({
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
            'stars_earned': starsReward,
          })
          .eq('child_id', childId)
          .eq('quest_date', today)
          .eq('quest_id', questId)
          .select('*, definition:quest_definitions(*)')
          .single();

      // Award stars to reward system (fire and forget)
      try {
        await _client.rpc('add_quest_stars', params: {
          'p_child_id': childId,
          'p_stars': starsReward,
        });
      } catch (_) {}

      return (DailyQuest.fromJson(updated as Map<String, dynamic>), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(int, Failure?)> getQuestProgress(String childId, String questId) async {
    try {
      final row = await _client
          .from('quest_progress')
          .select('current_value')
          .eq('child_id', childId)
          .eq('quest_id', questId)
          .maybeSingle();

      final map = row as Map<String, dynamic>?;
      return ((map?['current_value'] as int?) ?? 0, null);
    } catch (e) {
      return (0, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> incrementQuestProgress(
    String childId,
    String questId,
    int by,
  ) async {
    try {
      await _client.rpc('increment_quest_progress', params: {
        'p_child_id': childId,
        'p_quest_id': questId,
        'p_value': by,
      });
      return (true, null);
    } catch (e) {
      return (false, DatabaseFailure(message: e.toString()));
    }
  }
}