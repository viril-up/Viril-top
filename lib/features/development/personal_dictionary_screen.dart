import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

class PersonalDictionaryScreen extends StatefulWidget {
  const PersonalDictionaryScreen({super.key});

  @override
  State<PersonalDictionaryScreen> createState() => _PersonalDictionaryScreenState();
}

class _PersonalDictionaryScreenState extends State<PersonalDictionaryScreen> {
  static const _storageKey = 'viril.personal_dictionary.v1';
  List<_DictionaryWord> _words = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final decoded = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
    if (!mounted) return;
    setState(() {
      _words = decoded
          .whereType<Map<String, dynamic>>()
          .map(_DictionaryWord.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _loading = false;
    });
  }

  Future<void> _saveWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_words.map((word) => word.toJson()).toList()),
    );
  }

  Future<void> _addWord() async {
    final result = await showDialog<_DictionaryWord>(
      context: context,
      builder: (_) => const _WordEditorDialog(),
    );
    if (result == null) return;
    setState(() => _words.insert(0, result));
    await _saveWords();
  }

  Future<void> _editWord(_DictionaryWord word) async {
    final result = await showDialog<_DictionaryWord>(
      context: context,
      builder: (_) => _WordEditorDialog(word: word),
    );
    if (result == null) return;
    setState(() {
      final index = _words.indexWhere((item) => item.id == word.id);
      if (index >= 0) _words[index] = result;
    });
    await _saveWords();
  }

  Future<void> _deleteWord(_DictionaryWord word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: VirilColors.stone,
        title: const Text('Удалить слово?'),
        content: Text('«' + word.word + '» будет удалено из твоего словаря.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VirilColors.lava),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _words.removeWhere((item) => item.id == word.id));
    await _saveWords();
  }

  Future<void> _review(_DictionaryWord word, {required bool remembered}) async {
    final index = _words.indexWhere((item) => item.id == word.id);
    if (index < 0) return;
    final now = DateTime.now();
    setState(() {
      _words[index] = word.copyWith(
        reviewCount: word.reviewCount + (remembered ? 1 : 0),
        lastReviewedAt: now,
        nextReviewAt: now.add(Duration(days: remembered ? 3 : 1)),
      );
    });
    await _saveWords();
  }

  void _openWord(_DictionaryWord word) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _WordDetailScreen(
        word: word,
        onEdit: () => _editWord(word),
        onDelete: () => _deleteWord(word),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dueWords = _words.where((word) => !word.nextReviewAt.isAfter(now)).toList();
    final visibleWords = _words.where((word) {
      final query = _search.trim().toLowerCase();
      return query.isEmpty ||
          word.word.toLowerCase().contains(query) ||
          word.meaning.toLowerCase().contains(query) ||
          word.category.toLowerCase().contains(query);
    }).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: VirilColors.voidBlack,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Мой словарь', style: TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            IconButton(
              tooltip: 'Добавить слово',
              onPressed: _addWord,
              icon: const Icon(Icons.add_circle_outline_rounded, color: VirilColors.gold, size: 27),
            ),
            const SizedBox(width: 6),
          ],
          bottom: const TabBar(
            labelColor: VirilColors.gold,
            unselectedLabelColor: VirilColors.muted,
            indicatorColor: VirilColors.gold,
            tabs: [
              Tab(text: 'Мои слова'),
              Tab(text: 'Повторение'),
              Tab(text: 'Статистика'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: VirilColors.gold))
            : TabBarView(
                children: [
                  _myWordsTab(visibleWords),
                  _reviewTab(dueWords),
                  _statisticsTab(),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addWord,
          backgroundColor: VirilColors.gold,
          foregroundColor: VirilColors.voidBlack,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Добавить слово', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Widget _myWordsTab(List<_DictionaryWord> words) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
    children: [
      TextField(
        onChanged: (value) => setState(() => _search = value),
        decoration: const InputDecoration(
          hintText: 'Найти слово или значение',
          prefixIcon: Icon(Icons.search_rounded),
        ),
      ),
      const SizedBox(height: 12),
      if (_words.isEmpty)
        const _EmptyDictionaryState(
          icon: Icons.menu_book_rounded,
          title: 'Твой словарь пока пуст',
          subtitle: 'Добавляй новые, редкие и интересные слова. Значения и примеры ты записываешь сам.',
        )
      else if (words.isEmpty)
        const _EmptyDictionaryState(
          icon: Icons.search_off_rounded,
          title: 'Ничего не найдено',
          subtitle: 'Попробуй изменить поисковый запрос.',
        )
      else ...[
        Text('СОХРАНЁННЫЕ СЛОВА · ' + words.length.toString(),
          style: const TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        for (final word in words)
          _WordListTile(word: word, onTap: () => _openWord(word)),
      ],
    ],
  );

  Widget _reviewTab(List<_DictionaryWord> dueWords) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
    children: [
      const Text('ВРЕМЯ ОСВЕЖИТЬ ПАМЯТЬ',
        style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text('Повторяй свои записи, чтобы новые слова постепенно становились частью активного словарного запаса.',
        style: TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.5)),
      const SizedBox(height: 14),
      if (dueWords.isEmpty)
        const _EmptyDictionaryState(
          icon: Icons.check_circle_outline_rounded,
          title: 'Повторение завершено',
          subtitle: 'Сейчас нет слов, которым подошло время повторения. Новые слова появятся здесь после добавления.',
        )
      else
        for (final word in dueWords)
          _ReviewWordCard(
            word: word,
            onRemembered: () => _review(word, remembered: true),
            onLater: () => _review(word, remembered: false),
            onOpen: () => _openWord(word),
          ),
    ],
  );

  Widget _statisticsTab() {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 7));
    final addedThisWeek = _words.where((word) => word.createdAt.isAfter(weekStart)).length;
    final reviewed = _words.where((word) => word.reviewCount > 0).length;
    final due = _words.where((word) => !word.nextReviewAt.isAfter(now)).length;
    final categories = _words
        .map((word) => word.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      children: [
        const Text('ТВОЙ СЛОВАРНЫЙ ЗАПАС',
          style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _StatCard(value: _words.length.toString(), label: 'ВСЕГО СЛОВ', icon: Icons.menu_book_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: addedThisWeek.toString(), label: 'ЗА 7 ДНЕЙ', icon: Icons.trending_up_rounded)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _StatCard(value: reviewed.toString(), label: 'ПОВТОРЯЛИСЬ', icon: Icons.refresh_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: due.toString(), label: 'К ПОВТОРЕНИЮ', icon: Icons.schedule_rounded)),
        ]),
        const SizedBox(height: 8),
        _StatCard(value: categories.toString(), label: 'ТЕМАТИЧЕСКИХ КАТЕГОРИЙ', icon: Icons.category_rounded, wide: true),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ТВОЯ СИСТЕМА ЗНАНИЙ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(
              _words.isEmpty
                  ? 'Добавь первое слово — здесь начнёт собираться история твоего словарного запаса.'
                  : 'Каждое сохранённое слово — это новое понятие, которое ты сможешь осмыслить, повторить и использовать в речи.',
              style: const TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.5),
            ),
          ]),
        ),
      ],
    );
  }
}

