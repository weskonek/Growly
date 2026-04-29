import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/child_activity_providers.dart';

class InsightTab extends ConsumerWidget {
  final String childId;

  const InsightTab({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(screenTimeLast7Provider(childId));
    final sessionsAsync = ref.watch(learningSessionsLast7Provider(childId));
    final progressAsync = ref.watch(childLearningProgressProvider(childId));
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(screenTimeLast7Provider(childId));
        ref.invalidate(learningSessionsLast7Provider(childId));
        ref.invalidate(childLearningProgressProvider(childId));
      },
      child: weeklyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (weekly) {
          final insights = _generateInsights(weekly, sessionsAsync, progressAsync);

          if (insights.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 40),
                Icon(Icons.lightbulb_outline, size: 64, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'Belum Ada Insight',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Insight akan muncul setelah anak mulai menggunakan aplikasi dan belajar.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return _InsightCard(insight: insight);
            },
          );
        },
      ),
    );
  }

  List<_Insight> _generateInsights(
    WeeklyScreenTime weekly,
    AsyncValue<List<dynamic>> sessionsAsync,
    AsyncValue<List<dynamic>> progressAsync,
  ) {
    final insights = <_Insight>[];

    final avgDaily = weekly.days.isEmpty
        ? 0
        : weekly.totalMinutes ~/ weekly.days.length;

    if (avgDaily > 240) {
      insights.add(_Insight(
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
        title: 'Waktu Layar Tinggi',
        body: 'Rata-rata ${(avgDaily / 60).toStringAsFixed(1)} jam/hari. Pertimbangkan batasi waktu bermain.',
        severity: _InsightSeverity.warning,
      ));
    }

    if (avgDaily > 0 && avgDaily <= 120) {
      insights.add(_Insight(
        icon: Icons.thumb_up_alt_outlined,
        color: Colors.green,
        title: 'Waktu Layar Sehat',
        body: 'Rata-rata ${(avgDaily / 60).toStringAsFixed(1)} jam/hari. Baik untuk tumbuh kembang.',
        severity: _InsightSeverity.positive,
      ));
    }

    if (sessionsAsync.hasValue && sessionsAsync.value != null) {
      final sessions = sessionsAsync.value!;
      if (sessions.isNotEmpty) {
        insights.add(_Insight(
          icon: Icons.auto_stories,
          color: Colors.blue,
          title: 'Aktifitas Belajar',
          body: '${sessions.length} sesi belajar dalam 7 hari terakhir.',
          severity: _InsightSeverity.neutral,
        ));
      }
    }

    if (progressAsync.hasValue && progressAsync.value != null) {
      final progress = progressAsync.value!;
      final completed = progress.where((p) => p.completed).length;
      if (completed > 0) {
        insights.add(_Insight(
          icon: Icons.emoji_events_outlined,
          color: Colors.amber,
          title: 'Kemajuan Belajar',
          body: '$completed materi telah selesai. Hebat!',
          severity: _InsightSeverity.positive,
        ));
      }
    }

    final entertainmentMins = weekly.appBreakdown.entries
        .where((e) => e.key.contains('youtube') || e.key.contains('game'))
        .fold(0, (sum, e) => sum + e.value);
    if (entertainmentMins > weekly.totalMinutes * 0.7 && weekly.totalMinutes > 0) {
      insights.add(const _Insight(
        icon: Icons.balance,
        color: Colors.purple,
        title: 'Dorong Balance',
        body: '70%+ waktu dihabiskan untuk hiburan. Dorong juga kegiatan belajar.',
        severity: _InsightSeverity.suggestion,
      ));
    }

    return insights;
  }
}

enum _InsightSeverity { positive, warning, suggestion, neutral }

class _Insight {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final _InsightSeverity severity;

  const _Insight({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.severity,
  });
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(insight.icon, color: insight.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.body,
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
