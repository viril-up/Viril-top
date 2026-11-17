import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

/// Slow, subtle particles over a black / violet / midnight-blue cosmic field.
class ParticleBackdrop extends StatefulWidget {
  const ParticleBackdrop({super.key, required this.child});
  final Widget child;

  @override
  State<ParticleBackdrop> createState() => _ParticleBackdropState();
}

class _ParticleBackdropState extends State<ParticleBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(seconds: 64),
  )..repeat();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final t = _controller.value * math.pi * 2;
      return Stack(fit: StackFit.expand, children: [
        const DecoratedBox(decoration: BoxDecoration(
          color: VirilColors.voidBlack,
          gradient: RadialGradient(
            center: Alignment(-.58, -.72),
            radius: 1.42,
            colors: [
              Color(0xFF211632), // deep violet nebula
              Color(0xFF11182D), // midnight blue
              Color(0xFF090A12), // near-black space
              Color(0xFF030306), // black outer space
            ],
            stops: [0, .39, .73, 1],
          ),
        )),
        Positioned(
          left: -205 + math.sin(t * .18) * 32,
          top: -195 + math.cos(t * .16) * 25,
          child: _glow(450, const Color(0xFF493064).withValues(alpha: .24)),
        ),
        Positioned(
          right: -215 + math.cos(t * .17) * 34,
          top: 90 + math.sin(t * .14) * 28,
          child: _glow(440, const Color(0xFF233D70).withValues(alpha: .23)),
        ),
        Positioned(
          left: 12 + math.sin(t * .13) * 26,
          bottom: -245 + math.cos(t * .15) * 24,
          child: _glow(440, const Color(0xFF251A3D).withValues(alpha: .22)),
        ),
        CustomPaint(painter: _ParticlePainter(_controller.value), child: const SizedBox.expand()),
        widget.child,
      ]);
    },
  );

  Widget _glow(double size, Color color) => IgnorePointer(child: Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 155, spreadRadius: 42)]),
  ));
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [Color(0xFF8D7AB8), Color(0xFF6686C2), Color(0xFF51416F), Color(0xFF9AA6C8)];
    for (var i = 0; i < 82; i++) {
      final seed = i * 97.31;
      final x = ((math.sin(seed) + 1) / 2) * size.width
        + math.sin(progress * math.pi * 2 + seed) * (5 + i % 8);
      final baseY = ((math.cos(seed * .7) + 1) / 2) * size.height;
      final speed = 6 + (i % 7) * 2.6;
      final y = (baseY - progress * speed + size.height) % size.height;
      final radius = i % 13 == 0 ? 1.25 : .5 + (i % 4) * .18;
      final alpha = i % 13 == 0 ? .43 : (i % 3 == 0 ? .19 : .10);
      paint.color = colors[i % colors.length].withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
