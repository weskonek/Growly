import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parent_app/features/settings/providers/settings_providers.dart';
import 'package:parent_app/core/providers/subscription_provider.dart';
import 'package:growly_core/growly_core.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final profileAsync = ref.watch(parentProfileProvider);
    final subAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (!_isEditing && _nameController.text.isEmpty) {
            _nameController.text = profile['name'] as String? ?? '';
            _phoneController.text = profile['phone'] as String? ?? '';
          }

          final settings = profile['settings'] as Map? ?? {};
          final pinEnabled = settings['pin_enabled'] as bool? ?? false;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: cs.primaryContainer,
                        child: Text(
                          profile['name'] != null
                              ? (profile['name'] as String)[0].toUpperCase()
                              : '👤',
                          style: TextStyle(fontSize: 36, color: cs.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isEditing) ...[
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Nama'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Telepon'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _isEditing = false),
                              child: const Text('Batal'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => _saveProfile(),
                              child: const Text('Simpan'),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          profile['name'] as String? ?? 'Nama',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile['email'] as String? ?? '',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profil'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Subscription status
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Langganan'),
                subtitle: subAsync.when(
                  data: (sub) => Text(_tierDisplayName(sub?.tier ?? SubscriptionTier.free)),
                  loading: () => const Text('Memuat...'),
                  error: (_, __) => const Text('Free Plan'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/subscription'),
              ),

              // PIN Lock
              SwitchListTile(
                secondary: const Icon(Icons.lock),
                title: const Text('Kunci dengan PIN'),
                subtitle: const Text('Minta PIN untuk akses kontrol orang tua'),
                value: pinEnabled,
                onChanged: (v) => ref.read(updateParentProfileProvider.notifier).updateProfile(pinEnabled: v),
              ),

              const Divider(),

              // Notifications
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifikasi'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              // Help
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Bantuan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              // Privacy
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privasi & Keamanan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const Divider(),

              // Sign out
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Keluar', style: TextStyle(color: Colors.red)),
                onTap: () => _signOut(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveProfile() async {
    await ref.read(updateParentProfileProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Supabase.instance.client.auth.signOut();
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
}