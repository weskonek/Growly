import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/database/remote/supabase_service.dart';
import '../../domain/models/store_item.dart';
import '../../domain/repositories/store_repository.dart';

class StoreRepositoryImpl implements IStoreRepository {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<(List<StoreItem>?, Failure?)> getStoreItems() async {
    try {
      final response = await _client
          .from('store_items')
          .select()
          .eq('is_active', true)
          .order('price_stars');

      final items = (response as List<dynamic>)
          .map((json) => StoreItem.fromJson(json as Map<String, dynamic>))
          .toList();

      return (items, null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<StoreItem>?, Failure?)> getStoreItemsByCategory(
    StoreCategory category,
  ) async {
    try {
      final response = await _client
          .from('store_items')
          .select()
          .eq('is_active', true)
          .eq('category', category.name)
          .order('price_stars');

      final items = (response as List<dynamic>)
          .map((json) => StoreItem.fromJson(json as Map<String, dynamic>))
          .toList();

      return (items, null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<StoreItem>?, Failure?)> getChildPurchases(String childId) async {
    try {
      final response = await _client
          .from('child_store_purchases')
          .select('item_id, store_items(*)')
          .eq('child_id', childId);

      final items = (response as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        final itemJson = map['store_items'] as Map<String, dynamic>;
        return StoreItem.fromJson({...itemJson, 'is_owned': true});
      }).toList();

      return (items, null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(StoreItem?, Failure?)> purchaseItem(String childId, String itemId) async {
    try {
      // Get item details for return value
      final itemData = await _client
          .from('store_items')
          .select()
          .eq('id', itemId)
          .maybeSingle();

      final itemMap = itemData as Map<String, dynamic>?;
      if (itemMap == null) {
        return (null, DatabaseFailure(message: 'Item tidak ditemukan'));
      }

      // Check if already owned
      final existing = await _client
          .from('child_store_purchases')
          .select('id')
          .eq('child_id', childId)
          .eq('item_id', itemId)
          .maybeSingle();

      if (existing != null) {
        return (null, DatabaseFailure(message: 'Item sudah dimiliki'));
      }

      // Deduct stars + record purchase atomically via RPC (price fetched inside RPC)
      final result = await _client.rpc('purchase_store_item', params: {
        'p_child_id': childId,
        'p_item_id': itemId,
      });

      final resultMap = result as Map<String, dynamic>?;
      if (resultMap == null) {
        return (null, DatabaseFailure(message: 'Stars tidak mencukupi atau transaksi gagal'));
      }

      return (StoreItem.fromJson({...itemMap, 'is_owned': true}), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }
}