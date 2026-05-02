import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_memory_provider.dart';

class AiMemoryCard extends ConsumerWidget {
  final String childId;
  final String childName;

  const AiMemoryCard({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoryAsync = ref.watch(childAiMemoryProvider(childId));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🧠', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Profil AI $childName',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => ref.invalidate(childAiMemoryProvider(childId)),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const Divider(),
            memoryAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Gagal memuat profil AI',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ),
              data: (memory) {
                if (memory == null) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Belum ada data. Anak harus pakai AI Tutor dulu! 🤖',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (memory.nickname != null) ...[
                      _InfoRow(
                        icon: '👤',
                        label: 'Nama panggilan',
                        value: memory.nickname!,
                      ),
                    ],
                    if (memory.learningStyle != null) ...[
                      _InfoRow(
                        icon: '📚',
                        label: 'Gaya belajar',
                        value: memory.learningStyle!,
                      ),
                    ],
                    if (memory.lastMood != null) ...[
                      _InfoRow(
                        icon: _moodEmoji(memory.lastMood!),
                        label: 'Mood terakhir',
                        value: memory.lastMood!,
                      ),
                    ],
                    if (memory.lastAnalogyWorked != null) ...[
                      _InfoRow(
                        icon: '💡',
                        label: 'Analogi berhasil',
                        value: memory.lastAnalogyWorked!,
                      ),
                    ],
                    if (memory.interests.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '🎯 Minat',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: memory.interests.map((i) {
                          return Chip(
                            label: Text(i, style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.blue.shade50,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],
                    if (memory.topicMastery.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        '📊 Performa Topik',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      ...memory.topicMastery.entries
                          .toList()
                          .take(5)
                          .map((e) => _MasteryBar(
                                topic: e.key,
                                score: e.value,
                              )),
                    ],
                    if (memory.breakthroughs.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        '🌟 Momen Berhasil',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      ...memory.breakthroughs.take(2).map((b) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b['text'] ?? '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'excited': return '🤩';
      case 'curious': return '🤔';
      case 'frustrated': return '😤';
      default: return '😊';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryBar extends StatelessWidget {
  final String topic;
  final double score;

  const _MasteryBar({required this.topic, required this.score});

  @override
  Widget build(BuildContext context) {
    final level = score > 0.7 ? '🟢' : score > 0.4 ? '🟡' : '🔴';
    final percent = (score * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(level, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      score > 0.7
                          ? Colors.green
                          : score > 0.4
                              ? Colors.amber
                              : Colors.red,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percent%',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}