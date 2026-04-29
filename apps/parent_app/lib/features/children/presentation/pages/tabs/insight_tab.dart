import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../../providers/child_activity_providers.dart';
import '../../../providers/ai_insight_provider.dart';

class InsightTab extends ConsumerWidget {
  final String childId;

  const InsightTab({super.key, required this.childId});

  static const _engine = ChildInsightEngine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(screenTimeLast7Provider(childId));
    final sessionsAsync = ref.watch(learningSessionsLast7Provider(childId));
    final progressAsync = ref.watch(childLearningProgressProvider(childId));
    final aiInsightAsync = ref.watch(aiInsightProvider(childId));
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(screenTimeLast7Provider(childId));
        ref.invalidate(learningSessionsLast7Provider(childId));
        ref.invalidate(childLearningProgressProvider(childId));
        ref.invalidate(aiInsightProvider(childId));
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

          final ruleInsights = _engine.analyze(
            avgDailyMinutes: avgDaily,
            totalMinutes7Days: weekly.totalMinutes,
            daysWithData: weekly.days.length,
            appBreakdown: weekly.appBreakdown,
            learningSessionsCount: sessions.length,
            completedLessons: completedLessons,
          );

          final hasActivity = weekly.days.isNotEmpty || sessions.isNotEmpty;
          if (!hasActivity && !aiInsightAsync.hasValue) {
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

          return ListView(padding: const EdgeInsets.all(20), children: [
            // AI-generated insight — highlighted card at top
            _AiInsightCard(aiInsightAsync: aiInsightAsync),

            if (ruleInsights.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Insight Lainnya',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ),
              for (final insight in ruleInsights) _RuleInsightCard(insight: insight),
            ],
          ]);
        },
      ),
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  final AsyncValue<AiInsight?> aiInsightAsync;

  const _AiInsightCard({required this.aiInsightAsync});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return aiInsightAsync.when(
      loading: () => Card(
        color: cs.primaryContainer.withValues(alpha: 0.4),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Generating AI insight...', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (ai) {
        if (ai == null || ai.text.isEmpty) return const SizedBox.shrink();

        return Card(
          color: cs.primaryContainer.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: cs.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: cs.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'AI Growly Insight',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                    const Spacer(),
                    if (ai.isAiGenerated)
                      _Badge(label: 'AI', color: cs.primary)
                    else
                      _Badge(label: 'Basic', color: cs.onSurfaceVariant),
                    if (ai.cached) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.cached, size: 14, color: cs.onSurfaceVariant),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ai.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _RuleInsightCard extends StatelessWidget {
  final ChildInsight insight;

  const _RuleInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _colorForType(insight.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconForType(insight.type), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    insight.body,
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, height: 1.4),
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
