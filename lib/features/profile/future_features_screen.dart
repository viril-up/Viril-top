import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

class MotivationGameScreen extends StatelessWidget {
  const MotivationGameScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(title: const Text('Мотивационная игра'), backgroundColor: Colors.transparent),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), children: [
      GlassCard(child: Column(children: [
        Container(width: 78, height: 78, decoration: BoxDecoration(shape: BoxShape.circle,
          color: VirilColors.gold.withValues(alpha: .12), border: Border.all(color: VirilColors.gold.withValues(alpha: .4))),
          child: const Icon(Icons.emoji_events_rounded, color: VirilColors.gold, size: 38)),
        const SizedBox(height: 14),
        const Text('ТВОЙ ПРОГРЕСС МОЖЕТ СТАТЬ ВОЗНАГРАЖДЕНИЕМ',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, height: 1.4)),
        const SizedBox(height: 9),
        const Text('Мы рассматриваем запуск мотивационной системы, в которой участники смогут выполнять полезные задания, развивать навыки и получать дополнительные поощрения.',
          textAlign: TextAlign.center, style: TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.5)),
      ])),
      const SizedBox(height: 14),
      GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('МОЙ БАЛАНС', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('— — —', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const Text('Баланс станет доступен после официального запуска программы.',
          style: TextStyle(color: VirilColors.muted, fontSize: 10)),
      ])),
      const SizedBox(height: 14),
      GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('БУДУЩИЕ ЗАДАНИЯ', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
        SizedBox(height: 12),
        _FutureTask(icon: Icons.menu_book_rounded, title: 'Обучение', subtitle: 'Развивай знания и осваивай новое'),
        _FutureTask(icon: Icons.flag_rounded, title: 'Личные цели', subtitle: 'Выполняй запланированные этапы'),
        _FutureTask(icon: Icons.fitness_center_rounded, title: 'Полезные привычки', subtitle: 'Поддерживай регулярность и дисциплину'),
      ])),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(
        color: VirilColors.gold.withValues(alpha: .08), borderRadius: BorderRadius.circular(17),
        border: Border.all(color: VirilColors.gold.withValues(alpha: .3))),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, color: VirilColors.gold, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text('Функция находится на стадии рассмотрения. Её запуск будет зависеть от развития проекта и появления устойчивой системы финансирования. Сейчас задания, баланс и денежные вознаграждения не активны. Мы не обещаем выплаты до официального объявления условий.',
            style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.5))),
        ]),
      ),
    ]),
  );
}

class InviteFriendScreen extends StatelessWidget {
  const InviteFriendScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(title: const Text('Пригласить друга'), backgroundColor: Colors.transparent),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), children: [
      GlassCard(child: Column(children: [
        Container(width: 88, height: 88, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25), gradient: LinearGradient(
            colors: [VirilColors.gold.withValues(alpha: .24), VirilColors.lava.withValues(alpha: .12)]),
          border: Border.all(color: VirilColors.gold.withValues(alpha: .4))),
          child: const Icon(Icons.card_giftcard_rounded, color: VirilColors.gold, size: 43)),
        const SizedBox(height: 16),
        const Text('ПОДАРОК ДЛЯ ТВОЕГО ДРУГА', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: .5)),
        const SizedBox(height: 9),
        const Text('В будущем мы хотим добавить приглашения по персональной ссылке. Друг сможет присоединиться к Viril, а вы оба, возможно, получите специальные возможности или бонусы.',
          textAlign: TextAlign.center, style: TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.5)),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
          decoration: BoxDecoration(color: VirilColors.stoneLight, borderRadius: BorderRadius.circular(13), border: Border.all(color: VirilColors.line)),
          child: const Text('Реферальная программа готовится', textAlign: TextAlign.center,
            style: TextStyle(color: VirilColors.gold, fontSize: 10, fontWeight: FontWeight.w800))),
      ])),
    ]),
  );
}

class _FutureTask extends StatelessWidget {
  const _FutureTask({required this.icon, required this.title, required this.subtitle});
  final IconData icon; final String title, subtitle;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
    Icon(icon, color: VirilColors.ice, size: 19), const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      Text(subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
    ])),
    const Icon(Icons.lock_outline_rounded, color: VirilColors.muted, size: 16),
  ]));
}
