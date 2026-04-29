import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import 'package:uuid/uuid.dart';

class SafeModePage extends ConsumerStatefulWidget {
  final String childId;

  const SafeModePage({super.key, required this.childId});

  @override
  ConsumerState<SafeModePage> createState() => _SafeModePageState();
}

class _SafeModePageState extends ConsumerState<SafeModePage> {
  final _appNameController = TextEditingController();
  final _appPackageController = TextEditingController();
  bool _isToggling = false;

  @override
  void dispose() {
    _appNameController.dispose();
    _appPackageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final childAsync = ref.watch(_childProfileProvider(widget.childId));
    final whitelistAsync = ref.watch(_whitelistProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(title: const Text('Mode Aman')),
      body: childAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal: $e')),
        data: (child) {
          if (child == null) return const Center(child: Text('Profil anak tidak ditemukan'));

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        child.safeModeEnabled ? Icons.shield : Icons.shield_outlined,
                        size: 48,
                        color: child.safeModeEnabled ? Colors.green : cs.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        child.safeModeEnabled ? 'Mode Aman Aktif' : 'Mode Aman Nonaktif',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketika aktif, anak hanya bisa mengakses aplikasi yang sudah disetujui.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      if (_isToggling)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        SwitchListTile(
                          title: Text(
                            child.safeModeEnabled ? 'Nonaktifkan Mode Aman' : 'Aktifkan Mode Aman',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: const Text('Hanya tampilkan app di whitelist'),
                          value: child.safeModeEnabled,
                          onChanged: (v) => _toggleSafeMode(child, v),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aplikasi yang Diizinkan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddAppSheet(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              whitelistAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Gagal memuat: $e'),
                data: (apps) {
                  if (apps.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.apps, size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada aplikasi di whitelist',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambah aplikasi yang boleh diakses anak',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: apps.map((r) => _WhitelistAppTile(
                          restriction: r,
                          onDelete: () => _removeApp(r),
                        )).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleSafeMode(ChildProfile child, bool enabled) async {
    setState(() => _isToggling = true);
    try {
      await SupabaseService.client
          .from('child_profiles')
          .update({'safe_mode_enabled': enabled, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', widget.childId);
      ref.invalidate(_childProfileProvider(widget.childId));
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  void _showAddAppSheet(BuildContext context) {
    _appNameController.clear();
    _appPackageController.clear();
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
            const SizedBox(height: 20),
            Text('Tambah Aplikasi ke Whitelist', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Aplikasi ini akan selalu bisa diakses anak saat Mode Aman aktif.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _appNameController,
              decoration: const InputDecoration(labelText: 'Nama Aplikasi', hintText: 'cth: Growly Belajar'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _appPackageController,
              decoration: const InputDecoration(
                labelText: 'Package Name',
                hintText: 'cth: com.growly.learn',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                final appName = _appNameController.text.trim();
                final appPackage = _appPackageController.text.trim();
                if (appPackage.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Package name wajib diisi')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                await _addToWhitelist(appName, appPackage);
              },
              child: const Text('Tambah ke Whitelist'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _addToWhitelist(String appName, String appPackage) async {
    final repo = ref.read(_appRestrictionRepoProvider);
    final id = '${widget.childId}_whitelist_${const Uuid().v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8', appPackage)}';
    final restriction = AppRestriction(
      id: id,
      childId: widget.childId,
      appPackage: appPackage,
      appName: appName.isNotEmpty ? appName : null,
      isAllowed: true,
      createdAt: DateTime.now(),
    );
    final (_, failure) = await repo.saveRestriction(restriction);
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    } else {
      ref.invalidate(_whitelistProvider(widget.childId));
    }
  }

  Future<void> _removeApp(AppRestriction r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus dari Whitelist?'),
        content: Text('Hapus "${r.appName ?? r.appPackage}" dari daftar yang diizinkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final repo = ref.read(_appRestrictionRepoProvider);
    final (_, failure) = await repo.deleteRestriction(r.id);
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    } else {
      ref.invalidate(_whitelistProvider(widget.childId));
    }
  }
}

class _WhitelistAppTile extends StatelessWidget {
  final AppRestriction restriction;
  final VoidCallback onDelete;

  const _WhitelistAppTile({required this.restriction, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.check, color: Colors.green),
        ),
        title: Text(restriction.appName ?? restriction.appPackage),
        subtitle: Text(restriction.appPackage, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
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

final _whitelistProvider = FutureProvider.family<List<AppRestriction>, String>((ref, childId) async {
  final repo = ref.watch(_appRestrictionRepoProvider);
  final (restrictions, _) = await repo.getRestrictions(childId);
  return (restrictions ?? []).where((r) => r.isAllowed).toList();
});

final _appRestrictionRepoProvider = Provider<IAppRestrictionRepository>((ref) {
  return AppRestrictionRepositoryImpl();
});

final _childRepoProvider = Provider<IChildRepository>((ref) {
  return ChildRepositoryImpl(SupabaseService.client);
});
