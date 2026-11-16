import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';
import 'data/global_league_data.dart';

class GlobalLeagueScreen extends StatelessWidget {
  const GlobalLeagueScreen({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: VirilStore.instance,
    builder: (context, _) {
      final xp = VirilStore.instance.xp;
      final level = GlobalLeagueData.levelForXp(xp);
      final leagueIndex = GlobalLeagueData.leagueIndexForXp(xp);
      final tier = GlobalLeagueData.tierForXp(xp);
      final epochIndex = GlobalLeagueData.epochIndexForLeague(leagueIndex);
      final leagueName = GlobalLeagueData.allLeagues[leagueIndex];
      final color = GlobalLeagueData.colorForLeague(leagueIndex);
      return Scaffold(
        backgroundColor: VirilColors.voidBlack,
        appBar: AppBar(title: const Text('Путь глобальных лиг'), backgroundColor: VirilColors.voidBlack),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 34), children: [
          _currentCard(xp, level, leagueIndex, tier, leagueName, color, epochIndex),
          const SizedBox(height: 18),
          const Text('ПЯТЬ ЭПОХ · ШЕСТЬДЕСЯТ ЛИГ · 180 УРОВНЕЙ',
            style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (var i = 0; i < GlobalLeagueData.epochs.length; i++)
            _epochCard(i, leagueIndex, level),
          const SizedBox(height: 12),
          const Text('Каждая лига включает три уровня. Каждые 100 XP открывают следующий уровень. После третьего уровня открывается следующая лига.',
            textAlign: TextAlign.center, style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.5)),
        ]),
      );
    },
  );

  Widget _currentCard(int xp, int level, int index, int tier, String name, Color color, int epoch) {
    final progress = level >= 180 ? 1.0 : (xp % 100) / 100;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF342D20), Color(0xFF171923), Color(0xFF11151F)]),
        border: Border.all(color: color.withValues(alpha: .7)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: .12), blurRadius: 20)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ТВОЯ ТЕКУЩАЯ СТУПЕНЬ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2), color: Colors.black26),
            child: Icon(Icons.military_tech_rounded, color: color, size: 32)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(color: color, fontSize: 23, fontWeight: FontWeight.w900)),
            Text('ЛИГА ${index + 1} · ЭПОХА ${epoch + 1}', style: const TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1)),
          ])),
          Text('$xp XP', style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 17),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('ГЛОБАЛЬНЫЙ УРОВЕНЬ $level / 180', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          Text('СТУПЕНЬ $tier / 3', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 8,
          backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation<Color>(color))),
        const SizedBox(height: 7),
        Text(level >= 180 ? 'Максимальная ступень достигнута' : 'До следующего уровня: ${100 - (xp % 100)} XP',
          style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
      ]),
    );
  }

  Widget _epochCard(int epochIndex, int currentLeagueIndex, int currentLevel) {
    final epoch = GlobalLeagueData.epochs[epochIndex];
    final start = GlobalLeagueData.epochStartLeague(epochIndex);
    final end = GlobalLeagueData.epochEndLeague(epochIndex);
    final completed = currentLeagueIndex > end;
    final unlocked = currentLeagueIndex >= start;
    final color = GlobalLeagueData.colorForLeague(start);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(17),
        border: Border.all(color: unlocked ? color.withValues(alpha: .55) : VirilColors.line)),
      child: Theme(
        data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: epochIndex == GlobalLeagueData.epochIndexForLeague(currentLeagueIndex),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Icon(completed ? Icons.check_circle_rounded : unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
            color: completed ? VirilColors.gold : unlocked ? color : VirilColors.muted),
          title: Text(epoch.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .5)),
          subtitle: Text(epoch.subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
          children: [for (var i = 0; i < epoch.leagues.length; i++)
            _leagueRow(start + i, epoch.leagues[i], currentLeagueIndex, currentLevel)],
        ),
      ),
    );
  }

  Widget _leagueRow(int index, String name, int currentLeagueIndex, int currentLevel) {
    final isCurrent = index == currentLeagueIndex;
    final color = GlobalLeagueData.colorForLeague(index);
    final firstLevel = index * 3 + 1;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: .12) : Colors.black.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCurrent ? color.withValues(alpha: .8) : VirilColors.line.withValues(alpha: .65)),
      ),
      child: Column(children: [
        Row(children: [
          SizedBox(width: 28, child: Text('${index + 1}'.padLeft(2, '0'), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11))),
          Expanded(child: Text(name, style: TextStyle(color: isCurrent ? color : Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
          if (isCurrent) const Text('ТЫ ЗДЕСЬ', style: TextStyle(color: VirilColors.gold, fontSize: 8, fontWeight: FontWeight.w900))
          else if (index < currentLeagueIndex) const Icon(Icons.check_circle_rounded, color: VirilColors.gold, size: 16)
          else const Icon(Icons.lock_outline_rounded, color: VirilColors.muted, size: 15),
        ]),
        const SizedBox(height: 8),
        Row(children: [for (var tier = 1; tier <= 3; tier++) ...[
          Expanded(child: _levelChip(firstLevel + tier - 1, tier, currentLevel, color)),
          if (tier != 3) const SizedBox(width: 5),
        ]]),
      ]),
    );
  }

  Widget _levelChip(int globalLevel, int tier, int currentLevel, Color color) {
    final done = globalLevel < currentLevel;
    final current = globalLevel == currentLevel;
    final requiredXp = GlobalLeagueData.xpAtLevel(globalLevel);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
      decoration: BoxDecoration(
        color: done ? VirilColors.gold.withValues(alpha: .14) : current ? color.withValues(alpha: .18) : Colors.white.withValues(alpha: .025),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: current ? color : done ? VirilColors.gold.withValues(alpha: .35) : VirilColors.line.withValues(alpha: .6)),
      ),
      child: Column(children: [
        Icon(done ? Icons.check_rounded : current ? Icons.circle : Icons.lock_outline_rounded,
          color: done ? VirilColors.gold : current ? color : VirilColors.muted, size: 12),
        const SizedBox(height: 3),
        Text('УР. $tier', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900,
          color: current ? color : done ? VirilColors.gold : VirilColors.muted)),
        Text('${requiredXp} XP', style: const TextStyle(fontSize: 7, color: VirilColors.muted)),
      ]),
    );
  }
}
