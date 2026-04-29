import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart' hide Badge;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parent_app/features/dashboard/providers/dashboard_providers.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _checkedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _subscribeRealtime();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOnboarding());
  }

  Future<void> _checkOnboarding() async {
    if (_checkedOnboarding) return;
    _checkedOnboarding = true;
    final isCompleted = await ref.read(onboardingCompletedProvider.future);
    if (!isCompleted && mounted) {
      context.go('/onboarding');
    }
  }

  void _subscribeRealtime() {
    Supabase.instance.client
        .channel('dashboard-parent-${Supabase.instance.client.auth.currentUser?.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'screen_time_records',
          callback: (payload) {
            ref.invalidate(dashboardStatsProvider);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'learning_sessions',
          callback: (payload) {
            ref.invalidate(dashboardStatsProvider);
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(dashboardStatsProvider);
    final childrenAsync = ref.watch(childrenListProvider);
    final risksAsync = ref.watch(riskIndicatorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unreadAsync = ref.watch(unreadNotificationCountProvider);
              return IconButton(
                icon: unreadAsync.when(
                  data: (count) => count > 0
                      ? Badge(
                          label: Text(count > 99 ? '99+' : '$count'),
                          child: const Icon(Icons.notifications_outlined),
                        )
                      : const Icon(Icons.notifications_outlined),
                  loading: () => const Icon(Icons.notifications_outlined),
                  error: (_, __) => const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => context.go('/notifications'),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(childrenListProvider);
          ref.invalidate(riskIndicatorsProvider);
          ref.invalidate(dashboardInsightsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting
            Text(
              'Halo, Orang Tua! 👋',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Lihat perkembangan anak hari ini',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),

            // Stats cards
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (stats) {
                final screenMinutes = stats['totalScreenTimeMinutes'] as int? ?? 0;
                final sessions = stats['totalSessions'] as int? ?? 0;
                final badges = stats['totalBadges'] as int? ?? 0;
                final childCount = stats['childCount'] as int? ?? 0;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Screen Time',
                            value: '${screenMinutes ~/ 60}j ${screenMinutes % 60}m',
                            icon: Icons.access_time,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Sesi Belajar',
                            value: '$sessions',
                            icon: Icons.school_outlined,
                            color: const Color(0xFF2ECC71),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Badges',
                            value: '$badges',
                            icon: Icons.emoji_events_outlined,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Anak',
                            value: '$childCount',
                            icon: Icons.child_care,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Risk indicators
            risksAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (risks) {
                if (risks.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Peringatan AI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.orange,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...risks.map((risk) => Card(
                          color: risk.color.withValues(alpha: 0.08),
                          child: ListTile(
                            leading: Icon(risk.icon, color: risk.color),
                            title: Row(
                              children: [
                                Expanded(child: Text(risk.message)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: risk.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    risk.childName,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: risk.color),
                                  ),
                                ),
                              ],
                            ),
                            dense: true,
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            // Children section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profil Anak',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go('/children'),
                  child: const Text('Lihat semua'),
                ),
              ],
            ),

            childrenAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Gagal: $e'),
              data: (children) {
                if (children.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.child_care, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text('Belum ada profil anak'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context.go('/children/add'),
                            child: const Text('Tambah Anak'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: children.map((child) {
                    return _DashboardChildCard(
                      child: child,
                      screenTimeAsync: ref.watch(todayScreenTimeProvider(child.id)),
                      onTap: () => context.go('/children/detail/${child.id}'),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // AI Insights
            Text(
              'AI Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            _DashboardInsightsSection(
              insightsAsync: ref.watch(dashboardInsightsProvider),
              onRefresh: () => ref.invalidate(dashboardInsightsProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DashboardChildCard extends StatelessWidget {
  final ChildProfile child;
  final AsyncValue<int> screenTimeAsync;
  final VoidCallback onTap;

  const _DashboardChildCard({
    required this.child,
    required this.screenTimeAsync,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Text(child.avatarUrl ?? '👦', style: const TextStyle(fontSize: 24)),
        ),
        title: Text(child.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: screenTimeAsync.when(
          loading: () => const Text('Memuat...'),
          error: (_, __) => const Text(''),
          data: (minutes) => Text(
            '${child.ageDisplay} • Layar: ${minutes ~/ 60}j ${minutes % 60}m',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _DashboardInsightsSection extends StatelessWidget {
  final AsyncValue<List<({String childName, String childId, ChildInsight insight})>> insightsAsync;
  final VoidCallback onRefresh;

  const _DashboardInsightsSection({
    required this.insightsAsync,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return insightsAsync.when(
      loading: () => Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text('Gagal memuat insight: $e')),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
              ),
            ],
          ),
        ),
      ),
      data: (insights) {
        if (insights.isEmpty) {
          return Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Insight Mingguan',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada data cukup. Aktifkan HP anak untuk mulai memantau.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final item in insights)
              _InsightTile(
                childName: item.childName,
                childId: item.childId,
                insight: item.insight,
              ),
          ],
        );
      },
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String childName;
  final String childId;
  final ChildInsight insight;

  const _InsightTile({
    required this.childName,
    required this.childId,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _colorForType(insight.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go('/children/detail/$childId'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconForType(insight.type), color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          insight.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            childName,
                            style: TextStyle(fontSize: 10, color: cs.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      insight.body,
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.3),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
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