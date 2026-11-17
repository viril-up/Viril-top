import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

/// Opaque obsidian panel with a crisp antique-gold outline.
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
      color: VirilColors.stone,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF211E2A), Color(0xFF17151F), Color(0xFF1C1925)],
      ),
      border: Border.all(color: VirilColors.goldSoft, width: 1),
      boxShadow: const [
        BoxShadow(color: Color(0x77000000), blurRadius: 20, offset: Offset(0, 9)),
        BoxShadow(color: Color(0x1FC6A568), blurRadius: 12, spreadRadius: -5),
      ],
    ),
    child: child,
  );
}
