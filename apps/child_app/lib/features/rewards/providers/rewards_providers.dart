import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../launcher/providers/launcher_providers.dart';

/// All earned badges for current child
final badgesProvider = FutureProvider<List<Badge>>((ref) async {
  final child = ref.read(currentChildProvider).valueOrNull;
  if (child == null) return [];
  final repository = ref.watch(badgeRepositoryProvider);
  final (badges, _) = await repository.getBadges(child.id);
  return badges ?? [];
});

/// Reward system (stars, streaks) for current child
final rewardSystemProvider = FutureProvider<RewardSystem>((ref) async {
  final child = ref.read(currentChildProvider).valueOrNull;
  if (child == null) {
    return RewardSystem(childId: '');
  }
  final repository = ref.watch(badgeRepositoryProvider);
  final (reward, _) = await repository.getRewardSystem(child.id);
  return reward ?? RewardSystem(childId: child.id);
});

/// All possible badges catalog (for locked badge display)
final allBadgesCatalogProvider =
    Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'emoji': '⭐', 'name': 'Bintang Pertama', 'type': 0},
    {'emoji': '📚', 'name': 'Pembaca Hebat', 'type': 1},
    {'emoji': '🔢', 'name': 'Ahli Hitung', 'type': 2},
    {'emoji': '🌍', 'name': 'Ilmuwan Kecil', 'type': 3},
    {'emoji': '🎨', 'name': 'Seniman Muda', 'type': 4},
    {'emoji': '🚀', 'name': 'Explorer', 'type': 5},
  ];
});

/// Badge repository provider (child app)
final badgeRepositoryProvider = Provider<IBadgeRepository>((ref) {
  return BadgeRepositoryImpl();
});