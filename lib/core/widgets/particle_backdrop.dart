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
    vsync: this, duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Stack(fit: StackFit.expand, children: [
        const DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF101A2B), VirilColors.voidBlack, Color(0xFF171226)]),
        )),
        Positioned(top: -100, left: -90, child: _glow(270, VirilColors.navy.withValues(alpha: .34))),
        Positioned(bottom: 90, right: -110, child: _glow(300, VirilColors.violet.withValues(alpha: .12))),
        CustomPaint(painter: _ParticlePainter(_controller.value), child: const SizedBox.expand()),
        widget.child,
      ]),
    );
  }

  Widget _glow(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 24)]),
  );
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 42; i++) {
      final seed = i * 97.31;
      final x = ((math.sin(seed) + 1) / 2) * size.width;
      final baseY = ((math.cos(seed * .7) + 1) / 2) * size.height;
      final y = (baseY - progress * (18 + (i % 5) * 8) + size.height) % size.height;
      final radius = 0.6 + (i % 4) * .35;
      paint.color = (i % 7 == 0 ? VirilColors.gold : VirilColors.ice).withValues(alpha: .13 + (i % 3) * .07);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}
