import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:growly_core/growly_core.dart';

/// Parent profile provider
final parentProfileProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');

  final result = await Supabase.instance.client
      .from('parent_profiles')
      .select()
      .eq('id', user.id)
      .single();

  if (result.error != null) throw Exception(result.error!.message);
  return Map<String, dynamic>.from(result.data as Map<String, dynamic>);
});

/// Update parent profile notifier
class UpdateParentProfileNotifier
    extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    return ref.watch(parentProfileProvider.future);
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
      final current = (await ref.read(parentProfileProvider.future))['settings'] as Map? ?? {};
      updates['settings'] = {...current, 'pin_enabled': pinEnabled};
    }

    final result = await SupabaseService.client
        .from('parent_profiles')
        .update(updates)
        .eq('id', user.id);

    if (result.error != null) {
      state = AsyncError(result.error!.message, StackTrace.current);
    } else {
      state = await ref.read(parentProfileProvider.future);
    }
  }
}

final updateParentProfileProvider =
    AsyncNotifierProvider<UpdateParentProfileNotifier, Map<String, dynamic>>(() {
  return UpdateParentProfileNotifier();
});