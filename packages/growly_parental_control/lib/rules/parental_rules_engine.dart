import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:growly_core/growly_core.dart';
import '../../domain/models/app_restriction.dart';

part 'parental_rules_engine.g.dart';

@riverpod
class ParentalRulesEngine extends _$ParentalRulesEngine {
  @override
  List<Schedule> build(String childId) {
    return [];
  }

  Future<void> loadSchedules(String childId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('schedules')
        .select()
        .eq('child_id', childId)
        .order('day_of_week');

    final schedules = (response as List)
        .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
        .toList();

    state = schedules;
  }

  Future<void> addSchedule(Schedule schedule) async {
    final supabase = Supabase.instance.client;
    await supabase.from('schedules').insert(schedule.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('schedules')
        .update(schedule.toJson())
        .eq('id', schedule.id);
    ref.invalidateSelf();
  }

  Future<void> deleteSchedule(String scheduleId) async {
    final supabase = Supabase.instance.client;
    await supabase.from('schedules').delete().eq('id', scheduleId);
    ref.invalidateSelf();
  }

  Schedule? getActiveSchedule() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    for (final schedule in state) {
      if (schedule.dayOfWeek == dayOfWeek && schedule.isActive) {
        return schedule;
      }
    }
    return null;
  }

  ScreenTimeMode getCurrentMode() {
    final activeSchedule = getActiveSchedule();
    if (activeSchedule == null) return ScreenTimeMode.normal;

    switch (activeSchedule.mode.toLowerCase()) {
      case 'learning':
        return ScreenTimeMode.learning;
      case 'break':
        return ScreenTimeMode.breakTime;
      case 'school':
        return ScreenTimeMode.schoolMode;
      case 'sleep':
        return ScreenTimeMode.sleepMode;
      default:
        return ScreenTimeMode.normal;
    }
  }

  bool isAppAllowed(String appPackage) {
    final activeSchedule = getActiveSchedule();
    if (activeSchedule == null) return true;

    final mode = getCurrentMode();
    switch (mode) {
      case ScreenTimeMode.learning:
        // Only learning apps allowed
        return _isLearningApp(appPackage);
      case ScreenTimeMode.schoolMode:
        // Only school-related apps allowed
        return _isSchoolApp(appPackage);
      case ScreenTimeMode.sleepMode:
        // No apps allowed
        return false;
      default:
        return true;
    }
  }

  bool _isLearningApp(String package) {
    final learningApps = [
      'com.growly.child',
      'com.khanacademy',
      'com.duolingo',
    ];
    return learningApps.any((app) => package.contains(app));
  }

  bool _isSchoolApp(String package) {
    final schoolApps = [
      'com.growly.child',
      'com.google.android.apps.calculator',
      'com.google.android.apps.docs',
    ];
    return schoolApps.any((app) => package.contains(app));
  }

  Future<void> syncRules(String childId) async {
    final supabase = Supabase.instance.client;

    // Sync all schedules to local
    final response = await supabase
        .from('schedules')
        .select()
        .eq('child_id', childId);

    state = (response as List)
        .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}