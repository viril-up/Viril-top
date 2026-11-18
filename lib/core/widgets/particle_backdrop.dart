import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

/// Quiet animated atmosphere: drifting pinpoints over layered black, graphite and navy.
class ParticleBackdrop extends StatefulWidget {
  const ParticleBackdrop({super.key, required this.child});
  final Widget child;

  @override
  State<ParticleBackdrop> createState() => _ParticleBackdropState();
}

class _ParticleBackdropState extends State<ParticleBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(seconds: 72),
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
            center: Alignment(-.72, -.82),
            radius: 1.55,
            colors: [
              Color(0xFF17263B), // soft midnight-blue depth
              Color(0xFF101722), // graphite navy
              Color(0xFF0B0F16), // deep charcoal
              Color(0xFF06080C), // near-black edges
            ],
            stops: [0, .34, .70, 1],
          ),
        )),
        Positioned(
          left: -250 + math.sin(t * .12) * 22,
          top: -245 + math.cos(t * .10) * 18,
          child: _glow(470, const Color(0xFF263A55).withValues(alpha: .075)),
        ),
        Positioned(
          right: -260 + math.cos(t * .11) * 24,
          bottom: -260 + math.sin(t * .09) * 20,
          child: _glow(480, const Color(0xFF8F784F).withValues(alpha: .035)),
        ),
        CustomPaint(
          painter: _ParticlePainter(_controller.value),
          child: const SizedBox.expand(),
        ),
        widget.child,
      ]);
    },
  );

  Widget _glow(double size, Color color) => IgnorePointer(child: Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 145, spreadRadius: 36)]),
  ));
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [
      Color(0xFF9EACC0), Color(0xFF8A9CB4),
      Color(0xFF8393A8), Color(0xFF7189A8),
    ];

    // Sparse, low-contrast particles: atmospheric, never competing with text.
    for (var i = 0; i < 58; i++) {
      final seed = i * 83.417;
      final phase = (progress + i * .6180339887) % 1.0;
      final xBase = ((math.sin(seed) + 1) * .5) * size.width;
      final x = (xBase + math.sin(progress * math.pi * 2 + seed) * 8) % size.width;
      final travel = size.height * (.12 + (i % 5) * .045);
      final y = ((math.cos(seed * .71) + 1) * .5 * size.height
        - phase * travel + size.height) % size.height;
      final twinkle = .72 + .28 * math.sin(progress * math.pi * 2 + seed).abs();
      final radius = i % 12 == 0 ? 1.15 : .55 + (i % 3) * .12;
      final alpha = (i % 12 == 0 ? .34 : .13) * twinkle;
      paint.color = colors[i % colors.length].withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
