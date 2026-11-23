import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A self-contained animated insignia for the 60 Viril leagues.
/// No external image or animation assets are required.
class LeagueEmblem extends StatefulWidget {
  const LeagueEmblem({
    super.key,
    required this.number,
    required this.size,
    this.unlocked = true,
    this.active = false,
  });

  final int number;
  final double size;
  final bool unlocked;
  final bool active;

  @override
  State<LeagueEmblem> createState() => _LeagueEmblemState();
}

class _LeagueEmblemState extends State<LeagueEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.active ? 2600 : 5200),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant LeagueEmblem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _controller.duration =
          Duration(milliseconds: widget.active ? 2600 : 5200);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _LeagueEmblemPainter(
            number: widget.number.clamp(1, 60),
            phase: _controller.value,
            unlocked: widget.unlocked,
            active: widget.active,
          ),
        ),
      ),
    );
  }
}

class _LeagueEmblemPainter extends CustomPainter {
  const _LeagueEmblemPainter({
    required this.number,
    required this.phase,
    required this.unlocked,
    required this.active,
  });

  final int number;
  final double phase;
  final bool unlocked;
  final bool active;

  static const _materials = <Color>[
    Color(0xFF8B9299), // iron
    Color(0xFFB9784E), // bronze
    Color(0xFFC7D0D8), // silver
    Color(0xFFD7AE55), // gold
    Color(0xFFDCE3E8), // platinum
    Color(0xFF4D91D9), // sapphire
    Color(0xFF36A77B), // emerald
    Color(0xFFB94D58), // ruby
    Color(0xFF4D9B85), // jade
    Color(0xFF65717C), // onyx
    Color(0xFF82C9D8), // crystal
    Color(0xFF626B78), // obsidian
  ];

  static const _epochs = <Color>[
    Color(0xFFB7A4E5),
    Color(0xFFD2B36C),
    Color(0xFF75C8D8),
    Color(0xFF9AC7A5),
    Color(0xFFE0C27A),
  ];

  Color get _metal {
    final material = _materials[(number - 1) % _materials.length];
    final epoch = _epochs[number <= 12 ? 0 : number <= 28 ? 1 : number <= 38 ? 2 : number <= 47 ? 3 : 4];
    return Color.lerp(material, epoch, number <= 12 ? .12 : .28)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final scale = s / 100;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    final metal = unlocked ? _metal : const Color(0xFF51565D);
    final dark = Color.lerp(metal, const Color(0xFF080B10), .72)!;
    final light = Color.lerp(metal, Colors.white, .48)!;

    final shield = Path()
      ..moveTo(0, -45)
      ..quadraticBezierTo(25, -44, 38, -34)
      ..lineTo(34, 10)
      ..quadraticBezierTo(27, 31, 0, 45)
      ..quadraticBezierTo(-27, 31, -34, 10)
      ..lineTo(-38, -34)
      ..quadraticBezierTo(-25, -44, 0, -45)
      ..close();

    final halo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2.8 : 1.6
      ..color = metal.withValues(alpha: active ? .52 : .24);
    canvas.drawCircle(Offset.zero, 47, halo);

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: .65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(shield.shift(const Offset(0, 3)), shadow);

    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [light, metal, dark, const Color(0xFF10141A)],
        stops: const [0, .25, .72, 1],
      ).createShader(const Rect.fromLTWH(-40, -46, 80, 94));
    canvas.drawPath(shield, body);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: .9), metal, dark],
      ).createShader(const Rect.fromLTWH(-40, -46, 80, 94));
    canvas.drawPath(shield, edge);

    final inset = shield.transform(
      (Matrix4.identity()..scale(.82, .82)).storage,
    );
    canvas.drawPath(
      inset,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = light.withValues(alpha: .62),
    );

    // Distinct engraved geometry for every rank.
    final motif = number % 6;
    final accent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeJoin = StrokeJoin.round
      ..color = light.withValues(alpha: .76);

    if (motif == 0) {
      _drawPolygon(canvas, 0, 0, 22, 6, phase * math.pi * 2, accent);
      _drawPolygon(canvas, 0, 0, 12, 6, -phase * math.pi * 2, accent);
    } else if (motif == 1) {
      for (var i = -2; i <= 2; i++) {
        canvas.drawLine(Offset(i * 8.0, -23), Offset(i * 8.0, 23), accent);
      }
      canvas.drawLine(const Offset(-24, 0), const Offset(24, 0), accent);
    } else if (motif == 2) {
      for (var i = 0; i < 4; i++) {
        final angle = i * math.pi / 2 + phase * math.pi * .15;
        canvas.drawLine(
          Offset(math.cos(angle) * 7, math.sin(angle) * 7),
          Offset(math.cos(angle) * 25, math.sin(angle) * 25),
          accent,
        );
      }
      canvas.drawCircle(Offset.zero, 8, accent);
    } else if (motif == 3) {
      final path = Path()
        ..moveTo(-23, 17)
        ..lineTo(0, -22)
        ..lineTo(23, 17)
        ..moveTo(-15, 8)
        ..lineTo(15, 8);
      canvas.drawPath(path, accent);
    } else if (motif == 4) {
      for (var i = -1; i <= 1; i++) {
        canvas.drawArc(
          Rect.fromCenter(center: Offset.zero, width: 28 + i * 9.0, height: 28 + i * 9.0),
          math.pi * .12,
          math.pi * .76,
          false,
          accent,
        );
      }
    } else {
      _drawPolygon(canvas, 0, 0, 24, 4, math.pi / 4, accent);
      _drawPolygon(canvas, 0, 0, 13, 4, -math.pi / 4, accent);
    }

    // A small engraved rank marker anchors each individual emblem.
    final marker = Paint()..color = light.withValues(alpha: .9);
    canvas.drawCircle(const Offset(0, 31), 2.2, marker);
    final numberText = TextPainter(
      text: TextSpan(
        text: number.toString().padLeft(2, '0'),
        style: TextStyle(
          color: Colors.white.withValues(alpha: unlocked ? .96 : .45),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    numberText.paint(canvas, Offset(-numberText.width / 2, 13));

    // A restrained moving highlight gives the metal a living finish.
    if (unlocked) {
      final sweep = (phase * 2 - 1) * 90;
      final shine = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: active ? .22 : .10),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(sweep - 12, -42, 24, 84));
      canvas.save();
      canvas.clipPath(shield);
      canvas.drawRect(Rect.fromLTWH(sweep - 12, -46, 24, 92), shine);
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawPolygon(
    Canvas canvas,
    double x,
    double y,
    double radius,
    int sides,
    double rotation,
    Paint paint,
  ) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = rotation + i * math.pi * 2 / sides - math.pi / 2;
      final point = Offset(x + math.cos(angle) * radius, y + math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LeagueEmblemPainter oldDelegate) =>
      oldDelegate.number != number ||
      oldDelegate.phase != phase ||
      oldDelegate.unlocked != unlocked ||
      oldDelegate.active != active;
}
