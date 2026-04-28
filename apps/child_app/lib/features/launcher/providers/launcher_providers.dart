import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';

/// Currently selected child profile in child app
/// Fetches from Supabase using child ID stored in flutter_secure_storage
/// TODO: integrate with flutter_secure_storage after PIN verification
final currentChildProvider = FutureProvider<ChildProfile?>((ref) async {
  // TODO: integrate with flutter_secure_storage to get child ID after PIN verification
  // For now, returns null — child must complete PIN flow first
  return null;
});

/// App restrictions for launcher (whitelist)
final launcherRestrictionsProvider =
    FutureProvider.family<List<AppRestriction>, String>((ref, childId) async {
  final repository = ref.watch(appRestrictionRepositoryProvider);
  final (restrictions, _) = await repository.getRestrictions(childId);
  return (restrictions ?? []).where((r) => r.isAllowed).toList();
});

/// Daily screen time remaining for a child
final screenTimeRemainingProvider =
    FutureProvider.family<int, String>((ref, childId) async {
  final repository = ref.watch(screenTimeRepositoryProvider);
  final (daily, _) = await repository.getDailyScreenTime(childId, DateTime.now());

  final repository2 = ref.watch(appRestrictionRepositoryProvider);
  final (restrictions, _) = await repository2.getRestrictions(childId);
  final limit = restrictions?.isNotEmpty == true
      ? (restrictions!.first.scheduleLimits['daily_limit'] as int? ?? 120)
      : 120;

  return (limit - (daily?.totalMinutes ?? 0)).clamp(0, limit);
});

/// Active schedule for current time (learning/break/school/sleep)
final activeScheduleProvider =
    FutureProvider.family<Schedule?, String>((ref, childId) async {
  final repository = ref.watch(appRestrictionRepositoryProvider);
  final (schedules, _) = await repository.getSchedules(childId);

  final now = DateTime.now();
  final today = now.weekday; // 1=Mon, 7=Sun
  final h = now.hour.toString().padLeft(2, '0');
  final m = now.minute.toString().padLeft(2, '0');
  final currentTime = '$h:$m';

  if (schedules == null) return null;
  for (final s in schedules) {
    if (s.dayOfWeek == today &&
        s.isEnabled &&
        currentTime.compareTo(s.startTime) >= 0 &&
        currentTime.compareTo(s.endTime) <= 0) {
      return s;
    }
  }
  return null;
});

/// App restriction repository provider (child app)
final appRestrictionRepositoryProvider =
    Provider<IAppRestrictionRepository>((ref) {
  return AppRestrictionRepositoryImpl();
});

/// Screen time repository provider (child app)
final screenTimeRepositoryProvider = Provider<IScreenTimeRepository>((ref) {
  return ScreenTimeRepositoryImpl();
});