class _DictionaryWord {
  const _DictionaryWord({
    required this.id,
    required this.word,
    required this.meaning,
    required this.example,
    required this.notes,
    required this.category,
    required this.createdAt,
    required this.reviewCount,
    required this.nextReviewAt,
    this.lastReviewedAt,
  });

  final String id;
  final String word;
  final String meaning;
  final String example;
  final String notes;
  final String category;
  final DateTime createdAt;
  final int reviewCount;
  final DateTime nextReviewAt;
  final DateTime? lastReviewedAt;

  factory _DictionaryWord.fromJson(Map<String, dynamic> json) => _DictionaryWord(
    id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
    word: json['word'] as String? ?? '',
    meaning: json['meaning'] as String? ?? '',
    example: json['example'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    category: json['category'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    reviewCount: json['reviewCount'] as int? ?? 0,
    nextReviewAt: DateTime.tryParse(json['nextReviewAt'] as String? ?? '') ?? DateTime.now(),
    lastReviewedAt: DateTime.tryParse(json['lastReviewedAt'] as String? ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'meaning': meaning,
    'example': example,
    'notes': notes,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'reviewCount': reviewCount,
    'nextReviewAt': nextReviewAt.toIso8601String(),
    'lastReviewedAt': lastReviewedAt?.toIso8601String(),
  };

  _DictionaryWord copyWith({
    int? reviewCount,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
  }) => _DictionaryWord(
    id: id,
    word: word,
    meaning: meaning,
    example: example,
    notes: notes,
    category: category,
    createdAt: createdAt,
    reviewCount: reviewCount ?? this.reviewCount,
    lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
  );
}

class _WordEditorDialog extends StatefulWidget {
  const _WordEditorDialog({this.word});
  final _DictionaryWord? word;

  @override
  State<_WordEditorDialog> createState() => _WordEditorDialogState();
}

class _WordEditorDialogState extends State<_WordEditorDialog> {
  late final TextEditingController _word;
  late final TextEditingController _meaning;
  late final TextEditingController _example;
  late final TextEditingController _notes;
  late final TextEditingController _category;

  @override
  void initState() {
    super.initState();
    final item = widget.word;
    _word = TextEditingController(text: item?.word ?? '');
    _meaning = TextEditingController(text: item?.meaning ?? '');
    _example = TextEditingController(text: item?.example ?? '');
    _notes = TextEditingController(text: item?.notes ?? '');
    _category = TextEditingController(text: item?.category ?? '');
  }

  @override
  void dispose() {
    _word.dispose();
    _meaning.dispose();
    _example.dispose();
    _notes.dispose();
    _category.dispose();
    super.dispose();
  }

  void _submit() {
    if (_word.text.trim().isEmpty || _meaning.text.trim().isEmpty) return;
    final old = widget.word;
    final now = DateTime.now();
    Navigator.pop(context, _DictionaryWord(
      id: old?.id ?? now.microsecondsSinceEpoch.toString(),
      word: _word.text.trim(),
      meaning: _meaning.text.trim(),
      example: _example.text.trim(),
      notes: _notes.text.trim(),
      category: _category.text.trim(),
      createdAt: old?.createdAt ?? now,
      reviewCount: old?.reviewCount ?? 0,
      nextReviewAt: old?.nextReviewAt ?? now,
      lastReviewedAt: old?.lastReviewedAt,
    ));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: VirilColors.stone,
    title: Text(widget.word == null ? 'Новое слово' : 'Редактировать слово'),
    content: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _word, autofocus: true, textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Слово или выражение *', hintText: 'Например: целеустремлённость')),
        const SizedBox(height: 10),
        TextField(controller: _meaning, minLines: 2, maxLines: 5,
          decoration: const InputDecoration(labelText: 'Твоё значение *', hintText: 'Объясни своими словами, что это означает')),
        const SizedBox(height: 10),
        TextField(controller: _example, minLines: 2, maxLines: 4,
          decoration: const InputDecoration(labelText: 'Пример использования', hintText: 'Составь своё предложение')),
        const SizedBox(height: 10),
        TextField(controller: _category,
          decoration: const InputDecoration(labelText: 'Тема или категория', hintText: 'Например: характер, наука, общение')),
        const SizedBox(height: 10),
        TextField(controller: _notes, minLines: 2, maxLines: 4,
          decoration: const InputDecoration(labelText: 'Личные заметки', hintText: 'Ассоциации, оттенки смысла, где встретил слово')),
        const SizedBox(height: 7),
        const Text('* Обязательные поля. Все определения и примеры ты записываешь самостоятельно.',
          style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4)),
      ]),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
      FilledButton(onPressed: _submit, child: const Text('Сохранить')),
    ],
  );
}

