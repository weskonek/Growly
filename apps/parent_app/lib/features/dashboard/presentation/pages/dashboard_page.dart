import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parent_app/features/children/providers/child_providers.dart';
import 'package:parent_app/features/dashboard/providers/dashboard_providers.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    Supabase.instance.client
        .channel('dashboard-parent-${Supabase.instance.client.auth.currentUser?.id}')
        .onpostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'screen_time_records',
          callback: (payload) {
            ref.invalidate(dashboardStatsProvider);
          },
        )
        .onpostgresChanges(
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
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(childrenListProvider);
          ref.invalidate(riskIndicatorsProvider);
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
                          color: Colors.orange.shade50,
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber, color: Colors.orange),
                            title: Text(risk),
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
            Card(
              color: cs.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: cs.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Insight Mingguan',
                          style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pantausan pola belajar anak setiap minggu untuk insight yang lebih personal.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
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