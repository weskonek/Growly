import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivacyPage extends ConsumerStatefulWidget {
  const PrivacyPage({super.key});

  @override
  ConsumerState<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends ConsumerState<PrivacyPage> {
  bool _dataCollection = true;
  bool _analytics = true;
  bool _crashReporting = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privasi & Keamanan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.shield, color: cs.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kebijakan Privasi Growly',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kami melindungi data anak Anda sesuai regulasi COPPA.',
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Pengumpulan Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Pengumpulan Data Penggunaan'),
                  subtitle: const Text('Bantu kami meningkatkan Growly'),
                  value: _dataCollection,
                  onChanged: (v) => setState(() => _dataCollection = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Analitik'),
                  subtitle: const Text('Lacak penggunaan fitur'),
                  value: _analytics,
                  onChanged: (v) => setState(() => _analytics = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Laporan Kegagalan'),
                  subtitle: const Text('Kirim laporan error otomatis'),
                  value: _crashReporting,
                  onChanged: (v) => setState(() => _crashReporting = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Keamanan Akun',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Ubah Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: const Text('Kelola PIN Anak'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/children'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('Perangkat Terhubung'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/parental-control'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Hak Anda (COPPA)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PrivacyRightItem(
                    icon: Icons.visibility_off,
                    title: 'Tidak ikuti pengumpulan data',
                    desc: 'Matikan semua opsi pengumpulan data di atas.',
                  ),
                  const SizedBox(height: 12),
                  _PrivacyRightItem(
                    icon: Icons.download,
                    title: 'Unduh data anak',
                    desc: 'Minta salinan data yang kami kumpulkan tentang anak Anda.',
                  ),
                  const SizedBox(height: 12),
                  _PrivacyRightItem(
                    icon: Icons.delete_forever,
                    title: 'Hapus semua data',
                    desc: 'Ajukan permintaan penghapusan data anak di bawah ini.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () => _requestDataDeletion(context),
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('Minta Penghapusan Data Anak', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data akan dihapus dalam 30 hari setelah permintaan diverifikasi.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password Baru',
            hintText: 'Minimal 8 karakter',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (controller.text.length >= 8) {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(password: controller.text),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diubah')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _requestDataDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Anak?'),
        content: const Text(
          'Permintaan ini akan menghapus semua data yang terkait dengan profil anak Anda dari server Growly. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              // Log COPPA deletion request
              await Supabase.instance.client.from('audit_logs').insert({
                'action': 'coppa_data_deletion_requested',
                'table_name': 'child_profiles',
                'parent_id': Supabase.instance.client.auth.currentUser?.id,
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permintaan penghapusan data telah dikirim. Tim kami akan menghubungi Anda.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Konfirmasi Hapus'),
          ),
        ],
      ),
    );
  }
}

class _PrivacyRightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _PrivacyRightItem({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }
}
