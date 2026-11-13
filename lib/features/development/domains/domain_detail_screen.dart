import 'package:flutter/material.dart';
import '../../../core/data/viril_store.dart';
import '../../../core/theme/viril_colors.dart';
import '../../../core/widgets/glass_card.dart';

class DomainDetailScreen extends StatelessWidget {
  const DomainDetailScreen({super.key, required this.domain});
  final String domain;

  static const Map<String, _DomainInfo> _domains = {
    'Физическое': _DomainInfo(
      subtitle: 'Сила начинается с осознанного движения',
      description: 'Развивай выносливость, координацию и заботу о теле. Выбирай комфортную нагрузку, уделяй внимание технике и восстановлению.',
      icon: Icons.fitness_center_rounded,
      color: VirilColors.lava,
      practices: [
        ('Разминка и лёгкая подвижность', '5–8 минут мягких движений без боли'),
        ('Прогулка на свежем воздухе', 'Спокойная прогулка в удобном темпе'),
        ('Восстановление', 'Пауза, вода и полноценный отдых'),
      ],
    ),
    'Ментальное': _DomainInfo(
      subtitle: 'Ясность — навык, который можно тренировать',
      description: 'Учись замечать своё состояние, управлять вниманием и спокойно разбирать сложные ситуации.',
      icon: Icons.psychology_alt_rounded,
      color: VirilColors.ice,
      practices: [
        ('Пауза осознанности', 'На несколько минут переключи внимание на дыхание'),
        ('Дневник мыслей', 'Запиши событие, свою мысль и альтернативный взгляд'),
        ('Практика концентрации', 'Удели одному спокойному делу 15 минут'),
      ],
    ),
    'Интеллект': _DomainInfo(
      subtitle: 'Любознательность превращает знания в силу',
      description: 'Развивай кругозор, речь, критическое мышление и способность учиться самостоятельно.',
      icon: Icons.auto_stories_rounded,
      color: VirilColors.gold,
      practices: [
        ('Чтение с заметками', 'Прочитай небольшой фрагмент и запиши одну идею'),
        ('Изучение языка', 'Повтори слова и составь несколько предложений'),
        ('Разбор одной идеи', 'Проверь аргументы и найди альтернативное объяснение'),
      ],
    ),
    'Духовное': _DomainInfo(
      subtitle: 'Ценности помогают выбирать направление',
      description: 'Исследуй свои ценности, укрепляй благодарность и находи смысл в ежедневных поступках.',
      icon: Icons.spa_rounded,
      color: VirilColors.violet,
      practices: [
        ('Личные ценности', 'Выбери одну ценность и подумай, как проявить её сегодня'),
        ('Практика благодарности', 'Запиши три вещи, за которые благодарен'),
        ('Добрый поступок', 'Сделай небольшое полезное дело для другого человека'),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final info = _domains[domain]!;
    return Scaffold(
      backgroundColor: VirilColors.voidBlack,
      appBar: AppBar(title: Text(domain), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                color: info.color.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: info.color.withValues(alpha: .35)),
              ),
              child: Icon(info.icon, color: info.color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(info.subtitle, style: TextStyle(color: info.color, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(info.description, style: const TextStyle(color: VirilColors.muted, height: 1.55, fontSize: 13)),
          ])),
          const SizedBox(height: 22),
          const Text('ПРАКТИКИ', style: TextStyle(color: VirilColors.gold, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final practice in info.practices)
            _PracticeCard(domain: domain, title: practice.$1, description: practice.$2, color: info.color),
        ],
      ),
    );
  }
}

class _DomainInfo {
  const _DomainInfo({
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.practices,
  });
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<(String, String)> practices;
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.domain, required this.title, required this.description, required this.color});
  final String domain, title, description;
  final Color color;

  @override
  Widget build(BuildContext context) => GlassCard(
    margin: const EdgeInsets.only(bottom: 11),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
        Icon(Icons.auto_awesome_rounded, color: color, size: 19),
      ]),
      const SizedBox(height: 6),
      Text(description, style: const TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.4)),
      const SizedBox(height: 13),
      Align(
        alignment: Alignment.centerRight,
        child: FilledButton.tonalIcon(
          onPressed: () async {
            await VirilStore.instance.addTask(title, domain);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('«$title» добавлено в планы')),
              );
            }
          },
          icon: const Icon(Icons.add_rounded, size: 17),
          label: const Text('В план на сегодня'),
        ),
      ),
    ]),
  );
}
