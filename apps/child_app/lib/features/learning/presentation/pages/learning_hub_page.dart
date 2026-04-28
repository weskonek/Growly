import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:child_app/features/learning/providers/learning_providers.dart';

class LearningHubPage extends ConsumerWidget {
  const LearningHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('📚 Belajar')),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (subjects) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: subjects.length,
          itemBuilder: (context, i) {
            final s = subjects[i];
            return _SubjectCard(
              emoji: s['emoji'] as String,
              title: s['title'] as String,
              subtitle: s['subtitle'] as String,
              level: 'Level ${(i + 1)}',
              onTap: () => context.go('/learning/subject/${s['id']}'),
            );
          },
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String emoji, title, subtitle, level;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.onTap,
  });

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
              value: 0.0,
              borderRadius: BorderRadius.circular(4),
              color: cs.primary,
            ),
          ],
        ),
        trailing: Chip(label: Text(level, style: const TextStyle(fontWeight: FontWeight.w700))),
        onTap: onTap,
      ),
    );
  }
}
