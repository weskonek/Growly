import 'package:flutter/material.dart';

/// Screen for handling parental control permissions setup.
/// Shown when permissions are not granted.
class PermissionSetupScreen extends StatelessWidget {
  final PermissionType permissionType;
  final VoidCallback onPermissionGranted;
  final VoidCallback? onSkip;

  const PermissionSetupScreen({
    super.key,
    required this.permissionType,
    required this.onPermissionGranted,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              const SizedBox(height: 32),
              Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _getDescription(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: onPermissionGranted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Berikan Izin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              if (onSkip != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'Lewati untuk saat ini',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (permissionType) {
      case PermissionType.usageStats:
        icon = Icons.timer;
        color = const Color(0xFF2196F3);
        break;
      case PermissionType.deviceAdmin:
        icon = Icons.security;
        color = const Color(0xFF9C27B0);
        break;
      case PermissionType.accessibility:
        icon = Icons.accessibility_new;
        color = const Color(0xFFFF9800);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 64, color: color),
    );
  }

  String _getTitle() {
    switch (permissionType) {
      case PermissionType.usageStats:
        return 'Izinkan Pemantauan Waktu';
      case PermissionType.deviceAdmin:
        return 'Aktifkan Device Admin';
      case PermissionType.accessibility:
        return 'Izinkan Accessibility Service';
    }
  }

  String _getDescription() {
    switch (permissionType) {
      case PermissionType.usageStats:
        return 'Growly membutuhkan izin untuk memantau waktu layar anak.\n\n'
            '1. Buka Pengaturan > Aplikasi > Akses khusus\n'
            '2. Temukan Growly Child\n'
            '3. Aktifkan "Akses data penggunaan"';
      case PermissionType.deviceAdmin:
        return 'Device Admin memungkinkan Growly mengunci perangkat saat waktu belajar.\n\n'
            'Ini aman dan hanya digunakan untuk kontrol orang tua.';
      case PermissionType.accessibility:
        return 'Accessibility Service digunakan untuk mendeteksi dan memblokir aplikasi yang tidak diizinkan.\n\n'
            'Service ini tidak membaca keystroke atau data pribadi.';
    }
  }
}

enum PermissionType {
  usageStats,
  deviceAdmin,
  accessibility,
}