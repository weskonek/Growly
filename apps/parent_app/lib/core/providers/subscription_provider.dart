import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart' hide childrenListProvider;
import 'package:growly_core/shared/providers/child_providers.dart' show childrenListProvider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

final subscriptionRepoProvider = Provider<ISubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(Supabase.instance.client);
});

final subscriptionProvider =
    FutureProvider<SubscriptionModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final repo = ref.read(subscriptionRepoProvider);
  final (sub, _) = await repo.getSubscription(user.id);
  return sub;
});

class CanAddChildNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    final repo = ref.read(subscriptionRepoProvider);
    final (sub, _) = await repo.getSubscription(user.id);
    final tier = sub?.tier ?? SubscriptionTier.free;
    final limit = tier.childLimit;

    final childrenAsync = ref.watch(childrenListProvider);
    final children = childrenAsync.valueOrNull ?? [];
    return children.length < limit;
  }
}

final canAddChildProvider =
    AsyncNotifierProvider<CanAddChildNotifier, bool>(() {
  return CanAddChildNotifier();
});


/// Upgrade subscription notifier — calls upgrade_subscription RPC
class UpgradeSubscriptionNotifier extends AsyncNotifier<SubscriptionModel?> {
  @override
  Future<SubscriptionModel?> build() async => null;

  Future<bool> upgrade(String tier) async {
    state = const AsyncLoading();
    try {
      final result = await Supabase.instance.client.rpc('upgrade_subscription', params: {
        'p_tier': tier,
        'p_payment_method': null,
      }).maybeSingle();

      if (result == null) {
        state = AsyncError('Gagal upgrade langganan', StackTrace.current);
        return false;
      }

      final success = result['success'] == true;
      if (!success) {
        final msg = result['message'] as String? ?? 'Gagal';
        state = AsyncError(msg, StackTrace.current);
        return false;
      }

      // Invalidate cached providers so UI reflects new tier immediately
      ref.invalidate(subscriptionProvider);
      ref.invalidate(canAddChildProvider);

      // Return new subscription model
      state = AsyncData(SubscriptionModel(
        id: '',
        parentId: Supabase.instance.client.auth.currentUser?.id ?? '',
        tier: SubscriptionTier.values.firstWhere(
          (t) => t.name.toLowerCase().replaceAll('premium', 'premium_').replaceAll('_', '') == tier.replaceAll('_', '').replaceAll('premium', 'premium'),
          orElse: () => SubscriptionTier.free,
        ),
        status: result['status'] as String? ?? 'active',
        billingCycle: 'monthly',
        createdAt: DateTime.now(),
      ));
      return true;
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
      return false;
    }
  }
}

final upgradeSubscriptionProvider =
    AsyncNotifierProvider<UpgradeSubscriptionNotifier, SubscriptionModel?>(() {
  return UpgradeSubscriptionNotifier();
});

class TierGateNotifier extends FamilyAsyncNotifier<bool, String> {
  @override
  Future<bool> build(String arg) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    final repo = ref.read(subscriptionRepoProvider);
    final (allowed, failure) = await repo.isFeatureAllowed(user.id, arg);
    if (failure != null) return false;
    return allowed;
  }
}

final tierGateProvider =
    AsyncNotifierProvider.family<TierGateNotifier, bool, String>(
  TierGateNotifier.new,
);