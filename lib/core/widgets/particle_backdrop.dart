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
    vsync: this, duration: const Duration(seconds: 58),
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
            gradient: RadialGradient(
              center: Alignment(-.45, -.65),
              radius: 1.35,
              colors: [Color(0xFF211637), Color(0xFF120F20), Color(0xFF09080F), Color(0xFF050509)],
              stops: [0, .38, .76, 1],
            ),
          )),
          Positioned(left: -190 + math.sin(t * .22) * 34, top: -185 + math.cos(t * .19) * 28,
            child: _glow(440, VirilColors.cosmicBlue.withValues(alpha: .28))),
          Positioned(right: -195 + math.cos(t * .2) * 38, top: 115 + math.sin(t * .17) * 32,
            child: _glow(420, VirilColors.violet.withValues(alpha: .20))),
          Positioned(left: 8 + math.sin(t * .16) * 30, bottom: -240 + math.cos(t * .18) * 22,
            child: _glow(430, VirilColors.nebulaBlue.withValues(alpha: .24))),
          CustomPaint(painter: _ParticlePainter(_controller.value), child: const SizedBox.expand()),
          widget.child,
        ]);
      },
    );
  }

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
    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [VirilColors.starlightBlue, VirilColors.cosmicBlue,
      VirilColors.violet, VirilColors.gold, VirilColors.chartBlueLight];
    for (var i = 0; i < 76; i++) {
      final seed = i * 97.31;
      final x = ((math.sin(seed) + 1) / 2) * size.width
        + math.sin(progress * math.pi * 2 + seed) * (6 + i % 9);
      final baseY = ((math.cos(seed * .7) + 1) / 2) * size.height;
      final speed = 7 + (i % 7) * 3;
      final y = (baseY - progress * speed + size.height) % size.height;
      final radius = i % 12 == 0 ? 1.35 : .55 + (i % 4) * .2;
      final alpha = i % 12 == 0 ? .52 : (i % 3 == 0 ? .22 : .12);
      paint.color = colors[i % colors.length].withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
