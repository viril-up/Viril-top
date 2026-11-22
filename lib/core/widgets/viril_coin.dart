import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lightweight, self-contained V-Coin visual. It does not affect balance or
/// storage; it is safe to use anywhere the currency is displayed.
class VirilCoin extends StatefulWidget {
  const VirilCoin({super.key, this.size = 48, this.animate = true});
  final double size;
  final bool animate;

  @override
  State<VirilCoin> createState() => _VirilCoinState();
}

class _VirilCoinState extends State<VirilCoin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant VirilCoin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return SizedBox.square(
        dimension: widget.size,
        child: const CustomPaint(painter: _VirilCoinPainter()),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * math.pi * 2;
        final backFace = math.cos(angle) < 0;
        return SizedBox.square(
          dimension: widget.size,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0015)
              ..rotateY(angle),
            child: Transform.scale(
              scaleX: backFace ? -1 : 1,
              child: child,
            ),
          ),
        );
      },
      child: const CustomPaint(painter: _VirilCoinPainter()),
    );
  }
}

class _VirilCoinPainter extends CustomPainter {
  const _VirilCoinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .47;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center.translate(0, radius * .055),
      radius,
      Paint()
        ..color = const Color(0xFF05080D)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE5A0), Color(0xFFB87925), Color(0xFF5D3515)],
        ).createShader(rect),
    );

    canvas.drawCircle(
      center,
      radius * .91,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF292725), Color(0xFF08090B), Color(0xFF1B1A18)],
        ).createShader(rect),
    );

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * .075
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFFE6A2), Color(0xFF9A5B1D), Color(0xFFFFD978),
          Color(0xFF744314), Color(0xFFFFE6A2),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius * .82, rim);

    final blueRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * .025
      ..color = const Color(0xFFD5A85C);
    canvas.drawCircle(center, radius * .72, blueRim);

    final v = Path()
      ..moveTo(center.dx - radius * .47, center.dy - radius * .30)
      ..lineTo(center.dx - radius * .29, center.dy - radius * .30)
      ..lineTo(center.dx, center.dy + radius * .27)
      ..lineTo(center.dx + radius * .29, center.dy - radius * .30)
      ..lineTo(center.dx + radius * .47, center.dy - radius * .30)
      ..lineTo(center.dx + radius * .08, center.dy + radius * .43)
      ..lineTo(center.dx - radius * .08, center.dy + radius * .43)
      ..close();

    canvas.drawPath(
      v.shift(const Offset(0, 1.2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = radius * .085
        ..color = const Color(0xFF4D2A0D),
    );
    canvas.drawPath(
      v,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0C2), Color(0xFFD69A43), Color(0xFF8D551E)],
        ).createShader(rect),
    );
    canvas.drawPath(
      v,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = radius * .018
        ..color = const Color(0xFFFFE9B0),
    );

    final glint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * .018
      ..color = const Color(0xFFFFD98B).withValues(alpha: .55);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * .68),
      math.pi * 1.08,
      math.pi * .34,
      false,
      glint,
    );
  }

  @override
  bool shouldRepaint(covariant _VirilCoinPainter oldDelegate) => false;
}
