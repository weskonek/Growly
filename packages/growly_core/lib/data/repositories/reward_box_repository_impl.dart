import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/database/remote/supabase_service.dart';
import '../../domain/models/reward_box.dart';
import '../../domain/repositories/reward_box_repository.dart';

class RewardBoxRepositoryImpl implements IRewardBoxRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<(List<RewardBox>?, Failure?)> getRewardBoxes(String parentId) async {
    try {
      // Try RPC with enriched data first
      final rpcResult = await _client.rpc('get_reward_boxes', params: {
        'p_parent_id': parentId,
      });

      final rpcList = rpcResult as List<dynamic>;
      final boxes = rpcList
          .map((json) => RewardBox.fromJson(json as Map<String, dynamic>))
          .toList();

      return (boxes, null);
    } catch (_) {
      // Fallback to direct query
      try {
        final response = await _client
            .from('reward_boxes')
            .select('*')
            .eq('parent_id', parentId)
            .order('created_at', ascending: false);

        final boxes = (response as List<dynamic>)
            .map((b) => RewardBox.fromJson(b as Map<String, dynamic>))
            .toList();

        return (boxes, null);
      } catch (e) {
        return (null, DatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<(RewardBox?, Failure?)> createRewardBox(RewardBox box) async {
    try {
      final json = box.toJson();
      json.remove('id');
      json['parent_id'] = box.parentId;
      json['is_claimed'] = false;

      final created = await _client
          .from('reward_boxes')
          .insert(json)
          .select()
          .single();

      return (RewardBox.fromJson(created as Map<String, dynamic>), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(RewardBox?, Failure?)> claimRewardBox(String boxId) async {
    try {
      final updated = await _client
          .from('reward_boxes')
          .update({
            'is_claimed': true,
            'claimed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', boxId)
          .select()
          .single();

      return (RewardBox.fromJson(updated as Map<String, dynamic>), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> deleteRewardBox(String boxId) async {
    try {
      await _client.from('reward_boxes').delete().eq('id', boxId);
      return (true, null);
    } catch (e) {
      return (false, DatabaseFailure(message: e.toString()));
    }
  }
}