import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/screen_time_repository.dart';
import '../../domain/models/screen_time.dart';
import '../../core/errors/failures.dart';
import '../../core/database/remote/supabase_service.dart';

class ScreenTimeRepositoryImpl implements IScreenTimeRepository {
  SupabaseClient get _client => SupabaseService.client;

  ScreenTimeRepositoryImpl();

  @override
  Future<(List<ScreenTimeRecord>?, Failure?)> getRecords(String childId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('screen_time_records')
          .select()
          .eq('child_id', childId)
          .gte('date', startOfDay.toIso8601String())
          .lt('date', endOfDay.toIso8601String());

      final records = (response as List)
          .map((json) => ScreenTimeRecord.fromJson(json as Map<String, dynamic>))
          .toList();

      return (records, null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(DailyScreenTime?, Failure?)> getDailyScreenTime(String childId, DateTime date) async {
    try {
      final (records, failure) = await getRecords(childId, date);
      if (failure != null) return (null, failure);

      final totalMinutes = records?.fold(0, (sum, r) => sum + r.durationMinutes) ?? 0;

      return (DailyScreenTime(
        childId: childId,
        date: date,
        totalMinutes: totalMinutes,
        appBreakdown: {},
      ), null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(ScreenTimeSettings?, Failure?)> getSettings(String childId) async {
    try {
      final response = await _client
          .from('screen_time_settings')
          .select()
          .eq('child_id', childId)
          .maybeSingle();

      if (response == null) {
        return (ScreenTimeSettings(
          childId: childId,
          dailyLimitMinutes: 120,
          isEnabled: true,
          createdAt: DateTime.now(),
        ), null);
      }

      return (ScreenTimeSettings.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(ScreenTimeSettings?, Failure?)> saveSettings(ScreenTimeSettings settings) async {
    try {
      final json = settings.toJson();

      final response = await _client
          .from('screen_time_settings')
          .upsert(json)
          .select()
          .single();

      return (ScreenTimeSettings.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> recordUsage(
    String childId,
    String appPackage, {
    String? appName,
    int durationMinutes = 0,
  }) async {
    try {
      await _client
          .from('screen_time_records')
          .insert({
            'child_id': childId,
            'app_package': appPackage,
            'app_name': appName,
            'duration_minutes': durationMinutes,
            'date': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          });

      return (true, null);
    } catch (e) {
      return (false, Failure.database(message: e.toString()));
    }
  }
}