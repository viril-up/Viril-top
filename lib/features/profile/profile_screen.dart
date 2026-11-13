import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/data/viril_store.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/metric_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: VirilStore.instance,
    builder: (context, _) {
      final store = VirilStore.instance;
      return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), children: [
    const SectionTitle('Профиль', subtitle: 'Твоя личная территория развития'),
    GlassCard(padding: const EdgeInsets.all(0), child: Column(children: [
      Container(height: 155, decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF263653), Color(0xFF171827), Color(0xFF473329)]),
      ), child: Stack(children: [
        Positioned(right: 20, top: 18, child: Icon(Icons.account_balance, size: 90, color: VirilColors.gold.withValues(alpha: .18))),
        const Positioned(left: 20, bottom: 18, child: Text('VIRIL · YOUR PATH', style: TextStyle(color: VirilColors.gold, letterSpacing: 2, fontWeight: FontWeight.w800, fontSize: 10))),
      ])),
      Padding(padding: const EdgeInsets.all(18), child: Column(children: [
        Row(children: [
          Container(width: 62, height: 62, decoration: BoxDecoration(shape: BoxShape.circle,
            color: VirilColors.stoneLight, border: Border.all(color: VirilColors.gold, width: 1.5)),
            child: const Icon(Icons.psychology_alt, color: VirilColors.ice, size: 32)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Путник', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21)),
            Text('Уровень ${store.level} · Путь продолжается', style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
            const Text('VIRIL MEMBER', style: TextStyle(color: VirilColors.gold, letterSpacing: 1.5, fontSize: 9)),
          ])),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: MetricTile(value: '${store.xp}', label: 'ОБЩИЙ XP')),
          const SizedBox(width: 8),
          Expanded(child: MetricTile(value: '${store.xp}', label: 'XP СЕЗОНА')),
          const SizedBox(width: 8),
          Expanded(child: MetricTile(value: '${store.completedCount}', label: 'ЗАДАЧ')),
        ]),
      ])),
    ])),
    const SectionTitle('Глобальная лига', subtitle: 'Соревнуйся с собой и отмечай личный рост'),
    GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.emoji_events_rounded, color: VirilColors.gold, size: 25),
        SizedBox(width: 9),
        Expanded(child: Text('VIRIL · WORLD LEAGUE', style: TextStyle(color: VirilColors.gold, letterSpacing: 1.4, fontSize: 10, fontWeight: FontWeight.w800))),
        Text('СЕЗОН 01', style: TextStyle(color: VirilColors.muted, fontSize: 9)),
      ]),
      const SizedBox(height: 12),
      const Text('Твой путь — твой рекорд.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Рейтинг и таблица участников появятся после подключения аккаунтов и серверной системы.', style: TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.4)),
      const SizedBox(height: 14),
      Row(children: [
        const Expanded(child: _LeagueBadge(label: 'ТЕКУЩАЯ ЛИГА', value: 'Бронза')),
        const SizedBox(width: 9),
        Expanded(child: _LeagueBadge(label: 'ОЧКИ СЕЗОНА', value: '${store.xp} XP')),
      ]),
    ])),
    const SectionTitle('Настройки профиля'),
    for (final item in [
      (Icons.person_outline, 'Личные данные'),
      (Icons.tune_rounded, 'Персонализация'),
      (Icons.notifications_none, 'Уведомления'),
      (Icons.security_rounded, 'Конфиденциальность'),
      (Icons.help_outline, 'Помощь и поддержка'),
    ]) GlassCard(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(children: [Icon(item.$1, color: VirilColors.ice), const SizedBox(width: 13), Expanded(child: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w600))), const Icon(Icons.chevron_right, color: VirilColors.muted)])),
      ]);
    },
  );
}

class _LeagueBadge extends StatelessWidget {
  const _LeagueBadge({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: VirilColors.stoneLight.withValues(alpha: .65), borderRadius: BorderRadius.circular(15)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: VirilColors.muted, fontSize: 8)),
    ]));
}
