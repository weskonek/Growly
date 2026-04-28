import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import 'package:fl_chart/fl_chart.dart';

class ScreenTimePage extends ConsumerStatefulWidget {
  final String childId;

  const ScreenTimePage({super.key, required this.childId});

  @override
  ConsumerState<ScreenTimePage> createState() => _ScreenTimePageState();
}

class _ScreenTimePageState extends ConsumerState<ScreenTimePage> {
  int _dailyLimit = 120;
  bool _isEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _screenTimeRestrictionId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(_screenTimeRestrictionRepoProvider);
    final (restrictions, failure) = await repo.getRestrictions(widget.childId);

    if (!mounted) return;
    if (failure != null || restrictions == null) {
      setState(() => _isLoading = false);
      return;
    }

    final screenTimeRestriction = restrictions
        .where((r) => r.appPackage == 'screen_time')
        .firstOrNull;

    setState(() {
      if (screenTimeRestriction != null) {
        _screenTimeRestrictionId = screenTimeRestriction.id;
        _dailyLimit = screenTimeRestriction.scheduleLimits['daily_limit'] ??
            screenTimeRestriction.timeLimitMinutes ??
            120;
        _isEnabled = screenTimeRestriction.isAllowed;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    final repo = ref.read(_screenTimeRestrictionRepoProvider);
    final restriction = AppRestriction(
      id: _screenTimeRestrictionId ?? '',
      childId: widget.childId,
      appPackage: 'screen_time',
      appName: 'Screen Time',
      isAllowed: _isEnabled,
      timeLimitMinutes: _dailyLimit,
      scheduleLimits: {'daily_limit': _dailyLimit},
      createdAt: DateTime.now(),
    );

    final (_, failure) = await repo.saveRestriction(restriction);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $failure'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan tersimpan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final todayAsync = ref.watch(_todayScreenTimeProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batas Waktu Layar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Today's usage
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: cs.primary),
                            const SizedBox(width: 8),
                            Text('Hari Ini',
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 16),
                        todayAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Gagal memuat'),
                          data: (minutes) => Row(
                            children: [
                              Text(
                                '${minutes ~/ 60}h ${minutes % 60}m',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: minutes > _dailyLimit
                                          ? Colors.red
                                          : cs.primary,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                'batas $_dailyLimit menit',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Toggle
                SwitchListTile(
                  title: const Text('Aktifkan Batas Waktu'),
                  subtitle: const Text('Batasi waktu layar anak per hari'),
                  value: _isEnabled,
                  onChanged: (v) => setState(() => _isEnabled = v),
                ),
                if (_isEnabled) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Batas Harian: $_dailyLimit menit',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _dailyLimit.toDouble(),
                    min: 30,
                    max: 240,
                    divisions: 14,
                    label: '${_dailyLimit ~/ 60}h ${_dailyLimit % 60}m',
                    onChanged: (v) => setState(() => _dailyLimit = v.round()),
                  ),
                ],
                const SizedBox(height: 32),
                // Save button
                FilledButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
                const SizedBox(height: 32),
                // Weekly chart placeholder
                Text('Statistik Mingguan',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles:
                            AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                  ['S', 'M', 'T', 'W', 'F', 'S', 'S']
                                      [value.toInt() % 7]);
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        7,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: (i + 1) * 20.0,
                              color: cs.primary.withValues(alpha: 0.8),
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

final _todayScreenTimeProvider =
    FutureProvider.family<int, String>((ref, childId) async {
  final repo = ref.watch(_screenTimeRepoProvider);
  final (daily, _) = await repo.getDailyScreenTime(childId, DateTime.now());
  return daily?.totalMinutes ?? 0;
});

final _screenTimeRepoProvider = Provider<IScreenTimeRepository>((ref) {
  return ScreenTimeRepositoryImpl();
});

final _screenTimeRestrictionRepoProvider =
    Provider<IAppRestrictionRepository>((ref) {
  return AppRestrictionRepositoryImpl();
});
