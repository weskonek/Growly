import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:growly_core/growly_core.dart';
import 'package:parent_app/features/children/providers/child_providers.dart';

// ── Shared state providers so wizard parent can read sub-step data ──────────

class _ScreenTimeData {
  final int dailyLimitHours;
  final bool bedtimeEnabled;
  final TimeOfDay bedtimeStart;
  final TimeOfDay bedtimeEnd;
  const _ScreenTimeData({
    this.dailyLimitHours = 2,
    this.bedtimeEnabled = false,
    this.bedtimeStart = const TimeOfDay(hour: 20, minute: 0),
    this.bedtimeEnd = const TimeOfDay(hour: 7, minute: 0),
  });
}

final _screenTimeStateProvider = StateProvider<_ScreenTimeData>((ref) => const _ScreenTimeData());

class _SchoolData {
  final bool enabled;
  final String start;
  final String end;
  final bool monEnabled, tueEnabled, wedEnabled, thuEnabled, friEnabled;
  const _SchoolData({
    this.enabled = false,
    this.start = '07:00',
    this.end = '15:00',
    this.monEnabled = true, this.tueEnabled = true, this.wedEnabled = true,
    this.thuEnabled = true, this.friEnabled = true,
  });
}

final _schoolStateProvider = StateProvider<_SchoolData>((ref) => const _SchoolData());

class OnboardingWizardPage extends ConsumerStatefulWidget {
  const OnboardingWizardPage({super.key});

  @override
  ConsumerState<OnboardingWizardPage> createState() => _OnboardingWizardPageState();
}

class _OnboardingWizardPageState extends ConsumerState<OnboardingWizardPage> {
  int _currentStep = 1;
  bool _loading = false;

  void _nextStep() async {
    if (_currentStep < 6) {
      if (_currentStep >= 2) await _markCurrentStepComplete(_currentStep);
      // Persist sub-step data before advancing
      if (_currentStep == 3) await _saveScreenTimeRules();
      if (_currentStep == 5) await _saveSchoolSchedule();
      setState(() => _currentStep++);
    }
  }

  Future<void> _saveScreenTimeRules() async {
    final childId = await _getFirstChildId();
    if (childId == null) return;
    final stState = ref.read(_screenTimeStateProvider);
    await Supabase.instance.client.from('screen_time_rules').upsert({
      'child_id': childId,
      'daily_limit_minutes': stState.dailyLimitHours * 60,
      'bedtime_enabled': stState.bedtimeEnabled,
      'bedtime_start': stState.bedtimeStart,
      'bedtime_end': stState.bedtimeEnd,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'child_id');
  }

  Future<void> _saveSchoolSchedule() async {
    final childId = await _getFirstChildId();
    if (childId == null) return;
    final schState = ref.read(_schoolStateProvider);
    if (!schState.enabled) return;
    final days = <int>[];
    if (schState.monEnabled) days.add(1);
    if (schState.tueEnabled) days.add(2);
    if (schState.wedEnabled) days.add(3);
    if (schState.thuEnabled) days.add(4);
    if (schState.friEnabled) days.add(5);
    for (final day in days) {
      await Supabase.instance.client.from('schedules').upsert({
        'child_id': childId,
        'day_of_week': day,
        'start_time': schState.start,
        'end_time': schState.end,
        'mode': 'school',
        'is_enabled': true,
        'label': 'Mode Sekolah',
      }, onConflict: 'child_id,day_of_week,mode');
    }
  }

  Future<String?> _getFirstChildId() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;
    final resp = await Supabase.instance.client
        .from('child_profiles')
        .select('id')
        .eq('parent_id', userId)
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();
    return resp?['id'] as String?;
  }

