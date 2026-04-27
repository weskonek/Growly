import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_parental_control/native/android_parental_control.dart';
import 'package:growly_parental_control/permission_setup_screen.dart';

/// Provider for checking and managing parental control permissions.
final permissionManagerProvider = Provider<PermissionManager>((ref) {
  return PermissionManager(ref.read(androidParentalControlProvider));
});

class PermissionManager {
  final AndroidParentalControl _androidControl;

  PermissionManager(this._androidControl);

  /// Check if all required permissions are granted.
  Future<PermissionStatus> checkPermissions() async {
    final usageStats = await _androidControl.checkUsageStatsPermission();
    final deviceAdmin = await _androidControl.isDeviceAdmin();

    if (usageStats && deviceAdmin) {
      return PermissionStatus.granted;
    }

    // Check which permissions are missing
    final missing = <PermissionType>[];
    if (!usageStats) missing.add(PermissionType.usageStats);
    if (!deviceAdmin) missing.add(PermissionType.deviceAdmin);

    return PermissionStatus.partial(missing);
  }

  /// Request a specific permission.
  Future<void> requestPermission(PermissionType type) async {
    switch (type) {
      case PermissionType.usageStats:
        await _androidControl.requestUsageStatsPermission();
        break;
      case PermissionType.deviceAdmin:
        await _androidControl.requestDeviceAdmin();
        break;
      case PermissionType.accessibility:
        await _androidControl.openAccessibilitySettings();
        break;
    }
  }

  /// Open device settings for a specific permission.
  Future<void> openSettings(PermissionType type) async {
    switch (type) {
      case PermissionType.usageStats:
        await _androidControl.openUsageAccessSettings();
        break;
      case PermissionType.deviceAdmin:
        await _androidControl.requestDeviceAdmin();
        break;
      case PermissionType.accessibility:
        await _androidControl.openAccessibilitySettings();
        break;
    }
  }
}

sealed class PermissionStatus {
  const PermissionStatus();

  factory PermissionStatus.granted() = AllPermissionsGranted;
  factory PermissionStatus.partial(List<PermissionType> missing) =
      PartialPermissions;
}

class AllPermissionsGranted extends PermissionStatus {
  const AllPermissionsGranted();
}

class PartialPermissions extends PermissionStatus {
  final List<PermissionType> missingPermissions;

  const PartialPermissions(this.missingPermissions);
}

/// Widget that handles permission flow for child app.
class PermissionGate extends ConsumerStatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, PermissionType, VoidCallback) onRequestPermission;

  const PermissionGate({
    super.key,
    required this.child,
    required this.onRequestPermission,
  });

  @override
  ConsumerState<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends ConsumerState<PermissionGate> {
  PermissionStatus? _status;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final manager = ref.read(permissionManagerProvider);
    final status = await manager.checkPermissions();
    if (mounted) {
      setState(() {
        _status = status;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    return switch (_status) {
      AllPermissionsGranted() => widget.child,
      PartialPermissions(:final missingPermissions) => _buildPermissionRequest(
          context,
          missingPermissions.first,
        ),
      null => widget.child,
    };
  }

  Widget _buildPermissionRequest(
    BuildContext context,
    PermissionType type,
  ) {
    return widget.onRequestPermission(
      context,
      type,
      () async {
        final manager = ref.read(permissionManagerProvider);
        await manager.requestPermission(type);
        // Give time for user to grant permission in settings
        await Future.delayed(const Duration(seconds: 2));
        await _checkPermissions();
      },
    );
  }
}