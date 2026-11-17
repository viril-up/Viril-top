import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.margin, this.radius = 24});
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: VirilColors.black.withValues(alpha: .94),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xF21A202B), Color(0xF20A0C11), Color(0xF216191F)]),
      border: Border.all(color: VirilColors.goldSoft.withValues(alpha: .22), width: 0.8),
      boxShadow: const [
        BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 12)),
        BoxShadow(color: Color(0x161A2B45), blurRadius: 18, spreadRadius: -5),
      ],
    ),
    child: child,
  );
}
