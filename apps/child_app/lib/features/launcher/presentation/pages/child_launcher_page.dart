import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart' hide currentChildProvider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:child_app/features/launcher/providers/launcher_providers.dart';

class ChildLauncherPage extends ConsumerStatefulWidget {
  const ChildLauncherPage({super.key});

  @override
  ConsumerState<ChildLauncherPage> createState() => _ChildLauncherPageState();
}

class _ChildLauncherPageState extends ConsumerState<ChildLauncherPage> {
  String? _childId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final childAsync = ref.watch(currentChildProvider);

    return Scaffold(
      backgroundColor: cs.primaryContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: childAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (child) {
              if (child == null) {
                return _PinGate(onVerified: (childId) {
                  setState(() => _childId = childId);
                  ref.invalidate(currentChildProvider);
                });
              }
              return _LauncherContent(child: child, childId: child.id);
            },
          ),
        ),
      ),
    );
  }
}

class _PinGate extends StatefulWidget {
  final void Function(String childId) onVerified;

  const _PinGate({required this.onVerified});

  @override
  State<_PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<_PinGate> {
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
      final data = await Supabase.instance.client
          .from('child_profiles')
          .select()
          .eq('pin', pin)
          .eq('is_active', true)
          .maybeSingle();

      if (data != null && mounted) {
        widget.onVerified(data['id'] as String);
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
          Text('🔒', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Masukkan PIN', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('untuk masuk ke akun Growly kamu', style: TextStyle(color: cs.onSurfaceVariant)),
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
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Masuk'),
          ),
        ],
      ),
    );
  }
}

class _LauncherContent extends ConsumerWidget {
  final ChildProfile child;
  final String childId;

  const _LauncherContent({required this.child, required this.childId});

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
    final statusColor = isBlocked
        ? Colors.grey.shade400
        : timeColor;

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
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primary,
              child: Text(child.avatarUrl ?? '👦', style: const TextStyle(fontSize: 28)),
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
                label: 'Tanya AI',
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
              : [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
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
