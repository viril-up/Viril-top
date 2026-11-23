import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';
import 'data/league_data.dart';
import 'widgets/league_emblem.dart';

class LeaguePathScreen extends StatefulWidget {
  const LeaguePathScreen({super.key});
  @override State<LeaguePathScreen> createState() => _LeaguePathScreenState();
}
class _LeaguePathScreenState extends State<LeaguePathScreen> {
  final _colors = const [Color(0xFFB9784E), Color(0xFFB7C0C9), Color(0xFF8C82D8), Color(0xFF75B9C8), Color(0xFF72C6B0)];
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: VirilStore.instance,
    builder: (context, _) {
      final xp = VirilStore.instance.xp;
      final league = LeagueSystem.forXp(xp);
      final level = LeagueSystem.globalLevelForXp(xp);
      final inner = LeagueSystem.levelWithinLeagueForXp(xp);
      final color = _colors[league.epochNumber - 1];
      return Scaffold(
        
        appBar: AppBar(title: const Text('Путь 60 глобальных лиг'), ),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
          _current(xp, league, level, inner, color),
          const SizedBox(height: 15),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: VirilColors.stone,
            borderRadius: BorderRadius.circular(16), border: Border.all(color: VirilColors.line)),
            child: const Row(children: [
              Expanded(child: _Summary(value: '5', label: 'ЭПОХ')),
              Expanded(child: _Summary(value: '60', label: 'ЛИГ')),
              Expanded(child: _Summary(value: '180', label: 'УРОВНЕЙ')),
              Expanded(child: _Summary(value: '17 900', label: 'XP ДО ФИНИША')),
            ])),
          const SizedBox(height: 20),
          const Text('ПЯТЬ ЭПОХ · ШЕСТЬДЕСЯТ ЛИГ', style: TextStyle(color: VirilColors.gold,
            fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (final epoch in LeagueSystem.epochs) _epoch(epoch, xp),
        ]),
      );
    });
  Widget _current(int xp, LeagueDefinition league, int level, int inner, Color color) {
    final progress = league.isFinal && xp >= 17900 ? 100 : LeagueSystem.xpIntoLevel(xp);
    return Container(padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF342D20), Color(0xFF171923), Color(0xFF11151F)]),
        border: Border.all(color: color.withValues(alpha: .7))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ТВОЯ ТЕКУЩАЯ ЛИГА', style: TextStyle(color: VirilColors.gold, fontSize: 9,
          letterSpacing: 1.6, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Row(children: [
          LeagueEmblem(number: league.number, size: 56, active: true),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(league.name, style: TextStyle(color: color, fontSize: 21, fontWeight: FontWeight.w900)),
            Text('ЭПОХА ${league.epochNumber} · ${league.epochName}',
              style: const TextStyle(color: VirilColors.muted, fontSize: 8, letterSpacing: .6)),
          ])),
          Text('${xp} XP', style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('ГЛОБАЛЬНЫЙ УРОВЕНЬ ${level}/180', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
          Text('ЭТАП ${inner}/3', style: const TextStyle(color: VirilColors.gold, fontSize: 9, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(
          value: progress / 100, minHeight: 8, backgroundColor: Colors.white12, color: color)),
        const SizedBox(height: 6),
        Text(league.isFinal && xp >= 17900 ? 'МАКСИМАЛЬНЫЙ УРОВЕНЬ ДОСТИГНУТ' : '${progress}/100 XP · ещё ${100-progress} XP до следующего уровня',
          style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
        const SizedBox(height: 12),
        Row(children: [
          _milestone('I', league.levelOneXp, xp, color),
          _milestone('II', league.levelTwoXp, xp, color),
          _milestone('III', league.levelThreeXp, xp, color),
        ]),
        if (league.isFinal) const Padding(padding: EdgeInsets.only(top: 12),
          child: Text('ОМНИВЕРСАЛЬНАЯ · ВЫСШАЯ СТУПЕНЬ ВСЕЙ СИСТЕМЫ',
            style: TextStyle(color: VirilColors.gold, fontSize: 9, fontWeight: FontWeight.w900))),
      ]));
  }
  Widget _milestone(String name, int xpAt, int xp, Color color) {
    final done = xp >= xpAt;
    return Expanded(child: Container(margin: const EdgeInsets.only(right: 5), padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: done ? color.withValues(alpha: .14) : Colors.black26,
        borderRadius: BorderRadius.circular(9), border: Border.all(color: done ? color : VirilColors.line)),
      child: Column(children: [
        Text('УРОВЕНЬ $name', style: TextStyle(color: done ? color : VirilColors.muted, fontSize: 8, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text('${xpAt} XP', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
      ])));
  }
  Widget _epoch(LeagueEpoch epoch, int xp) {
    final color = _colors[epoch.number - 1];
    final leagues = LeagueSystem.all.where((e) => e.epochNumber == epoch.number).toList();
    final first = leagues.first.number, last = leagues.last.number;
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.fromLTRB(13, 13, 13, 8),
      decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withValues(alpha: .35))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 16, backgroundColor: color.withValues(alpha: .14),
            child: Text('${epoch.number}', style: TextStyle(color: color, fontWeight: FontWeight.w900))),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ЭПОХА ${epoch.number} · ${epoch.name}', style: TextStyle(color: color, fontSize: 10, letterSpacing: .6, fontWeight: FontWeight.w900)),
            Text('${epoch.leagues.length} лиг · номера ${first}–${last}',
              style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
          ])),
        ]),
        Padding(padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(epoch.subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 9, height: 1.4))),
        for (final item in leagues) _league(item, xp, color),
      ]));
  }
  Widget _league(LeagueDefinition item, int xp, Color color) {
    final current = xp >= item.firstXp && (item.isFinal || xp < item.nextLeagueXp);
    final completed = !item.isFinal && xp >= item.nextLeagueXp;
    final unlocked = xp >= item.firstXp;
    return Container(margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(color: current ? color.withValues(alpha: .10) : Colors.black12,
        borderRadius: BorderRadius.circular(11), border: Border.all(color: current ? color : VirilColors.line.withValues(alpha: .7))),
      child: Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 9),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          leading: completed
              ? Icon(Icons.check_circle, color: color, size: 20)
              : LeagueEmblem(
                  number: item.number,
                  size: 34,
                  unlocked: unlocked,
                  active: current,
                ),
          title: Text('${item.number.toString().padLeft(2, '0')}. ${item.name}',
            style: TextStyle(color: current ? color : unlocked ? Colors.white : VirilColors.muted,
              fontSize: 11, fontWeight: FontWeight.w900)),
          subtitle: Text(current ? 'ТВОЯ ЛИГА' : completed ? 'ПРОЙДЕНА' : unlocked ? 'ОТКРЫТА' : 'ЗАКРЫТА',
            style: const TextStyle(color: VirilColors.muted, fontSize: 8, letterSpacing: .7)),
          children: [
            const Divider(color: VirilColors.line, height: 8),
            Row(children: [
              _level('I', item.levelOneXp, xp, color),
              _level('II', item.levelTwoXp, xp, color),
              _level('III', item.levelThreeXp, xp, color),
            ]),
            const SizedBox(height: 7),
            Text(item.isFinal ? 'Финальная ступень всей системы.' :
              'Следующая лига откроется после III уровня: ${item.nextLeagueXp} XP.',
              style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
          ])));
  }
  Widget _level(String name, int threshold, int xp, Color color) {
    final done = xp >= threshold;
    return Expanded(child: Container(margin: const EdgeInsets.only(right: 5), padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(color: done ? color.withValues(alpha: .13) : Colors.black12,
        borderRadius: BorderRadius.circular(8), border: Border.all(color: done ? color : VirilColors.line)),
      child: Column(children: [
        Text('УРОВЕНЬ $name', style: TextStyle(color: done ? color : VirilColors.muted, fontSize: 8, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text('${threshold} XP', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
        Text(done ? 'ДОСТИГНУТ' : 'ВПЕРЕДИ', style: const TextStyle(color: VirilColors.muted, fontSize: 7)),
      ])));
  }
}
class _Summary extends StatelessWidget {
  const _Summary({required this.value, required this.label});
  final String value, label;
  @override Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: VirilColors.gold, fontSize: 14, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3),
    Text(label, textAlign: TextAlign.center, style: const TextStyle(color: VirilColors.muted, fontSize: 7)),
  ]);
}
