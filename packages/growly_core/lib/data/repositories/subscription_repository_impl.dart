import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/failures.dart';
import '../../domain/models/subscription_model.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  final SupabaseClient _client;

  SubscriptionRepositoryImpl(this._client);

  @override
  Future<(SubscriptionModel?, Failure?)> getSubscription(String parentId) async {
    try {
      final response = await _client
          .from('subscriptions')
          .select()
          .eq('parent_id', parentId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return (null, null);
      return (SubscriptionModel.fromJson(Map<String, dynamic>.from(response)), null);
    } on PostgrestException catch (e) {
      return (null, DatabaseFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(int, Failure?)> getChildLimit(String parentId) async {
    final (sub, failure) = await getSubscription(parentId);
    if (failure != null) return (0, failure);
    final tier = sub?.tier ?? SubscriptionTier.free;
    return (tier.childLimit, null);
  }

  @override
  Future<(int, Failure?)> getAiTutorDailyLimit(String parentId) async {
    final (sub, failure) = await getSubscription(parentId);
    if (failure != null) return (0, failure);
    final tier = sub?.tier ?? SubscriptionTier.free;
    return (tier.aiTutorDailyLimit, null);
  }

  @override
  Future<(bool, Failure?)> isFeatureAllowed(String parentId, String feature) async {
    final (sub, failure) = await getSubscription(parentId);
    if (failure != null) return (false, failure);

    final tier = sub?.tier ?? SubscriptionTier.free;
    switch (feature) {
      case 'ai_tutor':
        return (tier.aiTutorEnabled, null);
      case 'unlimited_children':
        return (tier.unlimitedChildren, null);
      default:
        return (true, null);
    }
  }

  @override
  Future<(SubscriptionModel?, Failure?)> createSubscription(SubscriptionModel subscription) async {
    try {
      final json = subscription.toJson();
      json.remove('id');
      final response = await _client
          .from('subscriptions')
          .insert(json)
          .select()
          .single();
      return (SubscriptionModel.fromJson(Map<String, dynamic>.from(response)), null);
    } on PostgrestException catch (e) {
      return (null, DatabaseFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(SubscriptionModel?, Failure?)> updateSubscription(SubscriptionModel subscription) async {
    try {
      final response = await _client
          .from('subscriptions')
          .update(subscription.toJson())
          .eq('id', subscription.id)
          .select()
          .single();
      return (SubscriptionModel.fromJson(Map<String, dynamic>.from(response)), null);
    } on PostgrestException catch (e) {
      return (null, DatabaseFailure(message: e.message));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }
}
