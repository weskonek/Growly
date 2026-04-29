enum InsightType {
  screenTimeHigh,
  screenTimeHealthy,
  screenTimeLow,
  entertainmentHeavy,
  learningActive,
  learningProgress,
  learningInactive,
  balanceGood,
}

class ChildInsight {
  final InsightType type;
  final String title;
  final String body;
  final String? icon;
  final int priority;

  const ChildInsight({
    required this.type,
    required this.title,
    required this.body,
    this.icon,
    this.priority = 0,
  });
}

class ChildInsightEngine {
  const ChildInsightEngine();

  List<ChildInsight> analyze({
    required int avgDailyMinutes,
    required int totalMinutes7Days,
    required int daysWithData,
    required Map<String, int> appBreakdown,
    required int learningSessionsCount,
    required int completedLessons,
  }) {
    final insights = <ChildInsight>[];

    // Screen time analysis
    if (avgDailyMinutes > 240) {
      insights.add(ChildInsight(
        type: InsightType.screenTimeHigh,
        title: 'Waktu Layar Tinggi',
        body:
            'Rata-rata ${(avgDailyMinutes / 60).toStringAsFixed(1)} jam/hari. Pertimbangkan batasi waktu bermain.',
        icon: '⚠️',
        priority: 10,
      ));
    } else if (avgDailyMinutes > 0 && avgDailyMinutes <= 120) {
      insights.add(ChildInsight(
        type: InsightType.screenTimeHealthy,
        title: 'Waktu Layar Sehat',
        body:
            'Rata-rata ${(avgDailyMinutes / 60).toStringAsFixed(1)} jam/hari. Baik untuk tumbuh kembang.',
        icon: '✅',
        priority: 5,
      ));
    } else if (avgDailyMinutes == 0 && daysWithData > 0) {
      insights.add(ChildInsight(
        type: InsightType.screenTimeLow,
        title: 'Belum Ada Data Aktif',
        body: 'Tidak ada data waktu layar tercatat hari ini.',
        icon: '📱',
        priority: 0,
      ));
    }

    // Entertainment vs learning balance
    final entertainmentMins = appBreakdown.entries
        .where((e) =>
            e.key.contains('youtube') ||
            e.key.contains('game') ||
            e.key.contains('tiktok') ||
            e.key.contains('instagram'))
        .fold(0, (sum, e) => sum + e.value);

    if (totalMinutes7Days > 0 &&
        entertainmentMins > totalMinutes7Days * 0.7) {
      insights.add(ChildInsight(
        type: InsightType.entertainmentHeavy,
        title: 'Dorong Balance',
        body:
            '70%+ waktu dihabiskan untuk hiburan. Dorong juga kegiatan belajar.',
        icon: '⚖️',
        priority: 7,
      ));
    } else if (learningSessionsCount > 0 &&
        entertainmentMins < totalMinutes7Days * 0.5) {
      insights.add(ChildInsight(
        type: InsightType.balanceGood,
        title: 'Aktivitas Seimbang',
        body: 'Waktu belajar dan hiburan cukup seimbang. Bagus!',
        icon: '🎯',
        priority: 3,
      ));
    }

    // Learning activity
    if (learningSessionsCount > 0) {
      insights.add(ChildInsight(
        type: InsightType.learningActive,
        title: 'Aktifitas Belajar',
        body: '$learningSessionsCount sesi belajar dalam 7 hari terakhir.',
        icon: '📚',
        priority: 4,
      ));
    } else if (daysWithData >= 3 && learningSessionsCount == 0) {
      insights.add(ChildInsight(
        type: InsightType.learningInactive,
        title: 'Belum Ada Kegiatan Belajar',
        body:
            'Tidak ada sesi belajar tercatat. Dorong anak untuk mulai belajar hari ini!',
        icon: '💡',
        priority: 8,
      ));
    }

    // Learning progress
    if (completedLessons > 0) {
      insights.add(ChildInsight(
        type: InsightType.learningProgress,
        title: 'Kemajuan Belajar',
        body: '$completedLessons materi telah selesai. Hebat!',
        icon: '🏆',
        priority: 3,
      ));
    }

    // Sort by priority descending
    insights.sort((a, b) => b.priority.compareTo(a.priority));
    return insights;
  }
}
