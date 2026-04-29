import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart' hide currentChildProvider;
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

    return Scaffold(
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
    );
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
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final pin = _controller.text.trim();
    if (pin.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final children = await Supabase.instance.client
          .from('child_profiles')
          .select('id, name, parent_id')
          .eq('is_active', true)
          .not('pin_hash', 'is', null);

      dynamic matchedChild;
      for (final child in children) {
        final result = await Supabase.instance.client.rpc(
          'verify_child_pin',
          params: {
            'p_child_id': child['id'] as String,
            'p_pin': pin,
          },
        ).maybeSingle();
        if (result != null && result['success'] == true) {
          matchedChild = child;
          break;
        }
      }

      if (matchedChild != null && mounted) {
        final childId = matchedChild['id'] as String;
        final parentId = matchedChild['parent_id'] as String;
        ref.read(verifiedChildIdProvider.notifier).state = childId;
        widget.onVerified(childId, parentId);
      } else if (mounted) {
        setState(() => _error = 'PIN salah. Coba lagi ya!');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Terjadi kesalahan');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Masukkan PIN', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'untuk masuk ke akun Growly kamu',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                counterText: '',
                hintText: '• • • •',
                errorText: _error,
              ),
              onSubmitted: (_) => _verify(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isLoading ? null : _verify,
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
        ],
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
                color: const Color(0xFF2ECC71),
                onTap: isBlocked
                    ? null
                    : () => _showBlockedSnackbar(context, schedule?.mode),
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

  void _showBlockedSnackbar(BuildContext context, String? mode) {
    final messages = {
      'school': 'Sedang jam sekolah — belajar dulu ya! 📚',
      'sleep': 'Sudah jam tidur — selamat malam! 🌙',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messages[mode] ?? 'Fitur ini sedang tidak tersedia.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  const _LauncherCard({
    required this.emoji,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade300 : color,
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
          ],
        ),
      ),
    );
  }
}
