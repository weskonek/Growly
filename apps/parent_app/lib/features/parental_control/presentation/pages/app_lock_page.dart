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

  @override
  void dispose() {
    _appNameController.dispose();
    _appPackageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restrictionsAsync = ref.watch(_appRestrictionsProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(title: const Text('Kunci Aplikasi')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppSheet(context),
        child: const Icon(Icons.add),
      ),
      body: restrictionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (restrictions) {
          if (restrictions.isEmpty) {
            return const Center(
              child: Text('Belum ada aplikasi yang dibatasi.\nTekan + untuk menambahkan.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restrictions.length,
            itemBuilder: (context, index) {
              final r = restrictions[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: r.isAllowed ? Colors.green.shade100 : Colors.red.shade100,
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
          );
        },
      ),
    );
  }

  void _showAddAppSheet(BuildContext context) {
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
            TextField(
              controller: _appNameController,
              decoration: const InputDecoration(labelText: 'Nama Aplikasi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _appPackageController,
              decoration: const InputDecoration(labelText: 'Package Name'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                final appName = _appNameController.text.trim();
                final appPackage = _appPackageController.text.trim();
                if (appPackage.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Package name wajib diisi')),
                  );
                  return;
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

  Future<void> _addRestriction(String appName, String appPackage) async {
    final repo = ref.read(_appRestrictionRepoProvider);
    // Generate a stable client-side ID (upsert will use this)
    final id = '${widget.childId}_${const Uuid().v4()}';
    final restriction = AppRestriction(
      id: id,
      childId: widget.childId,
      appPackage: appPackage,
      appName: appName.isNotEmpty ? appName : null,
      isAllowed: false,
      createdAt: DateTime.now(),
    );
    final (result, failure) = await repo.saveRestriction(restriction);
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $failure'), backgroundColor: Colors.red),
      );
    } else {
      _appNameController.clear();
      _appPackageController.clear();
      ref.invalidate(_appRestrictionsProvider(widget.childId));
    }
  }

  Future<void> _toggleRestriction(AppRestriction r, bool isAllowed) async {
    final repo = ref.read(_appRestrictionRepoProvider);
    final (result, failure) = await repo.saveRestriction(r.copyWith(isAllowed: isAllowed));
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