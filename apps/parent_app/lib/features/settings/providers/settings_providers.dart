import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../auth/presentation/pages/login_page.dart';

/// Parent profile provider
final parentProfileProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final user = SupabaseService.client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');

  final { data, error } = await SupabaseService.client
      .from('parent_profiles')
      .select()
      .eq('id', user.id)
      .single();

  if (error != null) throw Exception(error.message);
  return Map<String, dynamic>.from(data);
});

/// Update parent profile notifier
class UpdateParentProfileNotifier
    extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    return ref.invalidate(parentProfileProvider);
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    bool? pinEnabled,
  }) async {
    state = const AsyncLoading();
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      state = AsyncError('Not authenticated', StackTrace.current);
      return;
    }

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (pinEnabled != null) {
      final current =
          (await ref.read(parentProfileProvider.future))['settings'] as Map? ?? {};
      updates['settings'] = {...current, 'pin_enabled': pinEnabled};
    }

    final { error } = await SupabaseService.client
        .from('parent_profiles')
        .update(updates)
        .eq('id', user.id);

    if (error != null) {
      state = AsyncError(error.message, StackTrace.current);
    } else {
      ref.invalidate(parentProfileProvider);
      state = await ref.read(parentProfileProvider.future);
    }
  }
}

final updateParentProfileProvider =
    AsyncNotifierProvider<UpdateParentProfileNotifier, Map<String, dynamic>>(() {
  return UpdateParentProfileNotifier();
});