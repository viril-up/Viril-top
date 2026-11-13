import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import 'data/resource_store.dart';
import 'models/resource_item.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});
  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  static const _categories = ['Все', 'Книги', 'Обучение', 'Практики', 'База знаний'];
  final _searchController = TextEditingController();
  String _category = 'Все';
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    ResourceStore.instance.initialize();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ResourceStore.instance,
    builder: (context, _) {
      final store = ResourceStore.instance;
      final query = _searchController.text.trim().toLowerCase();
      final items = ResourceItem.catalog.where((item) {
        final categoryMatch = _category == 'Все' || item.category == _category;
        final favoriteMatch = !_favoritesOnly || store.isFavorite(item.id);
        final searchMatch = query.isEmpty || item.title.toLowerCase().contains(query) ||
            item.subtitle.toLowerCase().contains(query) || item.description.toLowerCase().contains(query);
        return categoryMatch && favoriteMatch && searchMatch;
      }).toList();

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const SectionTitle('Ресурсы', subtitle: 'Твоя личная библиотека инструментов и знаний'),
          Container(
            decoration: BoxDecoration(
              color: VirilColors.stone.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: VirilColors.line),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: VirilColors.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Поиск по библиотеке...',
                hintStyle: const TextStyle(color: VirilColors.muted, fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded, color: VirilColors.ice),
                suffixIcon: query.isEmpty ? null : IconButton(
                  onPressed: _searchController.clear,
                  icon: const Icon(Icons.close_rounded, color: VirilColors.muted),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final category in _categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                      selectedColor: VirilColors.ice.withValues(alpha: .2),
                      backgroundColor: VirilColors.stone,
                      side: BorderSide(color: _category == category ? VirilColors.ice : VirilColors.line),
                      labelStyle: TextStyle(
                        color: _category == category ? VirilColors.ice : VirilColors.muted,
                        fontSize: 11, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text('${items.length} МАТЕРИАЛОВ', style: const TextStyle(
              color: VirilColors.gold, letterSpacing: 1.6, fontSize: 9, fontWeight: FontWeight.w800,
            ))),
            TextButton.icon(
              onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
              icon: Icon(_favoritesOnly ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 17),
              label: Text(_favoritesOnly ? 'Избранное' : 'Все материалы'),
              style: TextButton.styleFrom(foregroundColor: _favoritesOnly ? VirilColors.gold : VirilColors.muted),
            ),
          ]),
          if (items.isEmpty)
            GlassCard(child: Column(children: [
              const Icon(Icons.search_off_rounded, color: VirilColors.muted, size: 30),
              const SizedBox(height: 8),
              const Text('Ничего не найдено', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Измени запрос или выбери другую категорию.', style: TextStyle(color: VirilColors.muted, fontSize: 11)),
            ]))
          else
            for (final item in items) _ResourceCard(
              item: item,
              favorite: store.isFavorite(item.id),
              hasNote: store.noteFor(item.id).isNotEmpty,
              onFavorite: () => store.toggleFavorite(item.id),
              onOpen: () => _openResource(item),
            ),
        ],
      );
    },
  );

  void _openResource(ResourceItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResourceDetailScreen(item: item),
    ));
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.item, required this.favorite, required this.hasNote, required this.onFavorite, required this.onOpen});
  final ResourceItem item;
  final bool favorite, hasNote;
  final VoidCallback onFavorite, onOpen;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onOpen,
    borderRadius: BorderRadius.circular(23),
    child: GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(width: 50, height: 50, decoration: BoxDecoration(
          color: item.color.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withValues(alpha: .3)),
        ), child: Icon(item.icon, color: item.color, size: 25)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.category.toUpperCase(), style: TextStyle(color: item.color, fontSize: 8, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(item.subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.35)),
          if (hasNote) const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text('ЕСТЬ ТВОЯ ЗАМЕТКА', style: TextStyle(color: VirilColors.ice, fontSize: 8, letterSpacing: 1)),
          ),
        ])),
        IconButton(
          onPressed: onFavorite,
          icon: Icon(favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: favorite ? VirilColors.gold : VirilColors.muted),
        ),
      ]),
    ),
  );
}

class ResourceDetailScreen extends StatefulWidget {
  const ResourceDetailScreen({super.key, required this.item});
  final ResourceItem item;
  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: ResourceStore.instance.noteFor(widget.item.id));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: VirilColors.voidBlack,
      appBar: AppBar(title: const Text('Материал'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(
              color: item.color.withValues(alpha: .14), borderRadius: BorderRadius.circular(17),
            ), child: Icon(item.icon, color: item.color, size: 29)),
            const SizedBox(height: 16),
            Text(item.category.toUpperCase(), style: TextStyle(color: item.color, fontSize: 9, letterSpacing: 1.7, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(item.description, style: const TextStyle(color: VirilColors.muted, fontSize: 12, height: 1.55)),
            if (item.duration != null) ...[
              const SizedBox(height: 12),
              Row(children: [const Icon(Icons.schedule_rounded, color: VirilColors.gold, size: 16), const SizedBox(width: 6),
                Text(item.duration!, style: const TextStyle(color: VirilColors.gold, fontSize: 11, fontWeight: FontWeight.w700))]),
            ],
          ])),
          const SizedBox(height: 20),
          const Text('ПОРЯДОК РАБОТЫ', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (var i = 0; i < item.steps.length; i++)
            GlassCard(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.all(14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 27, height: 27, alignment: Alignment.center,
                  decoration: BoxDecoration(color: item.color.withValues(alpha: .15), borderRadius: BorderRadius.circular(9)),
                  child: Text('${i + 1}', style: TextStyle(color: item.color, fontWeight: FontWeight.w900))),
                const SizedBox(width: 11),
                Expanded(child: Text(item.steps[i], style: const TextStyle(fontSize: 12, height: 1.45))),
              ]),
            ),
          const SizedBox(height: 12),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ТВОИ ЗАМЕТКИ', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w800)),
            const SizedBox(height: 9),
            TextField(
              controller: _noteController,
              minLines: 3,
              maxLines: 7,
              style: const TextStyle(color: VirilColors.text, fontSize: 12, height: 1.45),
              decoration: InputDecoration(
                hintText: 'Запиши свои мысли, выводы или вопросы...',
                hintStyle: const TextStyle(color: VirilColors.muted, fontSize: 11),
                filled: true, fillColor: VirilColors.voidBlack.withValues(alpha: .45),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: VirilColors.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: VirilColors.line)),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => ResourceStore.instance.toggleFavorite(item.id),
                icon: const Icon(Icons.bookmark_border_rounded),
                label: const Text('В избранное'),
              )),
              const SizedBox(width: 9),
              Expanded(child: FilledButton.icon(
                onPressed: () async {
                  await ResourceStore.instance.saveNote(item.id, _noteController.text);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заметка сохранена на устройстве')),
                  );
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Сохранить'),
              )),
            ]),
          ])),
        ],
      ),
    );
  }
}
