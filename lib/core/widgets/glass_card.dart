import 'package:flutter/material.dart';

/// Deep graphite smoke surface with a restrained top edge that dissolves downward.
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
          stops: [0, .16, .48, .78, 1],
          colors: [
            Color(0x783A3F47),
            Color(0x5030363F),
            Color(0x30202730),
            Color(0x1810151D),
            Color(0x0806080C),
          ],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 22, offset: Offset(0, 9)),
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
      ..strokeWidth = 1.0
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, .18, .38, .58, 1],
        colors: [
          Color(0x8C9AA5B3),
          Color(0x526C7785),
          Color(0x263E4855),
          Color(0x083E4855),
          Color(0x003E4855),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _SmokeEdgePainter oldDelegate) => oldDelegate.radius != radius;
}
