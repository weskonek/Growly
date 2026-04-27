import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:growly_core/growly_core.dart';

class ParentalRulesEngine {
  final String childId;
  List<Schedule> _schedules = [];

  ParentalRulesEngine(this.childId);

  List<Schedule> get schedules => _schedules;

  Future<void> loadSchedules() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('schedules')
        .select()
        .eq('child_id', childId)
        .order('day_of_week');

    _schedules = (response as List)
        .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    final supabase = Supabase.instance.client;
    await supabase.from('schedules').insert(schedule.toJson());
    await loadSchedules();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('schedules')
        .update(schedule.toJson())
        .eq('id', schedule.id);
    await loadSchedules();
  }

  Future<void> deleteSchedule(String scheduleId) async {
    final supabase = Supabase.instance.client;
    await supabase.from('schedules').delete().eq('id', scheduleId);
    await loadSchedules();
  }

  Schedule? getActiveSchedule() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    for (final schedule in _schedules) {
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
        return _isLearningApp(appPackage);
      case ScreenTimeMode.schoolMode:
        return _isSchoolApp(appPackage);
      case ScreenTimeMode.sleepMode:
        return false;
      default:
        return true;
    }
  }

  bool _isLearningApp(String package) {
    const learningApps = [
      'com.growly.child',
      'com.khanacademy',
      'com.duolingo',
    ];
    return learningApps.any((app) => package.contains(app));
  }

  bool _isSchoolApp(String package) {
    const schoolApps = [
      'com.growly.child',
      'com.google.android.apps.calculator',
      'com.google.android.apps.docs',
    ];
    return schoolApps.any((app) => package.contains(app));
  }
}

class ParentalRulesState {
  final String childId;
  final List<Schedule> schedules;
  final bool isLoading;
  final String? error;

  const ParentalRulesState({
    required this.childId,
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  ParentalRulesState copyWith({
    String? childId,
    List<Schedule>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return ParentalRulesState(
      childId: childId ?? this.childId,
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ParentalRulesNotifier extends StateNotifier<ParentalRulesState> {
  ParentalRulesNotifier(String childId) : super(ParentalRulesState(childId: childId));

  Future<void> loadSchedules() async {
    state = state.copyWith(isLoading: true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('schedules')
          .select()
          .eq('child_id', state.childId)
          .order('day_of_week');

      final schedules = (response as List)
          .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(schedules: schedules, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Schedule? getActiveSchedule() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    for (final schedule in state.schedules) {
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
}

final parentalRulesProvider =
    StateNotifierProvider.family<ParentalRulesNotifier, ParentalRulesState, String>(
        (ref, childId) {
  return ParentalRulesNotifier(childId);
});