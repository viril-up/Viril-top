import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import 'data/goal_store.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _titleController = TextEditingController();
  final _stepController = TextEditingController();
  int _duration = 30;
  DateTime? _plannedStartAt;
  DateTime? _plannedEndAt;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    GoalStore.instance.initialize();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  Future<void> _createGoal() async {
    _titleController.clear();
    _duration = 30;
    _plannedStartAt = null;
    _plannedEndAt = null;

    Future<DateTime?> pickDate(BuildContext pickerContext, DateTime? current, {required bool isEnd}) async {
      final now = DateTime.now();
      final initial = current ?? (isEnd
          ? (_plannedStartAt ?? now.add(const Duration(days: 1)))
          : now);
      final date = await showDatePicker(
        context: pickerContext,
        initialDate: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        helpText: isEnd ? 'Дата дедлайна' : 'Дата начала',
      );
      if (date == null) return null;
      final hour = current?.hour ?? (isEnd ? 23 : 0);
      final minute = current?.minute ?? (isEnd ? 59 : 0);
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    Future<DateTime?> pickClock(BuildContext pickerContext, DateTime current, {required bool isEnd}) async {
      DateTime selectedTime = current;
      final result = await showModalBottomSheet<DateTime>(
        context: pickerContext,
        backgroundColor: VirilColors.stone,
        isScrollControlled: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          side: BorderSide(color: VirilColors.line),
        ),
        builder: (sheetContext) => SizedBox(
          height: 300,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 10, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEnd ? 'Время дедлайна' : 'Время начала',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext, selectedTime),
                        child: const Text('Готово'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: VirilColors.line),
                Expanded(
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.dark,
                      primaryColor: VirilColors.gold,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: VirilColors.text,
                          fontSize: 23,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: current,
                      use24hFormat: true,
                      minuteInterval: 1,
                      onDateTimeChanged: (value) => selectedTime = value,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (result == null) return null;
      return DateTime(current.year, current.month, current.day, result.hour, result.minute);
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        backgroundColor: VirilColors.stone,
        title: const Text('Новая цель'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            maxLength: 60,
            decoration: const InputDecoration(hintText: 'Например: освоить основы французского'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _duration,
            decoration: const InputDecoration(labelText: 'Срок по дням'),
            items: const [
              DropdownMenuItem(value: 7, child: Text('7 дней')),
              DropdownMenuItem(value: 30, child: Text('30 дней')),
              DropdownMenuItem(value: 90, child: Text('90 дней')),
            ],
            onChanged: (value) {
              if (value != null) setDialogState(() => _duration = value);
            },
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('РАСПИСАНИЕ ЦЕЛИ (НЕОБЯЗАТЕЛЬНО)',
              style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(_plannedStartAt == null ? 'Дата начала' : 'Дата начала: '+_date(_plannedStartAt!)),
            onPressed: () async {
              final value = await pickDate(context, _plannedStartAt, isEnd: false);
              if (value == null) return;
              setDialogState(() {
                _plannedStartAt = value;
                if (_plannedEndAt != null && !_plannedEndAt!.isAfter(value)) _plannedEndAt = null;
              });
            },
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.access_time_rounded, size: 18),
            label: Text(_plannedStartAt == null ? 'Время начала (сначала выбери дату)' : 'Время начала: '+_plannedStartAt!.hour.toString().padLeft(2, '0')+':'+_plannedStartAt!.minute.toString().padLeft(2, '0')),
            onPressed: _plannedStartAt == null ? null : () async {
              final value = await pickClock(context, _plannedStartAt!, isEnd: false);
              if (value == null) return;
              setDialogState(() {
                _plannedStartAt = value;
                if (_plannedEndAt != null && !_plannedEndAt!.isAfter(value)) _plannedEndAt = null;
              });
            },
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            icon: const Icon(Icons.event_rounded, size: 18),
            label: Text(_plannedEndAt == null ? 'Дата завершения / дедлайн' : 'Дата дедлайна: '+_date(_plannedEndAt!)),
            onPressed: () async {
              final value = await pickDate(context, _plannedEndAt, isEnd: true);
              if (value == null) return;
              if (_plannedStartAt != null && !value.isAfter(_plannedStartAt!)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Дедлайн должен быть позже времени начала')),
                );
                return;
              }
              setDialogState(() => _plannedEndAt = value);
            },
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.alarm_rounded, size: 18),
            label: Text(_plannedEndAt == null ? 'Время дедлайна (сначала выбери дату)' : 'Время дедлайна: '+_plannedEndAt!.hour.toString().padLeft(2, '0')+':'+_plannedEndAt!.minute.toString().padLeft(2, '0')),
            onPressed: _plannedEndAt == null ? null : () async {
              final value = await pickClock(context, _plannedEndAt!, isEnd: true);
              if (value == null) return;
              if (_plannedStartAt != null && !value.isAfter(_plannedStartAt!)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Дедлайн должен быть позже времени начала')),
                );
                return;
              }
              setDialogState(() => _plannedEndAt = value);
            },
          ),
          if (_plannedStartAt != null || _plannedEndAt != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setDialogState(() { _plannedStartAt = null; _plannedEndAt = null; }),
                icon: const Icon(Icons.close, size: 15),
                label: const Text('Сбросить расписание'),
              ),
            ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Создать')),
        ],
      )),
    );
    if (result == true && _titleController.text.trim().isNotEmpty) {
      await GoalStore.instance.addGoal(
        _titleController.text,
        _duration,
        plannedStartAt: _plannedStartAt,
        plannedEndAt: _plannedEndAt,
      );
    }
  }

  Future<void> _addStep(VirilGoal goal) async {
    _stepController.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VirilColors.stone,
        title: const Text('Новый этап'),
        content: TextField(
          controller: _stepController,
          autofocus: true,
          maxLength: 70,
          decoration: const InputDecoration(hintText: 'Что нужно сделать?'),
          onSubmitted: (_) => Navigator.pop(dialogContext, true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Добавить')),
        ],
      ),
    );
    if (result == true && _stepController.text.trim().isNotEmpty) {
      await GoalStore.instance.addStep(goal.id, _stepController.text);
    }
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';

  String _dateTime(DateTime value) =>
      '${_date(value)}  ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final store = GoalStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final goals = _showArchived
            ? store.goals.where((goal) => goal.isArchived).toList()
            : store.activeGoals;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
          children: [
            const SectionTitle('Мои цели', subtitle: 'Превращай большие планы в конкретные шаги'),
            GlassCard(child: Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ДВИЖЕНИЕ К РЕЗУЛЬТАТУ', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                SizedBox(height: 5),
                Text('Одна цель — много небольших побед', style: TextStyle(fontSize: 12, color: VirilColors.muted)),
              ])),
              Column(children: [
                Text('${store.activeGoals.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: VirilColors.gold)),
                const Text('АКТИВНЫХ', style: TextStyle(fontSize: 8, color: VirilColors.muted, letterSpacing: 1)),
              ]),
            ])),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: FilledButton.icon(
                onPressed: _createGoal,
                icon: const Icon(Icons.add),
                label: const Text('Создать цель'),
              )),
              const SizedBox(width: 8),
              IconButton(
                tooltip: _showArchived ? 'Активные цели' : 'Архив',
                onPressed: () => setState(() => _showArchived = !_showArchived),
                icon: Icon(_showArchived ? Icons.flag_outlined : Icons.archive_outlined, color: VirilColors.gold),
              ),
            ]),
            const SizedBox(height: 8),
            if (goals.isEmpty)
              GlassCard(child: Column(children: [
                Icon(_showArchived ? Icons.inventory_2_outlined : Icons.track_changes_rounded, color: VirilColors.gold, size: 38),
                const SizedBox(height: 10),
                Text(_showArchived ? 'Архив пока пуст' : 'Пока нет целей', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(_showArchived ? 'Завершённые или отложенные цели появятся здесь.' : 'Выбери результат, которого хочешь достичь за 7, 30 или 90 дней.', textAlign: TextAlign.center, style: const TextStyle(color: VirilColors.muted, fontSize: 12, height: 1.5)),
              ]))
            else
              ...goals.map(_goalCard),
            const SizedBox(height: 12),
            const Text('Цели и этапы сохраняются локально на этом устройстве.', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
          ],
        );
      },
    );
  }

  Widget _goalCard(VirilGoal goal) {
    final status = goal.isCompleted ? 'ЗАВЕРШЕНА' : goal.isOverdue ? 'СРОК ИСТЁК' : 'В ПРОЦЕССЕ';
    final statusColor = goal.isCompleted ? VirilColors.ice : goal.isOverdue ? VirilColors.lava : VirilColors.gold;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(status, style: TextStyle(color: statusColor, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(goal.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ])),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'archive') GoalStore.instance.archiveGoal(goal.id);
                if (value == 'delete') GoalStore.instance.deleteGoal(goal.id);
              },
              itemBuilder: (_) => [
                if (!goal.isArchived) const PopupMenuItem(value: 'archive', child: Text('В архив')),
                const PopupMenuItem(value: 'delete', child: Text('Удалить')),
              ],
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Text(goal.plannedEndAt == null ? '${goal.durationDays} дней' : 'Точный срок', style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
            const Spacer(),
            Text('${_dateTime(goal.deadline)}', style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
            const SizedBox(width: 12),
            Text('${goal.progress}%', style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w800, fontSize: 12)),
          ]),
          if (goal.plannedStartAt != null || goal.plannedEndAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                '${goal.plannedStartAt == null ? '' : 'Старт: ${_dateTime(goal.plannedStartAt!)}'}${goal.plannedStartAt != null && goal.plannedEndAt != null ? '   •   ' : ''}${goal.plannedEndAt == null ? '' : 'Финиш: ${_dateTime(goal.plannedEndAt!)}'}',
                style: const TextStyle(color: VirilColors.muted, fontSize: 10),
              ),
            ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progress / 100,
              minHeight: 8,
              backgroundColor: VirilColors.line,
              valueColor: const AlwaysStoppedAnimation(VirilColors.gold),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: Text('ЭТАПЫ', style: TextStyle(fontSize: 10, letterSpacing: 1.3, color: VirilColors.muted, fontWeight: FontWeight.w800))),
            Text('${goal.completedSteps}/${goal.steps.length}', style: const TextStyle(fontSize: 10, color: VirilColors.muted)),
            if (!goal.isArchived && !goal.isCompleted)
              TextButton.icon(onPressed: () => _addStep(goal), icon: const Icon(Icons.add, size: 16), label: const Text('Этап')),
          ]),
          if (goal.steps.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Добавь первый этап, чтобы отслеживать прогресс.', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
            )
          else
            ...goal.steps.map((step) => Row(children: [
              Checkbox(
                value: step.isDone,
                activeColor: VirilColors.gold,
                onChanged: goal.isArchived ? null : (_) => GoalStore.instance.toggleStep(goal.id, step.id),
              ),
              Expanded(child: Text(
                step.title,
                style: TextStyle(
                  fontSize: 12,
                  color: step.isDone ? VirilColors.muted : VirilColors.text,
                  decoration: step.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              )),
              if (!goal.isArchived)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Удалить этап',
                  onPressed: () => GoalStore.instance.removeStep(goal.id, step.id),
                  icon: const Icon(Icons.close, size: 16, color: VirilColors.muted),
                ),
            ])),
          if (goal.isCompleted && !goal.isArchived)
            const Text('Отличная работа! Все этапы выполнены.', style: TextStyle(color: VirilColors.ice, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
