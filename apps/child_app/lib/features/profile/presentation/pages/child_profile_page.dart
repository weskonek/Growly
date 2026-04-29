import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:growly_core/growly_core.dart';

final _profileChildProvider = FutureProvider<ChildProfile?>((ref) async {
  final childId = ref.watch(_childIdProvider);
  if (childId == null) return null;
  final client = Supabase.instance.client;
  final resp = await client
      .from('child_profiles')
      .select()
      .eq('id', childId)
      .eq('is_active', true)
      .maybeSingle();
  if (resp == null) return null;
  return ChildProfile.fromJson(Map<String, dynamic>.from(resp));
});

final _childIdProvider = StateProvider<String?>((ref) => null);

final _profileRewardProvider = FutureProvider<RewardSystem>((ref) async {
  final child = await ref.watch(_profileChildProvider.future);
  if (child == null) return const RewardSystem(childId: '');
  final repo = BadgeRepositoryImpl();
  final (r, _) = await repo.getRewardSystem(child.id);
  return r ?? RewardSystem(childId: child.id);
});

final _profileBadgeCountProvider = FutureProvider<int>((ref) async {
  final child = await ref.watch(_profileChildProvider.future);
  if (child == null) return 0;
  final repo = BadgeRepositoryImpl();
  final (badges, _) = await repo.getBadges(child.id);
  return badges?.length ?? 0;
});

final _profileLessonCountProvider = FutureProvider<int>((ref) async {
  final child = await ref.watch(_profileChildProvider.future);
  if (child == null) return 0;
  final client = Supabase.instance.client;
  final resp = await client
      .from('learning_progress')
      .select('id')
      .eq('child_id', child.id)
      .eq('completed', true);
  return (resp as List).length;
});

class ChildProfilePage extends ConsumerWidget {
  const ChildProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(_profileChildProvider);
    final rewardAsync = ref.watch(_profileRewardProvider);
    final badgeCount = ref.watch(_profileBadgeCountProvider).valueOrNull ?? 0;
    final lessonCount = ref.watch(_profileLessonCountProvider).valueOrNull ?? 0;
    final cs = Theme.of(context).colorScheme;

    return childAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (child) {
        if (child == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profil')),
            body: const Center(child: Text('Profil tidak ditemukan')),
          );
        }

        final reward = rewardAsync.valueOrNull;
        final streak = reward?.currentStreak ?? 0;
        final stars = reward?.totalStars ?? 0;
        final longestStreak = reward?.longestStreak ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profilku'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profil',
                onPressed: () => _showEditAvatarSheet(context, ref, child),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Avatar + name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: cs.primaryContainer,
                      child: GestureDetector(
                        onTap: () => context.go('/rewards/store'),
                        child: Text(
                          child.avatarUrl ?? child.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ketuk avatar untuk ganti dari Toko',
                      style: TextStyle(fontSize: 11, color: cs.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      child.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${child.ageDisplay} • ${_ageGroupLabel(child.ageGroup)}',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Stats row
              Row(
                children: [
                  Expanded(child: _profileStat('🔥', '$streak', 'Streak', Colors.orange)),
                  Expanded(child: _profileStat('⭐', '$stars', 'Bintang', Colors.amber)),
                  Expanded(child: _profileStat('🏆', '$badgeCount', 'Badge', cs.primary)),
                ],
              ),
              const SizedBox(height: 24),

              // Stats detail card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.insights, color: cs.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Statistik Belajarku',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _statRow('📚', 'Lesson selesai', '$lessonCount'),
                      const Divider(height: 20),
                      _statRow('🔥', 'Streak terbaik', '$longestStreak hari'),
                      const Divider(height: 20),
                      _statRow('📅', 'Umur akun', _memberSince(child.createdAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Badge shortcut
              Card(
                child: ListTile(
                  leading: const Text('🏆', style: TextStyle(fontSize: 28)),
                  title: const Text('Koleksi Badgeku'),
                  subtitle: Text('$badgeCount badge sudah diraih'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/rewards'),
                ),
              ),

              const SizedBox(height: 16),

              // Store shortcut
              Card(
                child: ListTile(
                  leading: const Text('🏪', style: TextStyle(fontSize: 28)),
                  title: const Text('Toko Growly'),
                  subtitle: Text('⭐ $stars bintang tersedia'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/rewards/store'),
                ),
              ),
              const SizedBox(height: 24),

              // Motivational quote
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primaryContainer, cs.secondaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      streak > 0
                          ? '"Semangat $streak hari streak! Kamu keren!"'
                          : '"Mulai dari sini, satu langkah setiap hari!"',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '— Growly',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileStat(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String _ageGroupLabel(AgeGroup group) {
    switch (group) {
      case AgeGroup.earlyChildhood: return '2-5 tahun';
      case AgeGroup.primary: return '6-9 tahun';
      case AgeGroup.upperPrimary: return '10-12 tahun';
      case AgeGroup.teen: return '13-18 tahun';
    }
  }

  String _memberSince(DateTime created) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                   'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${created.day} ${months[created.month - 1]} ${created.year}';
  }

  // ── Edit Avatar Sheet ─────────────────────────────────────────
  static const _avatarOptions = [
    '👦', '👧', '🧒', '👶', '🦸', '🧚', '🐼', '🦁', '🐰', '🐸',
    '🦊', '🐨', '🐯', '🦄', '🐧', '🐲', '🦋', '🐝', '🌟', '🚀',
  ];

  void _showEditAvatarSheet(BuildContext context, WidgetRef ref, ChildProfile child) {
    String selected = child.avatarUrl ?? _avatarOptions[0];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Avatar', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _avatarOptions.map((emoji) {
                  final isSelected = emoji == selected;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selected = emoji),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(ctx).colorScheme.primaryContainer
                            : Theme.of(ctx).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(ctx).colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 30)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _updateAvatar(ref, child.id, selected);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateAvatar(WidgetRef ref, String childId, String emoji) async {
    try {
      await Supabase.instance.client
          .from('child_profiles')
          .update({'avatar_url': emoji})
          .eq('id', childId);
      ref.invalidate(_profileChildProvider);
    } catch (_) {}
  }
}