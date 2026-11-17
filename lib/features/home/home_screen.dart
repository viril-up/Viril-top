import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/models/viril_task.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import 'diary_tools_card.dart';
import '../profile/data/profile_store.dart';
import '../profile/data/global_league_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenProfile});
  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _period = 'day';

  static const _periods = <String, String>{
    'day': 'День',
    'week': 'Неделя',
    'month': 'Месяц',
    'year': 'Год',
  };

  @override
  Widget build(BuildContext context) {
    final store = VirilStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 650;
          final gap = compact ? 7.0 : 10.0;
          return Padding(
            padding: EdgeInsets.fromLTRB(16, compact ? 3 : 7, 0, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(store),
                SizedBox(height: gap),
                _levelBar(store),
                SizedBox(height: gap),
                Expanded(child: _goalsCard(store, compact)),
                SizedBox(height: gap),
                DiaryToolsCard(compact: compact),
                SizedBox(height: gap),
                _toolsCard(compact),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topBar(VirilStore store) => AnimatedBuilder(
    animation: ProfileStore.instance,
    builder: (context, _) {
      final profile = ProfileStore.instance;
      return Row(
        children: [
          Tooltip(
            message: 'Профиль · ${profile.name}',
            child: Material(
              color: VirilColors.stone,
              shape: const CircleBorder(side: BorderSide(color: VirilColors.gold)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onOpenProfile ?? () => _showInfo('Профиль', 'Открой вкладку «Профиль» в нижней панели.'),
                child: SizedBox(width: 42, height: 42, child: Icon(profile.avatarIcon, color: VirilColors.gold, size: 22)),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Flexible(child: Text(profile.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(15),
              border: Border.all(color: VirilColors.line)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.local_fire_department_rounded, color: VirilColors.gold, size: 18),
              const SizedBox(width: 4),
              Text('${store.activeDaysStreak}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ]),
          ),
          const SizedBox(width: 6),
          Tooltip(
            message: 'Уведомления',
            child: Material(
              color: VirilColors.stone,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: VirilColors.line)),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _showInfo('Уведомления', 'Центр уведомлений будет подключён на следующем этапе.'),
                child: const SizedBox(width: 40, height: 40,
                  child: Icon(Icons.notifications_none_rounded, color: VirilColors.ice, size: 20)),
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _levelBar(VirilStore store) {
    final leagueIndex = GlobalLeagueData.leagueIndexForXp(store.xp);
    final epochIndex = GlobalLeagueData.epochIndexForLeague(leagueIndex);
    final epoch = GlobalLeagueData.epochs[epochIndex];
    final leagueName = GlobalLeagueData.allLeagues[leagueIndex];
    return GlassCard(
    radius: 18,
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.shield_moon_rounded, color: VirilColors.gold, size: 18),
        const SizedBox(width: 6),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${epoch.name.split('—').first.trim()}',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: VirilColors.gold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .8)),
          Text('${leagueName.toUpperCase()} ЛИГА',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: VirilColors.text, fontSize: 11, fontWeight: FontWeight.w900)),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('УРОВЕНЬ ${store.level}', style: const TextStyle(
            color: VirilColors.ice, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1,
          )),
          Text('${store.xp} XP', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ]),
      ]),
      const SizedBox(height: 7),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: store.levelProgress / 100,
          minHeight: 6,
          backgroundColor: const Color(0xFF30394B),
          valueColor: const AlwaysStoppedAnimation(VirilColors.ice),
        ),
      ),
      const SizedBox(height: 4),
      Text('${100 - store.levelProgress} XP до следующего уровня',
        style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
    ]),
  );
  }

  Widget _goalsCard(VirilStore store, bool compact) {
    final goals = _period == 'day'
      ? store.dailyTasksFor(DateTime.now())
      : store.tasks.where((task) => task.period == _period).toList();
    return GlassCard(
      radius: 22,
      padding: EdgeInsets.all(compact ? 11 : 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Expanded(child: Text('Мои цели', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
          Text('${goals.where((task) => !task.completed).length} активные',
            style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
          const SizedBox(width: 7),
          Material(
            color: VirilColors.ice.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showAddGoalDialog,
              child: const Padding(
                padding: EdgeInsets.all(7),
                child: Icon(Icons.add_rounded, color: VirilColors.ice, size: 22),
              ),
            ),
          ),
        ]),
        SizedBox(height: compact ? 8 : 11),
        Row(children: [
          for (final entry in _periods.entries)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _periodButton(entry.key, entry.value),
              ),
            ),
        ]),
        SizedBox(height: compact ? 7 : 10),
        Expanded(
          child: goals.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.flag_outlined, color: VirilColors.muted.withValues(alpha: .8), size: 29),
                  const SizedBox(height: 7),
                  const Text('Здесь появятся твои цели', style: TextStyle(
                    color: VirilColors.muted, fontSize: 12, fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 3),
                  const Text('Нажми + и создай первую', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
                ]),
              )
            : ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: goals.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: VirilColors.line),
                itemBuilder: (context, index) => _GoalTile(task: goals[index]),
              ),
        ),
      ]),
    );
  }

  Widget _periodButton(String value, String label) {
    final selected = _period == value;
    return Material(
      color: selected ? VirilColors.ice.withValues(alpha: .17) : VirilColors.stoneLight.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _period = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? VirilColors.ice.withValues(alpha: .55) : VirilColors.line),
          ),
          child: Center(child: Text(label, style: TextStyle(
            fontSize: 11, fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? VirilColors.ice : VirilColors.muted,
          ))),
        ),
      ),
    );
  }

  Widget _toolsCard(bool compact) => Material(
    color: VirilColors.stone.withValues(alpha: .95),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _openPomodoro,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: compact ? 9 : 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VirilColors.lava.withValues(alpha: .34)),
        ),
        child: Row(children: [
          const Icon(Icons.grid_view_rounded, color: VirilColors.ice, size: 22),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Инструменты', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            Text('Pomodoro · 25 минут работы / 5 минут отдыха',
              style: TextStyle(color: VirilColors.muted, fontSize: 9)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: VirilColors.muted),
        ]),
      ),
    ),
  );

  Future<void> _showAddGoalDialog() async {
    final controller = TextEditingController();
    var reward = 5;
    var goalPeriod = _period;
    var priority = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VirilColors.stone,
          title: const Text('Новая цель'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 90,
              decoration: const InputDecoration(hintText: 'Напиши свою цель'),
            ),
            const SizedBox(height: 12),
            const Text('Период', style: TextStyle(color: VirilColors.muted, fontSize: 12)),
            const SizedBox(height: 7),
            Wrap(spacing: 6, children: [
              for (final entry in _periods.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: goalPeriod == entry.key,
                  onSelected: (_) => setDialogState(() => goalPeriod = entry.key),
                ),
            ]),
            if (goalPeriod == 'day') ...[
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: priority,
                activeColor: VirilColors.gold,
                title: const Text('Главная приоритетная цель', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                subtitle: const Text('Будет выделена в списке дня', style: TextStyle(fontSize: 10, color: VirilColors.muted)),
                onChanged: (value) => setDialogState(() => priority = value),
              ),
            ],
            const SizedBox(height: 12),
            const Text('Награда за выполнение', style: TextStyle(color: VirilColors.muted, fontSize: 12)),
            const SizedBox(height: 7),
            Wrap(spacing: 8, children: [
              ChoiceChip(label: const Text('5 XP'), selected: reward == 5, onSelected: (_) => setDialogState(() => reward = 5)),
              ChoiceChip(label: const Text('10 XP'), selected: reward == 10, onSelected: (_) => setDialogState(() => reward = 10)),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                await VirilStore.instance.addTask(
                  controller.text, 'Личная цель', period: goalPeriod, xpReward: reward, isPriority: goalPeriod == 'day' && priority,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  void _openPomodoro() {
    showDialog<void>(context: context, builder: (_) => const _PomodoroDialog());
  }

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VirilColors.stone,
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Понятно'))],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.task});
  final VirilTask task;

  @override
  Widget build(BuildContext context) {
    final store = VirilStore.instance;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: task.isPriority ? VirilColors.gold.withValues(alpha: .12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: task.isPriority ? Border.all(color: VirilColors.gold.withValues(alpha: .55)) : null,
      ),
      child: Row(children: [
        if (task.isPriority) const Padding(padding: EdgeInsets.only(right: 3), child: Icon(Icons.star_rounded, color: VirilColors.gold, size: 17)),
        Checkbox(
          value: task.completed,
          activeColor: const Color(0xFF43C58A),
          visualDensity: VisualDensity.compact,
          onChanged: (_) => store.toggleTask(task.id),
        ),
        Expanded(child: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? VirilColors.muted : VirilColors.text,
          ))),
        if (task.period == 'day') IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 28, height: 30),
          padding: EdgeInsets.zero,
          tooltip: task.isPriority ? 'Снять приоритет' : 'Сделать главной целью',
          onPressed: () => store.setPriorityTask(task.id),
          icon: Icon(task.isPriority ? Icons.star_rounded : Icons.star_border_rounded, size: 16,
            color: task.isPriority ? VirilColors.gold : VirilColors.muted),
        ),
        const SizedBox(width: 5),
        Text('${task.xpReward} XP', style: TextStyle(
          color: task.completed ? VirilColors.ice : VirilColors.muted,
          fontSize: 10, fontWeight: FontWeight.w800,
        )),
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
          padding: EdgeInsets.zero,
          tooltip: 'Удалить цель',
          onPressed: () => store.removeTask(task.id),
          icon: const Icon(Icons.close_rounded, size: 15, color: VirilColors.muted),
        ),
      ]),
    );
  }
}

