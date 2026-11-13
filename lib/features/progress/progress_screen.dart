import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../habits/data/habit_store.dart';
import '../goals/data/goal_store.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/metric_tile.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const SectionTitle('Прогресс', subtitle: 'Измеряй путь, а не сравнивай себя с другими'),
          Row(children: [
            Expanded(child: MetricTile(value: '${store.level}', label: 'УРОВЕНЬ')),
            const SizedBox(width: 10),
            Expanded(child: MetricTile(value: '${store.xp} XP', label: 'ОБЩИЙ ОПЫТ')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: MetricTile(value: '${store.completedCount}', label: 'ЗАДАЧ ВЫПОЛНЕНО')),
            const SizedBox(width: 10),
            Expanded(child: MetricTile(value: '${store.pendingCount}', label: 'В ПЛАНЕ')),
          ]),
          const SizedBox(height: 14),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Баланс развития', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            const Text('Выполненные задачи по четырём направлениям', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
            const SizedBox(height: 14),
            _DomainProgress(label: 'Физическое', icon: Icons.fitness_center, color: VirilColors.lava,
              count: store.tasks.where((task) => task.domain == 'Физическое' && task.completed).length,
              total: store.tasks.where((task) => task.domain == 'Физическое').length),
            _DomainProgress(label: 'Ментальное', icon: Icons.psychology_alt, color: VirilColors.ice,
              count: store.tasks.where((task) => task.domain == 'Ментальное' && task.completed).length,
              total: store.tasks.where((task) => task.domain == 'Ментальное').length),
            _DomainProgress(label: 'Интеллект', icon: Icons.auto_stories, color: VirilColors.gold,
              count: store.tasks.where((task) => task.domain == 'Интеллект' && task.completed).length,
              total: store.tasks.where((task) => task.domain == 'Интеллект').length),
            _DomainProgress(label: 'Духовное', icon: Icons.spa, color: VirilColors.violet,
              count: store.tasks.where((task) => task.domain == 'Духовное' && task.completed).length,
              total: store.tasks.where((task) => task.domain == 'Духовное').length),
          ])),
          const SizedBox(height: 14),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Путь к следующему уровню', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('${store.levelProgress} из 100 XP', style: const TextStyle(color: VirilColors.muted, fontSize: 12)),
            const SizedBox(height: 14),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(
              value: store.levelProgress / 100,
              minHeight: 9,
              backgroundColor: VirilColors.line,
              valueColor: const AlwaysStoppedAnimation(VirilColors.ice),
            )),
            const SizedBox(height: 10),
            Text('Ещё ${100 - store.levelProgress} XP до уровня ${store.level + 1}', style: const TextStyle(color: VirilColors.ice, fontSize: 12, fontWeight: FontWeight.w700)),
          ])),
          const SizedBox(height: 14),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Дисциплина и привычки', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            const Text('Результат ежедневных ритуалов', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: MetricTile(value: '${habits.totalCompletions}', label: 'ОТМЕТОК')),
              const SizedBox(width: 8),
              Expanded(child: MetricTile(value: '${habits.bestStreak}', label: 'ЛУЧШАЯ СЕРИЯ')),
              const SizedBox(width: 8),
              Expanded(child: MetricTile(value: '${habits.activeHabits}', label: 'ПРИВЫЧЕК')),
            ]),
            const SizedBox(height: 10),
            _Achievement(icon: Icons.wb_sunny_rounded, title: 'Первый ритуал', description: 'Отметь выполнение привычки', unlocked: habits.totalCompletions >= 1),
            _Achievement(icon: Icons.local_fire_department_rounded, title: 'Неделя дисциплины', description: 'Собери серию из 7 дней', unlocked: habits.bestStreak >= 7),
            _Achievement(icon: Icons.workspace_premium_rounded, title: 'Мастер постоянства', description: 'Набери 30 отметок привычек', unlocked: habits.totalCompletions >= 30),
          ])),
          const SizedBox(height: 14),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Цели и результаты', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            const Text('Как продвигаются твои долгосрочные планы', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: MetricTile(value: '${goals.inProgressGoals.length}', label: 'В ПРОЦЕССЕ')),
              const SizedBox(width: 8),
              Expanded(child: MetricTile(value: '${goals.completedGoals}', label: 'ЗАВЕРШЕНО')),
              const SizedBox(width: 8),
              Expanded(child: MetricTile(value: '${goals.averageProgress}%', label: 'СРЕДНИЙ ПРОГРЕСС')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.checklist_rounded, color: VirilColors.ice, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Выполнено этапов: ${goals.completedSteps} из ${goals.totalSteps}', style: const TextStyle(color: VirilColors.muted, fontSize: 11))),
            ]),
            const SizedBox(height: 10),
            _Achievement(icon: Icons.flag_circle_rounded, title: 'Первая цель', description: 'Заверши свою первую цель', unlocked: goals.completedGoals >= 1),
            _Achievement(icon: Icons.emoji_events_rounded, title: 'Три победы', description: 'Заверши три цели', unlocked: goals.completedGoals >= 3),
            _Achievement(icon: Icons.route_rounded, title: 'Путь из десяти шагов', description: 'Выполни 10 этапов целей', unlocked: goals.completedSteps >= 10),
            if (goals.completedHistory.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('ИСТОРИЯ ЗАВЕРШЕНИЙ', style: TextStyle(fontSize: 10, letterSpacing: 1.3, color: VirilColors.muted, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              ...goals.completedHistory.take(5).map((goal) => _GoalHistoryItem(
                title: goal.title,
                date: goal.completedAt!,
                durationDays: goal.durationDays,
              )),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Завершённые цели появятся здесь.', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
              ),
          ])),
          const SizedBox(height: 14),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Твои достижения', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 13),
            _Achievement(icon: Icons.flag_rounded, title: 'Первый шаг', description: 'Создай свой первый план', unlocked: store.tasks.isNotEmpty),
            _Achievement(icon: Icons.check_circle_rounded, title: 'Действие важнее намерения', description: 'Выполни первую задачу', unlocked: store.completedCount >= 1),
            _Achievement(icon: Icons.bolt_rounded, title: 'Десять шагов', description: 'Набери 100 XP', unlocked: store.xp >= 100),
            _Achievement(icon: Icons.military_tech_rounded, title: 'Постоянство', description: 'Выполни 10 задач', unlocked: store.completedCount >= 10),
          ])),
          const SizedBox(height: 12),
          const Text('Статистика обновляется на основе твоих планов на этом устройстве.', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
        ],
      ),
    );
  }
}


