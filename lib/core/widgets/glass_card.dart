import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

/// Matte graphite card with a restrained steel edge and layered depth.
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
        stops: [0, .56, 1],
        colors: [Color(0xFF202A36), Color(0xFF19212B), Color(0xFF151C26)],
      ),
      border: Border.all(color: VirilColors.line, width: 1),
      boxShadow: const [
        BoxShadow(color: Color(0x77000000), blurRadius: 18, offset: Offset(0, 8)),
        BoxShadow(color: Color(0x182D4968), blurRadius: 12, spreadRadius: -5),
      ],
    ),
    child: child,
  );
}
