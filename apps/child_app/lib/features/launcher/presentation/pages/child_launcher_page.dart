import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChildLauncherPage extends StatelessWidget {
  const ChildLauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.primaryContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo, Andi! 👋', style: Theme.of(context).textTheme.titleLarge),
                      Text('Ayo belajar hari ini!', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.primary,
                    child: const Text('👦', style: TextStyle(fontSize: 28)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Main action buttons
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _LauncherCard(
                      emoji: '📚',
                      label: 'Belajar',
                      color: const Color(0xFF3498DB),
                      onTap: () => context.go('/learning'),
                    ),
                    _LauncherCard(
                      emoji: '🤖',
                      label: 'Tanya AI',
                      color: const Color(0xFF9B59B6),
                      onTap: () => context.go('/ai-tutor'),
                    ),
                    _LauncherCard(
                      emoji: '🏆',
                      label: 'Hadiah',
                      color: const Color(0xFFF39C12),
                      onTap: () => context.go('/rewards'),
                    ),
                    _LauncherCard(
                      emoji: '🎮',
                      label: 'Bermain',
                      color: const Color(0xFF2ECC71),
                      onTap: () {}, // Controlled by parent policy
                    ),
                  ],
                ),
              ),
              // Screen time indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.access_time, size: 18),
                        SizedBox(width: 8),
                        Text('Waktu layar: 45m', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('OK', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LauncherCard extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;

  const _LauncherCard({required this.emoji, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
