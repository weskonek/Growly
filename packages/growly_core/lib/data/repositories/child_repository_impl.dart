import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/failures.dart';
import '../../domain/models/child_profile.dart';
import '../../domain/repositories/child_repository.dart';

class ChildRepositoryImpl implements IChildRepository {
  final SupabaseClient _client;

  ChildRepositoryImpl(this._client);

  @override
  Future<(List<ChildProfile>?, Failure?)> getChildren(String parentId) async {
    try {
      final response = await _client
          .from('child_profiles')
          .select()
          .eq('parent_id', parentId)
          .order('created_at');

      final children = (response as List)
          .map((json) => ChildProfile.fromJson(json as Map<String, dynamic>))
          .toList();

      return (children, null);
    } on PostgrestException catch (e) {
      return (null, Failure.database(message: e.message));
    } catch (e) {
      return (null, Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<(ChildProfile?, Failure?)> getChild(String childId) async {
    try {
      final response = await _client
          .from('child_profiles')
          .select()
          .eq('id', childId)
          .single();

      return (ChildProfile.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(ChildProfile?, Failure?)> createChild(ChildProfile child) async {
    try {
      final json = child.toJson();
      json.remove('id');

      final response = await _client
          .from('child_profiles')
          .insert(json)
          .select()
          .single();

      return (ChildProfile.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(ChildProfile?, Failure?)> updateChild(ChildProfile child) async {
    try {
      final json = child.toJson();

      final response = await _client
          .from('child_profiles')
          .update(json)
          .eq('id', child.id)
          .select()
          .single();

      return (ChildProfile.fromJson(response as Map<String, dynamic>), null);
    } catch (e) {
      return (null, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> deleteChild(String childId) async {
    try {
      await _client.from('child_profiles').delete().eq('id', childId);
      return (true, null);
    } catch (e) {
      return (false, Failure.database(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> verifyPin(String childId, String pin) async {
    try {
      final response = await _client.rpc('verify_child_pin', params: {
        'p_child_id': childId,
        'p_pin': pin,
      }).single();

      return (response['success'] as bool, null);
    } catch (e) {
      return (false, Failure.database(message: e.toString()));
    }
  }
}