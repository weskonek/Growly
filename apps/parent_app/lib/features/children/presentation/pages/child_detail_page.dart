import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart';
import '../../providers/child_providers.dart' show selectedChildDetailProvider, updateChildProvider, deleteChildProvider;

class ChildDetailPage extends ConsumerStatefulWidget {
  final String childId;

  const ChildDetailPage({super.key, required this.childId});

  @override
  ConsumerState<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends ConsumerState<ChildDetailPage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  DateTime? _birthDate;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(selectedChildDetailProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Profil Anak'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isEditing = false);
                ref.invalidate(selectedChildDetailProvider(widget.childId));
              },
            ),
        ],
      ),
      body: childAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (child) {
          if (child == null) {
            return const Center(child: Text('Profil tidak ditemukan'));
          }

          if (!_isEditing && _nameController.text.isEmpty) {
            _nameController.text = child.name;
            _birthDate = child.birthDate;
            _avatarUrl = child.avatarUrl;
          }

          return _isEditing ? _buildEditMode(child) : _buildViewMode(child);
        },
      ),
    );
  }

  Widget _buildViewMode(ChildProfile child) {
    final cs = Theme.of(context).colorScheme;
    final ageGroupLabel = switch (child.ageGroup) {
      AgeGroup.earlyChildhood => '2-5 tahun (Batita)',
      AgeGroup.primary => '6-9 tahun (Kanak-kanak awal)',
      AgeGroup.upperPrimary => '10-12 tahun (Kanak-kanak akhir)',
      AgeGroup.teen => '13-18 tahun (Remaja)',
    };

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Avatar
        Center(
          child: CircleAvatar(
            radius: 56,
            backgroundColor: cs.primaryContainer,
            backgroundImage: child.avatarUrl != null ? NetworkImage(child.avatarUrl!) : null,
            child: child.avatarUrl == null
                ? Text(child.avatarUrl ?? '👦', style: const TextStyle(fontSize: 48))
                : null,
          ),
        ),
        const SizedBox(height: 24),
        // Name
        Center(
          child: Text(
            child.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            ageGroupLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 32),
        // Info cards
        _InfoTile(
          icon: Icons.cake_outlined,
          label: 'Usia',
          value: child.ageDisplay,
        ),
        _InfoTile(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal Lahir',
          value: '${child.birthDate.day}/${child.birthDate.month}/${child.birthDate.year}',
        ),
        _InfoTile(
          icon: Icons.check_circle_outline,
          label: 'Status',
          value: child.isActive ? 'Aktif' : 'Nonaktif',
        ),
        const SizedBox(height: 32),
        // Action buttons
        OutlinedButton.icon(
          onPressed: () => context.go('/parental-control'),
          icon: const Icon(Icons.security),
          label: const Text('Kelola Kontrol Orang Tua'),
        ),
        const SizedBox(height: 12),
        DestructiveButton(
          label: 'Hapus Profil',
          onPressed: () => _confirmDelete(child),
        ),
      ],
    );
  }

  Widget _buildEditMode(ChildProfile child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
              validator: (v) => v?.trim().isEmpty == true ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _saveEdit(child),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEdit(ChildProfile child) async {
    if (!_formKey.currentState!.validate()) return;
    final updated = child.copyWith(name: _nameController.text.trim());
    await ref.read(updateChildProvider.notifier).updateChild(updated);
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    }
  }

  Future<void> _confirmDelete(ChildProfile child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Profil?'),
        content: Text(
          'Profil ${child.name} akan dinonaktifkan. Data tidak akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(deleteChildProvider.notifier).deleteChild(child.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil dinonaktifkan')),
        );
        context.go('/children');
      }
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const DestructiveButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: Text(label, style: const TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
      ),
    );
  }
}