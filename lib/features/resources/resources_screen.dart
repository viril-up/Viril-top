import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});
  static const _items = [
    (Icons.menu_book_rounded, 'Библиотека книг', 'Подборки по психологии, философии, науке и навыкам.', 'КНИГИ'),
    (Icons.school_rounded, 'Обучение', 'Курсы, языки и структурированные учебные маршруты.', 'ОБУЧЕНИЕ'),
    (Icons.headphones_rounded, 'Практики', 'Аудио, дыхательные упражнения и концентрация.', 'ПРАКТИКА'),
    (Icons.lightbulb_rounded, 'База знаний', 'Конспекты, идеи и личная система заметок.', 'ЗНАНИЯ'),
  ];
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 120), children: [
    const SectionTitle('Ресурсы', subtitle: 'Инструменты, которые помогают расти'),
    for (final item in _items) GlassCard(margin: const EdgeInsets.only(bottom: 13), child: Row(children: [
      Container(width: 54, height: 54, decoration: BoxDecoration(borderRadius: BorderRadius.circular(17),
        gradient: const LinearGradient(colors: [Color(0xFF34415D), Color(0xFF27223D)])),
        child: Icon(item.$1, color: VirilColors.gold, size: 27)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.$4, style: const TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        Text(item.$3, style: const TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.35)),
      ])),
      const Icon(Icons.chevron_right, color: VirilColors.muted),
    ])),
  ]);
}
