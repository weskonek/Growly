import '../../core/errors/failures.dart';
import '../models/store_item.dart';

abstract class IStoreRepository {
  /// Get all active store items.
  Future<(List<StoreItem>?, Failure?)> getStoreItems();

  /// Get items by category.
  Future<(List<StoreItem>?, Failure?)> getStoreItemsByCategory(StoreCategory category);

  /// Get items a child has already purchased.
  Future<(List<StoreItem>?, Failure?)> getChildPurchases(String childId);

  /// Purchase an item — deducts stars from reward system.
  Future<(StoreItem?, Failure?)> purchaseItem(String childId, String itemId);
}