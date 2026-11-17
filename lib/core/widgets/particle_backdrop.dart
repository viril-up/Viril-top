import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/viril_colors.dart';

/// Clearly visible but slow-moving particles over an almost-black violet cosmos.
class ParticleBackdrop extends StatefulWidget {
  const ParticleBackdrop({super.key, required this.child});
  final Widget child;

  @override
  State<ParticleBackdrop> createState() => _ParticleBackdropState();
}

class _ParticleBackdropState extends State<ParticleBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(seconds: 42),
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
            center: Alignment(-.55, -.68),
            radius: 1.38,
            colors: [
              Color(0xFF100A18), // almost-black violet
              Color(0xFF0B0B16), // violet-black / midnight
              Color(0xFF06070D), // deep space
              Color(0xFF020205), // absolute black
            ],
            stops: [0, .38, .72, 1],
          ),
        )),
        Positioned(
          left: -230 + math.sin(t * .16) * 28,
          top: -210 + math.cos(t * .14) * 22,
          child: _glow(470, const Color(0xFF281633).withValues(alpha: .15)),
        ),
        Positioned(
          right: -230 + math.cos(t * .15) * 30,
          top: 80 + math.sin(t * .13) * 24,
          child: _glow(460, const Color(0xFF17213D).withValues(alpha: .13)),
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
      boxShadow: [BoxShadow(color: color, blurRadius: 150, spreadRadius: 38)]),
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
      Color(0xFFC2B2E8), Color(0xFF9BAEDB),
      Color(0xFF8C78B5), Color(0xFFB8C5E8),
    ];

    // Particles travel a meaningful distance across the screen, not just a few pixels.
    for (var i = 0; i < 96; i++) {
      final seed = i * 91.713;
      final phase = (progress + (i * .6180339887)) % 1.0;
      final xBase = ((math.sin(seed) + 1) * .5) * size.width;
      final x = (xBase + math.sin(progress * math.pi * 2 + seed) * 13) % size.width;
      final y = ((math.cos(seed * .73) + 1) * .5 * size.height
        - phase * (size.height * (.22 + (i % 5) * .10)) + size.height) % size.height;
      final twinkle = .62 + .38 * math.sin(progress * math.pi * 2 * (1 + i % 3) + seed).abs();
      final radius = i % 11 == 0 ? 1.8 : (i % 4 == 0 ? 1.25 : .85);
      final alpha = (i % 11 == 0 ? .78 : (i % 3 == 0 ? .48 : .30)) * twinkle;
      paint.color = colors[i % colors.length].withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
      if (i % 11 == 0) {
        paint.color = colors[i % colors.length].withValues(alpha: alpha * .18);
        canvas.drawCircle(Offset(x, y), radius * 3.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
