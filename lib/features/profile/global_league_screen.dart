import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';
import 'data/league_data.dart';

class GlobalLeagueScreen extends StatefulWidget {
  const GlobalLeagueScreen({super.key});
  @override State<GlobalLeagueScreen> createState() => _GlobalLeagueScreenState();
}
class _GlobalLeagueScreenState extends State<GlobalLeagueScreen> {
  int? _expandedEpoch;
  static const _epochColors = <Color>[
    Color(0xFFB9784E), Color(0xFFB7C0C9), Color(0xFF8C82D8),
    Color(0xFF75B9C8), Color(0xFF72C6B0),
  ];
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: VirilStore.instance,
    builder: (context, _) {
      final store = VirilStore.instance;
      final current = LeagueSystem.forXp(store.xp);
      final globalLevel = LeagueSystem.globalLevelForXp(store.xp);
      final innerLevel = LeagueSystem.levelWithinLeagueForXp(store.xp);
      final color = _epochColors[current.epochNumber - 1];
      return Scaffold(
        backgroundColor: VirilColors.voidBlack,
        appBar: AppBar(title: const Text('Путь глобальных лиг'), backgroundColor: VirilColors.voidBlack),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
          _currentProgress(store.xp, current, globalLevel, innerLevel, color),
          const SizedBox(height: 16),
          _summary(),
          const SizedBox(height: 20),
          const Text('ПЯТЬ ЭПОХ · ШЕСТЬДЕСЯТ ЛИГ', style: TextStyle(
            color: VirilColors.gold, fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (final epoch in LeagueSystem.epochs) _epochSection(epoch, store.xp),
        ]),
      );
    });
  Widget _currentProgress(int xp, LeagueDefinition league, int globalLevel, int innerLevel, Color color) {
    final into = LeagueSystem.xpIntoLevel(xp);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF342D20), Color(0xFF171923), Color(0xFF11151F)]),
        border: Border.all(color: color.withValues(alpha: .7))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ТВОЯ ТЕКУЩАЯ ЛИГА', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.6, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.8), color: color.withValues(alpha: .12)),
            child: Icon(Icons.military_tech_rounded, color: color, size: 31)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(league.name, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
            Text('ЭПОХА ${league.epochNumber} · ${league.epochName}', style: const TextStyle(
              color: VirilColors.muted, fontSize: 8, letterSpacing: .7, fontWeight: FontWeight.w800)),
          ])),
          Text('${xp} XP', style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('УРОВЕНЬ ${globalLevel} ИЗ 180', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
          Text('ЭТАП ${innerLevel} / 3', style: const TextStyle(color: VirilColors.gold, fontSize: 9, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(
          value: into / 100, minHeight: 8, backgroundColor: Colors.white.withValues(alpha: .10), color: color)),
        const SizedBox(height: 7),
        Text('${into} / 100 XP · ещё ${100 - into} XP до следующего уровня',
          style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
        const SizedBox(height: 13),
        Row(children: [
          _milestone('I', league.levelOneXp, xp, color),
          _milestone('II', league.levelTwoXp, xp, color),
          _milestone('III', league.levelThreeXp, xp, color),
        ]),
        if (league.isFinal) const Padding(padding: EdgeInsets.only(top: 12),
          child: Text('ОМНИВЕРСАЛЬНАЯ · ВЫСШАЯ СТУПЕНЬ ВСЕЙ СИСТЕМЫ',
            style: TextStyle(color: VirilColors.gold, fontSize: 9, fontWeight: FontWeight.w900))),
      ]),
    );
  }
  Widget _milestone(String label, int threshold, int xp, Color color) {
    final reached = xp >= threshold;
    return Expanded(child: Container(margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      decoration: BoxDecoration(color: reached ? color.withValues(alpha: .15) : Colors.black.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(10), border: Border.all(color: reached ? color.withValues(alpha: .7) : VirilColors.line)),
      child: Column(children: [
        Text('УРОВЕНЬ ${label}', style: TextStyle(color: reached ? color : VirilColors.muted, fontSize: 8, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text('${threshold} XP', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
      ]),
    ));
  }
  Widget _summary() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(17), border: Border.all(color: VirilColors.line)),
    child: const Row(children: [
      Expanded(child: _SummaryValue(value: '5', label: 'ЭПОХ')),
      Expanded(child: _SummaryValue(value: '60', label: 'ЛИГ')),
      Expanded(child: _SummaryValue(value: '180', label: 'УРОВНЕЙ')),
      Expanded(child: _SummaryValue(value: '17 900', label: 'XP ДО ФИНИША')),
    ]),
  );
  Widget _epochSection(LeagueEpoch epoch, int xp) {
    final first = LeagueSystem.all.firstWhere((e) => e.epochNumber == epoch.number).number;
    final last = LeagueSystem.all.lastWhere((e) => e.epochNumber == epoch.number).number;
    final color = _epochColors[epoch.number - 1];
    final isOpen = _expandedEpoch == epoch.number || _expandedEpoch == null;
    return Container(margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withValues(alpha: .3))),
      child: Column(children: [
        InkWell(borderRadius: BorderRadius.circular(17),
          onTap: () => setState(() => _expandedEpoch = _expandedEpoch == epoch.number ? -1 : epoch.number),
          child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle,
              color: color.withValues(alpha: .13), border: Border.all(color: color.withValues(alpha: .65))),
              child: Center(child: Text('${epoch.number}', style: TextStyle(color: color, fontWeight: FontWeight.w900)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ЭПОХА ${epoch.number} · ${epoch.name}', style: TextStyle(color: color, fontSize: 10, letterSpacing: .7, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text('${epoch.leagues.length} лиг · уровни ${first}–${last}',
                style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
            ])),
            Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: color),
          ])),
        ),
        if (isOpen) ...[
          Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Text(epoch.subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4))),
          for (final league in LeagueSystem.all.where((item) => item.epochNumber == epoch.number))
            _leagueTile(league, xp, color),
          const SizedBox(height: 6),
        ],
      ]),
    );
  }
  Widget _leagueTile(LeagueDefinition league, int xp, Color color) {
    final isCurrent = xp >= league.firstXp && (league.isFinal || xp < league.nextLeagueXp);
    final isUnlocked = xp >= league.firstXp;
    final isCompleted = !league.isFinal && xp >= league.nextLeagueXp;
    return Container(margin: const EdgeInsets.fromLTRB(10, 3, 10, 5),
      decoration: BoxDecoration(color: isCurrent ? color.withValues(alpha: .10) : Colors.black.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCurrent ? color.withValues(alpha: .75) : VirilColors.line.withValues(alpha: .65))),
      child: Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 1),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Icon(isCompleted ? Icons.check_circle_rounded : isCurrent ? Icons.radio_button_checked_rounded :
            isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
            color: isCompleted || isCurrent ? color : VirilColors.muted, size: 19),
          title: Text('${league.number.toString().padLeft(2, '0')}. ${league.name}',
            style: TextStyle(color: isCurrent ? color : isUnlocked ? Colors.white : VirilColors.muted,
              fontSize: 12, fontWeight: FontWeight.w900)),
          subtitle: Text(isCurrent ? 'ТВОЯ ТЕКУЩАЯ ЛИГА' : isCompleted ? 'ПРОЙДЕНА' : isUnlocked ? 'ОТКРЫТА' : 'ЗАКРЫТА',
            style: TextStyle(color: isCurrent ? color : VirilColors.muted, fontSize: 8, letterSpacing: .8, fontWeight: FontWeight.w800)),
          children: [
            const Divider(color: VirilColors.line, height: 8),
            Row(children: [
              _levelCell('I', league.levelOneXp, xp, color),
              _levelCell('II', league.levelTwoXp, xp, color),
              _levelCell('III', league.levelThreeXp, xp, color),
            ]),
            const SizedBox(height: 8),
            Text(league.isFinal ? 'Финальная ступень системы.' :
              'После III уровня и достижения ${league.nextLeagueXp} XP откроется следующая лига.',
              style: const TextStyle(color: VirilColors.muted, fontSize: 9, height: 1.4)),
          ],
        )),
    );
  }
  Widget _levelCell(String name, int threshold, int xp, Color color) {
    final done = xp >= threshold;
    return Expanded(child: Container(margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(color: done ? color.withValues(alpha: .13) : Colors.black.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(9), border: Border.all(color: done ? color.withValues(alpha: .5) : VirilColors.line)),
      child: Column(children: [
        Text('УРОВЕНЬ ${name}', style: TextStyle(color: done ? color : VirilColors.muted, fontSize: 8, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text('${threshold} XP', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(done ? 'ДОСТИГНУТ' : 'ВПЕРЕДИ', style: const TextStyle(color: VirilColors.muted, fontSize: 7)),
      ]),
    ));
  }
}
class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.value, required this.label});
  final String value, label;
  @override Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: VirilColors.gold, fontSize: 15, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3),
    Text(label, textAlign: TextAlign.center, style: const TextStyle(color: VirilColors.muted, fontSize: 7, letterSpacing: .5)),
  ]);
}
