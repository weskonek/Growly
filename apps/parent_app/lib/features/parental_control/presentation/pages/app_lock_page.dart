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
    String _selectedCategory = 'all';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
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
                  const SizedBox(height: 16),
                  Text('Tambah Aplikasi', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  // Category filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final selected = _selectedCategory == cat['key'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat['label']!),
                            selected: selected,
                            onSelected: (_) => setSheetState(() => _selectedCategory = cat['key']!),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filtered preset grid
                  Text('Pilih aplikasi:', style: Theme.of(ctx).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getFilteredApps(_selectedCategory).map((app) {
                      return ActionChip(
                        avatar: Text(app['emoji']!),
                        label: Text(app['name']!, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                        onPressed: () {
                          _appNameController.text = app['name']!;
                          _appPackageController.text = app['package']!;
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // App name
                  TextField(
                    controller: _appNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama Aplikasi',
                      border: OutlineInputBorder(),
                      hintText: 'Ketik manual jika tidak ada di atas',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _appPackageController,
                    decoration: const InputDecoration(
                      labelText: 'Package Name',
                      border: OutlineInputBorder(),
                      hintText: 'com.example.app',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      final appName = _appNameController.text.trim();
                      if (appName.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Nama aplikasi wajib diisi')),
                        );
                        return;
                      }
                      var appPackage = _appPackageController.text.trim();
                      if (appPackage.isEmpty) {
                        appPackage = 'com.growly.locked.${appName.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '')}';
                      }
                      Navigator.pop(ctx);
                      await _addRestriction(appName, appPackage);
                    },
                    child: const Text('Tambah'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Categories for filtering
  static const _categories = [
    {'key': 'all',     'label': 'Semua'},
    {'key': 'social',  'label': 'Sosial'},
    {'key': 'games',   'label': 'Game'},
    {'key': 'video',   'label': 'Video'},
    {'key': 'chat',    'label': 'Chat'},
    {'key': 'browser', 'label': 'Browser'},
    {'key': 'other',   'label': 'Lainnya'},
  ];

  List<Map<String, String>> _getFilteredApps(String category) {
    if (category == 'all') return _popularApps;
    return _popularApps.where((app) => app['category'] == category).toList();
  }

  // Popular apps preset list — categorized for filtering
  static const _popularApps = [
    // Social media
    {'emoji': '📱', 'name': 'TikTok',        'package': 'com.zhiliaoapp.musically',  'category': 'social'},
    {'emoji': '📸', 'name': 'Instagram',     'package': 'com.instagram.android',      'category': 'social'},
    {'emoji': '👕', 'name': 'Facebook',      'package': 'com.facebook.katana',        'category': 'social'},
    {'emoji': '🐦', 'name': 'X (Twitter)',   'package': 'com.twitter.android',        'category': 'social'},
    {'emoji': '📘', 'name': 'Facebook Lite',  'package': 'com.facebook.lite',          'category': 'social'},
    {'emoji': '📹', 'name': 'SnackVideo',    'package': 'com.snackvideo',             'category': 'social'},
    {'emoji': '🎵', 'name': 'Lipsync',        'package': 'com.trill.lipsinc',          'category': 'social'},
    // Games
    {'emoji': '🎮', 'name': 'Mobile Legends','package': 'com.mobile.legends',          'category': 'games'},
    {'emoji': '🔥', 'name': 'Free Fire',     'package': 'com.dts.freefireth',         'category': 'games'},
    {'emoji': '🧩', 'name': 'Roblox',        'package': 'com.roblox.client',           'category': 'games'},
    {'emoji': '🏎️', 'name': 'PUBG Mobile',   'package': 'com.tencent.ig',             'category': 'games'},
    {'emoji': '⚽', 'name': 'FIFA Mobile',   'package': 'com.ea.gp.fifamobile',        'category': 'games'},
    {'emoji': '🎯', 'name': 'Stumble Guys',  'package': 'com.kitkagames.fallbuddies', 'category': 'games'},
    {'emoji': '🎲', 'name': 'Among Us',      'package': 'com.innersloth.amongus',     'category': 'games'},
    // Video streaming
    {'emoji': '▶️', 'name': 'YouTube',        'package': 'com.google.android.youtube', 'category': 'video'},
    {'emoji': '🎬', 'name': 'Netflix',       'package': 'com.netflix.mediaclient',     'category': 'video'},
    {'emoji': '🎥', 'name': 'Disney+ Hotstar','package': 'com.disney.starplus',        'category': 'video'},
    {'emoji': '📺', 'name': 'Vidio',          'package': 'com.vidio',                  'category': 'video'},
    {'emoji': '🎞️', 'name': 'WeTV',          'package': 'com.mewatch',                 'category': 'video'},
    // Chat / Messaging
    {'emoji': '💬', 'name': 'WhatsApp',      'package': 'com.whatsapp',               'category': 'chat'},
    {'emoji': '💭', 'name': 'Telegram',       'package': 'org.telegram.messenger',      'category': 'chat'},
    {'emoji': '💙', 'name': 'LINE',          'package': 'jp.naver.line.android',      'category': 'chat'},
    {'emoji': '📨', 'name': 'Gmail',          'package': 'com.google.android.gm',       'category': 'chat'},
    {'emoji': '💬', 'name': 'Discord',       'package': 'com.discord',                'category': 'chat'},
    // Browser
    {'emoji': '🌐', 'name': 'Chrome',         'package': 'com.android.chrome',         'category': 'browser'},
    {'emoji': '🌍', 'name': 'Opera Mini',    'package': 'com.opera.mini.native',      'category': 'browser'},
    {'emoji': '🦊', 'name': 'Firefox',        'package': 'org.mozilla.firefox',       'category': 'browser'},
    // Other
    {'emoji': '🎵', 'name': 'Spotify',        'package': 'com.spotify.music',          'category': 'other'},
    {'emoji': '🛒', 'name': 'Shopee',         'package': 'com.shopee.id',              'category': 'other'},
    {'emoji': '🛵', 'name': 'Gojek',          'package': 'com.gojek.app',              'category': 'other'},
    {'emoji': '🚗', 'name': 'Grab',            'package': 'com.grabtaxi.driver.legacy', 'category': 'other'},
    {'emoji': '📖', 'name': 'Wattpad',         'package': 'wp.wattpad',                 'category': 'other'},
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
