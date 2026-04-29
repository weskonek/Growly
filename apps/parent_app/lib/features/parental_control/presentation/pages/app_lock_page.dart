import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import 'package:uuid/uuid.dart';

class AppLockPage extends ConsumerStatefulWidget {
  final String childId;

  const AppLockPage({super.key, required this.childId});

  @override
  ConsumerState<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends ConsumerState<AppLockPage> {
  final _appNameController = TextEditingController();
  final _appPackageController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _appNameController.dispose();
    _appPackageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restrictionsAsync = ref.watch(_appRestrictionsProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kunci Aplikasi'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppSheet(context),
        child: const Icon(Icons.add),
      ),
      body: restrictionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (restrictions) {
          final filtered = restrictions.where((r) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return (r.appName ?? '').toLowerCase().contains(q) ||
                r.appPackage.toLowerCase().contains(q);
          }).toList();

          final blocked = filtered.where((r) => !r.isAllowed).length;
          final allowed = filtered.where((r) => r.isAllowed).length;

          return Column(
            children: [
              // AppBar subtitle row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Text(
                      '$blocked diblokir',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    Text(
                      '$allowed diizinkan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari aplikasi...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          restrictions.isEmpty
                              ? 'Belum ada aplikasi yang dibatasi.\nTekan + untuk menambahkan.'
                              : 'Tidak ada hasil untuk "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final r = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    r.isAllowed ? Colors.green.shade100 : Colors.red.shade100,
                                child: Icon(
                                  r.isAllowed ? Icons.check : Icons.block,
                                  color: r.isAllowed ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(r.appName ?? r.appPackage),
                              subtitle: Text(r.appPackage),
                              trailing: Switch(
                                value: r.isAllowed,
                                onChanged: (v) => _toggleRestriction(r, v),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddAppSheet(BuildContext context) {
    _appNameController.clear();
    _appPackageController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tambah Aplikasi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // ── Preset popular apps ──────────────────────────────────
            const Text('Aplikasi Populer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularApps.map((app) {
                return ActionChip(
                  avatar: Text(app['emoji']!),
                  label: Text(app['name']!, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    _appNameController.text = app['name']!;
                    _appPackageController.text = app['package']!;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // App name first — primary field
            TextField(
              controller: _appNameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Aplikasi',
                hintText: 'contoh: Mobile Legends',
              ),
            ),
            const SizedBox(height: 12),
            // Package name second — pre-filled when preset selected
            TextField(
              controller: _appPackageController,
              decoration: const InputDecoration(
                labelText: 'Package Name',
                hintText: 'Pilih preset di atas atau ketik manual',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                final appName = _appNameController.text.trim();
                if (appName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama aplikasi wajib diisi')),
                  );
                  return;
                }
                var appPackage = _appPackageController.text.trim();
                if (appPackage.isEmpty) {
                  // Generate pseudo-package from name
                  appPackage =
                      'com.growly.locked.${appName.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '')}';
                }
                Navigator.pop(context);
                await _addRestriction(appName, appPackage);
              },
              child: const Text('Tambah'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Popular apps preset list — common apps Indonesian kids use
  static const _popularApps = [
    {'emoji': '📱', 'name': 'TikTok',        'package': 'com.zhiliaoapp.musically'},
    {'emoji': '📸', 'name': 'Instagram',     'package': 'com.instagram.android'},
    {'emoji': '▶️', 'name': 'YouTube',        'package': 'com.google.android.youtube'},
    {'emoji': '💬', 'name': 'WhatsApp',       'package': 'com.whatsapp'},
    {'emoji': '🎮', 'name': 'Mobile Legends','package': 'com.mobile.legends'},
    {'emoji': '🔥', 'name': 'Free Fire',      'package': 'com.dts.freefireth'},
    {'emoji': '🧩', 'name': 'Roblox',        'package': 'com.roblox.client'},
    {'emoji': '🎬', 'name': 'Netflix',       'package': 'com.netflix.mediaclient'},
    {'emoji': '🐦', 'name': 'X (Twitter)',   'package': 'com.twitter.android'},
    {'emoji': '🌐', 'name': 'Chrome',         'package': 'com.android.chrome'},
    {'emoji': '🎵', 'name': 'Spotify',        'package': 'com.spotify.music'},
    {'emoji': '🛒', 'name': 'Shopee',         'package': 'com.shopee.id'},
    {'emoji': '👕', 'name': 'Facebook',      'package': 'com.facebook.katana'},
    {'emoji': '🎮', 'name': 'Game Kami',     'package': 'com.example.mygame'},
  ];

  Future<void> _addRestriction(String appName, String appPackage) async {
    final repo = ref.read(_appRestrictionRepoProvider);
    final id = '${widget.childId}_${const Uuid().v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8', appPackage)}';
    final restriction = AppRestriction(
      id: id,
      childId: widget.childId,
      appPackage: appPackage,
      appName: appName.isNotEmpty ? appName : null,
      isAllowed: false,
      createdAt: DateTime.now(),
    );
    final (_, failure) = await repo.saveRestriction(restriction);
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    }
    ref.invalidate(_appRestrictionsProvider(widget.childId));
  }

  Future<void> _toggleRestriction(AppRestriction r, bool isAllowed) async {
    final repo = ref.read(_appRestrictionRepoProvider);
    final (_, failure) = await repo.saveRestriction(r.copyWith(isAllowed: isAllowed));
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    }
    ref.invalidate(_appRestrictionsProvider(widget.childId));
  }
}

final _appRestrictionsProvider =
    FutureProvider.family<List<AppRestriction>, String>((ref, childId) async {
  final repo = ref.watch(_appRestrictionRepoProvider);
  final (restrictions, _) = await repo.getRestrictions(childId);
  return restrictions ?? [];
});

final _appRestrictionRepoProvider = Provider<IAppRestrictionRepository>((ref) {
  return AppRestrictionRepositoryImpl();
});
