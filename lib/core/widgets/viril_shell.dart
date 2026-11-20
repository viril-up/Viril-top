import 'package:flutter/material.dart';
import '../data/viril_store.dart';
import '../localization/viril_localization.dart';
import '../theme/viril_colors.dart';
import 'viril_animated_stack.dart';
import '../../features/home/home_screen.dart';
import '../../features/development/development_screen.dart';
import '../../features/resources/resources_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/data/profile_store.dart';

class VirilShell extends StatefulWidget {
  const VirilShell({super.key});
  @override State<VirilShell> createState() => _VirilShellState();
}
class _VirilShellState extends State<VirilShell> {
  int _index = 0;
  late final List<Widget> _screens = [
    HomeScreen(onOpenProfile: _openProfile), const DevelopmentScreen(),
    const ResourcesScreen(), const ProgressScreen(), const ProfileScreen(),
  ];
  void _openProfile() => setState(() => _index = 4);
  @override void initState() { super.initState(); VirilStore.instance.initialize(); }
  @override Widget build(BuildContext context) {
    final s = VirilStrings.of(context);
    return Scaffold(
    extendBody: false,
    body: SafeArea(bottom: false, child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
      if (_index == 1 || _index == 3)
        SizedBox(height: 64, child: _header()),
      Expanded(child: VirilAnimatedStack(index: _index, children: _screens)),
    ])),
    bottomNavigationBar: SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Container(decoration: BoxDecoration(color: const Color(0xF20A0D13),
        borderRadius: BorderRadius.circular(25), border: Border.all(color: VirilColors.goldSoft.withValues(alpha: .22), width: .8),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 22, offset: Offset(0, 8))]),
        child: NavigationBar(height: 72, selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_rounded), label: s.t('navHome')),
            NavigationDestination(icon: const Icon(Icons.auto_awesome_rounded), label: s.t('navDevelopment')),
            NavigationDestination(icon: const Icon(Icons.menu_book_rounded), label: s.t('navResources')),
            NavigationDestination(icon: const Icon(Icons.insights_rounded), label: s.t('navProgress')),
            NavigationDestination(icon: const Icon(Icons.person_rounded), label: s.t('navProfile')),
          ]),
      ),
    )),
    );
  }
  Widget _header() {
    if (_index == 1) return Padding(
      padding: EdgeInsets.fromLTRB(22, 12, 22, 12),
      child: Align(alignment: Alignment.centerLeft, child: Text(VirilStrings.of(context).t('navDevelopment'),
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: VirilColors.text))),
    );
    if (_index == 3) return AnimatedBuilder(animation: Listenable.merge([VirilStore.instance, ProfileStore.instance]), builder: (context, _) {
      final profile = ProfileStore.instance;
      return Padding(padding: const EdgeInsets.fromLTRB(16, 7, 16, 8), child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Material(
                    color: VirilColors.stone,
                    shape: const CircleBorder(side: BorderSide(color: VirilColors.gold)),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _openProfile,
                      child: SizedBox(width: 40, height: 40, child: Icon(profile.avatarIcon, color: VirilColors.gold, size: 21)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text(profile.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                  decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: VirilColors.line)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.local_fire_department_rounded, color: VirilColors.lava, size: 18),
                    const SizedBox(width: 4),
                    Text('${VirilStore.instance.activeDaysStreak}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(width: 6),
                Tooltip(message: VirilStrings.of(context).t('widgets'), child: Material(
                  color: VirilColors.stone,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: VirilColors.goldSoft)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => setState(() => _index = 0),
                    child: const SizedBox(width: 40, height: 40,
                      child: Icon(Icons.dashboard_customize_rounded, color: VirilColors.gold, size: 19)),
                  ),
                )),
                const SizedBox(width: 6),
                Tooltip(message: VirilStrings.of(context).t('notifications'), child: Material(
                  color: VirilColors.stone,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: VirilColors.line)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(VirilStrings.of(context).t('notificationsSoon')))),
                    child: const SizedBox(width: 40, height: 40,
                      child: Icon(Icons.notifications_none_rounded, color: VirilColors.ice, size: 20)),
                  ),
                )),
              ],
            ),
          ],
        ),
      ));
    });
    return Padding(padding: const EdgeInsets.fromLTRB(22, 10, 22, 12), child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [VirilColors.navy, VirilColors.black, VirilColors.stone]),
        border: Border.all(color: VirilColors.goldSoft.withValues(alpha: .34))),
        child: const Center(child: Text('🧠', style: TextStyle(fontSize: 23)))),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Viril Top', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        Text(VirilStrings.of(context).t('shellSubtitle'), style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
      ])),
    ]));
  }
}
