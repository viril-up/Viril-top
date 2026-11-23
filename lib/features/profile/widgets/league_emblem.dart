import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A self-contained animated insignia for the 60 Viril leagues.
/// No external image or animation assets are required.
class LeagueEmblem extends StatefulWidget {
  const LeagueEmblem({
    super.key,
    required this.number,
    required this.materialName,
    required this.size,
    this.unlocked = true,
    this.active = false,
  });

  final int number;
  final String materialName;
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
            materialName: widget.materialName,
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
    required this.materialName,
    required this.phase,
    required this.unlocked,
    required this.active,
  });

  final int number;
  final String materialName;
  final double phase;
  final bool unlocked;
  final bool active;

  // Exact league-to-material mapping: each title gets its own visual identity.
  static const _materials = <String, Color>{
    'Железная': Color(0xFF9AA8B5), 'Бронзовая': Color(0xFFE58A45),
    'Серебряная': Color(0xFFDDEBFA), 'Золотая': Color(0xFFFFC928),
    'Платиновая': Color(0xFFB9E7FF), 'Сапфировая': Color(0xFF176BFF),
    'Изумрудная': Color(0xFF00D889), 'Рубиновая': Color(0xFFFF3158),
    'Нефритовая': Color(0xFF00C9A7), 'Ониксовая': Color(0xFF7371A8),
    'Кристальная': Color(0xFF63E8FF), 'Обсидиановая': Color(0xFF8B72D9),
    'Хлорофитовая': Color(0xFF8BEA32), 'Мифриловая': Color(0xFF63C9FF),
    'Адамантитовая': Color(0xFF648DFF), 'Люминитовая': Color(0xFFFFF18A),
    'Стоическая': Color(0xFFB0BEC9), 'Прометеевская': Color(0xFFFF642E),
    'Мастер': Color(0xFF3E9BFF), 'Чемпион': Color(0xFFFF3F3F),
    'Превосходная': Color(0xFFCC8CFF), 'Совершенная': Color(0xFFF3F7FF),
    'Титан': Color(0xFF91C7E8), 'Легенда': Color(0xFFFFD34E),
    'Королевская': Color(0xFFB66BFF), 'Императорская': Color(0xFFFF455D),
    'Суверенная': Color(0xFFFFB84D), 'Верховная': Color(0xFFB8D7F5),
    'Гиперборейская': Color(0xFF65D9FF), 'Олимпийская': Color(0xFFFFD76A),
    'Эфирная': Color(0xFF9F9BFF), 'Архонтическая': Color(0xFF9565FF),
    'Мифическая': Color(0xFFFF65C7), 'Вознесённая': Color(0xFFE8A5FF),
    'Божественная': Color(0xFFFFE36E), 'Просветлённая': Color(0xFFFFFFB8),
    'Эоническая': Color(0xFF42F0D2), 'Вечная': Color(0xFFB9D8FF),
    'Телеологическая': Color(0xFF9DAEFF), 'Эйдетическая': Color(0xFFD0A0FF),
    'Софическая': Color(0xFFFFC477), 'Ноэтическая': Color(0xFF70D2FF),
    'Аретическая': Color(0xFFA6E875), 'Гносеологическая': Color(0xFF6FC5E8),
    'Эпистемическая': Color(0xFF829EFF), 'Ноуменальная': Color(0xFFB19BFF),
    'Абсолютная': Color(0xFFE8F1FF), 'Сингулярная': Color(0xFFB17BFF),
    'Сверхновая': Color(0xFFFF8A38), 'Астральная': Color(0xFF718CFF),
    'Межзвёздная': Color(0xFF42C7FF), 'Галактическая': Color(0xFFAD65FF),
    'Космическая': Color(0xFF4F83FF), 'Метагалактическая': Color(0xFF45E0D0),
    'Вселенская': Color(0xFFC4A0FF), 'Межвселенская': Color(0xFF9675FF),
    'Мультивселенская': Color(0xFF55B8FF), 'Трансцендентная': Color(0xFFE2B9FF),
    'Запредельная': Color(0xFFF1F5FF), 'Омниверсальная': Color(0xFFFFD65A),
  };

  Color get _metal => _materials[materialName] ?? const Color(0xFF55B8FF);
  bool get _isTitanium => materialName == 'Титан';
  bool get _isGem => const {
    'Сапфировая', 'Изумрудная', 'Рубиновая', 'Нефритовая',
    'Кристальная', 'Мифическая', 'Эфирная', 'Астральная',
  }.contains(materialName);
  bool get _isCosmic => number >= 48;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final scale = s / 100;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    // Keep every league vividly identifiable, including leagues not unlocked yet.
    final metal = _metal;
    final dark = Color.lerp(metal, const Color(0xFF080B10), .56)!;
    final light = Color.lerp(metal, Colors.white, _isGem ? .68 : .52)!;

    final shield = Path()
      ..moveTo(0, -45)
      ..quadraticBezierTo(25, -44, 38, -34)
      ..lineTo(34, 10)
      ..quadraticBezierTo(27, 31, 0, 45)
      ..quadraticBezierTo(-27, 31, -34, 10)
      ..lineTo(-38, -34)
      ..quadraticBezierTo(-25, -44, 0, -45)
      ..close();

    final glow = Paint()
      ..color = metal.withValues(alpha: active ? .42 : .25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, active ? 10 : 6);
    canvas.drawCircle(Offset.zero, active ? 43 : 39, glow);
    final halo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 3.2 : 2.0
      ..color = metal.withValues(alpha: active ? .95 : .72);
    canvas.drawCircle(Offset.zero, 47, halo);
    canvas.drawCircle(Offset.zero, 43,
      Paint()..style = PaintingStyle.stroke..strokeWidth = .8
        ..color = light.withValues(alpha: .65));

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: .65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(shield.shift(const Offset(0, 3)), shadow);

    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [light, metal, Color.lerp(metal, dark, .38)!, dark],
        stops: const [0, .30, .68, 1],
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

    canvas.save();
    canvas.scale(.82, .82);
    canvas.drawPath(
      shield,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = light.withValues(alpha: .62),
    );
    canvas.restore();

    // Material-specific finish: brushed titanium, gemstone facets and cosmic dust.
    final texture = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _isTitanium ? 1.15 : .75
      ..color = light.withValues(alpha: _isTitanium ? .48 : .34);
    if (_isTitanium) {
      for (var i = -3; i <= 3; i++) {
        canvas.drawLine(Offset(-27, i * 7.0 - 5), Offset(27, i * 7.0 + 5), texture);
      }
      canvas.drawLine(const Offset(-25, -29), const Offset(25, -29), texture);
    } else if (_isGem) {
      final facets = Path()
        ..moveTo(0, -29)..lineTo(19, -8)..lineTo(0, 25)..lineTo(-19, -8)..close()
        ..moveTo(0, -29)..lineTo(0, 25)
        ..moveTo(-19, -8)..lineTo(19, -8);
      canvas.drawPath(facets, texture);
    } else if (_isCosmic) {
      for (var i = 0; i < 9; i++) {
        final x = ((i * 17 + number * 7) % 49) - 24.0;
        final y = ((i * 23 + number * 11) % 48) - 24.0;
        canvas.drawCircle(Offset(x, y), i.isEven ? 1.25 : .7,
          Paint()..color = light.withValues(alpha: .65));
      }
    } else {
      for (var i = -2; i <= 2; i++) {
        canvas.drawLine(Offset(-25, i * 9.0), Offset(25, i * 9.0), texture);
      }
    }

    // Distinct engraved geometry for every rank.
    final motif = number % 6;
    final accent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeJoin = StrokeJoin.round
      ..color = light.withValues(alpha: .96);

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
          color: Colors.white.withValues(alpha: .98),
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
            Colors.white.withValues(alpha: active ? .38 : .22),
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
      oldDelegate.materialName != materialName ||
      oldDelegate.phase != phase ||
      oldDelegate.unlocked != unlocked ||
      oldDelegate.active != active;
}
