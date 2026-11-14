import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../habits/data/habit_store.dart';
import '../goals/data/goal_store.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/metric_tile.dart';

enum _ProgressRange { week, month, year }

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  _ProgressRange _range = _ProgressRange.week;
  DateTime _selectedDay = DateTime.now();

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
  DateTime _rangeStart(DateTime now) {
    final today = _dateOnly(now);
    switch (_range) {
      case _ProgressRange.week: return today.subtract(const Duration(days: 6));
      case _ProgressRange.month: return today.subtract(const Duration(days: 29));
      case _ProgressRange.year: return DateTime(now.year, 1, 1);
    }
  }

  DateTime _rangeEnd(DateTime now) => _range == _ProgressRange.year
      ? DateTime(now.year, now.month, now.day) : _dateOnly(now);

  int _periodPercent(VirilStore store, DateTime now, int days) {
    final end = _dateOnly(now);
    return store.averagePercent(end.subtract(Duration(days: days - 1)), end);
  }

  @override
  void initState() {
    super.initState();
    VirilStore.instance.initialize();
    HabitStore.instance.initialize();
    GoalStore.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final store = VirilStore.instance;
    final habits = HabitStore.instance;
    final goals = GoalStore.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([store, habits, goals]),
      builder: (context, _) {
        final now = DateTime.now();
        final start = _rangeStart(now);
        final end = _rangeEnd(now);
        final days = <DateTime>[];
        for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
          days.add(d);
        }
        if (_range == _ProgressRange.year) {
          days
            ..clear();
          for (var month = 1; month <= now.month; month++) {
            days.add(DateTime(now.year, month, 1));
          }
        }
        final selected = _dateOnly(_selectedDay);
        final selectedTasks = store.completedOn(selected);
        final selectedXp = store.xpForDay(selected);
        final week = _periodPercent(store, now, 7);
        final monthStart = DateTime(now.year, now.month, 1);
        final monthValue = store.averagePercent(monthStart, _dateOnly(now));
        final yearValue = store.averagePercent(DateTime(now.year, 1, 1), _dateOnly(now));
        final league = _leagueFor(store.xp);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            const SectionTitle('Прогресс', subtitle: 'Твой путь в цифрах — день за днём'),
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Сегодня', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: VirilColors.ice.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                  child: Text('${store.todayPercent}% дня', style: const TextStyle(color: VirilColors.ice, fontSize: 11, fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${store.todayXp}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, height: 1)),
                  const SizedBox(height: 4),
                  const Text('XP заработано сегодня', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('УРОВЕНЬ ${store.level}', style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w800, fontSize: 11)),
                  const SizedBox(height: 5),
                  Text(league, style: const TextStyle(color: VirilColors.ice, fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ]),
              const SizedBox(height: 13),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                value: store.todayPercent / 100, minHeight: 9,
                backgroundColor: VirilColors.line,
                valueColor: const AlwaysStoppedAnimation(VirilColors.ice),
              )),
              const SizedBox(height: 7),
              const Text('1 XP = 1% успешности дня, максимум 100%.', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
            ])),
            const SizedBox(height: 14),
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Динамика активности', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Нажми на столбец, чтобы открыть итоги дня', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
              const SizedBox(height: 14),
              SegmentedButton<_ProgressRange>(
                segments: const [
                  ButtonSegment(value: _ProgressRange.week, label: Text('7 дней')),
                  ButtonSegment(value: _ProgressRange.month, label: Text('30 дней')),
                  ButtonSegment(value: _ProgressRange.year, label: Text('Год')),
                ],
                selected: {_range},
                showSelectedIcon: false,
                onSelectionChanged: (value) => setState(() {
                  _range = value.first;
                  _selectedDay = _dateOnly(DateTime.now());
                }),
              ),
              const SizedBox(height: 18),
              SizedBox(height: 158, child: _ActivityChart(
                dates: days,
                values: [for (final date in days) _range == _ProgressRange.year
                  ? _monthAverage(store, date, now)
                  : store.percentForDay(date)],
                selected: _selectedDay,
                monthly: _range == _ProgressRange.year,
                onSelect: (date) => setState(() => _selectedDay = date),
              )),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _PeriodScore(label: 'Неделя', value: week)),
                const SizedBox(width: 8),
                Expanded(child: _PeriodScore(label: 'Месяц', value: monthValue)),
                const SizedBox(width: 8),
                Expanded(child: _PeriodScore(label: 'Год', value: yearValue)),
              ]),
              const SizedBox(height: 12),
              Text(_range == _ProgressRange.year
                ? 'Годовая оценка — среднее значение завершённых календарных дней с января по сегодня.'
                : 'Оценка периода — среднее значение дневных процентов. День без XP учитывается как 0%.',
                style: const TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4)),
            ])),
            const SizedBox(height: 14),
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Итоги выбранного дня', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                TextButton(onPressed: () => setState(() => _selectedDay = _dateOnly(DateTime.now())),
                  child: const Text('Сегодня', style: TextStyle(fontSize: 10))),
              ]),
              Text(_formatDate(_selectedDay), style: const TextStyle(color: VirilColors.ice, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 9),
              Row(children: [
                Expanded(child: MetricTile(value: '$selectedXp XP', label: 'ЗАРАБОТАНО')),
                const SizedBox(width: 8),
                Expanded(child: MetricTile(value: '${selectedXp.clamp(0, 100)}%', label: 'УСПЕШНОСТЬ')),
                const SizedBox(width: 8),
                Expanded(child: MetricTile(value: '${selectedTasks.length}', label: 'ЗАДАНИЙ')),
              ]),
              const SizedBox(height: 12),
              if (selectedTasks.isEmpty && selectedXp == 0)
                const Text('За этот день пока нет записанной активности.', style: TextStyle(color: VirilColors.muted, fontSize: 11))
              else ...[
                const Text('ВЫПОЛНЕНО', style: TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                ...selectedTasks.map((task) => _HistoryRow(
                  icon: Icons.check_circle_rounded, title: task.title,
                  subtitle: '${task.domain} · +${task.xpReward} XP')),
                if (selectedXp > selectedTasks.fold<int>(0, (sum, task) => sum + task.xpReward))
                  const _HistoryRow(icon: Icons.bolt_rounded, title: 'Дополнительный опыт', subtitle: 'В том числе награды за привычки'),
              ],
            ])),
            const SizedBox(height: 14),
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Баланс развития', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('100 уровней в каждом направлении', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
              const SizedBox(height: 13),
              _DomainLevel(label: 'Физический', icon: Icons.fitness_center_rounded, color: VirilColors.lava, level: store.domainLevel('Физическое')),
              _DomainLevel(label: 'Ментальный', icon: Icons.psychology_alt_rounded, color: VirilColors.ice, level: store.domainLevel('Ментальное')),
              _DomainLevel(label: 'Интеллектуальный', icon: Icons.auto_stories_rounded, color: VirilColors.gold, level: store.domainLevel('Интеллект')),
              _DomainLevel(label: 'Духовный', icon: Icons.spa_rounded, color: VirilColors.violet, level: store.domainLevel('Духовное')),
            ])),
            const SizedBox(height: 14),
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Дисциплина и привычки', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text('Маленькие действия, которые создают устойчивость', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: MetricTile(value: '${habits.totalCompletions}', label: 'ОТМЕТОК')),
                const SizedBox(width: 8),
                Expanded(child: MetricTile(value: '${habits.bestStreak}', label: 'ЛУЧШАЯ СЕРИЯ')),
                const SizedBox(width: 8),
                Expanded(child: MetricTile(value: '${habits.activeHabits}', label: 'ПРИВЫЧЕК')),
              ]),
              const SizedBox(height: 10),
              _Achievement(icon: Icons.local_fire_department_rounded, title: 'Неделя дисциплины', description: 'Серия из 7 дней', unlocked: habits.bestStreak >= 7),
              _Achievement(icon: Icons.repeat_rounded, title: 'Ритм создан', description: '30 отметок привычек', unlocked: habits.totalCompletions >= 30),
            ])),
            const SizedBox(height: 14),
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Цели и результаты', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text('Твой прогресс в долгосрочных планах', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: MetricTile(value: '${goals.inProgressGoals.length}', label: 'В ПРОЦЕССЕ')),
                const SizedBox(width: 8),
                Expanded(child: MetricTile(value: '${goals.completedGoals}', label: 'ЗАВЕРШЕНО')),
                const SizedBox(width: 8),
                Expanded(child: MetricTile(value: '${goals.averageProgress}%', label: 'СРЕДНИЙ ПРОГРЕСС')),
              ]),
              const SizedBox(height: 10),
              _Achievement(icon: Icons.flag_circle_rounded, title: 'Первая цель', description: 'Заверши первую цель', unlocked: goals.completedGoals >= 1),
              _Achievement(icon: Icons.emoji_events_rounded, title: 'Три победы', description: 'Заверши три цели', unlocked: goals.completedGoals >= 3),
              if (goals.completedHistory.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('ПОСЛЕДНИЕ ЗАВЕРШЕНИЯ', style: TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
                ...goals.completedHistory.take(3).map((goal) => _HistoryRow(
                  icon: Icons.verified_rounded, title: goal.title,
                  subtitle: _formatDate(goal.completedAt!))),
              ],
            ])),
            const SizedBox(height: 14),
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Твои достижения', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _Achievement(icon: Icons.flag_rounded, title: 'Первый шаг', description: 'Создай первый план', unlocked: store.tasks.isNotEmpty),
              _Achievement(icon: Icons.check_circle_rounded, title: 'Действие важнее намерения', description: 'Выполни первую задачу', unlocked: store.completedCount >= 1),
              _Achievement(icon: Icons.bolt_rounded, title: 'Сотня опыта', description: 'Набери 100 XP', unlocked: store.xp >= 100),
              _Achievement(icon: Icons.military_tech_rounded, title: 'Постоянство', description: 'Выполни 10 задач', unlocked: store.completedCount >= 10),
              _Achievement(icon: Icons.calendar_month_rounded, title: '30 активных дней', description: 'Отметь активность в 30 разных днях', unlocked: store.activeDaysCount >= 30),
            ])),
            const SizedBox(height: 12),
            const Text('История XP и активности хранится на устройстве. Новые отметки начнут собирать точную дневную статистику.', style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4)),
          ],
        );
      },
    );
  }

  static int _monthAverage(VirilStore store, DateTime month, DateTime now) {
    final start = DateTime(month.year, month.month, 1);
    final last = month.month == now.month && month.year == now.year
        ? DateTime(now.year, now.month, now.day)
        : DateTime(month.year, month.month + 1, 0);
    return store.averagePercent(start, last);
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  static String _leagueFor(int xp) {
    if (xp >= 2000) return 'Обсидиан';
    if (xp >= 1000) return 'Золото';
    if (xp >= 500) return 'Серебро';
    return 'Бронза';
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.dates, required this.values, required this.selected, required this.monthly, required this.onSelect});
  final List<DateTime> dates;
  final List<int> values;
  final DateTime selected;
  final bool monthly;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty) return const SizedBox.shrink();
    final step = monthly ? 1 : (dates.length > 14 ? 4 : 1);
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final slot = width / dates.length;
      return Column(children: [
        Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var i = 0; i < dates.length; i++)
            Expanded(child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(dates[i]),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('${values[i]}', style: TextStyle(fontSize: dates.length > 14 ? 7 : 9, color: _sameDay(dates[i], selected) ? VirilColors.gold : VirilColors.muted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Expanded(child: Align(alignment: Alignment.bottomCenter, child: Container(
                  width: math.max(3.0, slot * (dates.length > 14 ? .58 : .52)),
                  height: math.max(3.0, 92 * values[i] / 100),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                    color: _sameDay(dates[i], selected) ? VirilColors.gold : (values[i] == 0 ? VirilColors.line : VirilColors.ice.withValues(alpha: .75)),
                  ),
                ))),
                const SizedBox(height: 5),
                Text(monthly ? '${dates[i].month}' : (i % step == 0 ? '${dates[i].day}' : ''),
                  style: const TextStyle(fontSize: 8, color: VirilColors.muted)),
              ]),
            )),
        ])),
        const SizedBox(height: 4),
        Row(children: const [
          Text('0%', style: TextStyle(color: VirilColors.muted, fontSize: 8)),
          Spacer(),
          Text('100%', style: TextStyle(color: VirilColors.muted, fontSize: 8)),
        ]),
      ]);
    });
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _PeriodScore extends StatelessWidget {
  const _PeriodScore({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    decoration: BoxDecoration(color: VirilColors.stoneLight.withValues(alpha: .55), borderRadius: BorderRadius.circular(13)),
    child: Column(children: [
      Text('$value%', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: VirilColors.ice)),
      Text(label, style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
    ]),
  );
}

class _DomainLevel extends StatelessWidget {
  const _DomainLevel({required this.label, required this.icon, required this.color, required this.level});
  final String label;
  final IconData icon;
  final Color color;
  final int level;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(children: [
      Icon(icon, color: color, size: 19),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
      Text('Ур. $level / 100', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
      const SizedBox(width: 9),
      SizedBox(width: 64, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
        value: level / 100, minHeight: 6, backgroundColor: VirilColors.line,
        valueColor: AlwaysStoppedAnimation(color),
      ))),
    ]),
  );
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Icon(icon, color: VirilColors.ice, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
      Text(subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
    ]),
  );
}

class _Achievement extends StatelessWidget {
  const _Achievement({required this.icon, required this.title, required this.description, required this.unlocked});
  final IconData icon;
  final String title;
  final String description;
  final bool unlocked;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(
        color: (unlocked ? VirilColors.gold : VirilColors.stoneLight).withValues(alpha: .16),
        borderRadius: BorderRadius.circular(12), border: Border.all(color: unlocked ? VirilColors.gold.withValues(alpha: .45) : VirilColors.line),
      ), child: Icon(icon, color: unlocked ? VirilColors.gold : VirilColors.muted, size: 18)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: unlocked ? VirilColors.text : VirilColors.muted, fontSize: 11)),
        Text(description, style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
      ])),
      Icon(unlocked ? Icons.check_circle : Icons.lock_outline, color: unlocked ? VirilColors.ice : VirilColors.muted, size: 17),
    ]),
  );
}
