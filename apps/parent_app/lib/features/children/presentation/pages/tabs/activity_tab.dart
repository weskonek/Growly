import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart';
import '../../../providers/child_activity_providers.dart';

class ActivityTab extends ConsumerWidget {
  final String childId;

  const ActivityTab({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(screenTimeLast7Provider(childId));
        ref.invalidate(todayScreenTimeProvider(childId));
        ref.invalidate(learningSessionsLast7Provider(childId));
        ref.invalidate(todayAppBreakdownProvider(childId));
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TodayScreenTimeCard(childId: childId),
          const SizedBox(height: 20),
          _WeeklyBarChart(childId: childId),
          const SizedBox(height: 20),
          _AppUsageList(childId: childId),
          const SizedBox(height: 20),
          _LearningHistoryList(childId: childId),
        ],
      ),
    );
  }
}

class _TodayScreenTimeCard extends ConsumerWidget {
  final String childId;

  const _TodayScreenTimeCard({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayScreenTimeProvider(childId));
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: todayAsync.when(
          loading: () => const _CardSkeleton(),
          error: (e, _) => _ErrorCard(message: e.toString()),
          data: (today) {
            const limit = 120;
            final usedPct = (today.totalMinutes / limit).clamp(0.0, 1.0);
            final remaining = (limit - today.totalMinutes).clamp(0, limit);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: cs.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Waktu Layar Hari Ini',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDuration(today.totalMinutes),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: usedPct > 0.9
                                ? Colors.red
                                : usedPct > 0.7
                                    ? Colors.orange
                                    : cs.primary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'dari ${_formatDuration(limit)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: usedPct,
                    minHeight: 10,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      usedPct > 0.9
                          ? Colors.red
                          : usedPct > 0.7
                              ? Colors.orange
                              : cs.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  remaining > 0
                      ? '$remaining menit tersisa'
                      : 'Batas harian tercapai',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    leading: const Text('🎁', style: TextStyle(fontSize: 20)),
                    title: const Text('Kotak Hadiah Keluarga', style: TextStyle(fontSize: 13)),
                    subtitle: const Text('Kelola hadiah bintang', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => GoRouter.of(context).go('/family-rewards'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WeeklyBarChart extends ConsumerWidget {
  final String childId;

  const _WeeklyBarChart({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last7Async = ref.watch(screenTimeLast7Provider(childId));
    final prev7Async = ref.watch(screenTimePrev7Provider(childId));
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text('Perbandingan 2 Minggu',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: last7Async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (last7) {
                  final today = DateTime.now();
                  final labels = List.generate(7, (i) {
                    final d = today.subtract(Duration(days: 6 - i));
                    return _dayLabel(d.weekday);
                  });

                  final last7Bars = List.generate(7, (i) {
                    final d = today.subtract(Duration(days: 6 - i));
                    final dayData = last7.days.where((day) =>
                        day.date.year == d.year &&
                        day.date.month == d.month &&
                        day.date.day == d.day);
                    return dayData.isNotEmpty
                        ? dayData.first.totalMinutes.toDouble()
                        : 0.0;
                  });

                  final maxVal = [
                    ...last7Bars,
                    ...prev7Async.whenOrNull(data: (p) => p.days.map((d) => d.totalMinutes.toDouble())) ?? [],
                  ].fold(0.0, (a, b) => a > b ? a : b);
                  final maxY = maxVal == 0 ? 120.0 : maxVal * 1.2;

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barGroups: [
                        for (int i = 0; i < 7; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: last7Bars[i],
                                color: cs.primary.withValues(alpha: 0.9),
                                width: 16,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                              if (prev7Async.hasValue)
                                BarChartRodData(
                                  toY: prev7Async.value!.days.length > i
                                      ? prev7Async.value!.days[i].totalMinutes.toDouble()
                                      : 0,
                                  color: cs.surfaceContainerHighest,
                                  width: 16,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                            ],
                          ),
                      ],
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= 7) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  labels[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 60).toStringAsFixed(0)}j',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY / 4,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: cs.surfaceContainerHighest,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: cs.primary, label: 'Minggu ini'),
                const SizedBox(width: 16),
                _LegendDot(color: cs.surfaceContainerHighest, label: 'Minggu lalu'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppUsageList extends ConsumerWidget {
  final String childId;

  const _AppUsageList({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(todayAppBreakdownProvider(childId));
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.apps, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text('Penggunaan Aplikasi',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            breakdownAsync.when(
              loading: () => const _CardSkeleton(),
              error: (e, _) => Text('Error: $e'),
              data: (breakdown) {
                if (breakdown.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.apps_outlined,
                              size: 40, color: cs.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada data penggunaan',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final sorted = breakdown.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final total = sorted.fold(0, (sum, e) => sum + e.value);

                return Column(
                  children: [
                    for (final entry in sorted.take(8))
                      _AppUsageTile(
                        appName: entry.key.split('.').last,
                        packageName: entry.key,
                        minutes: entry.value,
                        totalMinutes: total,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AppUsageTile extends StatelessWidget {
  final String appName;
  final String packageName;
  final int minutes;
  final int totalMinutes;

  const _AppUsageTile({
    required this.appName,
    required this.packageName,
    required this.minutes,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = totalMinutes > 0 ? minutes / totalMinutes : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _iconForPackage(packageName),
                  size: 18,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalize(appName.replaceAll('_', ' ')),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDuration(minutes),
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForPackage(String pkg) {
    if (pkg.contains('youtube') || pkg.contains('video')) {
      return Icons.play_circle_outline;
    }
    if (pkg.contains('game') || pkg.contains('play')) return Icons.videogame_asset;
    if (pkg.contains('school') || pkg.contains('learn') || pkg.contains('edu')) {
      return Icons.school_outlined;
    }
    if (pkg.contains('youtube')) return Icons.play_circle_outline;
    if (pkg.contains('whatsapp') || pkg.contains('telegram') || pkg.contains('messenger')) {
      return Icons.chat_outlined;
    }
    return Icons.android;
  }
}

class _LearningHistoryList extends ConsumerWidget {
  final String childId;

  const _LearningHistoryList({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(learningSessionsLast7Provider(childId));
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text('Riwayat Belajar',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            sessionsAsync.when(
              loading: () => const _CardSkeleton(),
              error: (e, _) => Text('Error: $e'),
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.auto_stories_outlined,
                              size: 40, color: cs.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada sesi belajar',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final session in sessions.take(10))
                      _LearningSessionTile(session: session),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningSessionTile extends StatelessWidget {
  final LearningSession session;

  const _LearningSessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final subjectLabel = session.subject;
    final subjectEmoji = _emojiForSubject(session.subject);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(subjectEmoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectLabel.replaceFirst(
                      subjectLabel[0], subjectLabel[0].toUpperCase()),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${_formatDuration(session.durationMinutes)} • ${_dateLabel(session.startedAt)}',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (session.endedAt != null)
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
        ],
      ),
    );
  }

  String _emojiForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'reading':
        return '📖';
      case 'math':
        return '🔢';
      case 'science':
        return '🔬';
      case 'creative':
        return '🎨';
      case 'language':
        return '🗣️';
      default:
        return '📚';
    }
  }
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return '${s[0].toUpperCase()}${s.substring(1)}';
}

String _formatDuration(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m > 0 ? '${h}j ${m}m' : '${h}j';
}

String _dayLabel(int weekday) {
  const labels = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return labels[weekday];
}

String _dateLabel(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Hari ini';
  if (diff.inDays == 1) return 'Kemarin';
  return '${dt.day}/${dt.month}';
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: Text('Error: $message',
            style: const TextStyle(color: Colors.red, fontSize: 13)),
      ),
    );
  }
}

