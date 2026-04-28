import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  final String childId;

  const LocationPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 24),
              Text(
                'Pelacakan Lokasi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Fitur pelacakan lokasi memerlukan aplikasi Growly Child diinstal di perangkat anak dan izin lokasi yang sesuai.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.help_outline),
                label: const Text('Panduan Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}