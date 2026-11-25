import 'package:flutter/material.dart';

class ProfileFrameStyle {
  const ProfileFrameStyle({
    required this.name,
    required this.colors,
    required this.glow,
  });

  final String name;
  final List<Color> colors;
  final Color glow;
}

class ProfileFrame extends StatelessWidget {
  const ProfileFrame({
    super.key,
    required this.frameIndex,
    required this.size,
    required this.child,
  });

  final int frameIndex;
  final double size;
  final Widget child;

  static const styles = <ProfileFrameStyle>[
    ProfileFrameStyle(name: 'Мужество', colors: [Color(0xFFFF8A65), Color(0xFFB83232), Color(0xFF541B24)], glow: Color(0xFFE45A48)),
    ProfileFrameStyle(name: 'Мудрость', colors: [Color(0xFFF0F4F8), Color(0xFF8298B4), Color(0xFF35465D)], glow: Color(0xFF9CB7D7)),
    ProfileFrameStyle(name: 'Духовность', colors: [Color(0xFFD5B7FF), Color(0xFF7955B4), Color(0xFF30234D)], glow: Color(0xFF9875D4)),
    ProfileFrameStyle(name: 'Спорт', colors: [Color(0xFFB5F4C5), Color(0xFF319B65), Color(0xFF164A3B)], glow: Color(0xFF49B77A)),
    ProfileFrameStyle(name: 'Дисциплина', colors: [Color(0xFFFFE0A1), Color(0xFFB58A45), Color(0xFF594329)], glow: Color(0xFFC49A55)),
    ProfileFrameStyle(name: 'Интеллект', colors: [Color(0xFFB5E5FF), Color(0xFF398BC6), Color(0xFF193A65)], glow: Color(0xFF4CA8E5)),
    ProfileFrameStyle(name: 'Гармония', colors: [Color(0xFFB5F0E8), Color(0xFF3A9F9A), Color(0xFF174F55)], glow: Color(0xFF45B8AD)),
    ProfileFrameStyle(name: 'Стойкость', colors: [Color(0xFFE3E7EC), Color(0xFF697481), Color(0xFF252D38)], glow: Color(0xFF9BA8B8)),
  ];

  @override
  Widget build(BuildContext context) {
    final style = styles[frameIndex.clamp(0, styles.length - 1).toInt()];
    final inset = size >= 50 ? 3.0 : 2.0;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: style.colors,
            stops: const [0, .48, 1],
          ),
          boxShadow: [
            BoxShadow(color: style.glow.withValues(alpha: .28), blurRadius: size * .22, spreadRadius: .5),
            BoxShadow(color: Colors.black.withValues(alpha: .55), blurRadius: size * .16, offset: Offset(0, size * .08)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(inset),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF111720),
              border: Border.all(color: Colors.white.withValues(alpha: .34), width: .7),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
