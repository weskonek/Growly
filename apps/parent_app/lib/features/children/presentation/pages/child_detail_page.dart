import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:growly_core/growly_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/child_providers.dart'
    show selectedChildDetailProvider, updateChildProvider, deleteChildProvider;
import 'tabs/activity_tab.dart';
import 'tabs/insight_tab.dart';

class ChildDetailPage extends ConsumerStatefulWidget {
  final String childId;

  const ChildDetailPage({super.key, required this.childId});

  @override
  ConsumerState<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends ConsumerState<ChildDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(selectedChildDetailProvider(widget.childId));

    ref.listen(updateChildProvider, (prev, next) {
      if (next.hasError && (prev == null || !prev.hasError)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${next.error}'), backgroundColor: Colors.red),
        );
      }
      if (next.hasValue && (prev == null || !prev.hasValue)) {
        setState(() => _isEditing = false);
        ref.invalidate(selectedChildDetailProvider(widget.childId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Profil Anak'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'Aktivitas'),
            Tab(text: 'Insight'),
          ],
        ),
        actions: [
          if (!_isEditing && _tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else if (_tabController.index == 0)
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
          return TabBarView(
            controller: _tabController,
            children: [
              _isEditing
                  ? _buildEditMode(child)
                  : _buildProfileTab(child),
              ActivityTab(childId: widget.childId),
              InsightTab(childId: widget.childId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTab(ChildProfile child) {
    final cs = Theme.of(context).colorScheme;
    final ageGroupLabel = switch (child.ageGroup) {
      AgeGroup.earlyChildhood => '2-5 tahun (Batita)',
      AgeGroup.primary => '6-9 tahun (Kanak-kanak awal)',
      AgeGroup.upperPrimary => '10-12 tahun (Kanak-kanak akhir)',
      AgeGroup.teen => '13-18 tahun (Remaja)',
    };

    if (_nameController.text.isEmpty) {
      _nameController.text = child.name;
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 56,
            backgroundColor: cs.primaryContainer,
            backgroundImage:
                child.avatarUrl != null ? NetworkImage(child.avatarUrl!) : null,
            child: child.avatarUrl == null
                ? Text(child.avatarUrl ?? '👦', style: const TextStyle(fontSize: 48))
                : null,
          ),
        ),
        const SizedBox(height: 24),
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
        _InfoTile(
          icon: Icons.cake_outlined,
          label: 'Usia',
          value: child.ageDisplay,
        ),
        _InfoTile(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal Lahir',
          value:
              '${child.birthDate.day}/${child.birthDate.month}/${child.birthDate.year}',
        ),
        const _InfoTile(
          icon: Icons.check_circle_outline,
          label: 'Status',
          value: 'Aktif',
        ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () => context.go('/parental-control'),
          icon: const Icon(Icons.security),
          label: const Text('Kelola Kontrol Orang Tua'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showChangePinDialog(child),
          icon: const Icon(Icons.pin_outlined),
          label: const Text('Ganti PIN Anak'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showResetPinDialog(child),
          icon: const Icon(Icons.lock_reset),
          label: const Text('Reset PIN Anak'),
        ),
        const SizedBox(height: 12),
        _DestructiveButton(
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

    if (confirmed != true) return;
    final success =
        await ref.read(deleteChildProvider.notifier).deleteChild(child.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil dinonaktifkan')),
      );
      context.go('/children');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal menghapus profil'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showChangePinDialog(ChildProfile child) async {
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti PIN'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'PIN Baru (4-6 digit)',
              counterText: '',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'PIN wajib diisi';
              if (v.length < 4) return 'PIN minimal 4 digit';
              if (!RegExp(r'^\d+$').hasMatch(v)) return 'PIN hanya angka';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final parentId = Supabase.instance.client.auth.currentUser?.id;
    if (parentId == null) return;

    final result = await Supabase.instance.client.rpc('set_child_pin', params: {
      'p_child_id': child.id,
      'p_pin': pinController.text,
      'p_parent_id': parentId,
    });

    if (!mounted) return;
    final success = result?[0]?['success'] == true || result?['success'] == true;
    final message =
        result?[0]?['message'] ?? result?['message'] ?? (success ? 'PIN berhasil diubah' : 'Gagal');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? null : Colors.red,
      ),
    );
  }

  Future<void> _showResetPinDialog(ChildProfile child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset PIN?'),
        content: Text(
          'PIN ${child.name} akan direset ke 0000. Anak perlu membuat PIN baru.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset PIN'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await Supabase.instance.client.rpc('reset_child_pin', params: {
      'p_child_id': child.id,
    });

    if (!mounted) return;
    final success = result?[0]?['success'] == true || result?['success'] == true;
    final message =
        result?[0]?['message'] ?? result?['message'] ?? (success ? 'PIN direset' : 'Gagal reset PIN');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

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

class _DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DestructiveButton({required this.label, required this.onPressed});

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
