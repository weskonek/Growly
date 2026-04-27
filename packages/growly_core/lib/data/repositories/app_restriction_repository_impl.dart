import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/app_restriction_repository.dart';
import '../../domain/models/app_restriction.dart';
import '../../core/errors/failures.dart';
import '../../core/database/remote/supabase_service.dart';

class AppRestrictionRepositoryImpl implements IAppRestrictionRepository {
  SupabaseClient get _client => SupabaseService.client;

  AppRestrictionRepositoryImpl();

  @override
  Future<(List<AppRestriction>?, Failure?)> getRestrictions(String childId) async {
    try {
      final response = await _client
          .from('app_restrictions')
          .select()
          .eq('child_id', childId);

      final restrictions = (response as List)
          .map((json) => AppRestriction.fromJson(json as Map<String, dynamic>))
          .toList();

      return (restrictions, null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(AppRestriction?, Failure?)> saveRestriction(AppRestriction restriction) async {
    try {
      final json = restriction.toJson();

      final response = await _client
          .from('app_restrictions')
          .upsert(json)
          .select()
          .single();

      return (AppRestriction.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> deleteRestriction(String restrictionId) async {
    try {
      await _client.from('app_restrictions').delete().eq('id', restrictionId);
      return (true, null);
    } catch (e) {
      return (false, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(List<Schedule>?, Failure?)> getSchedules(String childId) async {
    try {
      final response = await _client
          .from('schedules')
          .select()
          .eq('child_id', childId)
          .order('day_of_week');

      final schedules = (response as List)
          .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
          .toList();

      return (schedules, null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(Schedule?, Failure?)> saveSchedule(Schedule schedule) async {
    try {
      final json = schedule.toJson();

      final response = await _client
          .from('schedules')
          .upsert(json)
          .select()
          .single();

      return (Schedule.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> deleteSchedule(String scheduleId) async {
    try {
      await _client.from('schedules').delete().eq('id', scheduleId);
      return (true, null);
    } catch (e) {
      return (false, Failure.database(message: e.toString()));
    }
  }
}