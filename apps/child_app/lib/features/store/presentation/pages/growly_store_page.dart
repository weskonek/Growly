import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/router/child_router.dart';

/// Current child — from launcher providers (PIN-gated, FutureProvider)
final _launcherChildProvider = FutureProvider<ChildProfile?>((ref) async {
  final childId = ref.watch(verifiedChildIdProvider);
  if (childId == null) return null;

  final client = Supabase.instance.client;
  try {
    final response = await client
        .from('child_profiles')
        .select()
        .eq('id', childId)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return ChildProfile.fromJson(Map<String, dynamic>.from(response));
  } catch (_) {
    return null;
  }
});

/// Badge repository provider
final _badgeRepoProvider = Provider<IBadgeRepository>((ref) {
  return BadgeRepositoryImpl();
});

/// Store repository provider
final _storeRepoProvider = Provider<IStoreRepository>((ref) {
  return StoreRepositoryImpl();
});

/// Reward system for current child
final _childRewardSystemProvider = FutureProvider<RewardSystem>((ref) async {
  final child = await ref.watch(_launcherChildProvider.future);
  if (child == null) return const RewardSystem(childId: '');
  final repo = ref.watch(_badgeRepoProvider);
  final (reward, _) = await repo.getRewardSystem(child.id);
  return reward ?? RewardSystem(childId: child.id);
});

/// All store items
final storeItemsProvider = FutureProvider<List<StoreItem>>((ref) async {
  final repo = ref.watch(_storeRepoProvider);
  final (items, _) = await repo.getStoreItems();
  return items ?? [];
});

/// Items purchased by current child
final childPurchasesProvider = FutureProvider<List<StoreItem>>((ref) async {
  final child = await ref.watch(_launcherChildProvider.future);
  if (child == null) return [];
  final repo = ref.watch(_storeRepoProvider);
  final (items, _) = await repo.getChildPurchases(child.id);
  return items ?? [];
});

class GrowlyStorePage extends ConsumerStatefulWidget {
  const GrowlyStorePage({super.key});

  @override
  ConsumerState<GrowlyStorePage> createState() => _GrowlyStorePageState();
}

class _GrowlyStorePageState extends ConsumerState<GrowlyStorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(storeItemsProvider);
    final purchasesAsync = ref.watch(childPurchasesProvider);
    final rewardAsync = ref.watch(_childRewardSystemProvider);

    final ownedIds = (purchasesAsync.valueOrNull ?? [])
        .map((i) => i.id)
        .toSet();
    final stars = (rewardAsync.valueOrNull?.totalStars) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏪 Toko Growly'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Avatar'),
            Tab(text: 'Profil'),
            Tab(text: 'Premium'),
            Tab(text: 'Dimiliki'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.amber.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(
                  '$stars Bintang',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _StoreGrid(
                  itemsAsync: itemsAsync,
                  ownedIds: ownedIds,
                  stars: stars,
                  category: StoreCategory.avatar,
                  onPurchase: _purchaseItem,
                ),
                _StoreGrid(
                  itemsAsync: itemsAsync,
                  ownedIds: ownedIds,
                  stars: stars,
                  category: StoreCategory.profile,
                  onPurchase: _purchaseItem,
                ),
                _StoreGrid(
                  itemsAsync: itemsAsync,
                  ownedIds: ownedIds,
                  stars: stars,
                  category: StoreCategory.premium,
                  onPurchase: _purchaseItem,
                ),
                _OwnedGrid(purchasesAsync: purchasesAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseItem(StoreItem item) async {
    final child = await ref.read(_launcherChildProvider.future);
    if (child == null) return;

    final stars = (ref.read(_childRewardSystemProvider).valueOrNull?.totalStars) ?? 0;
    if (stars < item.priceStars) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bintang tidak mencukupi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final repo = ref.read(_storeRepoProvider);
    final (_, failure) = await repo.purchaseItem(child.id, item.id);

    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    } else {
      ref.invalidate(storeItemsProvider);
      ref.invalidate(childPurchasesProvider);
      ref.invalidate(_childRewardSystemProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.emoji ?? '🎁'} "${item.name}" berhasil dibeli!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _StoreGrid extends StatelessWidget {
  final AsyncValue<List<StoreItem>> itemsAsync;
  final Set<String> ownedIds;
  final int stars;
  final StoreCategory category;
  final void Function(StoreItem) onPurchase;

  const _StoreGrid({
    required this.itemsAsync,
    required this.ownedIds,
    required this.stars,
    required this.category,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (items) {
        final filtered = items.where((i) => i.category == category).toList();
        if (filtered.isEmpty) {
          return Center(
            child: Text('Belum ada item di kategori ini',
                style: TextStyle(color: Colors.grey.shade500)),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            return _StoreItemCard(
              item: item,
              isOwned: ownedIds.contains(item.id),
              canAfford: stars >= item.priceStars,
              onPurchase: () => onPurchase(item),
            );
          },
        );
      },
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final StoreItem item;
  final bool isOwned;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _StoreItemCard({
    required this.item,
    required this.isOwned,
    required this.canAfford,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Opacity(
      opacity: isOwned ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isOwned
              ? cs.primaryContainer.withValues(alpha: 0.3)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isOwned ? Border.all(color: cs.primary, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.emoji ?? '🎁', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (item.description != null) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            if (isOwned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Dimiliki',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: canAfford ? Colors.amber.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${item.priceStars}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: canAfford ? Colors.amber.shade800 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: canAfford ? onPurchase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? cs.primary : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    'Tukar',
                    style: TextStyle(
                      fontSize: 12,
                      color: canAfford ? cs.onPrimary : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OwnedGrid extends StatelessWidget {
  final AsyncValue<List<StoreItem>> purchasesAsync;

  const _OwnedGrid({required this.purchasesAsync});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return purchasesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Belum punya item', style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(height: 8),
                Text('Tukar bintang di Toko Growly!',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.primary, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.emoji ?? '🎁', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(item.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Dimiliki',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}