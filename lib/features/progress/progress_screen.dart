import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/metric_tile.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), children: [
    const SectionTitle('Прогресс', subtitle: 'Измеряй путь, а не сравнивай себя с другими'),
    const Row(children: [
      Expanded(child: MetricTile(value: '1', label: 'УРОВЕНЬ')),
      SizedBox(width: 10),
      Expanded(child: MetricTile(value: '0 XP', label: 'ОПЫТ')),
    ]),
    const SizedBox(height: 10),
    const Row(children: [
      Expanded(child: MetricTile(value: '0', label: 'ЗАДАЧ ЗАВЕРШЕНО')),
      SizedBox(width: 10),
      Expanded(child: MetricTile(value: '—', label: 'ЛУЧШИЙ ДЕНЬ')),
    ]),
    const SizedBox(height: 14),
    GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Динамика развития', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Здесь появится твоя история достижений', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
      const SizedBox(height: 20),
      SizedBox(height: 150, child: CustomPaint(painter: _ProgressPainter(), child: const SizedBox.expand())),
      const SizedBox(height: 8),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('7 дней', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
        Text('Сегодня', style: TextStyle(color: VirilColors.ice, fontSize: 10)),
      ]),
    ])),
    const SizedBox(height: 14),
    GlassCard(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Баланс четырёх направлений', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      SizedBox(height: 14),
      _BalanceLine(label: 'Физическое', color: VirilColors.lava),
      _BalanceLine(label: 'Ментальное', color: VirilColors.ice),
      _BalanceLine(label: 'Интеллектуальное', color: VirilColors.gold),
      _BalanceLine(label: 'Духовное', color: VirilColors.violet),
    ])),
  ]);
}

class _BalanceLine extends StatelessWidget {
  const _BalanceLine({required this.label, required this.color});
  final String label; final Color color;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 9),
    Expanded(child: Text(label, style: const TextStyle(color: VirilColors.muted, fontSize: 12))),
    const Text('0%', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
  ]));
}

class _ProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = VirilColors.line.withValues(alpha: .65)..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final path = Path()..moveTo(0, size.height * .82)
      ..cubicTo(size.width * .18, size.height * .82, size.width * .22, size.height * .74, size.width * .38, size.height * .7)
      ..cubicTo(size.width * .56, size.height * .66, size.width * .68, size.height * .5, size.width, size.height * .43);
    final line = Paint()..color = VirilColors.ice..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawPath(path, line);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
