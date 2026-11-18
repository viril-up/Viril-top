import 'package:flutter/material.dart';

/// Smoke-gradient surface: a soft graphite crown dissolving into the app background.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.margin, this.radius = 20});
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double radius;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _SmokeEdgePainter(radius),
    child: Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, .18, .52, .82, 1],
          colors: [
            Color(0xB85B6068),
            Color(0x76505760),
            Color(0x40303640),
            Color(0x18131720),
            Color(0x0807090D),
          ],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), blurRadius: 22, offset: Offset(0, 9)),
          BoxShadow(color: Color(0x182D4968), blurRadius: 14, spreadRadius: -6),
        ],
      ),
      child: child,
    ),
  );
}

class _SmokeEdgePainter extends CustomPainter {
  _SmokeEdgePainter(this.radius);
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(.6), Radius.circular(radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, .22, .48, .72, 1],
        colors: [
          Color(0xA6AEB7C2),
          Color(0x667D8794),
          Color(0x263E4651),
          Color(0x083E4651),
          Color(0x003E4651),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _SmokeEdgePainter oldDelegate) => oldDelegate.radius != radius;
}
