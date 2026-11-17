import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

/// Crisp charcoal-black card with a fine antique-gold outline.
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
        stops: [0, .52, 1],
        colors: [Color(0xFF29282D), Color(0xFF17171B), Color(0xFF202025)],
      ),
      border: Border.all(color: VirilColors.gold, width: 1.15),
      boxShadow: const [
        BoxShadow(color: Color(0xAA000000), blurRadius: 20, offset: Offset(0, 9)),
        BoxShadow(color: Color(0x18C6A568), blurRadius: 10, spreadRadius: -5),
      ],
    ),
    child: child,
  );
}
