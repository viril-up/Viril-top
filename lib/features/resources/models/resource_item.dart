import 'package:flutter/material.dart';

class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.steps,
    required this.icon,
    required this.color,
    this.duration,
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String description;
  final List<String> steps;
  final IconData icon;
  final Color color;
  final String? duration;

  static const catalog = <ResourceItem>[
    ResourceItem(
      id: 'reading-notes', title: 'Чтение с пользой', subtitle: 'Превращай прочитанное в знания',
      category: 'Книги', description: 'Небольшая система активного чтения: не просто проходи страницы, а выделяй идеи и связывай их с реальной жизнью.',
      steps: ['Выбери небольшой фрагмент для чтения.', 'Выдели одну главную мысль своими словами.', 'Запиши вопрос, который возник после чтения.', 'Подумай, где сможешь применить эту идею.'],
      icon: Icons.menu_book_rounded, color: Color(0xFFD7B477), duration: '15–20 минут',
    ),
    ResourceItem(
      id: 'critical-thinking', title: 'Критическое мышление', subtitle: 'Проверяй идеи, а не принимай их на веру',
      category: 'Обучение', description: 'Практика помогает отделять факты от мнений и замечать, на чём основан вывод.',
      steps: ['Сформулируй утверждение.', 'Найди аргументы в его пользу.', 'Поищи надёжные контраргументы.', 'Отметь, каких данных пока не хватает.'],
      icon: Icons.psychology_alt_rounded, color: Color(0xFF91DDF2), duration: '10 минут',
    ),
    ResourceItem(
      id: 'language-learning', title: 'Язык каждый день', subtitle: 'Маленькие занятия с регулярным повторением',
      category: 'Обучение', description: 'Короткая учебная сессия помогает поддерживать регулярность и закреплять новые слова в контексте.',
      steps: ['Повтори несколько ранее изученных слов.', 'Изучи небольшую новую тему.', 'Составь свои примеры.', 'Вернись к материалу через день.'],
      icon: Icons.translate_rounded, color: Color(0xFF91DDF2), duration: '15 минут',
    ),
    ResourceItem(
      id: 'focus-session', title: 'Сессия концентрации', subtitle: 'Одно дело — одно внимание',
      category: 'Практики', description: 'Создай спокойный отрезок времени для одной понятной задачи без постоянных переключений.',
      steps: ['Выбери одну конкретную задачу.', 'Подготовь всё необходимое заранее.', 'Поставь таймер на удобный промежуток.', 'В конце запиши, что получилось.'],
      icon: Icons.center_focus_strong_rounded, color: Color(0xFFE16A43), duration: '20 минут',
    ),
    ResourceItem(
      id: 'reflection', title: 'Вечерняя рефлексия', subtitle: 'Замечай опыт и делай выводы',
      category: 'Практики', description: 'Спокойный обзор дня помогает увидеть полезные решения и определить следующий небольшой шаг.',
      steps: ['Что сегодня получилось?', 'Что оказалось сложным?', 'Какой вывод можно сделать?', 'Какой один шаг стоит попробовать завтра?'],
      icon: Icons.auto_awesome_rounded, color: Color(0xFF9B8BEA), duration: '5 минут',
    ),
    ResourceItem(
      id: 'idea-capture', title: 'Хранилище идей', subtitle: 'Собирай мысли в одном месте',
      category: 'База знаний', description: 'Фиксируй идеи коротко и добавляй контекст, чтобы к ним можно было вернуться.',
      steps: ['Запиши идею одним предложением.', 'Добавь источник или ситуацию, где она появилась.', 'Укажи тему или направление.', 'Периодически пересматривай записи.'],
      icon: Icons.lightbulb_outline_rounded, color: Color(0xFFD7B477),
    ),
    ResourceItem(
      id: 'values-map', title: 'Карта личных ценностей', subtitle: 'Сверяй решения с тем, что важно',
      category: 'База знаний', description: 'Упражнение для осмысления собственных ориентиров. Здесь нет правильного списка — важны твои осознанные ответы.',
      steps: ['Выбери пять принципов, которые для тебя важны.', 'Расположи их по значимости.', 'Вспомни поступок, который отражал один из них.', 'Подумай, как воплотить ещё один принцип на этой неделе.'],
      icon: Icons.explore_rounded, color: Color(0xFF9B8BEA),
    ),
  ];
}
