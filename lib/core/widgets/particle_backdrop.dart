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
    vsync: this, duration: const Duration(seconds: 42),
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
              colors: [Color(0xFF172A45), Color(0xFF101D32), Color(0xFF090F1B), Color(0xFF080A10)],
              stops: [0, .32, .72, 1]),
          )),
          // Slow-moving blue nebula clouds create a calm cosmic atmosphere.
          Positioned(left: -145 + math.sin(t * .55) * 42, top: -155 + math.cos(t * .42) * 34,
            child: _glow(390, VirilColors.cosmicBlue.withValues(alpha: .30))),
          Positioned(right: -175 + math.cos(t * .48) * 46, top: 150 + math.sin(t * .38) * 38,
            child: _glow(360, VirilColors.nebulaBlue.withValues(alpha: .28))),
          Positioned(left: 5 + math.sin(t * .32) * 35, bottom: -210 + math.cos(t * .4) * 22,
            child: _glow(390, VirilColors.navyLight.withValues(alpha: .23))),
          Positioned(right: -170 + math.sin(t * .28) * 30, bottom: 40 + math.cos(t * .34) * 28,
            child: _glow(300, VirilColors.lavaDeep.withValues(alpha: .09))),
          CustomPaint(painter: _ParticlePainter(_controller.value), child: const SizedBox.expand()),
          widget.child,
        ]);
      },
    );
  }

  Widget _glow(double size, Color color) => IgnorePointer(child: Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 135, spreadRadius: 34)]),
  ));
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [VirilColors.starlightBlue, VirilColors.cosmicBlue,
      VirilColors.navyLight, VirilColors.ice, VirilColors.gold, VirilColors.lava];
    for (var i = 0; i < 82; i++) {
      final seed = i * 97.31;
      final x = ((math.sin(seed) + 1) / 2) * size.width
        + math.sin(progress * math.pi * 2 + seed) * (7 + i % 11);
      final baseY = ((math.cos(seed * .7) + 1) / 2) * size.height;
      final speed = 8 + (i % 7) * 4;
      final y = (baseY - progress * speed + size.height) % size.height;
      final radius = i % 9 == 0 ? 1.35 : .65 + (i % 4) * .25;
      final alpha = i % 9 == 0 ? .62 : (i % 3 == 0 ? .30 : .17);
      paint.color = colors[i % colors.length].withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
      // A few tiny stars softly pulse without flashing.
      if (i % 13 == 0) {
        final pulse = .25 + ((math.sin(progress * math.pi * 2 + seed) + 1) / 2) * .35;
        paint.color = VirilColors.starlightBlue.withValues(alpha: pulse);
        canvas.drawCircle(Offset(x, y), radius + 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
