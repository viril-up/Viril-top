import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import 'data/habit_store.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    HabitStore.instance.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addHabit() async {
    _controller.clear();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VirilColors.stone,
        title: const Text('Новая привычка'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          maxLength: 42,
          decoration: const InputDecoration(hintText: 'Например: читать 15 минут'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('Добавить')),
        ],
      ),
    );
    if (title != null && title.trim().isNotEmpty) {
      await HabitStore.instance.addHabit(title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = HabitStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final habits = store.habits;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const SectionTitle('Привычки', subtitle: 'Небольшие действия, которые формируют большой путь'),
            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(child: Text('РИТМ СЕГОДНЯ', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w800))),
                  Text('${store.completedToday}/${habits.length}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: store.todayPercent / 100,
                    minHeight: 10,
                    backgroundColor: VirilColors.line,
                    valueColor: const AlwaysStoppedAnimation(VirilColors.gold),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${store.todayPercent}% ежедневного плана', style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
              ]),
            ),
            const SizedBox(height: 18),
            Row(children: [
              const Expanded(child: Text('ТВОИ РИТУАЛЫ', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: VirilColors.muted, fontWeight: FontWeight.w800))),
              TextButton.icon(onPressed: _addHabit, icon: const Icon(Icons.add, size: 18), label: const Text('Добавить')),
            ]),
            if (habits.isEmpty)
              GlassCard(child: Column(children: [
                const Icon(Icons.spa_outlined, size: 38, color: VirilColors.gold),
                const SizedBox(height: 10),
                const Text('Создай первую привычку', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 5),
                const Text('Начни с простого действия, которое реально повторять каждый день.', textAlign: TextAlign.center, style: TextStyle(color: VirilColors.muted, fontSize: 12, height: 1.5)),
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: _addHabit, icon: const Icon(Icons.add), label: const Text('Создать привычку')),
              ]))
            else
              ...habits.map((habit) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: VirilColors.gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.auto_awesome_rounded, color: VirilColors.gold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(habit.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('🔥 ${store.streakFor(habit)} дн. подряд  ·  ${store.weekCount(habit)}/7 за неделю', style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
                    ])),
                    IconButton(
                      tooltip: habit.completedToday ? 'Отменить отметку' : 'Отметить выполнение',
                      onPressed: () => store.toggleToday(habit.id),
                      icon: Icon(habit.completedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: habit.completedToday ? VirilColors.ice : VirilColors.muted, size: 28),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') store.removeHabit(habit.id);
                      },
                      itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Удалить привычку'))],
                    ),
                  ]),
                ),
              )),
            if (habits.isNotEmpty) ...[
              const SizedBox(height: 8),
              GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('НЕДЕЛЬНЫЙ РИТМ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                ...habits.map((habit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Expanded(child: Text(habit.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))),
                    const SizedBox(width: 12),
                    ...List.generate(7, (index) {
                      final date = DateTime.now().subtract(Duration(days: 6 - index));
                      final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                      final done = habit.completedDays.contains(key);
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Container(width: 12, height: 12, decoration: BoxDecoration(
                          color: done ? VirilColors.gold : VirilColors.line,
                          borderRadius: BorderRadius.circular(4),
                        )),
                      );
                    }),
                  ]),
                )),
                const SizedBox(height: 6),
                const Text('Квадраты показывают выполнение за последние 7 дней.', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
              ])),
            ],
            const SizedBox(height: 12),
            const Text('Отметки и серии хранятся локально на этом устройстве.', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
          ],
        );
      },
    );
  }
}
