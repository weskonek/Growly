import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../children/providers/child_providers.dart';

/// Today's screen time for a child (aggregated minutes)
final todayScreenTimeProvider =
    FutureProvider.family<int, String>((ref, childId) async {
  final repository = ref.watch(screenTimeRepositoryProvider);
  final (record, _) = await repository.getDailyScreenTime(childId, DateTime.now());
  return record?.totalMinutes ?? 0;
});

/// Learning stats for a child
final learningStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, childId) async {
  final repository = ref.watch(learningRepositoryProvider);
  final (stats, failure) = await repository.getStats(childId);
  if (failure != null) return {};
  return stats ?? {};
});

/// Dashboard aggregate stats across all children
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = SupabaseService.client.auth.currentUser;
  if (user == null) return {};

  final childrenAsync = ref.watch(childrenListProvider);
  final children = childrenAsync.valueOrNull ?? [];

  int totalScreenMinutes = 0;
  int totalSessions = 0;
  int totalBadges = 0;

  for (final child in children) {
    final stRepo = ref.watch(screenTimeRepositoryProvider);
    final (st, _) = await stRepo.getDailyScreenTime(child.id, DateTime.now());
    totalScreenMinutes += st?.totalMinutes ?? 0;

    final lrRepo = ref.watch(learningRepositoryProvider);
    final (stats, _) = await lrRepo.getStats(child.id);
    totalSessions += (stats?['totalSessions'] as int? ?? 0);

    final br = ref.watch(badgeRepositoryProvider);
    final (badges, _) = await br.getBadges(child.id);
    totalBadges += badges?.length ?? 0;
  }

  return {
    'totalScreenTimeMinutes': totalScreenMinutes,
    'totalSessions': totalSessions,
    'totalBadges': totalBadges,
    'childCount': children.length,
  };
});

/// Risk indicators based on screen time vs learning balance
final riskIndicatorsProvider = FutureProvider<List<String>>((ref) async {
  final user = SupabaseService.client.auth.currentUser;
  if (user == null) return [];

  final childrenAsync = ref.watch(childrenListProvider);
  final children = childrenAsync.valueOrNull ?? [];
  final risks = <String>[];

  for (final child in children) {
    final stRepo = ref.watch(screenTimeRepositoryProvider);
    final (st, _) = await stRepo.getDailyScreenTime(child.id, DateTime.now());
    final screenMinutes = st?.totalMinutes ?? 0;

    final lrRepo = ref.watch(learningRepositoryProvider);
    final (stats, _) = await lrRepo.getStats(child.id);
    final learningMinutes = stats?['learningMinutes'] as int? ?? 0;

    if (screenMinutes > 120 && learningMinutes < 30) {
      risks.add('${child.name} sudah lebih dari 2 jam di layar hari ini');
    }
    if (learningMinutes == 0 && screenMinutes > 60) {
      risks.add('${child.name} belum belajar sama sekali hari ini');
    }
  }
  return risks;
});

/// Weekly screen time for a child (last 7 days)
final weeklyScreenTimeProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, childId) async {
  final client = SupabaseService.client;
  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));

  try {
    final List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(
      await client
          .from('screen_time_records')
          .select('date, duration_minutes')
          .eq('child_id', childId)
          .gte('date', sevenDaysAgo.toIso8601String().split('T')[0])
          .lte('date', now.toIso8601String().split('T')[0])
          .order('date'),
    );
    return result;
  } catch (e) {
    return [];
  }
});