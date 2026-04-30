import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:growly_core/growly_core.dart';
import 'package:child_app/core/router/child_router.dart' show verifiedChildIdProvider;

final _childProvider = FutureProvider<ChildProfile?>((ref) async {
  final childId = ref.watch(verifiedChildIdProvider);
  if (childId == null) return null;
  final client = Supabase.instance.client;
  final resp = await client
      .from('child_profiles')
      .select()
      .eq('id', childId)
      .eq('is_active', true)
      .maybeSingle();
  if (resp == null) return null;
  return ChildProfile.fromJson(Map<String, dynamic>.from(resp));
});

final _rewardProvider = FutureProvider<RewardSystem>((ref) async {
  final child = await ref.watch(_childProvider.future);
  if (child == null) return const RewardSystem(childId: '');
  final repo = BadgeRepositoryImpl();
  final (r, _) = await repo.getRewardSystem(child.id);
  return r ?? RewardSystem(childId: child.id);
});

final _badgeRepoProvider = Provider<IBadgeRepository>((ref) => BadgeRepositoryImpl());

final _badgesCountProvider = FutureProvider<int>((ref) async {
  final child = await ref.watch(_childProvider.future);
  if (child == null) return 0;
  final repo = ref.watch(_badgeRepoProvider);
  final (badges, _) = await repo.getBadges(child.id);
  return badges?.length ?? 0;
});

class ChildHomePage extends ConsumerWidget {
  const ChildHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(_childProvider);
    final rewardAsync = ref.watch(_rewardProvider);
    final badgeCount = ref.watch(_badgesCountProvider).valueOrNull ?? 0;
    final cs = Theme.of(context).colorScheme;

    return childAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (child) {
        if (child == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.child_care, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Profil anak tidak ditemukan'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/launcher'),
                    child: const Text('Kembali ke Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final reward = rewardAsync.valueOrNull;
        final streak = reward?.currentStreak ?? 0;
        final stars = reward?.totalStars ?? 0;

        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Greeting header
              const SizedBox(height: 16),
              Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: cs.primaryContainer,
                      child: Text(
                        child.avatarUrl ?? child.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${child.name}! 👋',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${child.ageDisplay} • ${child.ageGroup.name}',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, size: 28),
                    onPressed: () => context.go('/profile'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      emoji: '🔥',
                      value: '$streak',
                      label: 'Streak',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      emoji: '⭐',
                      value: '$stars',
                      label: 'Bintang',
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      emoji: '🏆',
                      value: '$badgeCount',
                      label: 'Badge',
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Ayo Mulai!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),

              _QuickActionCard(
                emoji: '📚',
                title: 'Belajar Sekarang',
                subtitle: 'Lanjutkan pelajaranmu',
                color: Colors.blue,
                onTap: () => context.go('/learning'),
              ),
              const SizedBox(height: 10),
              _QuickActionCard(
                emoji: '🤖',
                title: 'Tanya AI Tutor',
                subtitle: 'Ada yang bingung? Tanya assistant',
                color: Colors.purple,
                onTap: () => context.go('/ai-tutor'),
              ),
              const SizedBox(height: 10),
              _QuickActionCard(
                emoji: '🏪',
                title: 'Toko Growly',
                subtitle: 'Tukar bintang dengan hadiah',
                color: Colors.green,
                onTap: () => context.go('/rewards/store'),
              ),
              const SizedBox(height: 10),
              _QuickActionCard(
                emoji: '🏆',
                title: 'Badge & Hadiah',
                subtitle: 'Lihat koleksi badge kamu',
                color: Colors.amber,
                onTap: () => context.go('/rewards'),
              ),
              const SizedBox(height: 24),

              // Motivational message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('💪', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        streak > 0
                            ? 'Hebat! Streak $streak hari berjalan! Terus jaga! 🔥'
                            : 'Mulai streak hari ini! Belajar sekarang!',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}