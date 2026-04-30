import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart' hide currentChildProvider;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:child_app/features/launcher/providers/launcher_providers.dart';
import 'package:child_app/core/router/child_router.dart';
import 'package:child_app/core/services/services_providers.dart';

const _channel = MethodChannel('com.growly/android_parental_control');

class ChildLauncherPage extends ConsumerStatefulWidget {
  const ChildLauncherPage({super.key});

  @override
  ConsumerState<ChildLauncherPage> createState() => _ChildLauncherPageState();
}

class _ChildLauncherPageState extends ConsumerState<ChildLauncherPage>
    with WidgetsBindingObserver {
  RealtimeConnectionStatus _connectionStatus = RealtimeConnectionStatus.connecting;
  RealtimeChannel? _syncChannel;
  bool _showAccessibilityBlock = false;
  bool _willExit = false;
  Timer? _accessibilityCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accessibilityCheckTimer?.cancel();
    _syncChannel?.unsubscribe();
    // Stop all sync services on unmount
    ref.read(parentalControlSyncServiceProvider).stopSync();
    ref.read(screenTimeUploadServiceProvider).stopPeriodicUpload();
    ref.read(permissionGuardServiceProvider).stopGuarding();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAccessibility();
    }
    if (state == AppLifecycleState.paused) {
      _accessibilityCheckTimer?.cancel();
      // Upload screen time when app goes to background
      _uploadScreenTimeOnPause();
    }
  }

  void _uploadScreenTimeOnPause() {
    final childId = ref.read(verifiedChildIdProvider);
    if (childId != null) {
      ref.read(screenTimeUploadServiceProvider).uploadNow(childId);
    }
  }

  Future<void> _checkAccessibility() async {
    final guard = ref.read(permissionGuardServiceProvider);
    final enabled = await guard.checkAccessibilityEnabled();
    if (mounted && !enabled) {
      setState(() => _showAccessibilityBlock = true);
    } else if (mounted && enabled) {
      setState(() => _showAccessibilityBlock = false);
    }
  }

  Future<void> _ensureDeviceAdmin() async {
    try {
      final isAdmin = await _channel.invokeMethod<bool>('isDeviceAdmin') ?? false;
      if (!isAdmin) {
        // Show dialog explaining why Device Admin is needed, then request it
        final shouldRequest = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Izin Diperlukan'),
            content: const Text(
              'Growly memerlukan akses Device Admin untuk mengunci aplikasi yang '
              'dibatasi oleh orang tua. Tanpa izin ini, beberapa batasan tidak '
              'akan berjalan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Nanti'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Berikan Izin'),
              ),
            ],
          ),
        );
        if (shouldRequest == true) {
          await _channel.invokeMethod('requestDeviceAdmin');
        }
      }
    } catch (_) {
      // Native code unavailable — continue without Device Admin
    }
  }

  void _subscribeToChildSync(String childId, String parentId) {
    _syncChannel?.unsubscribe();

    // Ensure Device Admin is granted before enforcement starts
    _ensureDeviceAdmin();

    // Start all services for this child
    ref.read(parentalControlSyncServiceProvider).startSync(childId);
    ref.read(screenTimeUploadServiceProvider).startPeriodicUpload(childId);
    ref.read(permissionGuardServiceProvider).startGuarding(childId, parentId);

    // Initial accessibility check
    _checkAccessibility();
    // Periodic check every 30s
    _accessibilityCheckTimer?.cancel();
    _accessibilityCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAccessibility(),
    );

    final client = Supabase.instance.client;
    _syncChannel = client
        .channel('child-sync-$childId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'app_restrictions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'child_id',
            value: childId,
          ),
          callback: (_) {
            if (mounted) {
              ref.invalidate(activeScheduleProvider);
              // Force immediate sync of restrictions to device
              ref.read(parentalControlSyncServiceProvider).forceSync();
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'schedules',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'child_id',
            value: childId,
          ),
          callback: (_) {
            if (mounted) {
              ref.invalidate(activeScheduleProvider);
              ref.invalidate(screenTimeRemainingProvider);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'screen_time_records',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'child_id',
            value: childId,
          ),
          callback: (_) {
            if (mounted) ref.invalidate(screenTimeRemainingProvider);
          },
        )
        .subscribe((status, error) {
          if (!mounted) return;
          if (status == 'SUBSCRIBED') {
            setState(() => _connectionStatus = RealtimeConnectionStatus.connected);
          } else {
            setState(() => _connectionStatus = RealtimeConnectionStatus.disconnected);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    // Block entire UI if accessibility is disabled
    if (_showAccessibilityBlock) {
      return _AccessibilityBlockingScreen(
        onOpenSettings: () {
          ref.read(permissionGuardServiceProvider).openAccessibilitySettings();
        },
        onRetry: _checkAccessibility,
      );
    }

    final childAsync = ref.watch(currentChildProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_willExit) {
          _willExit = false;
          final confirmed = await _showExitDialog(context);
          if (confirmed && context.mounted) {
            SystemNavigator.pop();
          }
        } else {
          _willExit = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tekan lagi untuk keluar'),
              duration: Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) _willExit = false;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
          child: childAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (child) {
              if (child == null) {
                return _PinGate(
                  onVerified: (childId, parentId) {
                    ref.invalidate(currentChildProvider);
                    _subscribeToChildSync(childId, parentId);
                  },
                );
              }
              return _LauncherContent(
                child: child,
                childId: child.id,
                connectionStatus: _connectionStatus,
              );
            },
          ),
        ),
      ),
    ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Keluar dari Growly?'),
            content: const Text('Tekan keluar untuk menutup aplikasi.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Keluar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _AccessibilityBlockingScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  const _AccessibilityBlockingScreen({
    required this.onOpenSettings,
    required this.onRetry,
  });

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
                  'Layanan Aksesibilitas Growly harus aktif agar aplikasi bisa digunakan.\n\nMatikan fitur ini akan membatasi akses anak ke aplikasi yang tidak disetujui orang tua.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Buka Pengaturan Aksesibilitas'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum RealtimeConnectionStatus {
  connecting,
  connected,
  disconnected,
}

