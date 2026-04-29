import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/child_providers.dart' show createChildProvider, childrenListProvider;
import '../../../../core/providers/subscription_provider.dart';

class AddChildPage extends ConsumerStatefulWidget {
  const AddChildPage({super.key});

  @override
  ConsumerState<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends ConsumerState<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedAvatar;

  final List<String> _avatarOptions = [
    '👦', '👧', '🧒', '👶', '🦸', '🧚', '🐼', '🦁', '🐰', '🐸',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childState = ref.watch(createChildProvider);
    final canAddAsync = ref.watch(canAddChildProvider);

    // Re-check limit when subscription changes (e.g., after upgrade)
    ref.listen(subscriptionProvider, (prev, next) {
      next.whenData((_) => ref.invalidate(canAddChildProvider));
    });

    // Re-check limit when children list changes (add/delete)
    ref.listen(childrenListProvider, (prev, next) {
      ref.invalidate(canAddChildProvider);
    });

    ref.listen(createChildProvider, (prev, next) {
      if (next.hasError && (prev == null || !prev.hasError)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${next.error}'), backgroundColor: Colors.red),
        );
      }
      if (next.hasValue && next.value != null && (prev == null || prev.value == null)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil anak berhasil ditambahkan!')),
        );
        context.go('/children');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Profil Anak')),
      body: canAddAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildForm(context, childState, Theme.of(context).colorScheme),
        data: (canAdd) => canAdd
            ? _buildForm(context, childState, Theme.of(context).colorScheme)
            : _buildUpgradeBanner(context),
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👶', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Batas Anak Tercapai',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Akun Free hanya bisa menambahkan hingga 2 anak. Upgrade ke Premium untuk menambah lebih banyak.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/settings/subscription'),
              child: const Text('Upgrade Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AsyncValue childState, ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilih Avatar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarOptions.length,
                itemBuilder: (context, index) {
                  final avatar = _avatarOptions[index];
                  final isSelected = _selectedAvatar == avatar;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = avatar),
                    child: Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: cs.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(avatar, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama Anak',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                child: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Pilih tanggal',
                  style: TextStyle(
                    color: _selectedDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN (opsional)',
                prefixIcon: Icon(Icons.pin_outlined),
                helperText: '4-6 digit untuk anak masuk app',
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: childState.isLoading ? null : _saveChild,
              child: childState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal lahir')),
      );
      return;
    }

    await ref.read(createChildProvider.notifier).createChild(
          name: _nameController.text.trim(),
          birthDate: _selectedDate!,
          avatarUrl: _selectedAvatar,
          pin: _pinController.text.isNotEmpty ? _pinController.text : null,
        );
    // Navigation and feedback handled by ref.listen above
  }
}
