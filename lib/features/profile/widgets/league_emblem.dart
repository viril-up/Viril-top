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
    'Железная': Color(0xFF8B9299), 'Бронзовая': Color(0xFFB9784E),
    'Серебряная': Color(0xFFC7D0D8), 'Золотая': Color(0xFFD7AE55),
    'Платиновая': Color(0xFFDCE3E8), 'Сапфировая': Color(0xFF2867B8),
    'Изумрудная': Color(0xFF16845D), 'Рубиновая': Color(0xFFAC263F),
    'Нефритовая': Color(0xFF38A58A), 'Ониксовая': Color(0xFF343D49),
    'Кристальная': Color(0xFF9DE4F0), 'Обсидиановая': Color(0xFF34364B),
    'Хлорофитовая': Color(0xFF65A83C), 'Мифриловая': Color(0xFF86B7D9),
    'Адамантитовая': Color(0xFF526B91), 'Люминитовая': Color(0xFFB8D9E8),
    'Стоическая': Color(0xFF777D83), 'Прометеевская': Color(0xFFD66A32),
    'Мастер': Color(0xFF477BB7), 'Чемпион': Color(0xFFC3443C),
    'Превосходная': Color(0xFFB6A6D8), 'Совершенная': Color(0xFFE4E8EE),
    'Титан': Color(0xFF879EAD), 'Легенда': Color(0xFFB79A50),
    'Королевская': Color(0xFF7551A5), 'Императорская': Color(0xFF9F343B),
    'Суверенная': Color(0xFFB49B69), 'Верховная': Color(0xFFBAC5D0),
    'Гиперборейская': Color(0xFF9BC9E8), 'Олимпийская': Color(0xFFD8C18A),
    'Эфирная': Color(0xFF9AADD9), 'Архонтическая': Color(0xFF7561B2),
    'Мифическая': Color(0xFFB35C9C), 'Вознесённая': Color(0xFFE3C5F0),
    'Божественная': Color(0xFFFFE5A1), 'Просветлённая': Color(0xFFFFF1C7),
    'Эоническая': Color(0xFF6BC9C2), 'Вечная': Color(0xFFB8C4D2),
    'Телеологическая': Color(0xFF8F9CBA), 'Эйдетическая': Color(0xFFB5A4D8),
    'Софическая': Color(0xFFB59A6B), 'Ноэтическая': Color(0xFF77A9C8),
    'Аретическая': Color(0xFF9CBA91), 'Гносеологическая': Color(0xFF6F91A8),
    'Эпистемическая': Color(0xFF8C9DCB), 'Ноуменальная': Color(0xFF77718F),
    'Абсолютная': Color(0xFFE1E4E8), 'Сингулярная': Color(0xFF9C7BE0),
    'Сверхновая': Color(0xFFFFA64D), 'Астральная': Color(0xFF6677C9),
    'Межзвёздная': Color(0xFF4E91B8), 'Галактическая': Color(0xFF7753A8),
    'Космическая': Color(0xFF365C91), 'Метагалактическая': Color(0xFF477F9B),
    'Вселенская': Color(0xFFB7A6E5), 'Межвселенская': Color(0xFF8D75C9),
    'Мультивселенская': Color(0xFF5B8CBA), 'Трансцендентная': Color(0xFFD4C3F0),
    'Запредельная': Color(0xFFEEF0F5), 'Омниверсальная': Color(0xFFFFD98A),
  };

  Color get _metal => _materials[materialName] ?? const Color(0xFF8B9299);
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

    final metal = unlocked ? _metal : const Color(0xFF51565D);
    final dark = Color.lerp(metal, const Color(0xFF080B10), .72)!;
    final light = Color.lerp(metal, Colors.white, _isGem ? .72 : .48)!;

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
      ..color = light.withValues(alpha: _isTitanium ? .30 : .18);
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
      oldDelegate.materialName != materialName ||
      oldDelegate.phase != phase ||
      oldDelegate.unlocked != unlocked ||
      oldDelegate.active != active;
}