class _PomodoroDialog extends StatefulWidget {
  const _PomodoroDialog();

  @override
  State<_PomodoroDialog> createState() => _PomodoroDialogState();
}

class _PomodoroDialogState extends State<_PomodoroDialog> {
  static const _workDuration = Duration(minutes: 25);
  static const _restDuration = Duration(minutes: 5);
  Timer? _timer;
  Duration _remaining = _workDuration;
  bool _running = false;
  bool _isWorkSession = true;
  int _completedWorkSessions = 0;

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_remaining == Duration.zero) {
      _remaining = _isWorkSession ? _workDuration : _restDuration;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        if (_isWorkSession) _completedWorkSessions++;
        setState(() {
          _isWorkSession = !_isWorkSession;
          _remaining = _isWorkSession ? _workDuration : _restDuration;
        });
        return;
      }
      if (mounted) setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remaining = _workDuration;
      _running = false;
      _isWorkSession = true;
      _completedWorkSessions = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    final phase = _isWorkSession ? 'Время для работы' : 'Время для отдыха';
    final phaseColor = _isWorkSession ? VirilColors.ice : VirilColors.gold;
    return AlertDialog(
      backgroundColor: VirilColors.stone,
      title: const Text('Pomodoro'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(phase, style: TextStyle(color: phaseColor, fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        const Text('25 минут работы · 5 минут отдыха · повторять по кругу',
          textAlign: TextAlign.center, style: TextStyle(color: VirilColors.muted, fontSize: 10)),
        const SizedBox(height: 20),
        Text('$minutes:$seconds', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('Завершено рабочих циклов: $_completedWorkSessions',
          style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
      ]),
      actions: [
        TextButton(onPressed: _reset, child: const Text('Сбросить')),
        FilledButton(onPressed: _toggle,
          child: Text(_running ? 'Пауза' : 'Старт')),
      ],
    );
  }
}
