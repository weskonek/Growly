import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../children/providers/child_providers.dart';
import '../../children/providers/child_activity_providers.dart';

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

  // Read providers once outside the loop — ref.watch inside async loops causes unnecessary rebuilds
  final stRepo = ref.read(screenTimeRepositoryProvider);
  final lrRepo = ref.read(learningRepositoryProvider);
  final br = ref.read(badgeRepositoryProvider);

  int totalScreenMinutes = 0;
  int totalSessions = 0;
  int totalBadges = 0;

  for (final child in children) {
    final (st, _) = await stRepo.getDailyScreenTime(child.id, DateTime.now());
    totalScreenMinutes += st?.totalMinutes ?? 0;

    final (stats, _) = await lrRepo.getStats(child.id);
    totalSessions += (stats?['totalSessions'] as int? ?? 0);

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
final riskIndicatorsProvider =
    FutureProvider<List<RiskIndicator>>((ref) async {
  final user = SupabaseService.client.auth.currentUser;
  if (user == null) return [];

  final childrenAsync = ref.watch(childrenListProvider);
  final children = childrenAsync.valueOrNull ?? [];
  if (children.isEmpty) return [];

  final stRepo = ref.read(screenTimeRepositoryProvider);
  final lrRepo = ref.read(learningRepositoryProvider);
  final risks = <RiskIndicator>[];

  for (final child in children) {
    final (st, _) = await stRepo.getDailyScreenTime(child.id, DateTime.now());
    final screenMinutes = st?.totalMinutes ?? 0;

    final (stats, _) = await lrRepo.getStats(child.id);
    final learningMinutes = stats?['learningMinutes'] as int? ?? 0;

    // Rule 1: Screen time > 3 jam hari ini → 🔴 high
    if (screenMinutes > 180) {
      risks.add(RiskIndicator(
        childName: child.name,
        childId: child.id,
        message: '${child.name} sudah ${screenMinutes ~/ 60}j di layar — lebih dari 3 jam.',
        level: RiskLevel.high,
      ));
    }

    // Rule 2: Screen time > 2 jam + learning < 30 menit → 🟡 medium
    if (screenMinutes > 120 && learningMinutes < 30) {
      risks.add(RiskIndicator(
        childName: child.name,
        childId: child.id,
        message: '${child.name} sudah lebih dari 2 jam di layar hari ini.',
        level: RiskLevel.medium,
      ));
    }

    // Rule 3: Belum belajar + screen > 1 jam → 🟡 medium
    if (learningMinutes == 0 && screenMinutes > 60) {
      risks.add(RiskIndicator(
        childName: child.name,
        childId: child.id,
        message: '${child.name} belum belajar sama sekali hari ini.',
        level: RiskLevel.medium,
      ));
    }

    // Rule 4: Cek 7 hari trend — screen time naik > 50% vs minggu lalu
    final now = DateTime.now();
    int totalLast7 = 0;
    int totalPrev7 = 0;

    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      final (daily, _) = await stRepo.getDailyScreenTime(child.id, d);
      totalLast7 += daily?.totalMinutes ?? 0;
    }
    for (int i = 7; i < 14; i++) {
      final d = now.subtract(Duration(days: i));
      final (daily, _) = await stRepo.getDailyScreenTime(child.id, d);
      totalPrev7 += daily?.totalMinutes ?? 0;
    }

    if (totalPrev7 > 0 && totalLast7 > totalPrev7 * 1.5) {
      risks.add(RiskIndicator(
        childName: child.name,
        childId: child.id,
        message:
            'Waktu layar ${child.name} naik >50% dibanding minggu lalu.',
        level: RiskLevel.medium,
      ));
    }

    // Rule 5: Belajar 0 sesi dalam 7 hari → 🔴 high
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final (sessions, _) = await lrRepo.getSessions(
      child.id,
      from: sevenDaysAgo,
      to: now,
    );
    if ((sessions ?? []).isEmpty) {
      risks.add(RiskIndicator(
        childName: child.name,
        childId: child.id,
        message: '${child.name} belum ada sesi belajar dalam 7 hari terakhir.',
        level: RiskLevel.high,
      ));
    }
  }

  // Sort: high first, then medium, then low
  risks.sort((a, b) => a.level.index.compareTo(b.level.index));
  return risks;
});

/// Aggregated dashboard AI insights — up to 2 insights per child, max 5 total
final dashboardInsightsProvider =
    FutureProvider<List<({String childName, String childId, ChildInsight insight})>>((ref) async {
  final childrenAsync = ref.watch(childrenListProvider);
  final children = childrenAsync.valueOrNull ?? [];
  if (children.isEmpty) return [];

  const engine = ChildInsightEngine();
  final results =
      <({String childName, String childId, ChildInsight insight})>[];

  for (final child in children) {
    final weekly = await ref.read(screenTimeLast7Provider(child.id).future);
    final sessions =
        await ref.read(learningSessionsLast7Provider(child.id).future);
    final progress =
        await ref.read(childLearningProgressProvider(child.id).future);

    final avgDaily = weekly.days.isEmpty
        ? 0
        : weekly.totalMinutes ~/ weekly.days.length;
    final completedLessons = progress.where((p) => p.completed).length;

    final insights = engine.analyze(
      avgDailyMinutes: avgDaily,
      totalMinutes7Days: weekly.totalMinutes,
      daysWithData: weekly.days.length,
      appBreakdown: weekly.appBreakdown,
      learningSessionsCount: sessions.length,
      completedLessons: completedLessons,
    );

    for (final insight in insights.take(2)) {
      results.add((
        childName: child.name,
        childId: child.id,
        insight: insight,
      ));
    }
  }

  // Sort by priority and take top 5
  results.sort((a, b) => b.insight.priority.compareTo(a.insight.priority));
  return results.take(5).toList();
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