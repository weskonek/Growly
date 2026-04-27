import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';

class ScreenTimeData {
  final String childId;
  final DateTime date;
  final int totalMinutes;
  final int learningMinutes;
  final int entertainmentMinutes;
  final Map<String, int> appBreakdown;

  const ScreenTimeData({
    required this.childId,
    required this.date,
    required this.totalMinutes,
    required this.learningMinutes,
    required this.entertainmentMinutes,
    required this.appBreakdown,
  });
}

class ScreenTimeMonitorNotifier extends AsyncNotifier<ScreenTimeData> {
  @override
  Future<ScreenTimeData> build() async {
    return _loadScreenTimeData('');
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
      appBreakdown: const {
        'Growly': 30,
        'YouTube Kids': 15,
      },
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final screenTimeMonitorProvider =
    AsyncNotifierProvider<ScreenTimeMonitorNotifier, ScreenTimeData>(() {
  return ScreenTimeMonitorNotifier();
});

final weeklyScreenTimeProvider =
    FutureProvider.family<DailyScreenTime, String>((ref, childId) async {
  final now = DateTime.now();
  int totalMinutes = 0;
  int learningMinutes = 0;
  int entertainmentMinutes = 0;

  // Aggregate last 7 days
  for (int i = 0; i < 7; i++) {
    // Mock data for now
    totalMinutes += 45;
    learningMinutes += 30;
    entertainmentMinutes += 15;
  }

  return DailyScreenTime(
    childId: childId,
    date: now,
    totalMinutes: totalMinutes,
    learningMinutes: learningMinutes,
    entertainmentMinutes: entertainmentMinutes,
  );
});

bool isScreenTimeOverLimit(ScreenTimeData data, int limitMinutes) {
  return data.totalMinutes >= limitMinutes;
}

double getScreenTimeProgress(ScreenTimeData data, int limitMinutes) {
  if (limitMinutes == 0) return 0;
  return (data.totalMinutes / limitMinutes).clamp(0.0, 1.0);
}