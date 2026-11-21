import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/viril_staggered_list.dart';
import '../../core/data/viril_store.dart';
import '../profile/data/profile_store.dart';
import '../habits/data/habit_store.dart';
import '../goals/data/goal_store.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

enum _ProgressRange { week, month, year }

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  _ProgressRange _range = _ProgressRange.week;
  DateTime _selectedDay = DateTime.now();

  Widget _progressTopBar(VirilStore store) => AnimatedBuilder(
    animation: ProfileStore.instance,
    builder: (context, _) {
      final profile = ProfileStore.instance;
      return Row(children: [
        Expanded(child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: VirilColors.stone,
              shape: BoxShape.circle,
              border: Border.all(color: VirilColors.gold.withValues(alpha: .75)),
            ),
            child: Icon(profile.avatarIcon, color: VirilColors.gold, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(profile.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
        ])),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: VirilColors.stone,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VirilColors.line),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.local_fire_department_rounded, color: VirilColors.lava, size: 17),
            const SizedBox(width: 4),
            Text('${store.activeDaysStreak}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
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
            const Icon(Icons.toll_rounded, color: VirilColors.gold, size: 16),
            const SizedBox(width: 4),
            Text('${store.vcoins}', style: const TextStyle(
              color: VirilColors.gold, fontSize: 11, fontWeight: FontWeight.w900)),
          ]),
        ),
      ]);
    },
  );

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
        final selectedDailyTasks = store.dailyTasksFor(selected);
        final selectedXp = store.xpForDay(selected);
        final week = _periodPercent(store, now, 7);
        final monthStart = DateTime(now.year, now.month, 1);
        final monthValue = store.averagePercent(monthStart, _dateOnly(now));
        final yearValue = store.averagePercent(DateTime(now.year, 1, 1), _dateOnly(now));
        final league = _leagueFor(store.xp);
        return VirilStaggeredList(pageIndex: 3, 
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            _progressTopBar(store),
            const SizedBox(height: 10),
            GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Динамика развития', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
                Text('${store.todayPercent}% сегодня', style: const TextStyle(color: VirilColors.ice, fontSize: 11, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _ProgressMetric(value: '${store.todayXp} XP', label: 'СЕГОДНЯ')),
                const SizedBox(width: 7),
                Expanded(child: _ProgressMetric(value: 'Ур. ${store.level}', label: 'УРОВЕНЬ')),
                const SizedBox(width: 7),
                Expanded(child: _ProgressMetric(value: league, label: 'ЛИГА')),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                value: store.todayPercent / 100, minHeight: 6,
                backgroundColor: VirilColors.line,
                valueColor: const AlwaysStoppedAnimation(VirilColors.ice),
              )),
              const SizedBox(height: 15),
              const Text('ДИНАМИКА РАЗВИТИЯ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              const Text('Рост, снижение и периоды стабильности твоей активности', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
              const SizedBox(height: 12),
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
              const SizedBox(height: 14),
              SizedBox(height: 166, child: _ActivityChart(
                dates: days,
                values: [for (final date in days) _range == _ProgressRange.year
                  ? _monthAverage(store, date, now)
                  : store.percentForDay(date)],
                selected: _selectedDay,
                monthly: _range == _ProgressRange.year,
                onSelect: (date) => setState(() => _selectedDay = date),
              )),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _PeriodScore(label: 'Неделя', value: week)),
                const SizedBox(width: 8),
                Expanded(child: _PeriodScore(label: 'Месяц', value: monthValue)),
                const SizedBox(width: 8),
                Expanded(child: _PeriodScore(label: 'Год', value: yearValue)),
              ]),
              const Divider(color: VirilColors.line, height: 24),
              Row(children: [
                const Expanded(child: Text('История выбранного дня', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
                TextButton(onPressed: () => setState(() => _selectedDay = _dateOnly(DateTime.now())),
                  child: const Text('Сегодня', style: TextStyle(fontSize: 10))),
              ]),
              Text(_formatDate(_selectedDay), style: const TextStyle(color: VirilColors.ice, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _ProgressMetric(value: '$selectedXp XP', label: 'ОПЫТ')),
                const SizedBox(width: 7),
                Expanded(child: _ProgressMetric(value: '${selectedDailyTasks.where((t) => t.completed).length}/${selectedDailyTasks.length}', label: 'ЦЕЛИ')),
                const SizedBox(width: 7),
                Expanded(child: _ProgressMetric(value: '${selectedDailyTasks.isEmpty ? 0 : (selectedDailyTasks.where((t) => t.completed).length * 100 ~/ selectedDailyTasks.length)}%', label: 'ВЫПОЛНЕНО')),
              ]),
              if (selectedDailyTasks.isNotEmpty) ...[
                const SizedBox(height: 9),
                for (final task in selectedDailyTasks)
                  _HistoryRow(
                    icon: task.completed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: task.completed ? const Color(0xFF43C58A) : VirilColors.lava,
                    title: task.title,
                    subtitle: task.completed ? 'Выполнено · +${task.xpReward} XP' : 'Не выполнено',
                  ),
              ] else if (selectedTasks.isNotEmpty) ...[
                const SizedBox(height: 9),
                for (final task in selectedTasks)
                  _HistoryRow(icon: Icons.check_circle_rounded, title: task.title, subtitle: '${task.domain} · +${task.xpReward} XP'),
              ] else
                const Padding(padding: EdgeInsets.only(top: 8), child: Text('За этот день пока нет целей.', style: TextStyle(color: VirilColors.muted, fontSize: 10))),
              const SizedBox(height: 8),
              const Divider(color: VirilColors.line, height: 18),
              const Text('ЛИЧНЫЕ ЗАПИСИ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              ...store.journalEntries.where((entry) {
                final date = DateTime.tryParse(entry['createdAt'] ?? '');
                return date != null && store.dayKey(date) == store.dayKey(selected);
              }).map((entry) => _HistoryRow(icon: Icons.menu_book_rounded, title: 'Дневник мыслей', subtitle: (entry['text'] ?? '').replaceAll('\n', ' '))),
              ...store.gratitudeEntries.where((entry) {
                final date = DateTime.tryParse(entry['createdAt'] ?? '');
                return date != null && store.dayKey(date) == store.dayKey(selected);
              }).map((entry) => _HistoryRow(icon: Icons.favorite_rounded, title: 'Благодарность', subtitle: (entry['text'] ?? '').replaceAll('\n', ' '))),
              if (!store.journalEntries.any((entry) {
                final date = DateTime.tryParse(entry['createdAt'] ?? '');
                return date != null && store.dayKey(date) == store.dayKey(selected);
              }) && !store.gratitudeEntries.any((entry) {
                final date = DateTime.tryParse(entry['createdAt'] ?? '');
                return date != null && store.dayKey(date) == store.dayKey(selected);
              }))
                const Padding(padding: EdgeInsets.only(top: 6), child: Text('Нет записей за выбранную дату.', style: TextStyle(color: VirilColors.muted, fontSize: 10))),
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
              const Text('Твои достижения', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Награды за системную работу. Одного действия недостаточно — важны регулярность и результат.',
                style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4)),
              const SizedBox(height: 10),
              const Text('ЛЁГКИЕ ДОСТИЖЕНИЯ', style: TextStyle(
                color: VirilColors.ice, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              _Achievement(icon: Icons.flag_rounded, title: 'Начало пути',
                description: 'Создай свой первый план', unlocked: store.tasks.isNotEmpty),
              _Achievement(icon: Icons.check_circle_outline_rounded, title: 'Первое действие',
                description: 'Выполни первую задачу', unlocked: store.completedCount >= 1),
              _Achievement(icon: Icons.bolt_rounded, title: 'Первые 50 XP',
                description: 'Набери 50 очков опыта', unlocked: store.xp >= 50),
              _Achievement(icon: Icons.wb_sunny_rounded, title: 'Три дня движения',
                description: 'Будь активен 3 дня подряд', unlocked: store.activeDaysStreak >= 3),
              _Achievement(icon: Icons.repeat_rounded, title: 'Новая привычка',
                description: 'Сделай 5 отметок привычек', unlocked: habits.totalCompletions >= 5),
              _Achievement(icon: Icons.edit_note_rounded, title: 'Мысли на бумаге',
                description: 'Создай первую запись в дневнике', unlocked: store.journalEntries.isNotEmpty),
              const SizedBox(height: 12),
              const Text('СРЕДНИЕ ДОСТИЖЕНИЯ', style: TextStyle(
                color: VirilColors.gold, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              _Achievement(icon: Icons.local_fire_department_rounded, title: 'Неделя силы',
                description: 'Сохраняй активность 7 дней подряд', unlocked: store.activeDaysStreak >= 7),
              _Achievement(icon: Icons.repeat_on_rounded, title: 'Устойчивая привычка',
                description: 'Набери 30 отметок привычек', unlocked: habits.totalCompletions >= 30),
              _Achievement(icon: Icons.task_alt_rounded, title: 'Десять выполненных дел',
                description: 'Выполни 10 задач', unlocked: store.completedCount >= 10),
              _Achievement(icon: Icons.stars_rounded, title: 'Первые 500 XP',
                description: 'Набери 500 очков опыта', unlocked: store.xp >= 500),
              _Achievement(icon: Icons.flag_circle_rounded, title: 'Целеустремлённость',
                description: 'Заверши 3 долгосрочные цели', unlocked: goals.completedGoals >= 3),
              _Achievement(icon: Icons.menu_book_rounded, title: 'Осмысленный путь',
                description: 'Сохрани 10 записей в дневнике', unlocked: store.journalEntries.length >= 10),
              const SizedBox(height: 12),
              const Text('СЛОЖНЫЕ ДОСТИЖЕНИЯ', style: TextStyle(
                color: VirilColors.lava, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              _Achievement(icon: Icons.local_fire_department_rounded, title: 'Стальной характер',
                description: 'Сохраняй активность 14 дней подряд и отметь не менее 14 активных дней всего',
                unlocked: store.activeDaysStreak >= 14 && store.activeDaysCount >= 14),
              _Achievement(icon: Icons.calendar_month_rounded, title: 'Месяц в строю',
                description: 'Поддерживай непрерывную активность 30 дней подряд',
                unlocked: store.activeDaysStreak >= 30),
              _Achievement(icon: Icons.repeat_rounded, title: 'Ритм мастера',
                description: 'Набери 100 отметок привычек и серию минимум 21 день',
                unlocked: habits.totalCompletions >= 100 && habits.bestStreak >= 21),
              _Achievement(icon: Icons.task_alt_rounded, title: 'Дело за делом',
                description: 'Выполни 50 задач из своих планов',
                unlocked: store.completedCount >= 50),
              _Achievement(icon: Icons.bolt_rounded, title: 'Тысячник',
                description: 'Набери 1 000 XP и выполни не менее 30 задач',
                unlocked: store.xp >= 1000 && store.completedCount >= 30),
              _Achievement(icon: Icons.flag_circle_rounded, title: 'Стратег',
                description: 'Заверши 5 долгосрочных целей и выполни 25 их шагов',
                unlocked: goals.completedGoals >= 5 && goals.completedSteps >= 25),
              _Achievement(icon: Icons.menu_book_rounded, title: 'Глубина мысли',
                description: 'Сохрани 20 записей в дневнике мыслей',
                unlocked: store.journalEntries.length >= 20),
              _Achievement(icon: Icons.favorite_rounded, title: 'Осознанная благодарность',
                description: 'Сохрани 20 записей благодарности',
                unlocked: store.gratitudeEntries.length >= 20),
              _Achievement(icon: Icons.balance_rounded, title: 'Четыре опоры',
                description: 'Достигни 10-го уровня в физическом, ментальном, интеллектуальном и духовном направлениях',
                unlocked: store.domainLevel('Физическое') >= 10 &&
                  store.domainLevel('Ментальное') >= 10 &&
                  store.domainLevel('Интеллект') >= 10 &&
                  store.domainLevel('Духовное') >= 10),
              _Achievement(icon: Icons.workspace_premium_rounded, title: 'Легенда Viril',
                description: 'Набери 5 000 XP, 90 активных дней, выполни 100 задач, собери 150 отметок привычек и заверши 10 целей',
                unlocked: store.xp >= 5000 && store.activeDaysCount >= 90 &&
                  store.completedCount >= 100 && habits.totalCompletions >= 150 &&
                  goals.completedGoals >= 10),
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
    return LayoutBuilder(builder: (context, constraints) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final index = ((details.localPosition.dx / constraints.maxWidth) * dates.length)
          .floor().clamp(0, dates.length - 1).toInt();
        onSelect(dates[index]);
      },
      child: CustomPaint(
        size: Size(constraints.maxWidth, 166),
        painter: _MarketLinePainter(dates: dates, values: values, selected: selected, monthly: monthly),
      ),
    ));
  }
}

class _MarketLinePainter extends CustomPainter {
  _MarketLinePainter({required this.dates, required this.values, required this.selected, required this.monthly});
  final List<DateTime> dates;
  final List<int> values;
  final DateTime selected;
  final bool monthly;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 8.0, right = 8.0, top = 12.0, bottom = 25.0;
    final plot = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final grid = Paint()..color = VirilColors.line.withValues(alpha: .8)..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = plot.top + plot.height * i / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      final label = TextPainter(
        text: TextSpan(text: '${100 - i * 25}', style: const TextStyle(color: VirilColors.muted, fontSize: 8)),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(0, y - 5));
    }
    if (values.isEmpty) return;
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? plot.center.dx : plot.left + plot.width * i / (values.length - 1);
      final y = plot.bottom - plot.height * values[i].clamp(0, 100) / 100;
      points.add(Offset(x, y));
    }
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1], current = points[i];
      final mid = (previous.dx + current.dx) / 2;
      line.cubicTo(mid, previous.dy, mid, current.dy, current.dx, current.dy);
    }
    final area = Path.from(line)..lineTo(points.last.dx, plot.bottom)..lineTo(points.first.dx, plot.bottom)..close();
    canvas.drawPath(area, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [VirilColors.chartBlue.withValues(alpha: .34), VirilColors.chartBlue.withValues(alpha: .015)],
    ).createShader(plot));
    canvas.drawPath(line, Paint()
      ..color = VirilColors.chartBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
    for (var i = 0; i < points.length; i++) {
      final isSelected = dates[i].year == selected.year && dates[i].month == selected.month && dates[i].day == selected.day;
      canvas.drawCircle(points[i], isSelected ? 5 : 2.4, Paint()..color = isSelected ? VirilColors.lava : VirilColors.chartBlueLight);
      if (isSelected) canvas.drawCircle(points[i], 8, Paint()
        ..color = VirilColors.gold.withValues(alpha: .18)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    final labelCount = math.min(monthly ? 12 : 7, dates.length);
    for (var i = 0; i < labelCount; i++) {
      final index = labelCount == 1 ? 0 : (i * (dates.length - 1) / (labelCount - 1)).round();
      final date = dates[index];
      final text = monthly ? '${date.month}' : '${date.day}';
      final painter = TextPainter(text: TextSpan(text: text,
        style: const TextStyle(color: VirilColors.muted, fontSize: 8)), textDirection: TextDirection.ltr)..layout();
      final x = points[index].dx - painter.width / 2;
      painter.paint(canvas, Offset(x.clamp(0, size.width - painter.width).toDouble(), size.height - 17));
    }
  }

  @override
  bool shouldRepaint(covariant _MarketLinePainter old) =>
    old.values != values || old.selected != selected || old.dates != dates || old.monthly != monthly;
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
    decoration: BoxDecoration(color: VirilColors.stoneLight.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(12), border: Border.all(color: VirilColors.line)),
    child: Column(children: [
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: VirilColors.ice)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: VirilColors.muted, fontSize: 7, letterSpacing: .7, fontWeight: FontWeight.w800)),
    ]),
  );
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
  const _HistoryRow({required this.icon, required this.title, required this.subtitle, this.color = VirilColors.ice});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Icon(icon, color: color, size: 16),
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
      Icon(unlocked ? Icons.check_circle : Icons.lock_outline, color: unlocked ? const Color(0xFF39D98A) : VirilColors.muted, size: 19),
    ]),
  );
}