class _WordDetailScreen extends StatelessWidget {
  const _WordDetailScreen({required this.word, required this.onEdit, required this.onDelete});
  final _DictionaryWord word;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      title: const Text('Карточка слова'),
      actions: [
        IconButton(tooltip: 'Редактировать', onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
        IconButton(tooltip: 'Удалить', onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, color: VirilColors.lava)),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      children: [
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (word.category.isNotEmpty) ...[
            Text(word.category.toUpperCase(), style: const TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
          ],
          Text(word.word, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 17),
          const Text('ЗНАЧЕНИЕ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          SelectableText(word.meaning, style: const TextStyle(fontSize: 15, height: 1.6)),
          if (word.example.isNotEmpty) ...[
            const Divider(color: VirilColors.line, height: 28),
            const Text('ПРИМЕР ИСПОЛЬЗОВАНИЯ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            SelectableText(word.example, style: const TextStyle(fontSize: 13, height: 1.6, fontStyle: FontStyle.italic)),
          ],
          if (word.notes.isNotEmpty) ...[
            const Divider(color: VirilColors.line, height: 28),
            const Text('ЛИЧНЫЕ ЗАМЕТКИ', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            SelectableText(word.notes, style: const TextStyle(fontSize: 13, height: 1.6)),
          ],
        ])),
        const SizedBox(height: 12),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ИСТОРИЯ ПОВТОРЕНИЯ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Повторений с отметкой «Помню»: ' + word.reviewCount.toString(),
            style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
          const SizedBox(height: 4),
          Text('Добавлено: ' + _dateLabel(word.createdAt),
            style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
        ])),
      ],
    ),
  );
}

