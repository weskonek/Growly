import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:child_app/features/learning/providers/learning_providers.dart';

class SubjectDetailPage extends ConsumerStatefulWidget {
  final String subjectId;

  const SubjectDetailPage({super.key, required this.subjectId});

  @override
  ConsumerState<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends ConsumerState<SubjectDetailPage> {
  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectsAsync.whenOrNull(
              data: (list) => list.firstWhere(
                (s) => s['id'] == widget.subjectId,
                orElse: () => {'title': 'Materi'},
              )['title'] as String,
            ) ??
            'Materi'),
      ),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (subjects) {
          final subject = subjects.firstWhere(
            (s) => s['id'] == widget.subjectId,
            orElse: () => {'emoji': '📚', 'title': 'Materi'},
          );
          final color = Color(subject['color'] as int? ?? 0xFF3498DB);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: color.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(subject['emoji'] as String, style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject['title'] as String,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              subject['subtitle'] as String,
                              style: TextStyle(color: color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Materi Tersedia',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              _LessonCard(
                emoji: '1️⃣',
                title: 'Pengenalan Dasar',
                subtitle: 'Mulai di sini!',
                duration: '15 menit',
                onTap: () => context.go('/learning/lesson/${widget.subjectId}/intro'),
              ),
              _LessonCard(
                emoji: '2️⃣',
                title: 'Latihan Seru',
                subtitle: 'Terapkan yang kamu sudah pelajari',
                duration: '20 menit',
                onTap: () => context.go('/learning/lesson/${widget.subjectId}/practice'),
              ),
              _LessonCard(
                emoji: '3️⃣',
                title: 'Tantangan',
                subtitle: 'Uji pengetahuanmu',
                duration: '10 menit',
                onTap: () => context.go('/learning/lesson/${widget.subjectId}/challenge'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final String emoji, title, subtitle, duration;
  final VoidCallback onTap;

  const _LessonCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(emoji, style: const TextStyle(fontSize: 32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(duration, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: cs.primary),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
