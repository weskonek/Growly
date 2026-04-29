import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart';
import 'package:parent_app/features/children/providers/child_providers.dart' show childrenListProvider;

class ParentalControlPage extends ConsumerStatefulWidget {
  const ParentalControlPage({super.key});

  @override
  ConsumerState<ParentalControlPage> createState() => _ParentalControlPageState();
}

class _ParentalControlPageState extends ConsumerState<ParentalControlPage> {
  String? _selectedChildId;

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenListProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Kontrol Orang Tua')),
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (children) {
          if (children.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.child_care, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Tambahkan profil anak terlebih dahulu'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/children/add'),
                    child: const Text('Tambah Anak'),
                  ),
                ],
              ),
            );
          }

          // Auto-select first child if none selected
          _selectedChildId ??= children.first.id;

          final selectedChild = children.firstWhere(
            (c) => c.id == _selectedChildId,
            orElse: () => children.first,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Child selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: cs.primaryContainer,
                        child: Text(selectedChild.avatarUrl ?? '👦'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedChild.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(selectedChild.ageDisplay, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.expand_more),
                        onSelected: (id) => setState(() => _selectedChildId = id),
                        itemBuilder: (context) => children
                            .map((c) => PopupMenuItem(
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Text(c.avatarUrl ?? '👦'),
                                      const SizedBox(width: 8),
                                      Text(c.name),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Control tiles
              _ControlTile(
                title: 'Batas Waktu Layar',
                subtitle: 'Atur jadwal dan batas pemakaian',
                icon: Icons.access_time,
                onTap: () => context.go('/parental-control/screen-time/$_selectedChildId'),
              ),
              _ControlTile(
                title: 'Kunci Aplikasi',
                subtitle: 'Pilih aplikasi yang boleh dipakai',
                icon: Icons.apps,
                onTap: () => context.go('/parental-control/app-lock/$_selectedChildId'),
              ),
              _ControlTile(
                title: 'Mode Sekolah',
                subtitle: 'Mode khusus saat jam sekolah',
                icon: Icons.school,
                onTap: () => context.go('/parental-control/school-mode/$_selectedChildId'),
              ),
              _ControlTile(
                title: 'Mode Aman',
                subtitle: 'Launcher aman untuk anak kecil',
                icon: Icons.shield,
                onTap: () => context.go('/parental-control/safe-mode/$_selectedChildId'),
              ),
              _ControlTile(
                title: 'Perangkat Terhubung',
                subtitle: 'Kelola perangkat terdaftar',
                icon: Icons.devices,
                onTap: () => context.go('/parental-control/devices/$_selectedChildId'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ControlTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ControlTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}