  Future<void> _markCurrentStepComplete(int step) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await Supabase.instance.client.from('onboarding_steps').upsert({
      'parent_id': userId,
      'step_number': step,
      'completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'parent_id,step_number');
  }

  Future<void> _finishOnboarding() async {
    setState(() => _loading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await Supabase.instance.client
          .from('parent_profiles')
          .update({'onboarding_completed': true})
          .eq('id', userId);
    }
    ref.invalidate(onboardingCompletedProvider);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressBar(cs),

            // Step content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildStepContent(cs),
            ),

            // Bottom buttons
            _buildBottomButtons(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: List.generate(6, (i) {
              final step = i + 1;
              final isActive = step == _currentStep;
              final isDone = step < _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 5 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isDone
                        ? cs.primary
                        : isActive
                            ? cs.primary.withValues(alpha: 0.5)
                            : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Langkah $_currentStep dari 6',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStepContent(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: switch (_currentStep) {
        1 => _buildWelcomeStep(cs),
        2 => _buildAddChildStep(cs),
        3 => _buildScreenTimeStep(cs),
        4 => _buildAppLockStep(cs),
        5 => _buildSchoolModeStep(cs),
        6 => _buildCompletionStep(cs),
        _ => const SizedBox(),
      },
    );
  }

  // ── Step 1: Welcome ──────────────────────────────────────────────
  Widget _buildWelcomeStep(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('👋', style: TextStyle(fontSize: 64)),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Selamat Datang\ndi Growly!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Growly adalah platform pertumbuhan digital berbasis AI yang dirancang khusus untuk anak-anak usia 2–18 tahun.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _featureCard(cs, '🤖', 'AI Tutor Pribadi',
            'Asisten belajar AI yang menjawab pertanyaan anak dengan bahasa yang mudah dipahami'),
        const SizedBox(height: 12),
        _featureCard(cs, '🔒', 'Kontrol Orang Tua',
            'Kelola waktu layar, aplikasi, dan aktivitas anak dari satu dashboard'),
        const SizedBox(height: 12),
        _featureCard(cs, '🏆', 'Sistem Reward',
            'Bintang dan badge untuk memotivasi anak belajar tanpa thérapeutik screen time'),
      ],
    );
  }

  Widget _featureCard(ColorScheme cs, String emoji, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Step 2: Add first child ─────────────────────────────────────
  Widget _buildAddChildStep(ColorScheme cs) {
    return _AddChildOnboardingStep(onChildAdded: _nextStep);
  }

  // ── Step 3: Screen time ──────────────────────────────────────────
  Widget _buildScreenTimeStep(ColorScheme cs) {
    return _ScreenTimeOnboardingStep(onConfigured: _nextStep);
  }

  // ── Step 4: App lock ─────────────────────────────────────────────
  Widget _buildAppLockStep(ColorScheme cs) {
    return _AppLockOnboardingStep(onConfigured: _nextStep);
  }

  // ── Step 5: School mode ──────────────────────────────────────────
  Widget _buildSchoolModeStep(ColorScheme cs) {
    return _SchoolModeOnboardingStep(onConfigured: _nextStep);
  }

  // ── Step 6: Completion ───────────────────────────────────────────
  Widget _buildCompletionStep(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primaryContainer, cs.secondaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('🎉', style: TextStyle(fontSize: 64))),
        ),
        const SizedBox(height: 32),
        Text(
          'Semua Siap!\nMari Mulai!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Profil anak sudah dibuat dan kontrol orang tua sudah dikonfigurasi.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _summaryCard(cs, '👶', 'Profil Anak', 'Sudah dibuat'),
        const SizedBox(height: 12),
        _summaryCard(cs, '⏰', 'Waktu Layar', 'Sudah dikonfigurasi'),
        const SizedBox(height: 12),
        _summaryCard(cs, '🔒', 'Kontrol Aplikasi', 'Sudah disetel'),
        const SizedBox(height: 12),
        _summaryCard(cs, '📚', 'Mode Sekolah', 'Tersedia kapan saja'),
      ],
    );
  }

  Widget _summaryCard(ColorScheme cs, String emoji, String title, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primaryContainer),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
        Text(status, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildBottomButtons(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Kembali'),
              ),
            ),
          if (_currentStep > 1) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _currentStep == 6 ? _finishOnboarding : _nextStep,
              child: Text(_currentStep == 6 ? 'Mulai Sekarang 🎉' : 'Lanjut →'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Onboarding sub-steps ──────────────────────────────────────────

class _AddChildOnboardingStep extends ConsumerStatefulWidget {
  final VoidCallback onChildAdded;
  const _AddChildOnboardingStep({required this.onChildAdded});

  @override
  ConsumerState<_AddChildOnboardingStep> createState() => _AddChildOnboardingStepState();
}

class _AddChildOnboardingStepState extends ConsumerState<_AddChildOnboardingStep> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedAvatar;
  bool _saving = false;

  final List<String> _avatarOptions = ['👦', '👧', '🧒', '👶', '🦸', '🧚', '🐼', '🦁', '🐰', '🐸'];

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Listen for child creation success
    ref.listen(createChildProvider, (prev, next) {
      if (next.hasValue && next.value != null && (prev == null || prev.value == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil anak berhasil dibuat! 🎉')),
        );
        widget.onChildAdded();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('👶', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          'Tambah Anak Pertama',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Masukkan nama dan tanggal lahir anak untuk membuat profil mereka.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Anak',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nama harus diisi' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Pilih tanggal'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Pilih Avatar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _avatarOptions.map((a) {
                  final selected = _selectedAvatar == a;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = a),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? cs.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(child: Text(a, style: const TextStyle(fontSize: 28))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN (4 digit)',
                  prefixIcon: Icon(Icons.pin),
                  border: OutlineInputBorder(),
                  helperText: 'PIN ini akan digunakan anak untuk masuk ke aplikasi mereka',
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (v) => v == null || v.length != 4 ? 'PIN harus 4 digit' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
                  label: Text(_saving ? 'Menyimpan...' : 'Simpan Profil'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal lahir terlebih dahulu')),
      );
      return;
    }

    setState(() => _saving = true);

    final notifier = ref.read(createChildProvider.notifier);
    final childId = await notifier.createChild(
      name: _nameController.text.trim(),
      birthDate: _selectedDate!,
      pin: _pinController.text,
      avatarUrl: _selectedAvatar,
    );

    if (childId != null) {
      // Complete step 2 in onboarding_steps
      await _markStepComplete(2);
    }
    setState(() => _saving = false);
  }

  Future<void> _markStepComplete(int step) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await Supabase.instance.client.from('onboarding_steps').upsert({
      'parent_id': userId,
      'step_number': step,
      'completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'parent_id,step_number');
  }
}

class _ScreenTimeOnboardingStep extends ConsumerStatefulWidget {
  final VoidCallback onConfigured;
  const _ScreenTimeOnboardingStep({required this.onConfigured});

  @override
  ConsumerState<_ScreenTimeOnboardingStep> createState() => _ScreenTimeOnboardingStepState();
}

class _ScreenTimeOnboardingStepState extends ConsumerState<_ScreenTimeOnboardingStep> {
  int _dailyLimitHours = 2;
  bool _bedtimeEnabled = false;
  TimeOfDay _bedtimeStart = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _bedtimeEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⏰', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          'Atur Waktu Layar',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Tentukan batasan waktu layar harian yang sehat untuk anak.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Batas Harian', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('$_dailyLimitHours jam per hari', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _dailyLimitHours.toDouble(),
                  min: 0,
                  max: 6,
                  divisions: 6,
                  label: '$_dailyLimitHours jam',
                  onChanged: (v) {
                    setState(() => _dailyLimitHours = v.round());
                    _syncToProvider();
                  },
                ),
                if (_dailyLimitHours == 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Icon(Icons.warning, color: cs.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Batas 0 jam berarti anak tidak bisa menggunakan perangkat',
                            style: TextStyle(color: cs.error, fontSize: 12)),
                      ),
                    ]),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.bedtime, color: Colors.purple),
            title: const Text('Waktu Tidur'),
            subtitle: Text(_bedtimeEnabled
                ? '${_bedtimeStart.format(context)} - ${_bedtimeEnd.format(context)}'
                : 'Tidak aktif'),
            value: _bedtimeEnabled,
            onChanged: (v) => setState(() => _bedtimeEnabled = v),
          ),
        ),
        if (_bedtimeEnabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickTime(context, true),
                  icon: const Icon(Icons.access_time),
                  label: Text('Mulai: ${_bedtimeStart.format(context)}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickTime(context, false),
                  icon: const Icon(Icons.access_time),
                  label: Text('Akhir: ${_bedtimeEnd.format(context)}'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _syncToProvider() {
    ref.read(_screenTimeStateProvider.notifier).state = _ScreenTimeData(
      dailyLimitHours: _dailyLimitHours,
      bedtimeEnabled: _bedtimeEnabled,
      bedtimeStart: _bedtimeStart,
      bedtimeEnd: _bedtimeEnd,
    );
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _bedtimeStart : _bedtimeEnd,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _bedtimeStart = picked;
      } else {
        _bedtimeEnd = picked;
      }
    });
    _syncToProvider();
  }
}

