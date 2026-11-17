import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

/// Solid high-contrast panel. Kept opaque so text and controls stay crisp.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.margin, this.radius = 20});
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
      color: VirilColors.black,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B2B40), Color(0xFF111D2C), Color(0xFF142238)],
      ),
      border: Border.all(color: VirilColors.line, width: 1),
      boxShadow: const [
        BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 9)),
        BoxShadow(color: Color(0x183B6593), blurRadius: 16, spreadRadius: -7),
      ],
    ),
    child: child,
  );
}
