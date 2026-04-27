import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                      Text('Streak Belajar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text('5 hari berturut-turut!', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Badge Kamu', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: const [
              _BadgeCard(emoji: '⭐', label: 'Bintang Pertama', unlocked: true),
              _BadgeCard(emoji: '📚', label: 'Pembaca Hebat', unlocked: true),
              _BadgeCard(emoji: '🔢', label: 'Ahli Hitung', unlocked: true),
              _BadgeCard(emoji: '🌍', label: 'Ilmuwan Kecil', unlocked: false),
              _BadgeCard(emoji: '🎨', label: 'Seniman Muda', unlocked: false),
              _BadgeCard(emoji: '🚀', label: 'Explorer', unlocked: false),
            ],
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
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
