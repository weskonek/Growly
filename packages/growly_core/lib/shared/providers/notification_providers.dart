import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/remote/supabase_service.dart';
import '../../../core/errors/failures.dart';
import '../../domain/models/notification_model.dart';

/// Notification repository interface
abstract class INotificationRepository {
  Future<(List<NotificationModel>?, Failure?)> getNotifications(String parentId);
  Future<(NotificationModel?, Failure?)> markAsRead(String notificationId);
  Future<(int, Failure?)> getUnreadCount(String parentId);
  Future<(bool, Failure?)> markAllAsRead(String parentId);
  Future<Failure?> deleteNotification(String notificationId);
}

/// Supabase implementation
class NotificationRepositoryImpl implements INotificationRepository {
  final SupabaseClient _client;

  NotificationRepositoryImpl(this._client);

  @override
  Future<(List<NotificationModel>?, Failure?)> getNotifications(String parentId) async {
    try {
      final result = await _client
          .from('notifications')
          .select()
          .eq('parent_id', parentId)
          .order('created_at', ascending: false)
          .limit(50);
      final notifications = (result as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return (notifications, null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(NotificationModel?, Failure?)> markAsRead(String notificationId) async {
    try {
      final result = await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .select()
          .maybeSingle();
      if (result == null) return (null, const DatabaseFailure(message: 'Notifikasi tidak ditemukan'));
      return (NotificationModel.fromJson(result as Map<String, dynamic>), null);
    } catch (e) {
      return (null, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(int, Failure?)> getUnreadCount(String parentId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('parent_id', parentId)
          .eq('is_read', false)
          .count(CountOption.exact);
      final count = response.count;
      return (count, null);
    } catch (e) {
      return (0, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> markAllAsRead(String parentId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('parent_id', parentId)
          .eq('is_read', false);
      return (true, null);
    } catch (e) {
      return (false, DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> deleteNotification(String notificationId) async {
    try {
      await _client.from('notifications').delete().eq('id', notificationId);
      return null;
    } catch (e) {
      return DatabaseFailure(message: e.toString());
    }
  }
}

// Repository provider
final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepositoryImpl(SupabaseService.client);
});

// Notifications list provider
final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final user = SupabaseService.client.auth.currentUser;
  if (user == null) return [];
  final repo = ref.read(notificationRepositoryProvider);
  final (notifications, _) = await repo.getNotifications(user.id);
  return notifications ?? [];
});

// Unread count provider
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final user = SupabaseService.client.auth.currentUser;
  if (user == null) return 0;
  final repo = ref.read(notificationRepositoryProvider);
  final (count, _) = await repo.getUnreadCount(user.id);
  return count;
});

// Mark all as read notifier
class MarkAllNotificationsReadNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => false;

  Future<void> markAllRead() async {
    state = const AsyncLoading();
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      state = const AsyncData(false);
      return;
    }
    final repo = ref.read(notificationRepositoryProvider);
    final (success, _) = await repo.markAllAsRead(user.id);
    if (success) {
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
    }
    state = AsyncData(success);
  }
}

final markAllNotificationsReadProvider =
    AsyncNotifierProvider<MarkAllNotificationsReadNotifier, bool>(() {
  return MarkAllNotificationsReadNotifier();
});
