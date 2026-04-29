import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import 'package:parent_app/features/children/providers/child_providers.dart';

class SchoolModePage extends ConsumerStatefulWidget {
  final String childId;

  const SchoolModePage({super.key, required this.childId});

  @override
  ConsumerState<SchoolModePage> createState() => _SchoolModePageState();
}

class _SchoolModePageState extends ConsumerState<SchoolModePage> {
  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(_schoolSchedulesProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(title: const Text('Mode Sekolah')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleSheet(context),
        child: const Icon(Icons.add),
      ),
      body: schedulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(
              child: Text('Belum ada jadwal mode sekolah.\nTekan + untuk menambahkan.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final s = schedules[index];
              final dayName = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: s.isEnabled ? Colors.blue.shade100 : Colors.grey.shade200,
                    child: const Icon(Icons.school, color: Colors.blue),
                  ),
                  title: Text('${dayName[s.dayOfWeek - 1]}'),
                  subtitle: Text('${s.startTime} - ${s.endTime}'),
                  trailing: Switch(
                    value: s.isEnabled,
                    onChanged: (v) => _toggleSchedule(s, v),
                  ),
                  onTap: () => _showScheduleSheet(context, existing: s),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showScheduleSheet(BuildContext context, {Schedule? existing}) {
    int selectedDay = existing?.dayOfWeek ?? 1;
    TimeOfDay startTime = existing != null
        ? _parseTimeOfDay(existing.startTime)
        : const TimeOfDay(hour: 7, minute: 0);
    TimeOfDay endTime = existing != null
        ? _parseTimeOfDay(existing.endTime)
        : const TimeOfDay(hour: 14, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing != null ? 'Edit Jadwal' : 'Tambah Jadwal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedDay,
                decoration: const InputDecoration(labelText: 'Hari'),
                items: List.generate(
                  7,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][i]),
                  ),
                ),
                onChanged: (v) => setSheetState(() => selectedDay = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: startTime);
                        if (t != null) setSheetState(() => startTime = t);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Mulai'),
                        child: Text(startTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: endTime);
                        if (t != null) setSheetState(() => endTime = t);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Selesai'),
                        child: Text(endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  _saveSchedule(selectedDay, startTime, endTime, existing: existing);
                  Navigator.pop(context);
                },
                child: Text(existing != null ? 'Perbarui' : 'Tambah'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _saveSchedule(int day, TimeOfDay start, TimeOfDay end, {Schedule? existing}) async {
    final repo = ref.read(appRestrictionRepositoryProvider);
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    if (existing != null) {
      final updated = existing.copyWith(
        dayOfWeek: day,
        startTime: startStr,
        endTime: endStr,
      );
      await repo.updateSchedule(updated);
    } else {
      final schedule = Schedule(
        id: '',
        childId: widget.childId,
        dayOfWeek: day,
        startTime: startStr,
        endTime: endStr,
        mode: 'school',
        isEnabled: true,
        createdAt: DateTime.now(),
      );
      await repo.createSchedule(schedule);
    }
    ref.invalidate(_schoolSchedulesProvider(widget.childId));
  }

  Future<void> _toggleSchedule(Schedule s, bool enabled) async {
    final repo = ref.read(appRestrictionRepositoryProvider);
    await repo.saveSchedule(s.copyWith(isEnabled: enabled));
    ref.invalidate(_schoolSchedulesProvider(widget.childId));
  }
}

final _schoolSchedulesProvider =
    FutureProvider.family<List<Schedule>, String>((ref, childId) async {
  final repo = ref.watch(appRestrictionRepositoryProvider);
  final (schedules, _) = await repo.getSchedules(childId);
  return (schedules ?? []).where((s) => s.mode == 'school').toList();
});