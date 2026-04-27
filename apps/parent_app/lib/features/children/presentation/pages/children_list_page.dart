import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChildrenListPage extends StatelessWidget {
  const ChildrenListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Anak')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/children/add'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Anak'),
      ),
      body: const Center(child: Text('Daftar profil anak — coming soon')),
    );
  }
}