class _WordListTile extends StatelessWidget {
  const _WordListTile({required this.word, required this.onTap});
  final _DictionaryWord word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: VirilColors.stone,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: VirilColors.line)),
          child: Row(children: [
            Container(width: 38, height: 38,
              decoration: BoxDecoration(color: VirilColors.gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.bookmark_outline_rounded, color: VirilColors.gold, size: 19)),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(word.word, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(word.meaning, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.35)),
              if (word.category.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(word.category, style: const TextStyle(color: VirilColors.gold, fontSize: 9)),
              ],
            ])),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, color: VirilColors.muted),
          ]),
        ),
      ),
    ),
  );
}

class _ReviewWordCard extends StatefulWidget {
  const _ReviewWordCard({required this.word, required this.onRemembered, required this.onLater, required this.onOpen});
  final _DictionaryWord word;
  final VoidCallback onRemembered;
  final VoidCallback onLater;
  final VoidCallback onOpen;

  @override
  State<_ReviewWordCard> createState() => _ReviewWordCardState();
}

class _ReviewWordCardState extends State<_ReviewWordCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) => GlassCard(
    margin: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.word.word, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      if (_revealed)
        Text(widget.word.meaning, style: const TextStyle(fontSize: 13, height: 1.5))
      else
        TextButton.icon(
          onPressed: () => setState(() => _revealed = true),
          icon: const Icon(Icons.visibility_outlined, size: 17),
          label: const Text('Показать моё значение'),
        ),
      if (_revealed) ...[
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: widget.onLater, child: const Text('Повторить завтра'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton(onPressed: widget.onRemembered, child: const Text('Помню'))),
        ]),
      ],
      Align(alignment: Alignment.centerRight, child: TextButton(
        onPressed: widget.onOpen,
        child: const Text('Открыть карточку'),
      )),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon, this.wide = false});
  final String value;
  final String label;
  final IconData icon;
  final bool wide;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Row(children: [
      Icon(icon, color: VirilColors.gold, size: 21),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: VirilColors.ice)),
        Text(label, style: const TextStyle(color: VirilColors.muted, fontSize: 8, letterSpacing: .7, fontWeight: FontWeight.w800)),
      ])),
    ]),
  );
}

class _EmptyDictionaryState extends StatelessWidget {
  const _EmptyDictionaryState({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(children: [
        Icon(icon, color: VirilColors.gold, size: 34),
        const SizedBox(height: 10),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.5)),
      ]),
    ),
  );
}

String _dateLabel(DateTime date) =>
    date.day.toString().padLeft(2, '0') + '.' +
    date.month.toString().padLeft(2, '0') + '.' +
    date.year.toString();
