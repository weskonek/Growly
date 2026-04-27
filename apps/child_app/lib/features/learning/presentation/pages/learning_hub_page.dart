import 'package:flutter/material.dart';

class LearningHubPage extends StatelessWidget {
  const LearningHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 Belajar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SubjectCard(emoji: '🔢', title: 'Matematika', subtitle: 'Berhitung seru!', level: 'Level 3'),
          _SubjectCard(emoji: '📖', title: 'Membaca', subtitle: 'Baca cerita bersama', level: 'Level 2'),
          _SubjectCard(emoji: '🌍', title: 'Sains', subtitle: 'Kenali dunia sekitar', level: 'Level 1'),
          _SubjectCard(emoji: '🎨', title: 'Kreativitas', subtitle: 'Gambar & mewarnai', level: 'Level 4'),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String emoji, title, subtitle, level;
  const _SubjectCard({required this.emoji, required this.title, required this.subtitle, required this.level});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(emoji, style: const TextStyle(fontSize: 40)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.6,
              borderRadius: BorderRadius.circular(4),
              color: cs.primary,
            ),
          ],
        ),
        trailing: Chip(label: Text(level, style: const TextStyle(fontWeight: FontWeight.w700))),
        onTap: () {},
      ),
    );
  }
}
