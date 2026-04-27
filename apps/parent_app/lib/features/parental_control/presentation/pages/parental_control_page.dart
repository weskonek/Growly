import 'package:flutter/material.dart';

class ParentalControlPage extends StatelessWidget {
  const ParentalControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parental Control')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ControlTile(title: 'Screen Time Rules', subtitle: 'Atur jadwal dan batas pemakaian', icon: Icons.access_time),
          _ControlTile(title: 'App Lock & Whitelist', subtitle: 'Pilih aplikasi yang boleh dipakai', icon: Icons.apps),
          _ControlTile(title: 'School Mode', subtitle: 'Mode khusus saat jam sekolah', icon: Icons.school),
          _ControlTile(title: 'Safe Mode', subtitle: 'Launcher aman untuk anak kecil', icon: Icons.shield),
          _ControlTile(title: 'Lokasi & Perangkat', subtitle: 'Kelola perangkat terdaftar', icon: Icons.devices),
        ],
      ),
    );
  }
}

class _ControlTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _ControlTile({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
