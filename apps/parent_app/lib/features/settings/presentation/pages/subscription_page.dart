import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../../../core/providers/subscription_provider.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(subscriptionProvider);
    final cs = Theme.of(context).colorScheme;

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
              if (tier == SubscriptionTier.free) _buildUpgradeSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpgradeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () => _showUpgradeDialog(context),
          child: const Text('Upgrade ke Premium Family'),
        ),
        const SizedBox(height: 12),
        Text(
          'Hubungi kami untuk upgrade manual sementara sampai payment gateway aktif.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _showUpgradeDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upgrade ke Premium Family'),
        content: const Text(
          'Premium Family memberi Anda:\n\n'
          '• Anak tanpa batas\n'
          '• AI Tutor tanpa batas\n'
          '• Semua fitur parental control\n\n'
          'Hubungi tim Growly untuk upgrade manual untuk saat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Silakan hubungi growly@app.com untuk upgrade.'),
                ),
              );
            },
            child: const Text('Hubungi Kami'),
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

  const _CurrentPlanCard({
    required this.tier,
    required this.sub,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              tier == SubscriptionTier.free
                  ? Icons.local_offer_outlined
                  : Icons.star,
              size: 48,
              color: tier == SubscriptionTier.free ? colorScheme.primary : Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              _tierDisplayName(tier),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              sub?.status ?? 'free',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tier == SubscriptionTier.free
                    ? Colors.red[50]
                    : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tier == SubscriptionTier.free ? 'Free Plan' : 'Premium Aktif',
                style: TextStyle(
                  color: tier == SubscriptionTier.free
                      ? Colors.red[700]
                      : Colors.green[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
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
            Text(
              'Bandingkan Paket',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _ComparisonRow(
              feature: 'Jumlah Anak',
              freeValue: '2 anak',
              premiumValue: 'Tanpa batas',
              isPremiumBetter: true,
            ),
            const Divider(height: 24),
            _ComparisonRow(
              feature: 'AI Tutor',
              freeValue: '-',
              premiumValue: 'Tanpa batas',
              isPremiumBetter: true,
            ),
            const Divider(height: 24),
            _ComparisonRow(
              feature: 'Laporan Belajar',
              freeValue: 'Dasar',
              premiumValue: 'Lengkap',
              isPremiumBetter: true,
            ),
            const Divider(height: 24),
            _ComparisonRow(
              feature: 'Kontrol Orang Tua',
              freeValue: 'Dasar',
              premiumValue: 'Lengkap + Lokasi',
              isPremiumBetter: true,
            ),
            const Divider(height: 24),
            _ComparisonRow(
              feature: 'Mode Sekolah',
              freeValue: '-',
              premiumValue: 'Tersedia',
              isPremiumBetter: true,
            ),
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

  const _ComparisonRow({
    required this.feature,
    required this.freeValue,
    required this.premiumValue,
    required this.isPremiumBetter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(feature, style: const TextStyle(fontSize: 14)),
        ),
        Expanded(
          flex: 2,
          child: Text(
            freeValue,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: isPremiumBetter ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                premiumValue,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPremiumBetter ? Colors.green[800] : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _tierDisplayName(SubscriptionTier tier) {
  switch (tier) {
    case SubscriptionTier.free:
      return 'Free Plan';
    case SubscriptionTier.premiumFamily:
      return 'Premium Family';
    case SubscriptionTier.premiumAiTutor:
      return 'Premium AI Tutor';
    case SubscriptionTier.schoolInstitution:
      return 'Sekolah / Institusi';
  }
}
