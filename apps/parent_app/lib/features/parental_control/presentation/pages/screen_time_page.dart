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
  int _dailyLimit = 120; // minutes
  bool _isEnabled = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final todayAsync = ref.watch(_todayScreenTimeProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batas Waktu Layar'),
      ),
      body: ListView(
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
                      Text('Hari Ini', style: Theme.of(context).textTheme.titleMedium),
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
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: minutes > _dailyLimit ? Colors.red : cs.primary,
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
          // Weekly chart placeholder
          Text('Statistik Mingguan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(['S', 'M', 'T', 'W', 'F', 'S', 'S'][value.toInt() % 7]);
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
                        color: cs.primary.withOpacity(0.8),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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

final _todayScreenTimeProvider = FutureProvider.family<int, String>((ref, childId) async {
  final repo = ref.watch(_screenTimeRepoProvider);
  final (daily, _) = await repo.getDailyScreenTime(childId, DateTime.now());
  return daily?.totalMinutes ?? 0;
});

final _screenTimeRepoProvider = Provider<IScreenTimeRepository>((ref) {
  return ScreenTimeRepositoryImpl();
});