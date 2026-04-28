import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../children/providers/child_providers.dart';

/// App restrictions for a child
final appRestrictionsProvider =
    FutureProvider.family<List<AppRestriction>, String>((ref, childId) async {
  final repository = ref.watch(appRestrictionRepositoryProvider);
  final (restrictions, _) = await repository.getRestrictions(childId);
  return restrictions ?? [];
});

/// App restrictions notifier for CRUD
class AppRestrictionsNotifier extends AsyncNotifier<List<AppRestriction>> {
  @override
  Future<List<AppRestriction>> build() async {
    final childId = ref.watch(selectedChildIdProvider);
    if (childId == null) return [];
    final repository = ref.watch(appRestrictionRepositoryProvider);
    final (restrictions, _) = await repository.getRestrictions(childId);
    return restrictions ?? [];
  }

  Future<void> saveRestriction(AppRestriction restriction) async {
    final repository = ref.read(appRestrictionRepositoryProvider);
    await repository.saveRestriction(restriction);
    ref.invalidateSelf();
  }

  Future<void> deleteRestriction(String restrictionId) async {
    final repository = ref.read(appRestrictionRepositoryProvider);
    await repository.deleteRestriction(restrictionId);
    ref.invalidateSelf();
  }
}

final appRestrictionsNotifierProvider =
    AsyncNotifierProvider<AppRestrictionsNotifier, List<AppRestriction>>(() {
  return AppRestrictionsNotifier();
});

/// Schedules for a child
final schedulesProvider =
    FutureProvider.family<List<Schedule>, String>((ref, childId) async {
  final repository = ref.watch(appRestrictionRepositoryProvider);
  final (schedules, _) = await repository.getSchedules(childId);
  return schedules ?? [];
});

/// Schedules notifier for CRUD
class SchedulesNotifier extends AsyncNotifier<List<Schedule>> {
  @override
  Future<List<Schedule>> build() async {
    final childId = ref.watch(selectedChildIdProvider);
    if (childId == null) return [];
    final repository = ref.watch(appRestrictionRepositoryProvider);
    final (schedules, _) = await repository.getSchedules(childId);
    return schedules ?? [];
  }

  Future<void> saveSchedule(Schedule schedule) async {
    final repository = ref.read(appRestrictionRepositoryProvider);
    await repository.saveSchedule(schedule);
    ref.invalidateSelf();
  }

  Future<void> deleteSchedule(String scheduleId) async {
    final repository = ref.read(appRestrictionRepositoryProvider);
    await repository.deleteSchedule(scheduleId);
    ref.invalidateSelf();
  }
}

final schedulesNotifierProvider =
    AsyncNotifierProvider<SchedulesNotifier, List<Schedule>>(() {
  return SchedulesNotifier();
});

/// Screen time limit for a child (from app_restrictions schedule_limits)
final screenTimeLimitProvider =
    FutureProvider.family<int, String>((ref, childId) async {
  final restrictions = await ref.watch(appRestrictionsProvider(childId).future);
  if (restrictions.isEmpty) return 120; // default 2 hours

  final dailyLimit = restrictions
      .where((r) => r.scheduleLimits['daily_limit'] != null)
      .fold<int>(120, (acc, r) => r.scheduleLimits['daily_limit'] as int? ?? acc);
  return dailyLimit;
});

/// School mode schedules (filtered)
final schoolModeSchedulesProvider =
    FutureProvider.family<List<Schedule>, String>((ref, childId) async {
  final schedules = await ref.watch(schedulesProvider(childId).future);
  return schedules.where((s) => s.mode == 'school').toList();
});