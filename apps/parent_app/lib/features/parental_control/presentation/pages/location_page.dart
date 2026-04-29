import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LocationPage extends ConsumerStatefulWidget {
  final String childId;

  const LocationPage({super.key, required this.childId});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  bool _isRegistering = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final childAsync = ref.watch(_childProfileProvider(widget.childId));
    final devicesAsync = ref.watch(_devicesProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(title: const Text('Perangkat Terhubung')),
      body: childAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal: $e')),
        data: (child) {
          if (child == null) return const Center(child: Text('Profil anak tidak ditemukan'));

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Child info header
              Card(
                color: cs.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: cs.primary.withValues(alpha: 0.2),
                        child: Text(child.avatarUrl ?? child.name[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              child.ageDisplay,
                              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${devicesAsync.valueOrNull?.length ?? 0} perangkat',
                          style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pantau dan kelola perangkat yang digunakan anak untuk mengakses Growly.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Devices list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Perangkat',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (_isRegistering)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              devicesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Gagal memuat: $e'),
                data: (devices) {
                  if (devices.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.devices, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada perangkat terdaftar',
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daftarkan perangkat ini untuk mulai memantau.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _isRegistering ? null : () => _registerCurrentDevice(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Daftarkan Perangkat Ini'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ...devices.map((device) => _DeviceCard(
                            device: device,
                            onSetCurrent: () => _setCurrentDevice(device),
                            onRemove: () => _removeDevice(device),
                          )),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _isRegistering ? null : () => _registerCurrentDevice(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Perangkat Baru'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Tips card
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber.shade800, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Tips Keamanan',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _tip('Pastikan hanya perangkat Anda yang terdaftar'),
                      _tip('Cabut perangkat yang tidak digunakan'),
                      _tip('Perbarui aplikasi Growly secara berkala'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.amber.shade800)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.amber.shade900))),
        ],
      ),
    );
  }

  Future<void> _registerCurrentDevice(BuildContext context) async {
    setState(() => _isRegistering = true);

    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceName = 'Perangkat Tidak Dikenal';
      String? deviceModel;
      String? osVersion;

      try {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
        deviceModel = androidInfo.model;
        osVersion = 'Android ${androidInfo.version.release}';
      } catch (_) {
        try {
          final iosInfo = await deviceInfo.iosInfo;
          deviceName = iosInfo.name;
          deviceModel = iosInfo.model;
          osVersion = 'iOS ${iosInfo.systemVersion}';
        } catch (_) {
          // Fallback
        }
      }

      final device = DeviceModel(
        id: '',
        childId: widget.childId,
        deviceName: deviceName,
        deviceModel: deviceModel,
        osVersion: osVersion,
        lastActiveAt: DateTime.now(),
        isCurrent: true,
        createdAt: DateTime.now(),
      );

      final repo = ref.read(_deviceRepoProvider);
      final (_, failure) = await repo.registerDevice(device);

      if (!mounted) return;

      if (failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
        );
      } else {
        ref.invalidate(_devicesProvider(widget.childId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$deviceName berhasil didaftarkan'), backgroundColor: Colors.green),
        );
      }
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  Future<void> _setCurrentDevice(DeviceModel device) async {
    final repo = ref.read(_deviceRepoProvider);
    final (_, failure) = await repo.setCurrentDevice(widget.childId, device.id);
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    } else {
      ref.invalidate(_devicesProvider(widget.childId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perangkat ditandai sebagai aktif')),
      );
    }
  }

  Future<void> _removeDevice(DeviceModel device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cabut Perangkat?'),
        content: Text('Perangkat "${device.deviceName}" akan dicabut dari profil anak ini.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cabut'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final repo = ref.read(_deviceRepoProvider);
    final (_, failure) = await repo.removeDevice(device.id);
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    } else {
      ref.invalidate(_devicesProvider(widget.childId));
    }
  }
}

class _DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onSetCurrent;
  final VoidCallback onRemove;

  const _DeviceCard({
    required this.device,
    required this.onSetCurrent,
    required this.onRemove,
  });

  IconData _deviceIcon() {
    if (device.deviceModel?.toLowerCase().contains('tablet') ?? false) return Icons.tablet;
    if (device.deviceModel?.toLowerCase().contains('sm-') ?? false) return Icons.smartphone;
    return Icons.phone_android;
  }

  String _lastActive() {
    if (device.lastActiveAt == null) return 'Tidak aktif';
    final diff = DateTime.now().difference(device.lastActiveAt!);
    if (diff.inMinutes < 5) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: device.isCurrent ? Colors.green.shade100 : Colors.grey.shade100,
              child: Icon(
                _deviceIcon(),
                color: device.isCurrent ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        device.deviceName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (device.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Aktif',
                            style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [device.deviceModel, device.osVersion].whereType<String>().join(' • '),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    'Terakhir aktif: ${_lastActive()}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (!device.isCurrent)
              IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 20),
                tooltip: 'Tandai aktif',
                onPressed: onSetCurrent,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              tooltip: 'Cabut perangkat',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

// Providers
final _childProfileProvider = FutureProvider.family<ChildProfile?, String>((ref, childId) async {
  final repo = ref.watch(_childRepoProvider);
  final (child, _) = await repo.getChild(childId);
  return child;
});

final _devicesProvider = FutureProvider.family<List<DeviceModel>, String>((ref, childId) async {
  final repo = ref.watch(_deviceRepoProvider);
  final (devices, _) = await repo.getDevices(childId);
  return devices ?? [];
});

final _deviceRepoProvider = Provider<IDeviceRepository>((ref) {
  return DeviceRepositoryImpl();
});

final _childRepoProvider = Provider<IChildRepository>((ref) {
  return ChildRepositoryImpl(SupabaseService.client);
});
