import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/learning_repository.dart';
import '../../domain/models/learning_progress.dart';
import '../../core/errors/failures.dart';

class LearningRepositoryImpl implements ILearningRepository {
  final SupabaseClient _client;

  LearningRepositoryImpl(this._client);

  @override
  Future<(List<LearningProgress>?, Failure?)> getProgress(String childId, {int limit = 50}) async {
    try {
      final response = await _client
          .from('learning_progress')
          .select()
          .eq('child_id', childId)
          .order('created_at', ascending: false)
          .limit(limit);

      final progress = (response as List)
          .map((json) => LearningProgress.fromJson(json as Map<String, dynamic>))
          .toList();

      return (progress, null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<LearningSession>?, Failure?)> getSessions(
    String childId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      var query = _client
          .from('learning_sessions')
          .select()
          .eq('child_id', childId);

      if (from != null) {
        query = query.gte('started_at', from.toIso8601String());
      }
      if (to != null) {
        query = query.lte('started_at', to.toIso8601String());
      }

      final response = await query.order('started_at', ascending: false);

      final sessions = (response as List)
          .map((json) => LearningSession.fromJson(json as Map<String, dynamic>))
          .toList();

      return (sessions, null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(LearningProgress?, Failure?)> saveProgress(LearningProgress progress) async {
    try {
      final json = progress.toJson();

      final response = await _client
          .from('learning_progress')
          .upsert(json)
          .select()
          .single();

      return (LearningProgress.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(LearningSession?, Failure?)> startSession(String childId, String subject) async {
    try {
      final response = await _client
          .from('learning_sessions')
          .insert({
            'child_id': childId,
            'subject': subject,
            'started_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return (LearningSession.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(LearningSession?, Failure?)> endSession(
    String sessionId, {
    int durationMinutes = 0,
    List<String>? topicsCovered,
  }) async {
    try {
      final json = <String, dynamic>{
        'ended_at': DateTime.now().toIso8601String(),
        'duration_minutes': durationMinutes,
      };

      if (topicsCovered != null) {
        json['topics_covered'] = topicsCovered;
      }

      final response = await _client
          .from('learning_sessions')
          .update(json)
          .eq('id', sessionId)
          .select()
          .single();

      return (LearningSession.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> getStats(String childId) async {
    try {
      final progress = await _client
          .from('learning_progress')
          .select()
          .eq('child_id', childId);

      final sessions = await _client
          .from('learning_sessions')
          .select()
          .eq('child_id', childId);

      return ({
        'totalActivities': (progress as List).length,
        'completedActivities': (progress as List).where((p) => p['completed'] == true).length,
        'totalSessions': (sessions as List).length,
        'records': progress,
      }, null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }
}