import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/models/viril_task.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
            padding: EdgeInsets.fromLTRB(16, compact ? 3 : 7, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(store),
                SizedBox(height: gap),
                _levelBar(store),
                SizedBox(height: gap),
                Expanded(child: _goalsCard(store, compact)),
                SizedBox(height: gap),
                _personalTools(compact),
                SizedBox(height: gap),
                _pomodoroCard(compact),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topBar(VirilStore store) => Row(
    children: [
      _roundAction(
        icon: Icons.person_rounded,
        label: 'Профиль',
        onTap: () => _showInfo('Профиль', 'Открой вкладку «Профиль» в нижней панели.'),
      ),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: VirilColors.stone,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: VirilColors.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.local_fire_department_rounded, color: VirilColors.lava, size: 19),
          const SizedBox(width: 5),
          Text('${store.activeDaysStreak}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(width: 4),
          const Text('дн.', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
        ]),
      ),
      const SizedBox(width: 8),
      _roundAction(
        icon: Icons.notifications_none_rounded,
        label: 'Уведомления',
        onTap: () => _showInfo('Уведомления', 'Центр уведомлений будет подключён на следующем этапе.'),
      ),
    ],
  );

  Widget _roundAction({required IconData icon, required String label, required VoidCallback onTap}) =>
    Tooltip(
      message: label,
      child: Material(
        color: VirilColors.stone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: VirilColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: VirilColors.text, size: 21),
          ),
        ),
      ),
    );

  Widget _levelBar(VirilStore store) => GlassCard(
    radius: 18,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('УРОВЕНЬ ${store.level}', style: const TextStyle(
          color: VirilColors.ice, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1,
        )),
        const Spacer(),
        Text('${store.xp} XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
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

  Widget _goalsCard(VirilStore store, bool compact) {
    final goals = store.tasks.where((task) => task.period == _period).toList();
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

  Widget _personalTools(bool compact) => Row(children: [
    Expanded(child: _actionCard(
      icon: Icons.menu_book_rounded, label: 'Дневник\nмыслей', color: VirilColors.ice,
      onTap: () => _showTextEntry('Дневник мыслей', 'Запиши свои мысли, чувства, эмоции, переживания или идеи...', gratitude: false),
      compact: compact,
    )),
    const SizedBox(width: 7),
    Expanded(child: _actionCard(
      icon: Icons.mic_none_rounded, label: 'Записать\nаудио', color: VirilColors.violet,
      onTap: () => _showInfo('Голосовой дневник', 'Кнопка и место для функции предусмотрены. Запись и сохранение аудио подключу отдельным техническим этапом с разрешением на микрофон.'),
      compact: compact,
    )),
    const SizedBox(width: 7),
    Expanded(child: _actionCard(
      icon: Icons.favorite_border_rounded, label: 'Благодарность\nза всё', color: VirilColors.gold,
      onTap: () => _showTextEntry('Благодарность за всё', 'За что ты благодарен сегодня?', gratitude: true),
      compact: compact,
    )),
  ]);

  Widget _actionCard({
    required IconData icon, required String label, required Color color,
    required VoidCallback onTap, required bool compact,
  }) => Material(
    color: VirilColors.stone.withValues(alpha: .92),
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        height: compact ? 72 : 82,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withValues(alpha: .35)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: compact ? 21 : 23),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, maxLines: 2,
            style: const TextStyle(fontSize: 9, height: 1.15, fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
  );

  Widget _pomodoroCard(bool compact) => Material(
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
          const Icon(Icons.timer_outlined, color: VirilColors.lava, size: 23),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Инструменты · Pomodoro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            Text('Таймер для работы и концентрации', style: TextStyle(color: VirilColors.muted, fontSize: 9)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: VirilColors.muted),
        ]),
      ),
    ),
  );

  Future<void> _showAddGoalDialog() async {
    final controller = TextEditingController();
    var reward = 5;
    final selectedPeriod = _period;
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
                  selected: selectedPeriod == entry.key,
                  onSelected: null,
                ),
            ]),
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
                  controller.text, 'Личная цель', period: selectedPeriod, xpReward: reward,
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

  Future<void> _showTextEntry(String title, String hint, {required bool gratitude}) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VirilColors.stone,
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 4,
          maxLines: 7,
          maxLength: 3000,
          decoration: InputDecoration(hintText: hint, alignLabelWithHint: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              if (gratitude) {
                await VirilStore.instance.saveGratitude(controller.text);
              } else {
                await VirilStore.instance.saveJournalEntry(controller.text);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Запись сохранена')),
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Checkbox(
          value: task.completed,
          activeColor: VirilColors.ice,
          visualDensity: VisualDensity.compact,
          onChanged: (_) => store.toggleTask(task.id),
        ),
        Expanded(child: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? VirilColors.muted : VirilColors.text,
          ))),
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
  static const _duration = Duration(minutes: 25);
  Timer? _timer;
  Duration _remaining = _duration;
  bool _running = false;

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() { _remaining = Duration.zero; _running = false; });
        return;
      }
      if (mounted) setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() { _remaining = _duration; _running = false; });
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
    return AlertDialog(
      backgroundColor: VirilColors.stone,
      title: const Text('Pomodoro'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Время для сосредоточенной работы', style: TextStyle(color: VirilColors.muted, fontSize: 12)),
        const SizedBox(height: 20),
        Text('$minutes:$seconds', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(_remaining == Duration.zero ? 'Сессия завершена!' : '25 минут работы',
          style: const TextStyle(color: VirilColors.ice, fontSize: 12)),
      ]),
      actions: [
        TextButton(onPressed: _reset, child: const Text('Сбросить')),
        FilledButton(onPressed: _remaining == Duration.zero ? _reset : _toggle,
          child: Text(_remaining == Duration.zero ? 'Ещё раз' : _running ? 'Пауза' : 'Старт')),
      ],
    );
  }
}
