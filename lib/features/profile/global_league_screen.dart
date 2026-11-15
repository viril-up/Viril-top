import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';

class GlobalLeagueScreen extends StatefulWidget {
  const GlobalLeagueScreen({super.key});
  @override State<GlobalLeagueScreen> createState() => _GlobalLeagueScreenState();
}
class _GlobalLeagueScreenState extends State<GlobalLeagueScreen> {
  int _tab = 0;
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: VirilStore.instance,
    builder: (context, _) {
      final store = VirilStore.instance;
      final league = _leagueFor(store.xp);
      final now = DateTime.now();
      return Scaffold(
        backgroundColor: VirilColors.voidBlack,
        appBar: AppBar(title: const Text('Глобальная лига'), backgroundColor: VirilColors.voidBlack),
        body: ListView(padding: const EdgeInsets.fromLTRB(17, 8, 17, 35), children: [
          _podium(),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(
            color: VirilColors.stone, borderRadius: BorderRadius.circular(18), border: Border.all(color: VirilColors.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_monthName(now.month) + ' ${now.year}', style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.military_tech_rounded, color: VirilColors.gold, size: 27),
                const SizedBox(width: 9),
                Expanded(child: Text('ТВОЯ ЛИГА · ${league.toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
                Text('${store.xp} XP', style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900)),
              ]),
            ])),
          const SizedBox(height: 16),
          Row(children: [
            _TabButton(label: 'Топ 100 мира', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
            const SizedBox(width: 6),
            _TabButton(label: 'Рекорды сезонов', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
            const SizedBox(width: 6),
            _TabButton(label: 'Мой результат', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
          ]),
          const SizedBox(height: 15),
          if (_tab == 0) _emptyState(Icons.public_rounded, 'Мировой рейтинг скоро откроется',
            'Для настоящего Топ 100 нужны игровые аккаунты и общий сервер. Сейчас глобальные места ещё не рассчитываются.'),
          if (_tab == 1) _emptyState(Icons.emoji_events_rounded, 'История сезонов появится позже',
            'Рекорды будут сохраняться после запуска серверных сезонов.'),
          if (_tab == 2) _myResult(store.xp, store.level, league),
        ]),
      );
    });
  Widget _podium() => Container(
    padding: const EdgeInsets.fromLTRB(12, 17, 12, 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(23),
      gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF342D20), Color(0xFF171923), Color(0xFF11151F)]),
      border: Border.all(color: VirilColors.gold.withValues(alpha: .55)),
    ),
    child: Column(children: [
      const Text('ЗАЛ СЛАВЫ · ТЕКУЩИЙ СЕЗОН', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w900)),
      const SizedBox(height: 17),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: _PodiumPlace(rank: 2, label: 'СЕРЕБРО', height: 104, color: const Color(0xFFB7C0C9), delay: 250)),
        Expanded(child: _PodiumPlace(rank: 1, label: 'ЗОЛОТО', height: 137, color: VirilColors.gold, delay: 0)),
        Expanded(child: _PodiumPlace(rank: 3, label: 'БРОНЗА', height: 88, color: const Color(0xFFB9784E), delay: 450)),
      ]),
      const SizedBox(height: 12),
      const Text('Места и имена появятся после запуска серверного рейтинга.',
        textAlign: TextAlign.center, style: TextStyle(color: VirilColors.muted, fontSize: 10)),
    ]),
  );
  Widget _emptyState(IconData icon, String title, String body) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(18), border: Border.all(color: VirilColors.line)),
    child: Column(children: [
      Icon(icon, color: VirilColors.gold, size: 35), const SizedBox(height: 12),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
      const SizedBox(height: 7), Text(body, textAlign: TextAlign.center,
        style: const TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.5)),
    ]));
  Widget _myResult(int xp, int level, String league) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(18), border: Border.all(color: VirilColors.gold.withValues(alpha: .35))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ТВОЙ ЛОКАЛЬНЫЙ РЕЗУЛЬТАТ', style: TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 10)),
      const SizedBox(height: 14),
      _resultRow('Лига', league), _resultRow('Уровень', '$level'), _resultRow('Накопленный XP', '$xp'),
      _resultRow('Место в мире', 'Не рассчитано'),
      const SizedBox(height: 8),
      const Text('Это данные текущего устройства, они ещё не синхронизированы с глобальным рейтингом.',
        style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.45)),
    ]));
  Widget _resultRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: VirilColors.muted, fontSize: 12))),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13))]));
  static String _monthName(int m) => const ['ЯНВАРЬ','ФЕВРАЛЬ','МАРТ','АПРЕЛЬ','МАЙ','ИЮНЬ','ИЮЛЬ','АВГУСТ','СЕНТЯБРЬ','ОКТЯБРЬ','НОЯБРЬ','ДЕКАБРЬ'][m-1];
  static String _leagueFor(int xp) => xp >= 2000 ? 'Обсидиан' : xp >= 1000 ? 'Золото' : xp >= 500 ? 'Серебро' : 'Бронза';
}
class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({required this.rank, required this.label, required this.height, required this.color, required this.delay});
  final int rank, height, delay; final String label; final Color color;
  @override Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: .25, end: 1), duration: Duration(milliseconds: 850 + delay),
    curve: Curves.easeOutBack,
    builder: (context, value, child) => Opacity(opacity: value.clamp(0, 1),
      child: Transform.translate(offset: Offset(0, (1-value)*22), child: child)),
    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Icon(Icons.emoji_events_rounded, color: color, size: rank == 1 ? 32 : 25),
      const SizedBox(height: 5),
      Text('—', style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      Container(height: height.toDouble(), margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: .38), color.withValues(alpha: .08)]),
          border: Border.all(color: color.withValues(alpha: .65))),
        child: Center(child: Text('$rank', style: TextStyle(color: color, fontSize: 27, fontWeight: FontWeight.w900)))),
      const SizedBox(height: 7),
      Text(label, style: TextStyle(color: color, fontSize: 8, letterSpacing: .8, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      const Text('ОЖИДАНИЕ', style: TextStyle(color: VirilColors.muted, fontSize: 7)),
    ]),
  );
}
class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});
  final String label; final bool selected; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap,
    borderRadius: BorderRadius.circular(12), child: Container(height: 48,
      alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: selected ? VirilColors.gold.withValues(alpha: .16) : VirilColors.stone,
        borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? VirilColors.gold : VirilColors.line)),
      child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
        color: selected ? VirilColors.gold : VirilColors.muted)))));
}
