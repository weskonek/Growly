import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_alert_service.dart';

/// Guards that required Android permissions (UsageStats, Accessibility) are active.
/// Shows a blocking fullscreen dialog if Accessibility is disabled.
///
/// This is "defense in depth" — even if a child disables Accessibility Service,
/// they cannot use the app until it's re-enabled.
class PermissionGuardService {
  static const _channel = MethodChannel('com.growly/android_parental_control');

  String? _childId;
  String? _parentId;
  Timer? _checkTimer;
  NotificationAlertService? _alertService;

  /// Call after child is verified. Starts periodic permission checks.
  void startGuarding(String childId, String parentId) {
    _childId = childId;
    _parentId = parentId;
    _alertService = NotificationAlertService();
    // Check every 30 seconds while app is open
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAndNotifyIfDisabled(),
    );
  }

  void stopGuarding() {
    _checkTimer?.cancel();
    _checkTimer = null;
    _childId = null;
    _parentId = null;
    _alertService = null;
  }

  /// Returns true if Android Accessibility Service is currently enabled.
  Future<bool> checkAccessibilityEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAccessibilityEnabled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if UsageStats permission is granted.
  Future<bool> checkUsageStatsEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkUsageStatsPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkAndNotifyIfDisabled() async {
    if (_childId == null || _parentId == null) return;

    final hasAccessibility = await checkAccessibilityEnabled();
    if (!hasAccessibility) {
      await _notifyParentAccessibility();
    }

    final hasUsageStats = await checkUsageStatsEnabled();
    if (!hasUsageStats) {
      await _notifyParentUsageStats();
    }
  }

  Future<void> _notifyParentAccessibility() async {
    if (_childId == null || _parentId == null) return;
    await _alertService?.sendAlert(
      childId: _childId!,
      parentId: _parentId!,
      event: AlertEvent.accessibilityRevoked,
    );
  }

  Future<void> _notifyParentUsageStats() async {
    if (_childId == null || _parentId == null) return;
    await _alertService?.sendAlert(
      childId: _childId!,
      parentId: _parentId!,
      event: AlertEvent.usageStatsRevoked,
    );
  }

  /// Opens Android Accessibility settings so the user can re-enable it.
  Future<void> openAccessibilitySettings() async {
    await _channel.invokeMethod('openAccessibilitySettings');
  }

  /// Opens Android Usage Access settings.
  Future<void> openUsageAccessSettings() async {
    await _channel.invokeMethod('openUsageAccessSettings');
  }

  void dispose() {
    stopGuarding();
  }
}

/// Fullscreen blocking dialog shown when Accessibility is disabled.
/// Cannot be dismissed without re-enabling the service.
class AccessibilityBlockingDialog extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const AccessibilityBlockingDialog({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 80, color: Colors.orange),
                const SizedBox(height: 24),
                Text(
                  'Izin Diperlukan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Orang tua membutuhkan Growly Accessibility Service aktif untuk melindungi kamu.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Aktifkan Sekarang'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: null,
                  child: const Text('Tutup aplikasi untuk keluar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
