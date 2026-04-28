import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Parent profile provider
final parentProfileProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');

  try {
    final data = await Supabase.instance.client
        .from('parent_profiles')
        .select()
        .eq('id', user.id)
        .single();
    return Map<String, dynamic>.from(data as Map);
  } catch (e) {
    throw Exception('Failed to load profile: $e');
  }
});

/// Update parent profile notifier
class UpdateParentProfileNotifier
    extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final data = await Supabase.instance.client
        .from('parent_profiles')
        .select()
        .eq('id', user.id)
        .single();
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    bool? pinEnabled,
  }) async {
    state = const AsyncLoading();
    final user = Supabase.instance.client.auth.currentUser;
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
      try {
        final currentData = await Supabase.instance.client
            .from('parent_profiles')
            .select('settings')
            .eq('id', user.id)
            .single();
        final current = (currentData as Map)['settings'] as Map? ?? {};
        updates['settings'] = {...current, 'pin_enabled': pinEnabled};
      } catch (_) {
        updates['settings'] = {'pin_enabled': pinEnabled};
      }
    }

    try {
      await Supabase.instance.client
          .from('parent_profiles')
          .update(updates)
          .eq('id', user.id);

      final updatedData = await Supabase.instance.client
          .from('parent_profiles')
          .select()
          .eq('id', user.id)
          .single();
      state = AsyncData(Map<String, dynamic>.from(updatedData as Map));
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

final updateParentProfileProvider =
    AsyncNotifierProvider<UpdateParentProfileNotifier, Map<String, dynamic>>(() {
  return UpdateParentProfileNotifier();
});