class _GoalHistoryItem extends StatelessWidget {
  const _GoalHistoryItem({
    required this.title,
    required this.date,
    required this.durationDays,
  });

  final String title;
  final DateTime date;
  final int durationDays;

  @override
  Widget build(BuildContext context) {
    final formatted = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        const Icon(Icons.verified_rounded, color: VirilColors.ice, size: 17),
        const SizedBox(width: 8),
        Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        Text('$durationDays дн. · $formatted', style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
      ]),
    );
  }
}

class _Achievement extends StatelessWidget {
  const _Achievement({required this.icon, required this.title, required this.description, required this.unlocked});
  final IconData icon;
  final String title;
  final String description;
  final bool unlocked;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (unlocked ? VirilColors.gold : VirilColors.stoneLight).withValues(alpha: .18),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: unlocked ? VirilColors.gold.withValues(alpha: .5) : VirilColors.line),
        ),
        child: Icon(icon, color: unlocked ? VirilColors.gold : VirilColors.muted, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: unlocked ? VirilColors.text : VirilColors.muted, fontSize: 12)),
        Text(description, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
      ])),
      Icon(unlocked ? Icons.check_circle : Icons.lock_outline, color: unlocked ? VirilColors.ice : VirilColors.muted, size: 18),
    ]),
  );
}

class _DomainProgress extends StatelessWidget {
  const _DomainProgress({required this.label, required this.icon, required this.color, required this.count, required this.total});
  final String label;
  final IconData icon;
  final Color color;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(width: 10),
        SizedBox(width: 94, child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            backgroundColor: VirilColors.line,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        )),
        const SizedBox(width: 10),
        SizedBox(width: 28, child: Text('$count/$total', textAlign: TextAlign.end,
          style: const TextStyle(color: VirilColors.muted, fontSize: 10))),
      ]),
    );
  }
}
