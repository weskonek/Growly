import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final rewardBoxRepositoryProvider = Provider<IRewardBoxRepository>((ref) {
  return RewardBoxRepositoryImpl();
});

final rewardBoxesProvider = AsyncNotifierProvider<RewardBoxesNotifier, List<RewardBox>>(() {
  return RewardBoxesNotifier();
});

class RewardBoxesNotifier extends AsyncNotifier<List<RewardBox>> {
  @override
  Future<List<RewardBox>> build() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    final repo = ref.read(rewardBoxRepositoryProvider);
    final (boxes, _) = await repo.getRewardBoxes(userId);
    return boxes ?? [];
  }

  Future<void> createBox({
    required int targetStars,
    required String rewardDescription,
    String? childId,
    int validityDays = 30,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(rewardBoxRepositoryProvider);
    final box = RewardBox(
      id: '',
      parentId: userId,
      childId: childId,
      targetStars: targetStars,
      rewardDescription: rewardDescription,
      expiresAt: DateTime.now().add(Duration(days: validityDays)),
      createdAt: DateTime.now(),
    );

    await repo.createRewardBox(box);
    ref.invalidate(rewardBoxesProvider);
  }
}