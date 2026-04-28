import '../../../core/errors/failures.dart';
import '../models/subscription_model.dart';

abstract class ISubscriptionRepository {
  Future<(SubscriptionModel?, Failure?)> getSubscription(String parentId);
  Future<(int, Failure?)> getChildLimit(String parentId);
  Future<(int, Failure?)> getAiTutorDailyLimit(String parentId);
  Future<(bool, Failure?)> isFeatureAllowed(String parentId, String feature);
  Future<(SubscriptionModel?, Failure?)> createSubscription(SubscriptionModel subscription);
  Future<(SubscriptionModel?, Failure?)> updateSubscription(SubscriptionModel subscription);
}
