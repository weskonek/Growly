import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../../../core/providers/subscription_provider.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  Future<void> _showUpgradeSheet() async {
    final sub = ref.read(subscriptionProvider).valueOrNull;
    final tier = sub?.tier ?? SubscriptionTier.free;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _UpgradeBottomSheet(currentTier: tier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subAsync = ref.watch(subscriptionProvider);
    final upgradeAsync = ref.watch(upgradeSubscriptionProvider);
    final cs = Theme.of(context).colorScheme;

    ref.listen(upgradeSubscriptionProvider, (prev, next) {
      if (next.hasValue && (prev == null || !prev.hasValue)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upgrade berhasil! Selamat menikmati fitur Premium.'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(subscriptionProvider);
      }
      if (next.hasError && (prev == null || !prev.hasError)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${next.error}'), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Langganan')),
      body: subAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sub) {
          final tier = sub?.tier ?? SubscriptionTier.free;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _CurrentPlanCard(tier: tier, sub: sub, colorScheme: cs),
              const SizedBox(height: 24),
              _ComparisonTable(currentTier: tier),
              const SizedBox(height: 24),
              if (tier == SubscriptionTier.free)
                FilledButton.icon(
                  onPressed: upgradeAsync.isLoading ? null : _showUpgradeSheet,
                  icon: upgradeAsync.isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.star),
                  label: Text(upgradeAsync.isLoading ? 'Memproses...' : 'Upgrade ke Premium Family'),
                ),
              if (tier != SubscriptionTier.free) ...[
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Anda sudah menggunakan ${_tierDisplayName(tier)}!',
                            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// DEVELOPMENT MODE: Payment gateway is not yet integrated.
// All features are unlocked. This bottom sheet activates premium
// tier locally for development/testing purposes only.
//
// When payment gateway is ready:
// 1. Replace the upgrade button with a real payment flow (Midtrans)
// 2. Remove this dev-mode bottom sheet
// 3. Set kIsDevelopment = false
// ──────────────────────────────────────────────────────────────────
const kIsDevelopment = true;

class _UpgradeBottomSheet extends ConsumerStatefulWidget {
  final SubscriptionTier currentTier;

  const _UpgradeBottomSheet({required this.currentTier});

  @override
  ConsumerState<_UpgradeBottomSheet> createState() => _UpgradeBottomSheetState();
}

class _UpgradeBottomSheetState extends ConsumerState<_UpgradeBottomSheet> {
  bool _isProcessing = false;
  String? _selectedPayment;

  Future<void> _processMidtransPayment(BuildContext ctx) async {
    if (_selectedPayment == null) return;
    // TODO: wire WebView for Snap payment when Midtrans keys are configured
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('Payment gateway: $_selectedPayment selected — wire WebView here')),
    );
    Navigator.pop(ctx);
  }

  Future<void> _processUpgrade() async {
    if (!kIsDevelopment) return;
    setState(() => _isProcessing = true);
    final success = await ref.read(upgradeSubscriptionProvider.notifier).upgrade('premium_family');
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.star, size: 40, color: Colors.amber),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Upgrade Premium Family',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Buka semua fitur tanpa batas untuk keluarga Anda',
                style: TextStyle(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _PlanFeatureItem(emoji: '👶', title: 'Anak Tanpa Batas', desc: 'Tambahkan profil anak tanpa batas.'),
              _PlanFeatureItem(emoji: '🤖', title: 'AI Tutor Tanpa Batas', desc: 'Belajar dengan bantuan AI tanpa batasan.'),
              _PlanFeatureItem(emoji: '📊', title: 'Laporan Lengkap', desc: 'Lacak progress belajar anak setiap hari.'),
              _PlanFeatureItem(emoji: '🛡️', title: 'Kontrol Orang Tua Lengkap', desc: 'Mode sekolah, kunci aplikasi, & perangkat.'),
              const SizedBox(height: 24),
              Card(
                color: cs.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onPrimaryContainer)),
                          Text('99.000', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: cs.onPrimaryContainer)),
                        ],
                      ),
                      Text('/bulan per keluarga', style: TextStyle(color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                        child: Text('Hemat 20% bila tahunan', style: TextStyle(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (kIsDevelopment) ...[
                // ── DEV MODE: no payment gateway yet ──────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.build_circle, color: Colors.amber.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'MODE DEVELOPMENT — Semua fitur premium aktif tanpa batas. '
                        'Integrasi payment gateway akan ditambahkan saat mendekati launch.',
                        style: TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _isProcessing ? null : _processUpgrade,
                  icon: _isProcessing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.workspace_premium),
                  label: Text(_isProcessing ? 'Mengaktifkan...' : 'Aktifkan Premium (Dev)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Nanti dulu'),
                ),
              ] else ...[
                // ── PRODUCTION: real Midtrans payment flow ────────────────
                Text('Pilih Metode Pembayaran',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _PaymentOption(
                  icon: Icons.account_balance,
                  label: 'Transfer Bank',
                  sublabel: 'BCA, Mandiri, BNI, BRI',
                  selected: _selectedPayment == 'bank_transfer',
                  onTap: () => setState(() => _selectedPayment = 'bank_transfer'),
                ),
                _PaymentOption(
                  icon: Icons.qr_code,
                  label: 'QRIS',
                  sublabel: 'Semua e-wallet & mobile banking',
                  selected: _selectedPayment == 'qris',
                  onTap: () => setState(() => _selectedPayment = 'qris'),
                ),
                _PaymentOption(
                  icon: Icons.phone_android,
                  label: 'E-Wallet',
                  sublabel: 'GoPay, OVO, DANA',
                  selected: _selectedPayment == 'ewallet',
                  onTap: () => setState(() => _selectedPayment = 'ewallet'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _selectedPayment == null
                      ? null
                      : () => _processMidtransPayment(context),
                  child: const Text('Bayar Sekarang'),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : (enabled ? cs.surface : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? cs.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: enabled ? null : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: enabled ? null : Colors.grey)),
                  Text(sublabel, style: TextStyle(fontSize: 12, color: enabled ? cs.onSurfaceVariant : Colors.grey)),
                ],
              ),
            ),
            if (!enabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                child: const Text('Segera Hadir', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            if (selected && enabled)
              Icon(Icons.check_circle, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

class _PlanFeatureItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;

  const _PlanFeatureItem({required this.emoji, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final SubscriptionTier tier;
  final SubscriptionModel? sub;
  final ColorScheme colorScheme;

  const _CurrentPlanCard({required this.tier, required this.sub, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              tier == SubscriptionTier.free ? Icons.local_offer_outlined : Icons.star,
              size: 48,
              color: tier == SubscriptionTier.free ? colorScheme.primary : Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(_tierDisplayName(tier), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(sub?.status ?? 'free', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tier == SubscriptionTier.free ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tier == SubscriptionTier.free ? 'Free Plan' : 'Premium Aktif',
                style: TextStyle(
                  color: tier == SubscriptionTier.free ? Colors.red[700] : Colors.green[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            if (sub != null && sub!.currentPeriodEnd != null && tier != SubscriptionTier.free) ...[
              const SizedBox(height: 4),
              Text(
                'Berakhir: ${_formatDate(sub!.currentPeriodEnd)}',
                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final SubscriptionTier currentTier;
  const _ComparisonTable({required this.currentTier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bandingkan Paket', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const _ComparisonRow(feature: 'Jumlah Anak', freeValue: '2 anak', premiumValue: 'Tanpa batas', isPremiumBetter: true),
            const Divider(height: 24),
            const _ComparisonRow(feature: 'AI Tutor', freeValue: '-', premiumValue: 'Tanpa batas', isPremiumBetter: true),
            const Divider(height: 24),
            const _ComparisonRow(feature: 'Laporan Belajar', freeValue: 'Dasar', premiumValue: 'Lengkap', isPremiumBetter: true),
            const Divider(height: 24),
            const _ComparisonRow(feature: 'Kontrol Orang Tua', freeValue: 'Dasar', premiumValue: 'Lengkap + Perangkat', isPremiumBetter: true),
            const Divider(height: 24),
            const _ComparisonRow(feature: 'Mode Sekolah', freeValue: '-', premiumValue: 'Tersedia', isPremiumBetter: true),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String freeValue;
  final String premiumValue;
  final bool isPremiumBetter;

  const _ComparisonRow({required this.feature, required this.freeValue, required this.premiumValue, required this.isPremiumBetter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(feature, style: const TextStyle(fontSize: 14))),
        Expanded(flex: 2, child: Text(freeValue, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 16, color: isPremiumBetter ? Colors.green : Colors.grey),
              const SizedBox(width: 4),
              Text(premiumValue, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isPremiumBetter ? Colors.green[800] : null)),
            ],
          ),
        ),
      ],
    );
  }
}

String _tierDisplayName(SubscriptionTier tier) {
  switch (tier) {
    case SubscriptionTier.free: return 'Free Plan';
    case SubscriptionTier.premiumFamily: return 'Premium Family';
    case SubscriptionTier.premiumAiTutor: return 'Premium AI Tutor';
    case SubscriptionTier.schoolInstitution: return 'Sekolah / Institusi';
  }
}