import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

class ParticleBackdrop extends StatefulWidget {
  const ParticleBackdrop({super.key, required this.child});
  final Widget child;

  @override
  State<ParticleBackdrop> createState() => _ParticleBackdropState();
}

class _ParticleBackdropState extends State<ParticleBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(seconds: 34),
  )..repeat();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * math.pi * 2;
        return Stack(fit: StackFit.expand, children: [
          const DecoratedBox(decoration: BoxDecoration(
            color: VirilColors.voidBlack,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF171D29), Color(0xFF090B10), Color(0xFF111016), Color(0xFF080A0E)],
              stops: [0, .38, .72, 1]),
          )),
          Positioned(left: -115 + math.sin(t) * 28, top: -135 + math.cos(t * .7) * 20,
            child: _glow(310, VirilColors.navy.withValues(alpha: .23))),
          Positioned(right: -145 + math.cos(t * .8) * 24, bottom: 55 + math.sin(t) * 24,
            child: _glow(330, VirilColors.lavaDeep.withValues(alpha: .16))),
          Positioned(left: 30 + math.sin(t * .55) * 16, bottom: -190,
            child: _glow(290, VirilColors.goldSoft.withValues(alpha: .075))),
          CustomPaint(painter: _ParticlePainter(_controller.value), child: const SizedBox.expand()),
          widget.child,
        ]);
      },
    );
  }

  Widget _glow(double size, Color color) => IgnorePointer(child: Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 115, spreadRadius: 30)]),
  ));
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [VirilColors.gold, VirilColors.ice, VirilColors.navyLight,
      VirilColors.lava, VirilColors.stoneEdge];
    for (var i = 0; i < 54; i++) {
      final seed = i * 97.31;
      final x = ((math.sin(seed) + 1) / 2) * size.width
        + math.sin(progress * math.pi * 2 + seed) * (5 + i % 8);
      final baseY = ((math.cos(seed * .7) + 1) / 2) * size.height;
      final speed = 10 + (i % 6) * 5;
      final y = (baseY - progress * speed + size.height) % size.height;
      final radius = .55 + (i % 4) * .28;
      final alpha = i % 5 == 0 ? .28 : .11 + (i % 3) * .035;
      paint.color = colors[i % colors.length].withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
