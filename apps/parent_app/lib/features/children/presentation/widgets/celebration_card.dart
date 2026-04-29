import 'package:flutter/material.dart' hide Badge;
import 'package:growly_core/growly_core.dart';

class CelebrationCard extends StatelessWidget {
  final String childName;
  final Badge badge;
  final VoidCallback onDismiss;
  final VoidCallback? onMarkCelebrated;

  const CelebrationCard({
    super.key,
    required this.childName,
    required this.badge,
    required this.onDismiss,
    this.onMarkCelebrated,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy header
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.emoji_events, size: 40, color: Colors.amber),
            ),
            const SizedBox(height: 16),
            Text(
              'PENCAPAIAN LUAR BIASA!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.amber.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.emoji,
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 8),
            Text(
              '"${badge.name}"',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$childName meraih badge ini! 🌟',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber.shade800, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Rayakan bersama',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _tip('Ceritakan ke $childName betapa bangganya kamu'),
                  _tip('Buat momen spesial hari ini'),
                  _tip('Simpan sebagai kenangan bersama'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    child: const Text('Nanti'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      onMarkCelebrated?.call();
                      onDismiss();
                    },
                    child: const Text('Tandai Sudah Dirayakan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tip(String text) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ', style: TextStyle(color: Colors.amber.shade800)),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
              ),
            ),
          ],
        ),
      );
}

/// Banner shown in notifications list when badge is type=achievement
class AchievementNotificationTile extends StatelessWidget {
  final String childName;
  final String badgeName;
  final String emoji;
  final VoidCallback? onTap;

  const AchievementNotificationTile({
    super.key,
    required this.childName,
    required this.badgeName,
    required this.emoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Badge Diraih!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.amber.shade900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$childName mendapatkan "$badgeName"',
                      style: TextStyle(fontSize: 13, color: Colors.amber.shade800),
                    ),
                  ],
                ),
              ),
              Icon(Icons.celebration, color: Colors.amber.shade700, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}