class _PinGate extends ConsumerStatefulWidget {
  final void Function(String childId, String parentId) onVerified;

  const _PinGate({required this.onVerified});

  @override
  ConsumerState<_PinGate> createState() => _PinGateState();
}

class _PinGateState extends ConsumerState<_PinGate> {
  // Step 1: scanning state
  String? _scannedPairingCode;
  // Step 2: child info after successful lookup
  String? _childId;
  String? _parentId;
  String? _childName;

  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _hasCameraError = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // ─── Step 1: QR scan ───────────────────────────────────────────────────────

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null) return;

    // Accept deep link format: growly://pair/ABC123
    if (raw.startsWith('growly://pair/')) {
      final code = raw.replaceFirst('growly://pair/', '');
      _lookupChild(code);
    } else if (raw.length == 6 && RegExp(r'^[A-Z0-9]+$').hasMatch(raw)) {
      // Fallback: raw 6-char code typed or shown without scheme
      _lookupChild(raw);
    }
  }

  Future<void> _lookupChild(String pairingCode) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await Supabase.instance.client
          .from('child_profiles')
          .select('id, name, parent_id, pin_hash')
          .eq('pairing_code', pairingCode)
          .eq('is_active', true)
          .maybeSingle();

      if (result == null) {
        setState(() {
          _error = 'Kode tidak valid. Minta orang tua tampilkan QR lagi.';
          _isLoading = false;
        });
        return;
      }

      // Check if PIN is set — if no pin_hash, redirect to parent app to set PIN first
      if (result['pin_hash'] == null) {
        setState(() {
          _error = 'PIN belum diatur. Minta orang tua atur PIN di aplikasi Growly Parent.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _scannedPairingCode = pairingCode;
        _childId = result['id'] as String;
        _parentId = result['parent_id'] as String;
        _childName = result['name'] as String;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Terjadi kesalahan. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  void _showManualCodeInput() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ketik Kode Manual',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan kode 6 huruf yang ditampilkan di aplikasi Growly Parent.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '------',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                Navigator.pop(ctx);
                if (value.trim().isNotEmpty) _lookupChild(value.trim().toUpperCase());
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (controller.text.trim().isNotEmpty) {
                  _lookupChild(controller.text.trim().toUpperCase());
                }
              },
              child: const Text('Cari Profil'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Step 2: PIN verification ──────────────────────────────────────────────

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await Supabase.instance.client.rpc(
        'verify_child_pin',
        params: {'p_child_id': _childId!, 'p_pin': pin},
      ).maybeSingle();

      if (result != null && result['success'] == true) {
        ref.read(verifiedChildIdProvider.notifier).state = _childId;
        widget.onVerified(_childId!, _parentId!);
      } else {
        setState(() {
          _error = 'PIN salah. Coba lagi ya!';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Terjadi kesalahan';
        _isLoading = false;
      });
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_scannedPairingCode != null) {
      return _buildPinInputView(context);
    }
    return _buildScannerView(context);
  }

  Widget _buildScannerView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text('📷', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              'Scan QR dari HP Orang Tua',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Buka aplikasi Growly Parent, pilih profil anak, lalu tampilkan QR.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Camera scanner
            if (_hasCameraError)
              _cameraErrorView()
            else
              SizedBox(
                width: 280,
                height: 280,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MobileScanner(
                    onDetect: _onBarcodeDetected,
                    errorBuilder: (_, __, ___) {
                      // Camera unavailable — fall through to manual input
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _hasCameraError = true);
                      });
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),

            if (_isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],

            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _showManualCodeInput,
              icon: const Icon(Icons.keyboard),
              label: const Text('Ketik kode manual'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraErrorView() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(
            'Kamera tidak tersedia',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInputView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),

            // Child detected badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Profil: $_childName',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Masukkan PIN',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'untuk masuk ke akun Growly',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: 200,
              child: TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                obscureText: true,
                maxLength: 6,
                autofocus: true,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• • • •',
                  errorText: _error,
                ),
                onSubmitted: (_) => _verifyPin(),
              ),
            ),
            const SizedBox(height: 16),

            FilledButton(
              onPressed: _isLoading ? null : _verifyPin,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Masuk'),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _showForgotPinSheet(context),
              child: const Text('Lupa PIN?'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _scannedPairingCode = null;
                _childId = null;
                _parentId = null;
                _childName = null;
                _pinController.clear();
                _error = null;
              }),
              child: const Text('Scan QR lain'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showForgotPinSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔑', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Lupa PIN?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Minta orang tua reset PIN kamu di aplikasi Growly Parent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LauncherContent extends ConsumerWidget {
  final ChildProfile child;
  final String childId;
  final RealtimeConnectionStatus connectionStatus;

  const _LauncherContent({
    required this.child,
    required this.childId,
    required this.connectionStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final remainingAsync = ref.watch(screenTimeRemainingProvider(childId));
    final scheduleAsync = ref.watch(activeScheduleProvider(childId));

    final remaining = remainingAsync.valueOrNull ?? 0;
    final schedule = scheduleAsync.valueOrNull;
    final isBlocked = schedule != null &&
        (schedule.mode == 'school' || schedule.mode == 'sleep');

    final timeColor = remaining <= 10
        ? Colors.red
        : remaining <= 30
            ? Colors.orange
            : Colors.green;
    final timeLabel = '${remaining ~/ 60}j ${remaining % 60}m';
    final statusLabel = isBlocked
        ? 'Tutup'
        : remaining <= 10
            ? 'Habis!'
            : remaining <= 30
                ? 'Hampir habis'
                : 'OK';
    final statusColor = isBlocked ? Colors.grey.shade400 : timeColor;

    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${child.name}! 👋',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Ayo belajar hari ini!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Row(
              children: [
                _ConnectionBadge(status: connectionStatus),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.primary,
                  child: Text(
                    child.avatarUrl ?? '👦',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _LauncherCard(
                emoji: '📚',
                label: 'Belajar',
                color: const Color(0xFF3498DB),
                onTap: () => context.go('/learning'),
              ),
              _LauncherCard(
                emoji: '🤖',
                label: _aiLabelForAge(child.ageGroup),
                color: const Color(0xFF9B59B6),
                onTap: () => context.go('/ai-tutor'),
              ),
              _LauncherCard(
                emoji: '🏆',
                label: 'Hadiah',
                color: const Color(0xFFF39C12),
                onTap: () => context.go('/rewards'),
              ),
              _LauncherCard(
                emoji: '🎮',
                label: 'Bermain',
                color: isBlocked
                    ? Colors.grey.shade400
                    : remaining <= 0
                        ? Colors.red.shade300
                        : const Color(0xFFE74C3C),
                onTap: isBlocked || remaining <= 0
                    ? null
                    : () => context.go('/home'),
                disabledReason: isBlocked
                    ? 'Mode ${schedule?.mode == 'school' ? 'Sekolah' : 'Tidur'} aktif'
                    : remaining <= 0
                        ? 'Waktu layar habis'
                        : null,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: timeColor),
                  const SizedBox(width: 8),
                  Text(
                    'Waktu layar: $timeLabel',
                    style: TextStyle(fontWeight: FontWeight.w600, color: timeColor),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _aiLabelForAge(AgeGroup ageGroup) {
    switch (ageGroup) {
      case AgeGroup.earlyChildhood:
        return 'Cerita Bareng';
      case AgeGroup.primary:
        return 'Cerita Bareng';
      default:
        return 'Tanya AI';
    }
  }
}

class _ConnectionBadge extends StatelessWidget {
  final RealtimeConnectionStatus status;

  const _ConnectionBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (status) {
      RealtimeConnectionStatus.connected => ('🟢', 'Terhubung'),
      RealtimeConnectionStatus.disconnected => ('🔴', 'Offline'),
      RealtimeConnectionStatus.connecting => ('🟡', 'Menghubungi...'),
    };
    return Tooltip(
      message: label,
      child: Text(icon, style: const TextStyle(fontSize: 16)),
    );
  }
}

class _LauncherCard extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback? onTap;
  final String? disabledReason;

  const _LauncherCard({
    required this.emoji,
    required this.label,
    required this.color,
    this.onTap,
    this.disabledReason,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade400 : color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: disabled ? Colors.grey.shade600 : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (disabledReason != null) ...[
              const SizedBox(height: 4),
              Text(
                disabledReason!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
