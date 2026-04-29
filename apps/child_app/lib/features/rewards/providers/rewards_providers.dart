import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../launcher/providers/launcher_providers.dart' as launcher;

/// All earned badges for current child
final badgesProvider = FutureProvider<List<Badge>>((ref) async {
  final child = await ref.watch(launcher.currentChildProvider.future);
  if (child == null) return [];
  final repository = ref.watch(badgeRepositoryProvider);
  final (badges, _) = await repository.getBadges(child.id);
  return badges ?? [];
});

/// Reward system (stars, streaks) for current child
final rewardSystemProvider = FutureProvider<RewardSystem>((ref) async {
  final child = await ref.watch(launcher.currentChildProvider.future);
  if (child == null) {
    return const RewardSystem(childId: '');
  }
  final repository = ref.watch(badgeRepositoryProvider);
  final (reward, _) = await repository.getRewardSystem(child.id);
  return reward ?? RewardSystem(childId: child.id);
});

/// All possible badges catalog — aligned with BadgeType enum (index 0-7)
final allBadgesCatalogProvider =
    Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'emoji': '🔥', 'name': 'Streak',          'type': 0},
    {'emoji': '🎓', 'name': 'Master Topik',    'type': 1},
    {'emoji': '✅', 'name': 'Target Harian',   'type': 2},
    {'emoji': '📅', 'name': 'Target Mingguan', 'type': 3},
    {'emoji': '⏱️', 'name': 'Jam Belajar',     'type': 4},
    {'emoji': '⭐', 'name': 'Skor Sempurna',   'type': 5},
    {'emoji': '📈', 'name': 'Konsisten',        'type': 6},
    {'emoji': '🗺️', 'name': 'Penjelajah',      'type': 7},
  ];
});

/// Badge repository provider (child app)
/// BadgeRepositoryImpl uses SupabaseService.client internally
final badgeRepositoryProvider = Provider<IBadgeRepository>((ref) {
  return BadgeRepositoryImpl();
});