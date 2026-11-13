import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import 'domains/domain_detail_screen.dart';

class DevelopmentScreen extends StatelessWidget {
  const DevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
    children: [
      const SectionTitle('Развитие', subtitle: 'Четыре грани личности — единая система'),
      _TrackCard(icon: Icons.fitness_center, title: 'Физическое развитие', text: 'Тренировки, мобильность, восстановление и привычки движения.', color: VirilColors.lava, tag: 'ТЕЛО', domain: 'Физическое'),
      _TrackCard(icon: Icons.psychology_alt, title: 'Ментальное развитие', text: 'Эмоциональная грамотность, внимание, стресс-менеджмент и рефлексия.', color: VirilColors.ice, tag: 'РАЗУМ', domain: 'Ментальное'),
      _TrackCard(icon: Icons.auto_stories, title: 'Интеллектуальное развитие', text: 'Чтение, языки, память, критическое и стратегическое мышление.', color: VirilColors.gold, tag: 'ИНТЕЛЛЕКТ', domain: 'Интеллект'),
      _TrackCard(icon: Icons.spa, title: 'Духовное развитие', text: 'Ценности, осознанность, благодарность и личный смысл.', color: VirilColors.violet, tag: 'СМЫСЛ', domain: 'Духовное'),
    ],
  );
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.icon, required this.title, required this.text, required this.color, required this.tag, required this.domain});
  final IconData icon;
  final String title, text, tag, domain;
  final Color color;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: () => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DomainDetailScreen(domain: domain),
    )),
    child: GlassCard(
      margin: const EdgeInsets.only(bottom: 13),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: color.withValues(alpha: .13),
          border: Border.all(color: color.withValues(alpha: .3)),
        ), child: Icon(icon, color: color, size: 26)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tag, style: TextStyle(color: color, fontSize: 9, letterSpacing: 1.7, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 5),
          Text(text, style: const TextStyle(color: VirilColors.muted, height: 1.4, fontSize: 12)),
          const SizedBox(height: 8),
          Text('ОТКРЫТЬ НАПРАВЛЕНИЕ  →', style: TextStyle(color: color, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w800)),
        ])),
        const Icon(Icons.chevron_right, color: VirilColors.muted),
      ]),
    ),
  );
}
