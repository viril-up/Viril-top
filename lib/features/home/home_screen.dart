import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/models/viril_task.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/metric_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VirilStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _hero(store),
          const SectionTitle('Твои четыре направления', subtitle: 'Развивай себя целостно, без перекоса в одну сторону'),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: const [
              _DomainCard(icon: Icons.fitness_center, title: 'Физическое', detail: 'Сила и энергия', color: VirilColors.lava),
              _DomainCard(icon: Icons.psychology_alt, title: 'Ментальное', detail: 'Устойчивость и ясность', color: VirilColors.ice),
              _DomainCard(icon: Icons.auto_stories, title: 'Интеллект', detail: 'Знания и мышление', color: VirilColors.gold),
              _DomainCard(icon: Icons.spa, title: 'Духовное', detail: 'Ценности и смысл', color: VirilColors.violet),
            ],
          ),
          SectionTitle('Планы на сегодня', subtitle: '${store.pendingCount} активных · ${store.completedCount} выполнено'),
          GlassCard(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.flag_rounded, color: VirilColors.gold, size: 25),
                const SizedBox(width: 12),
                const Expanded(child: Text('Маленькие действия создают большие перемены.', style: TextStyle(color: VirilColors.muted, fontSize: 12))),
                FilledButton.tonal(
                  onPressed: () => _showAddTaskDialog(context),
                  child: const Text('Добавить'),
                ),
              ]),
              if (store.tasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: VirilColors.line),
                for (final task in store.tasks) _TaskTile(task: task),
              ] else ...[
                const SizedBox(height: 14),
                const Text('Пока планов нет. Добавь первую задачу на сегодня.', style: TextStyle(color: VirilColors.muted, fontSize: 12)),
              ],
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: MetricTile(value: '${store.completedCount}', label: 'ЗАДАЧ ВЫПОЛНЕНО')),
            const SizedBox(width: 10),
            Expanded(child: MetricTile(value: '${store.xp}', label: 'ОБЩИЙ XP')),
          ]),
        ],
      ),
    );
  }

  Widget _hero(VirilStore store) => GlassCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ТВОЯ СИСТЕМА РОСТА', style: TextStyle(color: VirilColors.gold, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      const Text('Стань версией,\nкоторую уважаешь.', style: TextStyle(fontSize: 29, height: 1.08, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      const Text('Четыре направления. Один путь. Твой выбор.', style: TextStyle(color: VirilColors.muted, fontSize: 13)),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('УРОВЕНЬ ${store.level}', style: const TextStyle(color: VirilColors.ice, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text('${store.xp} XP', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
        ])),
        Container(width: 64, height: 64, decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: VirilColors.gold, width: 2),
          boxShadow: [BoxShadow(color: VirilColors.gold.withValues(alpha: .16), blurRadius: 20)],
        ), child: const Icon(Icons.local_fire_department_rounded, color: VirilColors.gold, size: 30)),
      ]),
      const SizedBox(height: 12),
      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(
        value: store.levelProgress / 100,
        minHeight: 7,
        backgroundColor: const Color(0xFF30394B),
        valueColor: const AlwaysStoppedAnimation(VirilColors.ice),
      )),
      const SizedBox(height: 7),
      Text('${100 - store.levelProgress} XP до следующего уровня · +10 XP за задачу', style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
    ]),
  );

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final controller = TextEditingController();
    var domain = 'Физическое';
    const domains = ['Физическое', 'Ментальное', 'Интеллект', 'Духовное', 'Другое'];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VirilColors.stone,
          title: const Text('Новый план'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 70,
              decoration: const InputDecoration(hintText: 'Например: прочитать 10 страниц'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: domain,
              dropdownColor: VirilColors.stoneLight,
              decoration: const InputDecoration(labelText: 'Направление'),
              items: domains.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) { if (value != null) setDialogState(() => domain = value); },
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                await VirilStore.instance.addTask(controller.text, domain);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});
  final VirilTask task;

  @override
  Widget build(BuildContext context) {
    final store = VirilStore.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Checkbox(
          value: task.completed,
          activeColor: VirilColors.ice,
          onChanged: (_) => store.toggleTask(task.id),
        ),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.title, style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? VirilColors.muted : VirilColors.text,
          )),
          Text(task.domain, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
        ])),
        if (task.completed) const Text('+10 XP', style: TextStyle(color: VirilColors.ice, fontSize: 10, fontWeight: FontWeight.w700)),
        IconButton(
          tooltip: 'Удалить задачу',
          visualDensity: VisualDensity.compact,
          onPressed: () => store.removeTask(task.id),
          icon: const Icon(Icons.close_rounded, size: 17, color: VirilColors.muted),
        ),
      ]),
    );
  }
}

class _DomainCard extends StatelessWidget {
  const _DomainCard({required this.icon, required this.title, required this.detail, required this.color});
  final IconData icon; final String title, detail; final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(21),
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [color.withValues(alpha: .17), const Color(0xD9151925)]),
      border: Border.all(color: color.withValues(alpha: .26)),
      boxShadow: [BoxShadow(color: color.withValues(alpha: .06), blurRadius: 18, offset: const Offset(0, 7))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Icon(icon, color: color, size: 25),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        Text(detail, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
      ]),
    ]),
  );
}