class _AppLockOnboardingStep extends ConsumerStatefulWidget {
  final VoidCallback onConfigured;
  const _AppLockOnboardingStep({required this.onConfigured});

  @override
  ConsumerState<_AppLockOnboardingStep> createState() => _AppLockOnboardingStepState();
}

class _AppLockOnboardingStepState extends ConsumerState<_AppLockOnboardingStep> {
  bool _whitelistMode = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔒', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          'Atur Kontrol Aplikasi',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih aplikasi yang boleh digunakan anak. Mode daftar putih (hanya aplikasi yang dipilih) lebih direkomendasikan.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Daftar Putih'), icon: Icon(Icons.check_circle)),
            ButtonSegment(value: false, label: Text('Daftar Hitam'), icon: Icon(Icons.block)),
          ],
          selected: {_whitelistMode},
          onSelectionChanged: (s) => setState(() => _whitelistMode = s.first),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _whitelistMode ? cs.primaryContainer : cs.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(_whitelistMode ? Icons.shield : Icons.warning, color: _whitelistMode ? cs.primary : cs.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _whitelistMode
                    ? 'Hanya aplikasi yang Anda pilih yang bisa digunakan anak.'
                    : 'Semua aplikasi bisa digunakan KECUALI yang Anda pilih.',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Text(
          'Belum ada aplikasi yang dipindai. Aplikasi akan muncul setelah anak menggunakan perangkat.',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(Icons.info_outline, color: cs.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Anda bisa mengatur ulang kontrol aplikasi kapan saja di menu Kontrol Orang Tua.',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Future<void> _markStepComplete(int step) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await Supabase.instance.client.from('onboarding_steps').upsert({
      'parent_id': userId,
      'step_number': step,
      'completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'parent_id,step_number');
  }
}

class _SchoolModeOnboardingStep extends ConsumerStatefulWidget {
  final VoidCallback onConfigured;
  const _SchoolModeOnboardingStep({required this.onConfigured});

  @override
  ConsumerState<_SchoolModeOnboardingStep> createState() => _SchoolModeOnboardingStepState();
}

class _SchoolModeOnboardingStepState extends ConsumerState<_SchoolModeOnboardingStep> {
  bool _schoolModeEnabled = false;
  String _schoolStart = '07:00';
  String _schoolEnd = '15:00';
  bool _monEnabled = true, _tueEnabled = true, _wedEnabled = true, _thuEnabled = true, _friEnabled = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📚', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          'Mode Sekolah',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Aktifkan Mode Sekolah untuk memblokir semua aplikasi di luar aplikasi belajar saat jam sekolah.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.school, color: Colors.blue),
            title: const Text('Aktifkan Mode Sekolah'),
            subtitle: const Text('Semua aplikasi non-belajar diblokir saat jam sekolah'),
            value: _schoolModeEnabled,
            onChanged: (v) => setState(() => _schoolModeEnabled = v),
          ),
        ),
        if (_schoolModeEnabled) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jam Sekolah', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickTime(context, true),
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text('Mulai: $_schoolStart'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickTime(context, false),
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text('Akhir: $_schoolEnd'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Hari Aktif', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(label: const Text('Senin'), selected: _monEnabled, onSelected: (v) => setState(() => _monEnabled = v)),
                      FilterChip(label: const Text('Selasa'), selected: _tueEnabled, onSelected: (v) => setState(() => _tueEnabled = v)),
                      FilterChip(label: const Text('Rabu'), selected: _wedEnabled, onSelected: (v) => setState(() => _wedEnabled = v)),
                      FilterChip(label: const Text('Kamis'), selected: _thuEnabled, onSelected: (v) => setState(() => _thuEnabled = v)),
                      FilterChip(label: const Text('Jumat'), selected: _friEnabled, onSelected: (v) => setState(() => _friEnabled = v)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final parts = (isStart ? _schoolStart : _schoolEnd).split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      final time = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStart) _schoolStart = time; else _schoolEnd = time;
    });
  }
}