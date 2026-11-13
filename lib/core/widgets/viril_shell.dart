import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';
import 'particle_backdrop.dart';
import '../../features/home/home_screen.dart';
import '../../features/development/development_screen.dart';
import '../../features/resources/resources_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/profile/profile_screen.dart';

class VirilShell extends StatefulWidget {
  const VirilShell({super.key});
  @override
  State<VirilShell> createState() => _VirilShellState();
}

class _VirilShellState extends State<VirilShell> {
  int _index = 0;
  late final List<Widget> _screens = [
    HomeScreen(onOpenProfile: _openProfile),
    const DevelopmentScreen(), const ResourcesScreen(), const ProgressScreen(), const ProfileScreen(),
  ];

  void _openProfile() => setState(() => _index = 4);
  static const _items = [
    (Icons.home_rounded, 'Главная'),
    (Icons.auto_awesome_rounded, 'Развитие'),
    (Icons.menu_book_rounded, 'Ресурсы'),
    (Icons.insights_rounded, 'Прогресс'),
    (Icons.person_rounded, 'Профиль'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: ParticleBackdrop(child: SafeArea(
        bottom: false,
        child: Column(children: [
          if (_index != 0) _header(),
          Expanded(child: IndexedStack(index: _index, children: _screens)),
        ]),
      )),
      bottomNavigationBar: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xF0101420),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: VirilColors.line.withValues(alpha: .8)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 22, offset: Offset(0, 8))],
          ),
          child: NavigationBar(
            height: 72,
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: [for (final item in _items)
              NavigationDestination(icon: Icon(item.$1), label: item.$2)],
          ),
        ),
      )),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF34415D), Color(0xFF27223D)]),
        border: Border.all(color: VirilColors.ice.withValues(alpha: .45)),
      ), child: const Center(child: Text('🧠', style: TextStyle(fontSize: 23)))),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Viril Top', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        Text('Система дисциплины и целей', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
      ])),
    ]),
  );
}
