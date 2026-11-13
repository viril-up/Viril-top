import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/metric_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), children: [
    GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ТВОЯ СИСТЕМА РОСТА', style: TextStyle(color: VirilColors.gold, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      const Text('Стань версией,\nкоторую уважаешь.', style: TextStyle(fontSize: 29, height: 1.08, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      const Text('Четыре направления. Один путь. Твой выбор.', style: TextStyle(color: VirilColors.muted, fontSize: 13)),
      const SizedBox(height: 20),
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('УРОВЕНЬ 1 · НОВИЧОК', style: TextStyle(color: VirilColors.ice, fontSize: 10, letterSpacing: 1)),
          SizedBox(height: 8),
          Text('0 XP', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
        ])),
        Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: VirilColors.gold, width: 2),
          boxShadow: [BoxShadow(color: VirilColors.gold.withValues(alpha: .16), blurRadius: 20)],
        ), child: const Icon(Icons.local_fire_department_rounded, color: VirilColors.gold, size: 30)),
      ]),
      const SizedBox(height: 12),
      ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: .08, minHeight: 7,
        backgroundColor: Color(0xFF30394B), valueColor: AlwaysStoppedAnimation(VirilColors.ice))),
      const SizedBox(height: 7),
      const Text('Начни с одного небольшого действия сегодня.', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
    ])),
    const SectionTitle('Твои четыре направления', subtitle: 'Развивай себя целостно, без перекоса в одну сторону'),
    GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2,
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.35,
      children: const [
        _DomainCard(icon: Icons.fitness_center, title: 'Физическое', detail: 'Сила и энергия', color: VirilColors.lava),
        _DomainCard(icon: Icons.psychology_alt, title: 'Ментальное', detail: 'Устойчивость и ясность', color: VirilColors.ice),
        _DomainCard(icon: Icons.auto_stories, title: 'Интеллект', detail: 'Знания и мышление', color: VirilColors.gold),
        _DomainCard(icon: Icons.spa, title: 'Духовное', detail: 'Ценности и смысл', color: VirilColors.violet),
      ]),
    const SectionTitle('Планы на сегодня'),
    GlassCard(child: Row(children: [
      const Icon(Icons.flag_rounded, color: VirilColors.gold, size: 25),
      const SizedBox(width: 12),
      const Expanded(child: Text('Твой день начинается с первого шага.', style: TextStyle(color: VirilColors.muted))),
      FilledButton.tonal(onPressed: () {}, child: const Text('Добавить')),
    ])),
    const SizedBox(height: 14),
    const Row(children: [
      Expanded(child: MetricTile(value: '0', label: 'ЗАДАЧ ВЫПОЛНЕНО')),
      SizedBox(width: 10),
      Expanded(child: MetricTile(value: '0', label: 'ДНЕЙ СЕРИИ')),
    ]),
  ]);

}

class _DomainCard extends StatelessWidget {
  const _DomainCard({required this.icon, required this.title, required this.detail, required this.color});
  final IconData icon; final String title, detail; final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(21),
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [color.withValues(alpha: .17), const Color(0xD9151925)]),
      border: Border.all(color: color.withValues(alpha: .26)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Icon(icon, color: color, size: 25),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        Text(detail, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
      ]),
    ]),
  );
}
