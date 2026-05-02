import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screen_time_upload_service.dart';
import 'parental_control_sync_service.dart';
import 'permission_guard_service.dart';
import 'notification_alert_service.dart';

/// Screen time upload service — pushes UsageStats data to Supabase every 15 min.
final screenTimeUploadServiceProvider = Provider<ScreenTimeUploadService>((ref) {
  final service = ScreenTimeUploadService();
  ref.onDispose(service.dispose);
  return service;
});

/// Parental control sync — syncs app_restrictions to device SharedPrefs via realtime.
final parentalControlSyncServiceProvider = Provider<ParentalControlSyncService>((ref) {
  final service = ParentalControlSyncService();
  ref.onDispose(service.stopSync);
  return service;
});

/// Permission guard — monitors Android permission state and alerts parent if disabled.
final permissionGuardServiceProvider = Provider<PermissionGuardService>((ref) {
  final service = PermissionGuardService();
  ref.onDispose(service.dispose);
  return service;
});

/// Notification alert service — sends push/in-app alerts from child to parent.
final notificationAlertServiceProvider = Provider<NotificationAlertService>((ref) {
  return NotificationAlertService();
});
