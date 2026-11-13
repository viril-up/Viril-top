import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/metric_tile.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VirilStore.instance;
    return AnimatedBuilder(
      animation: store,
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
