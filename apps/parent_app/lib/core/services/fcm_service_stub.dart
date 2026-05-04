import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub FCM service — Firebase removed, FCM not yet implemented.
/// To enable: rename to fcm_service.dart, add firebase_core + firebase_messaging
/// to pubspec.yaml, run flutterfire configure, and restore the original implementation.

/// Provider that holds the pending deep link from a notification.
/// Placeholder for future FCM deep-link support.
final pendingDeepLinkProvider = StateProvider<String?>((ref) => null);

/// Init FCM stub — does nothing until Firebase is configured.
Future<String?> initFcm() async {
  debugPrint('[FCM] Stub mode — not initialized. Add Firebase to enable.');
  return null;
}

/// Background message handler stub.
Future<void> fcmBackgroundHandler(message) async {
  debugPrint('[FCM Background] Stub — Firebase not configured.');
}

/// Setup navigation from FCM notifications stub.
void setupFcmNavigation(WidgetRef ref) {
  debugPrint('[FCM] Navigation setup skipped — stub mode.');
}