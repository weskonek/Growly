import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shell for child app after PIN verification.
/// Shows 4 tabs: Beranda, Belajar, Tutor, Hadiah.
/// Launcher (PIN gate) is outside this shell.
class ChildShell extends StatelessWidget {
  final Widget child;
  final String location;

  const ChildShell({super.key, required this.child, required this.location});

  int _indexForLocation(String loc) {
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/learning')) return 1;
    if (loc.startsWith('/ai-tutor')) return 2;
    if (loc.startsWith('/rewards') || loc.startsWith('/store')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 28),
            selectedIcon: Icon(Icons.home, size: 28),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, size: 28),
            selectedIcon: Icon(Icons.menu_book, size: 28),
            label: 'Belajar',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined, size: 28),
            selectedIcon: Icon(Icons.smart_toy, size: 28),
            label: 'Tutor',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined, size: 28),
            selectedIcon: Icon(Icons.emoji_events, size: 28),
            label: 'Hadiah',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/home'); break;
            case 1: context.go('/learning'); break;
            case 2: context.go('/ai-tutor'); break;
            case 3: context.go('/rewards'); break;
          }
        },
      ),
    );
  }
}