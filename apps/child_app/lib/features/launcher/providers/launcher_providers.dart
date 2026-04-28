import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/child_router.dart';

/// Fetches child profile for the verified child ID.
/// Returns null if no child is verified yet (PIN gate shown).
final currentChildProvider = FutureProvider<ChildProfile?>((ref) async {
  final childId = ref.watch(verifiedChildIdProvider);
  if (childId == null) return null;

  final client = Supabase.instance.client;
  try {
    final response = await client
        .from('child_profiles')
        .select()
        .eq('id', childId)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return ChildProfile.fromJson(Map<String, dynamic>.from(response));
  } catch (_) {
    return null;
  }
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
  final allRestrictions = restrictions ?? [];
  final limit = allRestrictions.isNotEmpty
      ? (allRestrictions.first.scheduleLimits['daily_limit'] ?? 120)
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

/// Badge repository provider (child app)
final badgeRepositoryProvider = Provider<IBadgeRepository>((ref) {
  return BadgeRepositoryImpl();
});

/// Learning repository provider (child app)
final learningRepositoryProvider = Provider<ILearningRepository>((ref) {
  return LearningRepositoryImpl(Supabase.instance.client);
});
