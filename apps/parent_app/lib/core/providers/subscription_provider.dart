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

final childRepositoryProvider = Provider<IChildRepository>((ref) {
  return ChildRepositoryImpl(Supabase.instance.client);
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