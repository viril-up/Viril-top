import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import 'domains/domain_detail_screen.dart';
import '../workouts/workouts_screen.dart';

class DevelopmentScreen extends StatelessWidget {
  const DevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
    children: [
      InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkoutsScreen())),
        child: GlassCard(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(colors: [VirilColors.gold.withValues(alpha: .25), VirilColors.gold.withValues(alpha: .06)]),
                border: Border.all(color: VirilColors.gold.withValues(alpha: .45)),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: VirilColors.gold, size: 29),
            ),
            const SizedBox(width: 15),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ТРЕНИРОВКИ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w900)),
              SizedBox(height: 5),
              Text('Твоя система тренировок', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Программы, упражнения и личный прогресс', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, color: VirilColors.gold, size: 17),
          ]),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(3, 7, 3, 12),
        child: Text('НАПРАВЛЕНИЯ САМОРАЗВИТИЯ', style: TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.8, fontWeight: FontWeight.w800)),
      ),
      _DevelopmentHubCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DevelopmentDirectionsScreen())),
      ),
    ],
  );
}

class _DevelopmentHubCard extends StatelessWidget {
  const _DevelopmentHubCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: onTap,
    child: GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: VirilColors.gold.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: VirilColors.gold.withValues(alpha: .3)),
            ),
            child: const Icon(Icons.hub_rounded, color: VirilColors.gold, size: 25),
          ),
          const SizedBox(width: 13),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Саморазвитие', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Четыре направления в одной системе', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: VirilColors.gold),
        ]),
        const SizedBox(height: 17),
        const Divider(color: VirilColors.line, height: 1),
        const SizedBox(height: 14),
        const _DirectionLine(icon: Icons.fitness_center_rounded, title: 'Физическое развитие', color: VirilColors.lava),
        const _DirectionLine(icon: Icons.psychology_alt_rounded, title: 'Ментальное развитие', color: VirilColors.ice),
        const _DirectionLine(icon: Icons.auto_stories_rounded, title: 'Интеллектуальное развитие', color: VirilColors.gold),
        const _DirectionLine(icon: Icons.spa_rounded, title: 'Духовное развитие', color: VirilColors.violet),
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerRight,
          child: Text('ОТКРЫТЬ НАПРАВЛЕНИЯ  →', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w800)),
        ),
      ]),
    ),
  );
}

class _DirectionLine extends StatelessWidget {
  const _DirectionLine({required this.icon, required this.title, required this.color});
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 11),
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

class DevelopmentDirectionsScreen extends StatelessWidget {
  const DevelopmentDirectionsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(title: const Text('Саморазвитие'), backgroundColor: Colors.transparent),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      children: const [
        _DirectionCard(icon: Icons.fitness_center_rounded, title: 'Физическое развитие', subtitle: 'Движение, выносливость и восстановление', color: VirilColors.lava, domain: 'Физическое'),
        _DirectionCard(icon: Icons.psychology_alt_rounded, title: 'Ментальное развитие', subtitle: 'Внимание, эмоциональная грамотность и рефлексия', color: VirilColors.ice, domain: 'Ментальное'),
        _DirectionCard(icon: Icons.auto_stories_rounded, title: 'Интеллектуальное развитие', subtitle: 'Чтение, языки и критическое мышление', color: VirilColors.gold, domain: 'Интеллект'),
        _DirectionCard(icon: Icons.spa_rounded, title: 'Духовное развитие', subtitle: 'Ценности, осознанность и личный смысл', color: VirilColors.violet, domain: 'Духовное'),
      ],
    ),
  );
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.domain});
  final IconData icon;
  final String title, subtitle, domain;
  final Color color;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DomainDetailScreen(domain: domain))),
    child: GlassCard(
      margin: const EdgeInsets.only(bottom: 13),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withValues(alpha: .3))),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.35)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: VirilColors.gold),
      ]),
    ),
  );
}
