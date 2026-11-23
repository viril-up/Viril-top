import 'package:flutter/material.dart';
import '../../core/widgets/viril_staggered_list.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import 'domains/domain_detail_screen.dart';
import '../workouts/workouts_screen.dart';
import 'personal_dictionary_screen.dart';
import 'running_screen.dart';
import 'meditation_screen.dart';

class DevelopmentScreen extends StatelessWidget {
  const DevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context) => VirilStaggeredList(pageIndex: 1, 
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
    children: [
      InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkoutsScreen())),
        child: GlassCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 88,
              child: Stack(fit: StackFit.expand, children: [
                Image.asset(
                  'assets/section_cards/training/training.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF343A42), Color(0xFF171D26)]),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text('Тренировки', style: TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 9, offset: Offset(0, 2))],
                    )),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
      _DevelopmentFeatureCard(
        title: 'Бег',
        imagePath: 'assets/section_cards/running/running.png',
        accent: VirilColors.lava,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RunningScreen())),
      ),
      _DevelopmentFeatureCard(
        title: 'Медитация',
        imagePath: 'assets/section_cards/meditation/meditation.png',
        accent: VirilColors.ice,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MeditationScreen())),
      ),
      _DevelopmentFeatureCard(
        title: 'Мой словарь',
        imagePath: 'assets/section_cards/my_dictionary/my_dictionary.png',
        accent: VirilColors.gold,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PersonalDictionaryScreen()),
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
              color: VirilColors.navyLight.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: VirilColors.line),
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


class _DevelopmentFeatureCard extends StatelessWidget {
  const _DevelopmentFeatureCard({
    required this.title,
    required this.imagePath,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String imagePath;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: GlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 12),
      radius: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 88,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent.withValues(alpha: .28), const Color(0xFF171D26)],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(color: Colors.black.withValues(alpha: .72), blurRadius: 9, offset: const Offset(0, 2)),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 17,
                child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: .95), size: 16),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
