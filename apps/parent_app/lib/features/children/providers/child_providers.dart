import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:growly_core/growly_core.dart';
import '../../../../core/providers/subscription_provider.dart';

/// Re-export children providers from growly_core for parent app feature usage
export 'package:growly_core/shared/providers/child_providers.dart'
    show childrenListProvider, currentChildProvider, selectedChildIdProvider;

/// Selected child detail provider — fetches one child by ID
final selectedChildDetailProvider =
    FutureProvider.family<ChildProfile?, String>((ref, childId) async {
  final repository = ref.watch(childRepositoryProvider);
  final (child, failure) = await repository.getChild(childId);
  if (failure != null) return null;
  return child;
});

/// Create child notifier
class CreateChildNotifier extends AsyncNotifier<ChildProfile?> {
  @override
  Future<ChildProfile?> build() async => null;

  Future<ChildProfile?> createChild({
    required String name,
    required DateTime birthDate,
    String? avatarUrl,
    String? pin,
    String? gender,
  }) async {
    state = const AsyncLoading();
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return null;
    }

    final ageGroup = ChildProfile.calculateAgeGroup(birthDate);
    final child = ChildProfile(
      id: '',
      name: name,
      birthDate: birthDate,
      avatarUrl: avatarUrl,
      ageGroup: ageGroup,
      parentId: user.id,
      createdAt: DateTime.now(),
      settings: {},
      pin: pin,
      gender: gender,
    );

    final repository = ref.read(childRepositoryProvider);
    final (result, failure) = await repository.createChild(child);

    if (failure != null) {
      final msg = failure.message.toLowerCase();
      if (msg.contains('limit') || msg.contains('p0001')) {
        state = AsyncError(
          'Batas anak tercapai. Upgrade langganan untuk menambah anak.',
          StackTrace.current,
        );
      } else {
        state = AsyncError(failure.message, StackTrace.current);
      }
      return null;
    }

    // Set PIN if provided — call set_child_pin RPC
    if (pin != null && pin.isNotEmpty && result != null) {
      try {
        await Supabase.instance.client.rpc('set_child_pin', params: {
          'p_child_id': result.id,
          'p_pin': pin,
          'p_parent_id': user.id,
        });
      } catch (_) {
        // PIN set failed but child was created — non-critical, continue
      }
    }

    // Generate and save pairing code for QR setup
    if (result != null) {
      try {
        final code = await Supabase.instance.client.rpc('generate_pairing_code');
        await Supabase.instance.client
            .from('child_profiles')
            .update({'pairing_code': code as String})
            .eq('id', result.id);
        // Refetch to get updated pairingCode
        final repo = ref.read(childRepositoryProvider);
        final (updated, _) = await repo.getChild(result.id);
        state = AsyncData(updated!);
        return updated;
      } catch (_) {
        // Pairing code generation failed — non-critical, return result without code
      }
    }

    ref.invalidate(childrenListProvider);
    ref.invalidate(canAddChildProvider);
    state = AsyncData(result!);
    return result;
  }
}

final createChildProvider =
    AsyncNotifierProvider<CreateChildNotifier, ChildProfile?>(() {
  return CreateChildNotifier();
});

/// Update child notifier
class UpdateChildNotifier extends AsyncNotifier<ChildProfile?> {
  @override
  Future<ChildProfile?> build() async => null;

  Future<void> updateChild(ChildProfile child) async {
    state = const AsyncLoading();
    final repository = ref.read(childRepositoryProvider);
    final (result, failure) = await repository.updateChild(child);
    if (failure != null) {
      state = AsyncError(failure.message, StackTrace.current);
    } else {
      ref.invalidate(childrenListProvider);
      state = AsyncData(result!);
    }
  }
}

final updateChildProvider =
    AsyncNotifierProvider<UpdateChildNotifier, ChildProfile?>(() {
  return UpdateChildNotifier();
});

/// Delete child notifier (soft delete)
class DeleteChildNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => false;

  Future<bool> deleteChild(String childId) async {
    state = const AsyncLoading();
    try {
      final client = Supabase.instance.client;
      await client
          .from('child_profiles')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', childId);
      ref.invalidate(childrenListProvider);
      ref.invalidate(canAddChildProvider);
      state = const AsyncData(true);
      return true;
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
      return false;
    }
  }
}

final deleteChildProvider =
    AsyncNotifierProvider<DeleteChildNotifier, bool>(() {
  return DeleteChildNotifier();
});

/// App restriction repository provider
final appRestrictionRepositoryProvider =
    Provider<IAppRestrictionRepository>((ref) {
  return AppRestrictionRepositoryImpl();
});

/// Badge repository provider
final badgeRepositoryProvider = Provider<IBadgeRepository>((ref) {
  return BadgeRepositoryImpl();
});

/// Screen time repository provider
final screenTimeRepositoryProvider = Provider<IScreenTimeRepository>((ref) {
  return ScreenTimeRepositoryImpl();
});