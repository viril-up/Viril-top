import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/data/viril_store.dart';
import '../../core/models/viril_task.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import 'diary_tools_card.dart';
import 'tools_screen.dart';
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
  static const _widgetsPreferenceKey = 'viril.home.widgets.v1';
  bool _showLevel = true;
  bool _showGoals = true;
  bool _showDiary = true;
  bool _showTools = true;

  @override
  void initState() {
    super.initState();
    _loadWidgetPreferences();
  }

  Future<void> _loadWidgetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_widgetsPreferenceKey);
    if (!mounted || saved == null) return;
    setState(() {
      _showLevel = saved.contains('level');
      _showGoals = saved.contains('goals');
      _showDiary = saved.contains('diary');
      _showTools = saved.contains('tools');
    });
  }

  Future<void> _saveWidgetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = <String>[
      if (_showLevel) 'level',
      if (_showGoals) 'goals',
      if (_showDiary) 'diary',
      if (_showTools) 'tools',
    ];
    await prefs.setStringList(_widgetsPreferenceKey, enabled);
  }

  Future<void> _showWidgetsSheet() async {
    var level = _showLevel;
    var goals = _showGoals;
    var diary = _showDiary;
    var tools = _showTools;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 340),
        reverseDuration: Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      backgroundColor: VirilColors.stone,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        side: BorderSide(color: VirilColors.line),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, refresh) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 38, height: 4, decoration: BoxDecoration(
                color: VirilColors.goldSoft, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.dashboard_customize_rounded, color: VirilColors.gold),
                const SizedBox(width: 9),
                const Expanded(child: Text('Виджеты главной', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900))),
                TextButton(onPressed: () => refresh(() {
                  level = true; goals = true; diary = true; tools = true;
                }), child: const Text('Сбросить')),
              ]),
              const SizedBox(height: 5),
              const Align(alignment: Alignment.centerLeft, child: Text(
                'Выбери, какие блоки показывать на рабочем столе',
                style: TextStyle(color: VirilColors.muted, fontSize: 11))),
              const SizedBox(height: 10),
              _widgetSwitch('Уровень, лига и эпоха', 'XP и текущий уровень',
                Icons.military_tech_rounded, level, (v) => refresh(() => level = v)),
              _widgetSwitch('Мои цели', 'Задачи на день, неделю, месяц и год',
                Icons.flag_rounded, goals, (v) => refresh(() => goals = v)),
              _widgetSwitch('Дневник', 'Личные записи и рефлексия',
                Icons.menu_book_rounded, diary, (v) => refresh(() => diary = v)),
              _widgetSwitch('Инструменты', 'Дополнительные инструменты Viril',
                Icons.build_circle_rounded, tools, (v) => refresh(() => tools = v)),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: () async {
                  setState(() {
                    _showLevel = level;
                    _showGoals = goals;
                    _showDiary = diary;
                    _showTools = tools;
                  });
                  await _saveWidgetPreferences();
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                child: const Text('Сохранить настройки'),
              )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _widgetSwitch(String title, String subtitle, IconData icon,
      bool value, ValueChanged<bool> onChanged) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    value: value,
    onChanged: onChanged,
    secondary: Icon(icon, color: VirilColors.gold, size: 21),
    title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
    subtitle: Text(subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
  );

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
                if (_showLevel) ...[
                  SizedBox(height: gap),
                  _levelBar(store),
                ],
                if (_showGoals) ...[
                  SizedBox(height: gap),
                  Expanded(child: _goalsCard(store, compact)),
                ] else
                  Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.dashboard_customize_rounded, color: VirilColors.gold.withValues(alpha: .7), size: 32),
                    const SizedBox(height: 8),
                    const Text('Рабочий стол настроен', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Добавь нужные блоки через «Виджеты»', textAlign: TextAlign.center,
                      style: TextStyle(color: VirilColors.muted, fontSize: 11)),
                  ]))),
                if (_showDiary || _showTools) ...[
                  SizedBox(height: gap),
                  Row(children: [
                    if (_showDiary) Expanded(child: DiaryToolsCard(onTap: _openDiary)),
                    if (_showDiary && _showTools) const SizedBox(width: 8),
                    if (_showTools) Expanded(child: ToolsLauncherCard(onTap: _openTools)),
                  ]),
                ],
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
      return SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Row(
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
                  Flexible(
                    child: Text(profile.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                  decoration: BoxDecoration(color: VirilColors.stone, borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: VirilColors.line)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.local_fire_department_rounded, color: VirilColors.lava, size: 18),
                    const SizedBox(width: 4),
                    Text('${store.activeDaysStreak}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: VirilColors.gold.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: VirilColors.gold.withValues(alpha: .42)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.toll_rounded, color: VirilColors.gold, size: 17),
                    const SizedBox(width: 4),
                    Text('${store.vcoins}', style: const TextStyle(
                      color: VirilColors.gold, fontSize: 12, fontWeight: FontWeight.w900)),
                  ]),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Виджеты главной',
                  child: Material(
                    color: VirilColors.stone,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: VirilColors.goldSoft)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: _showWidgetsSheet,
                      child: const SizedBox(width: 40, height: 40,
                        child: Icon(Icons.dashboard_customize_rounded, color: VirilColors.gold, size: 19)),
                    ),
                  ),
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
            ),
          ],
        ));
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
          backgroundColor: VirilColors.line,
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


  Future<void> _showAddGoalDialog() async {
    final controller = TextEditingController();
    var reward = 5;
    var goalPeriod = _period;
    var priority = false;
    DateTime? plannedStartAt;
    DateTime? plannedEndAt;

    bool hasCalendarDate(DateTime? value) => value != null && value.year != 2000;
    int? minutesOf(DateTime? value) => value == null || (value.year != 2000 && value.hour == 0 && value.minute == 0) ? null : value.hour * 60 + value.minute;

    String dateLabel(DateTime? value) {
      if (value == null || !hasCalendarDate(value)) return 'Не задана';
      return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
    }

    String timeLabel(DateTime? value) {
      if (value == null || (value.year != 2000 && value.hour == 0 && value.minute == 0)) return 'Выбрать время';
      return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    }

    Future<DateTime?> pickDate(
      BuildContext pickerContext,
      DateTime? current, {
      required bool isEnd,
    }) async {
      final initial = hasCalendarDate(current)
          ? current!
          : (isEnd && hasCalendarDate(plannedStartAt)
              ? plannedStartAt!
              : DateTime.now());
      final picked = await showDatePicker(
        context: pickerContext,
        initialDate: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        helpText: isEnd ? 'Дата завершения' : 'Дата начала',
      );
      if (picked == null) return null;
      final minutes = minutesOf(current);
      return DateTime(picked.year, picked.month, picked.day,
          minutes == null ? 0 : minutes ~/ 60,
          minutes == null ? 0 : minutes % 60);
    }

    Future<DateTime?> pickTime(
      BuildContext pickerContext,
      DateTime? current, {
      required bool isEnd,
    }) async {
      final existingMinutes = minutesOf(current);
      final initialTime = TimeOfDay(
        hour: existingMinutes == null ? (isEnd ? 10 : 9) : existingMinutes ~/ 60,
        minute: existingMinutes == null ? 0 : existingMinutes % 60,
      );
      final picked = await showTimePicker(
        context: pickerContext,
        initialTime: initialTime,
        helpText: isEnd ? 'ВРЕМЯ ЗАВЕРШЕНИЯ' : 'ВРЕМЯ НАЧАЛА',
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              primary: VirilColors.gold,
              surface: VirilColors.stone,
              onSurface: VirilColors.text,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: VirilColors.stone),
          ),
          child: child!,
        ),
      );
      if (picked == null) return null;
      final date = hasCalendarDate(current) ? current! : DateTime(2000, 1, 1);
      return DateTime(date.year, date.month, date.day, picked.hour, picked.minute);
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VirilColors.stone,
          title: const Text('Новая цель'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 14),
                const Text('СРОКИ ДОСТИЖЕНИЯ · НЕОБЯЗАТЕЛЬНО',
                  style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await pickDate(dialogContext, plannedStartAt, isEnd: false);
                      if (picked != null) setDialogState(() => plannedStartAt = picked);
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 17),
                    label: Text('Дата начала: ${dateLabel(plannedStartAt)}'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await pickTime(dialogContext, plannedStartAt, isEnd: false);
                      if (picked != null) setDialogState(() => plannedStartAt = picked);
                    },
                    icon: const Icon(Icons.schedule_rounded, size: 17),
                    label: Text('Время начала: ${timeLabel(plannedStartAt)}'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await pickDate(dialogContext, plannedEndAt, isEnd: true);
                      if (picked != null) setDialogState(() => plannedEndAt = picked);
                    },
                    icon: const Icon(Icons.flag_outlined, size: 17),
                    label: Text('Дата завершения: ${dateLabel(plannedEndAt)}'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await pickTime(dialogContext, plannedEndAt, isEnd: true);
                      if (picked != null) setDialogState(() => plannedEndAt = picked);
                    },
                    icon: const Icon(Icons.alarm_rounded, size: 17),
                    label: Text('Время завершения: ${timeLabel(plannedEndAt)}'),
                  ),
                  if (plannedStartAt != null || plannedEndAt != null)
                    TextButton.icon(
                      onPressed: () => setDialogState(() {
                        plannedStartAt = null;
                        plannedEndAt = null;
                      }),
                      icon: const Icon(Icons.close_rounded, size: 15),
                      label: const Text('Очистить сроки'),
                    ),
                ]),
                const SizedBox(height: 5),
                const Text('Дату и время можно задавать независимо. Например, только 09:00–10:00.',
                  style: TextStyle(color: VirilColors.muted, fontSize: 10)),
                const SizedBox(height: 12),
                const Text('НАГРАДА', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, children: [
                  ChoiceChip(label: const Text('5 XP'), selected: reward == 5, onSelected: (_) => setDialogState(() => reward = 5)),
                  ChoiceChip(label: const Text('10 XP'), selected: reward == 10, onSelected: (_) => setDialogState(() => reward = 10)),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                final startHasDate = hasCalendarDate(plannedStartAt);
                final endHasDate = hasCalendarDate(plannedEndAt);
                if (startHasDate && endHasDate &&
                    plannedEndAt!.isBefore(DateTime(plannedStartAt!.year, plannedStartAt!.month, plannedStartAt!.day))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Дата завершения не может быть раньше даты начала')),
                  );
                  return;
                }
                if (!startHasDate && !endHasDate && plannedStartAt != null && plannedEndAt != null &&
                    !plannedEndAt!.isAfter(plannedStartAt!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Время завершения должно быть позже времени начала')),
                  );
                  return;
                }
                await VirilStore.instance.addTask(
                  controller.text, 'Личная цель', period: goalPeriod, xpReward: reward,
                  isPriority: goalPeriod == 'day' && priority,
                  plannedStartAt: plannedStartAt,
                  plannedEndAt: plannedEndAt,
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

  void _openDiary() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const DiaryToolsPage(),
    ));
  }

  void _openTools() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const ToolsScreen(),
    ));
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

String _formatTaskDate(DateTime value) {
  final time = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  if (value.year == 2000) return 'Время $time';
  final date = '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
  return value.hour == 0 && value.minute == 0 ? date : '$date $time';
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
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                decoration: task.completed ? TextDecoration.lineThrough : null,
                color: task.completed ? VirilColors.muted : VirilColors.text,
              )),
            if (task.plannedStartAt != null || task.plannedEndAt != null) ...[
              const SizedBox(height: 3),
              Text([
                if (task.plannedStartAt != null) 'Старт ${_formatTaskDate(task.plannedStartAt!)}',
                if (task.plannedEndAt != null) 'До ${_formatTaskDate(task.plannedEndAt!)}',
              ].join('  ·  '), maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: VirilColors.gold, fontWeight: FontWeight.w600)),
            ],
          ],
        )),
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

