import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../../providers/child_activity_providers.dart';

class InsightTab extends ConsumerWidget {
  final String childId;

  const InsightTab({super.key, required this.childId});

  static const _engine = ChildInsightEngine();

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
          final sessions = sessionsAsync.valueOrNull ?? [];
          final progress = progressAsync.valueOrNull ?? [];
          final completedLessons = progress.where((p) => p.completed).length;

          final avgDaily = weekly.days.isEmpty
              ? 0
              : weekly.totalMinutes ~/ weekly.days.length;

          final insights = _engine.analyze(
            avgDailyMinutes: avgDaily,
            totalMinutes7Days: weekly.totalMinutes,
            daysWithData: weekly.days.length,
            appBreakdown: weekly.appBreakdown,
            learningSessionsCount: sessions.length,
            completedLessons: completedLessons,
          );

          if (insights.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 40),
                Icon(Icons.lightbulb_outline,
                    size: 64, color: cs.onSurfaceVariant),
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
}

class _InsightCard extends StatelessWidget {
  final ChildInsight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _colorForType(insight.type);

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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconForType(insight.type), color: color, size: 24),
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

  Color _colorForType(InsightType type) {
    switch (type) {
      case InsightType.screenTimeHigh:
      case InsightType.entertainmentHeavy:
      case InsightType.learningInactive:
        return Colors.orange;
      case InsightType.screenTimeHealthy:
      case InsightType.learningProgress:
      case InsightType.balanceGood:
        return Colors.green;
      case InsightType.learningActive:
        return Colors.blue;
      case InsightType.screenTimeLow:
        return Colors.grey;
    }
  }

  IconData _iconForType(InsightType type) {
    switch (type) {
      case InsightType.screenTimeHigh:
        return Icons.warning_amber_rounded;
      case InsightType.screenTimeHealthy:
        return Icons.thumb_up_alt_outlined;
      case InsightType.screenTimeLow:
        return Icons.phone_android_outlined;
      case InsightType.entertainmentHeavy:
        return Icons.balance;
      case InsightType.learningActive:
        return Icons.auto_stories;
      case InsightType.learningInactive:
        return Icons.lightbulb_outline;
      case InsightType.learningProgress:
        return Icons.emoji_events_outlined;
      case InsightType.balanceGood:
        return Icons.check_circle_outline;
    }
  }
}
