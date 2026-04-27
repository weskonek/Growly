import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:growly_core/growly_core.dart';
import '../../domain/models/screen_time.dart';

part 'screen_time_monitor.g.dart';

@riverpod
class ScreenTimeMonitor extends _$ScreenTimeMonitor {
  @override
  Future<ScreenTimeData> build(String childId) async {
    return _loadScreenTimeData(childId);
  }

  Future<ScreenTimeData> _loadScreenTimeData(String childId) async {
    // In production, this would fetch from native API
    // For now, return mock data
    return ScreenTimeData(
      childId: childId,
      date: DateTime.now(),
      totalMinutes: 45,
      learningMinutes: 30,
      entertainmentMinutes: 15,
      appBreakdown: {
        'Growly': 30,
        'YouTube Kids': 15,
      },
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<DailyScreenTime> getWeeklyData(String childId) async {
    final now = DateTime.now();
    int totalMinutes = 0;
    int learningMinutes = 0;
    int entertainmentMinutes = 0;

    // Aggregate last 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final daily = await _loadScreenTimeData(childId);
      totalMinutes += daily.totalMinutes;
      learningMinutes += daily.learningMinutes;
      entertainmentMinutes += daily.entertainmentMinutes;
    }

    return DailyScreenTime(
      childId: childId,
      date: now,
      totalMinutes: totalMinutes,
      learningMinutes: learningMinutes,
      entertainmentMinutes: entertainmentMinutes,
    );
  }

  bool isOverLimit(ScreenTimeData data, int limitMinutes) {
    return data.totalMinutes >= limitMinutes;
  }

  double getProgress(ScreenTimeData data, int limitMinutes) {
    if (limitMinutes == 0) return 0;
    return (data.totalMinutes / limitMinutes).clamp(0.0, 1.0);
  }
}

class ScreenTimeData {
  final String childId;
  final DateTime date;
  final int totalMinutes;
  final int learningMinutes;
  final int entertainmentMinutes;
  final Map<String, int> appBreakdown;

  ScreenTimeData({
    required this.childId,
    required this.date,
    required this.totalMinutes,
    required this.learningMinutes,
    required this.entertainmentMinutes,
    required this.appBreakdown,
  });
}