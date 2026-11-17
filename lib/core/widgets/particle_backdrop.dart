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
    vsync: this, duration: const Duration(seconds: 52),
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
              colors: [Color(0xFF172B45), Color(0xFF102139), Color(0xFF0D192A), Color(0xFF111A27)],
              stops: [0, .34, .72, 1]),
          )),
          // Restrained antique warmth is blended into the navy atmosphere, not laid over the cards.
          Positioned(left: -170 + math.sin(t * .28) * 28, top: -180 + math.cos(t * .25) * 24,
            child: _glow(430, VirilColors.cosmicBlue.withValues(alpha: .24))),
          Positioned(right: -180 + math.cos(t * .24) * 32, top: 100 + math.sin(t * .22) * 26,
            child: _glow(390, VirilColors.nebulaBlue.withValues(alpha: .20))),
          Positioned(left: 20 + math.sin(t * .18) * 24, bottom: -235 + math.cos(t * .2) * 18,
            child: _glow(420, VirilColors.goldSoft.withValues(alpha: .075))),
          CustomPaint(painter: _ParticlePainter(_controller.value), child: const SizedBox.expand()),
          widget.child,
        ]);
      },
    );
  }

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
    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [VirilColors.starlightBlue, VirilColors.cosmicBlue,
      VirilColors.navyLight, VirilColors.ice, VirilColors.gold];
    for (var i = 0; i < 64; i++) {
      final seed = i * 97.31;
      final x = ((math.sin(seed) + 1) / 2) * size.width
        + math.sin(progress * math.pi * 2 + seed) * (5 + i % 8);
      final baseY = ((math.cos(seed * .7) + 1) / 2) * size.height;
      final speed = 6 + (i % 6) * 3;
      final y = (baseY - progress * speed + size.height) % size.height;
      final radius = i % 11 == 0 ? 1.2 : .55 + (i % 3) * .22;
      final alpha = i % 11 == 0 ? .42 : (i % 3 == 0 ? .19 : .11);
      paint.color = colors[i % colors.length].withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
