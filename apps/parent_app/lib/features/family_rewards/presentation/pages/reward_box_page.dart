import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../providers/reward_box_providers.dart';

class RewardBoxPage extends ConsumerWidget {
  const RewardBoxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boxesAsync = ref.watch(rewardBoxesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kotak Hadiah Keluarga'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBoxSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Hadiah'),
      ),
      body: boxesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (boxes) {
          if (boxes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada hadiah',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambah hadiah untuk anak dengan mengukur progress bintang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: boxes.length,
            itemBuilder: (context, index) {
              final box = boxes[index];
              return _RewardBoxCard(
                box: box,
                onClaim: () => _claimBox(context, ref, box),
                onDelete: () => _deleteBox(context, ref, box),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddBoxSheet(BuildContext context, WidgetRef ref) {
    final targetController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Tambah Hadiah', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Janjikan hadiah nyata untuk anak saat bintang terkumpul.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Bintang',
                hintText: 'contoh: 200',
                prefixIcon: Icon(Icons.star),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Hadiah',
                hintText: 'contoh: Pilih 1 buku baru di toko',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                final target = int.tryParse(targetController.text.trim());
                final desc = descController.text.trim();
                if (target == null || target <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Target bintang wajib diisi dengan angka positif')),
                  );
                  return;
                }
                if (desc.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Deskripsi hadiah wajib diisi')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                await ref.read(rewardBoxesProvider.notifier).createBox(
                  targetStars: target,
                  rewardDescription: desc,
                );
              },
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _claimBox(BuildContext context, WidgetRef ref, RewardBox box) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tandai Sudah Diberikan?'),
        content: Text('Tandai hadiah "${box.rewardDescription}" sudah diberikan ke anak?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tandai Sudah'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final (_, failure) = await ref.read(rewardBoxRepositoryProvider).claimRewardBox(box.id);
    if (!context.mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    } else {
      ref.invalidate(rewardBoxesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Hadiah ditandai sudah diberikan!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _deleteBox(BuildContext context, WidgetRef ref, RewardBox box) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Hadiah?'),
        content: Text('Hapus hadiah "${box.rewardDescription}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final (_, failure) = await ref.read(rewardBoxRepositoryProvider).deleteRewardBox(box.id);
    if (!context.mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    } else {
      ref.invalidate(rewardBoxesProvider);
    }
  }
}

class _RewardBoxCard extends StatelessWidget {
  final RewardBox box;
  final VoidCallback onClaim;
  final VoidCallback onDelete;

  const _RewardBoxCard({
    required this.box,
    required this.onClaim,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = box.progress;
    final isExpired = box.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: isExpired || box.isClaimed ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: box.isClaimed
                          ? Colors.green.shade100
                          : isExpired
                              ? Colors.grey.shade100
                              : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      box.isClaimed
                          ? Icons.check_circle
                          : isExpired
                              ? Icons.timer_off
                              : Icons.card_giftcard,
                      color: box.isClaimed
                          ? Colors.green
                          : isExpired
                              ? Colors.grey
                              : cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          box.rewardDescription,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '⭐ ${box.currentStars}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' / ${box.targetStars} bintang',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!box.isClaimed && !isExpired)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    box.isClaimed
                        ? Colors.green
                        : progress >= 1.0
                            ? Colors.amber
                            : cs.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: progress >= 1.0 ? Colors.amber.shade800 : cs.onSurfaceVariant,
                    ),
                  ),
                  if (box.isClaimed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Sudah diberikan',
                        style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.w700),
                      ),
                    )
                  else if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Kedaluwarsa', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    )
                  else if (progress >= 1.0)
                    FilledButton.icon(
                      onPressed: onClaim,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Tandai Sudah'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    )
                  else
                    Text(
                      'Berakhir: ${_formatDate(box.expiresAt)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}