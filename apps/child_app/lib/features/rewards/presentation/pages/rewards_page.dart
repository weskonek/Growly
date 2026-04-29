import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_app/features/rewards/providers/rewards_providers.dart';

class RewardsPage extends ConsumerWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardAsync = ref.watch(rewardSystemProvider);
    final badgesAsync = ref.watch(badgesProvider);
    final catalog = ref.watch(allBadgesCatalogProvider);

    ref.listen(badgesProvider, (prev, next) {
      // Only trigger on data→data transition, not initial load
      if (prev?.hasValue == true && next.hasValue) {
        final prevIds = prev!.valueOrNull!.map((b) => b.type.index).toSet();
        final newIds = next.valueOrNull!
            .where((b) => !prevIds.contains(b.type.index))
            .toList();
        if (newIds.isNotEmpty) {
          _showCelebration(context, newIds.first.name);
        }
      }
    });

    final reward = rewardAsync.valueOrNull;
    final streak = reward?.currentStreak ?? 0;
    final stars = reward?.totalStars ?? 0;
    final unlockedIds = (badgesAsync.valueOrNull ?? [])
        .map((b) => b.type.index)
        .toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Hadiah & Badge')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Streak
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streak Belajar',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '$streak hari berturut-turut!',
                        style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Stars total
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Bintang',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '$stars bintang dikumpulkan!',
                        style: TextStyle(color: Colors.amber.shade700, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Badge Kamu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: catalog.length,
            itemBuilder: (context, i) {
              final badge = catalog[i];
              final unlocked = unlockedIds.contains(badge['type'] as int);
              return _BadgeCard(
                emoji: badge['emoji'] as String,
                label: badge['name'] as String,
                unlocked: unlocked,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCelebration(BuildContext context, String badgeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              'Badge "$badgeName" Diraih!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yeay!'),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String emoji, label;
  final bool unlocked;
  const _BadgeCard({required this.emoji, required this.label, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
