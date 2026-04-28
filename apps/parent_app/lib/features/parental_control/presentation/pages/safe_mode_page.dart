import 'package:flutter/material.dart';

class SafeModePage extends StatelessWidget {
  final String childId;

  const SafeModePage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mode Aman')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.shield, size: 48, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Mode Aman',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketika aktif, anak hanya bisa mengakses aplikasi yang sudah disetujui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SwitchListTile(
            title: Text('Aktifkan Mode Aman'),
            subtitle: Text('Hanya tampilkan app di whitelist'),
            value: false,
            onChanged: null,
          ),
          const SizedBox(height: 24),
          Text(
            'Aplikasi yang Diizinkan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: const Text('📚 Growly Belajar')),
              Chip(label: const Text('📖 Cerita Anak')),
              Chip(label: const Text('🎵 Musik Anak')),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Tambah Aplikasi'),
          ),
        ],
      ),
    );
  }
}