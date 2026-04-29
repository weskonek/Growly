import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';

/// 7-day screen time aggregated by date
class WeeklyScreenTime {
  final String childId;
  final List<DailyScreenTime> days;
  final int totalMinutes;
  final Map<String, int> appBreakdown;

  const WeeklyScreenTime({
    required this.childId,
    required this.days,
    required this.totalMinutes,
    required this.appBreakdown,
  });

  factory WeeklyScreenTime.empty(String childId) => WeeklyScreenTime(
        childId: childId,
        days: [],
        totalMinutes: 0,
        appBreakdown: {},
      );
}

/// Aggregate a list of screen time records into a WeeklyScreenTime
WeeklyScreenTime _aggregateRecords(
    String childId, List<ScreenTimeRecord> records) {
  final Map<String, DailyScreenTime> byDate = {};
  final Map<String, int> appTotals = {};

  for (final r in records) {
    final dateKey =
        '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';

    byDate.putIfAbsent(dateKey, () => DailyScreenTime(
          childId: childId,
          date: DateTime(r.date.year, r.date.month, r.date.day),
          totalMinutes: 0,
          appBreakdown: {},
        ));

    final existing = byDate[dateKey]!;
    byDate[dateKey] = existing.copyWith(
      totalMinutes: existing.totalMinutes + r.durationMinutes,
    );

    appTotals[r.appPackage] =
        (appTotals[r.appPackage] ?? 0) + r.durationMinutes;
  }

  final days = byDate.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return WeeklyScreenTime(
    childId: childId,
    days: days,
    totalMinutes: days.fold(0, (sum, d) => sum + d.totalMinutes),
    appBreakdown: appTotals,
  );
}

/// Screen time last 7 days (including today)
final screenTimeLast7Provider =
    FutureProvider.family<WeeklyScreenTime, String>((ref, childId) async {
  final repo = ScreenTimeRepositoryImpl();
  final now = DateTime.now();
  final List<ScreenTimeRecord> allRecords = [];

  for (int i = 0; i < 7; i++) {
    final date = now.subtract(Duration(days: i));
    final (records, _) = await repo.getRecords(childId, date);
    if (records != null) allRecords.addAll(records);
  }

  return _aggregateRecords(childId, allRecords);
});

/// Previous 7-day period (days 8-14 ago) for comparison
final screenTimePrev7Provider =
    FutureProvider.family<WeeklyScreenTime, String>((ref, childId) async {
  final repo = ScreenTimeRepositoryImpl();
  final now = DateTime.now();
  final List<ScreenTimeRecord> allRecords = [];

  for (int i = 8; i < 15; i++) {
    final date = now.subtract(Duration(days: i));
    final (records, _) = await repo.getRecords(childId, date);
    if (records != null) allRecords.addAll(records);
  }

  return _aggregateRecords(childId, allRecords);
});

/// Today's screen time breakdown
final todayScreenTimeProvider =
    FutureProvider.family<DailyScreenTime, String>((ref, childId) async {
  final repo = ScreenTimeRepositoryImpl();
  final (result, _) = await repo.getDailyScreenTime(childId, DateTime.now());
  return result ??
      DailyScreenTime(
        childId: childId,
        date: DateTime.now(),
        totalMinutes: 0,
      );
});

/// Today's app breakdown (per-app, from screen_time_records)
final todayAppBreakdownProvider =
    FutureProvider.family<Map<String, int>, String>((ref, childId) async {
  final repo = ScreenTimeRepositoryImpl();
  final (records, _) = await repo.getRecords(childId, DateTime.now());
  if (records == null) return {};
  final Map<String, int> breakdown = {};
  for (final r in records) {
    breakdown[r.appPackage] =
        (breakdown[r.appPackage] ?? 0) + r.durationMinutes;
  }
  return breakdown;
});

/// Learning sessions last 7 days
final learningSessionsLast7Provider =
    FutureProvider.family<List<LearningSession>, String>((ref, childId) async {
  try {
    final repo = ref.watch(learningRepositoryProvider);
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 7));
    final (sessions, _) = await repo.getSessions(childId, from: from, to: now);
    return sessions ?? [];
  } catch (_) {
    return [];
  }
});

/// Learning progress for child
final childLearningProgressProvider =
    FutureProvider.family<List<LearningProgress>, String>((ref, childId) async {
  try {
    final repo = ref.watch(learningRepositoryProvider);
    final (progress, _) = await repo.getProgress(childId);
    return progress ?? [];
  } catch (_) {
    return [];
  }
});
