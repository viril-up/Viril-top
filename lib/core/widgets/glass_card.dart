import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

/// Opaque black-to-antique-gold obsidian panel with a crisp gold frame.
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
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0, .48, 1],
        colors: [Color(0xFF302719), Color(0xFF17151A), Color(0xFF211B17)],
      ),
      border: Border.all(color: VirilColors.gold, width: 1.15),
      boxShadow: const [
        BoxShadow(color: Color(0x99000000), blurRadius: 22, offset: Offset(0, 10)),
        BoxShadow(color: Color(0x24C6A568), blurRadius: 13, spreadRadius: -4),
      ],
    ),
    child: child,
  );
}
