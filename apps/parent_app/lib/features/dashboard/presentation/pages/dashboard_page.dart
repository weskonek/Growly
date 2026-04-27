import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Greeting
          Text('Halo, Orang Tua! 👋', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Lihat perkembangan anak hari ini', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 24),
          // Stats cards row
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Screen Time', value: '2j 15m', icon: Icons.access_time, color: cs.primary)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Waktu Belajar', value: '45m', icon: Icons.school_outlined, color: const Color(0xFF2ECC71))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Streak Belajar', value: '5 hari', icon: Icons.local_fire_department, color: Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Badges', value: '12', icon: Icons.emoji_events_outlined, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 24),
          // Children section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profil Anak', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              TextButton(onPressed: () {}, child: const Text('Lihat semua')),
            ],
          ),
          const SizedBox(height: 12),
          _ChildCard(name: 'Andi', age: 8, status: 'Sedang belajar', avatarEmoji: '👦'),
          const SizedBox(height: 8),
          _ChildCard(name: 'Sari', age: 5, status: 'Mode bermain', avatarEmoji: '👧'),
          const SizedBox(height: 24),
          // AI Insights
          Text('AI Insights', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                      Text('Insight Minggu Ini', style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Andi menunjukkan kemajuan luar biasa di matematika! Fokus pada pembacaan minggu depan untuk keseimbangan.', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

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
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final String name, status, avatarEmoji;
  final int age;
  const _ChildCard({required this.name, required this.age, required this.status, required this.avatarEmoji});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Text(avatarEmoji, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$age tahun • $status'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
