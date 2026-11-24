import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../data/viril_store.dart';
import '../theme/viril_colors.dart';
import 'viril_animated_stack.dart';
import '../../features/home/home_screen.dart';
import '../../features/development/development_screen.dart';
import '../../features/resources/resources_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/community/community_screen.dart';
import '../../features/profile/data/profile_store.dart';

class VirilShell extends StatefulWidget {
  const VirilShell({super.key});
  @override State<VirilShell> createState() => _VirilShellState();
}
class _VirilShellState extends State<VirilShell> {
  int _index = 0;
  late final List<Widget> _screens = [
    HomeScreen(onOpenProfile: _openProfile), const DevelopmentScreen(),
    const ResourcesScreen(), const ProgressScreen(), const ProfileScreen(), const CommunityScreen(),
  ];
  void _openProfile() => setState(() => _index = 4);
  static const _items = [
    (Icons.home_rounded, 'Главная'), (Icons.auto_awesome_rounded, 'Развитие'),
    (Icons.menu_book_rounded, 'Ресурсы'), (Icons.insights_rounded, 'Прогресс'),
    (Icons.person_rounded, 'Профиль'), (Icons.groups_rounded, 'Сообщество'),
  ];
  @override void initState() { super.initState(); VirilStore.instance.initialize(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: true,
    body: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_index == 1 || _index == 3)
            SizedBox(height: 64, child: _header()),
          Expanded(child: VirilAnimatedStack(index: _index, children: _screens)),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: SizedBox(
          height: 112,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: _HillNavClipper(),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xE51B222D), Color(0xF20D1118), Color(0xFF090C11)],
                        ),
                        border: Border.all(
                          color: VirilColors.goldSoft.withValues(alpha: .34),
                          width: .9,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .34),
                            blurRadius: 26,
                            offset: const Offset(0, -7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 5,
                height: 57,
                child: Row(
                  children: [
                    _navItem(1, Icons.auto_awesome_rounded, 'Развитие'),
                    _navItem(2, Icons.menu_book_rounded, 'Ресурсы'),
                    _navItem(5, Icons.groups_rounded, 'Сообщество'),
                    _navItem(3, Icons.insights_rounded, 'Прогресс'),
                    _navItem(4, Icons.person_rounded, 'Профиль'),
                  ],
                ),
              ),
              Positioned(
                top: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: _homeNavItem(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _index == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _index = index),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: selected ? VirilColors.gold : VirilColors.ice.withValues(alpha: .78)),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.05,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: selected ? VirilColors.gold : VirilColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _homeNavItem() {
    final selected = _index == 0;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Главная',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _index = 0),
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            width: 82,
            height: 61,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: selected
                        ? [VirilColors.gold, VirilColors.goldSoft]
                        : [const Color(0xFF394657), const Color(0xFF1A222D)],
                    ),
                    border: Border.all(
                      color: VirilColors.goldSoft.withValues(alpha: selected ? .85 : .55),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: VirilColors.gold.withValues(alpha: selected ? .22 : .10),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    size: 23,
                    color: selected ? VirilColors.black : VirilColors.gold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Главная',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: selected ? VirilColors.gold : VirilColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    if (_index == 1) return const Padding(
      padding: EdgeInsets.fromLTRB(22, 12, 22, 12),
      child: Align(alignment: Alignment.centerLeft, child: Text('Развитие',
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: VirilColors.gold.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: VirilColors.gold.withValues(alpha: .42)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.toll_rounded, color: VirilColors.gold, size: 17),
                    const SizedBox(width: 4),
                    Text('${VirilStore.instance.vcoins}', style: const TextStyle(
                      color: VirilColors.gold, fontSize: 12, fontWeight: FontWeight.w900)),
                  ]),
                ),
                const SizedBox(width: 6),
                Tooltip(message: 'Виджеты', child: Material(
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
                Tooltip(message: 'Уведомления', child: Material(
                  color: VirilColors.stone,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: VirilColors.line)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Уведомления появятся в одном из следующих обновлений.'))),
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
        Text('Система дисциплины и целей', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
      ])),
    ]));
  }
}

class _HillNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 43);
    path.quadraticBezierTo(0, 25, 19, 25);
    path.lineTo(size.width * .285, 25);
    path.cubicTo(
      size.width * .365, 25,
      size.width * .385, 1,
      size.width * .5, 1,
    );
    path.cubicTo(
      size.width * .615, 1,
      size.width * .635, 25,
      size.width * .715, 25,
    );
    path.lineTo(size.width - 19, 25);
    path.quadraticBezierTo(size.width, 25, size.width, 43);
    path.lineTo(size.width, size.height - 23);
    path.quadraticBezierTo(size.width, size.height, size.width - 23, size.height);
    path.lineTo(23, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 23);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _HillNavClipper oldClipper) => false;
}
