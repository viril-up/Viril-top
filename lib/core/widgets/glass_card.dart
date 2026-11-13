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
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xD9232C3D), Color(0xC9101420)]),
      border: Border.all(color: VirilColors.line.withValues(alpha: .72)),
      boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 24, offset: Offset(0, 12))],
    ),
    child: child,
  );
}
