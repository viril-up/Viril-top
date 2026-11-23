import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/viril_staggered_list.dart';
import 'data/resource_store.dart';
import 'models/resource_item.dart';
import 'books/book_library_screen.dart';
import 'videos/video_library_screen.dart';
import 'audio_library_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  @override
  void initState() {
    super.initState();
    ResourceStore.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ResourceStore.instance,
      builder: (context, _) {
        final store = ResourceStore.instance;
        return VirilStaggeredList(
          pageIndex: 2,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            const SectionTitle('Ресурсы'),
            const SizedBox(height: 8),
            _LibraryLauncherCard(
              title: 'Библиотека',
              imagePath: 'assets/section_cards/library/library.png',
              accent: VirilColors.gold,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookLibraryScreen()),
              ),
            ),
            _LibraryLauncherCard(
              title: 'Видеотека',
              imagePath: 'assets/section_cards/videoteka/videoteka.png',
              accent: VirilColors.ice,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VideoLibraryScreen()),
              ),
            ),
            _AudioLibraryLauncherCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AudioLibraryScreen()),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DevelopmentToolsScreen extends StatefulWidget {
  const DevelopmentToolsScreen({super.key});

  @override
  State<DevelopmentToolsScreen> createState() => _DevelopmentToolsScreenState();
}

class _DevelopmentToolsScreenState extends State<DevelopmentToolsScreen> {
  final search = TextEditingController();
  String category = 'Все';
  bool favoritesOnly = false;

  static final categories = [
    'Все',
    ...ResourceItem.catalog.map((item) => item.category).toSet(),
  ];

  @override
  void initState() {
    super.initState();
    ResourceStore.instance.initialize();
    search.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    search.removeListener(_refresh);
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ResourceStore.instance,
      builder: (context, _) {
        final store = ResourceStore.instance;
        final query = search.text.trim().toLowerCase();
        final items = ResourceItem.catalog.where((item) {
          final matchesCategory = category == 'Все' || item.category == category;
          final matchesFavorite = !favoritesOnly || store.isFavorite(item.id);
          final matchesQuery = query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.subtitle.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query);
          return matchesCategory && matchesFavorite && matchesQuery;
        }).toList();

        return Scaffold(
          backgroundColor: VirilColors.voidBlack,
          appBar: AppBar(
            title: const Text('Инструменты развития'),
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'РАЗВИВАЙСЯ ЧЕРЕЗ ДЕЙСТВИЯ',
                      style: TextStyle(
                        color: VirilColors.gold,
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${store.completedToolsCount} из ${ResourceItem.catalog.length} пройдено',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '${(store.completedToolsCount / ResourceItem.catalog.length * 100).round()}%',
                          style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: store.completedToolsCount / ResourceItem.catalog.length,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: .08),
                        valueColor: const AlwaysStoppedAnimation(VirilColors.gold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: VirilColors.stone.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VirilColors.line),
                ),
                child: TextField(
                  controller: search,
                  style: const TextStyle(color: VirilColors.text, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Найти инструмент...',
                    hintStyle: const TextStyle(color: VirilColors.muted, fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, color: VirilColors.ice),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: search.clear,
                            icon: const Icon(Icons.close_rounded, color: VirilColors.muted),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 7),
                  itemBuilder: (context, index) {
                    final value = categories[index];
                    final selected = category == value;
                    return ChoiceChip(
                      label: Text(value),
                      selected: selected,
                      onSelected: (_) => setState(() => category = value),
                      selectedColor: VirilColors.gold.withValues(alpha: .2),
                      labelStyle: TextStyle(
                        color: selected ? VirilColors.gold : VirilColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide(
                        color: selected ? VirilColors.gold.withValues(alpha: .5) : VirilColors.line,
                      ),
                      backgroundColor: VirilColors.stone,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${items.length} ИНСТРУМЕНТОВ',
                      style: const TextStyle(
                        color: VirilColors.muted,
                        fontSize: 9,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => favoritesOnly = !favoritesOnly),
                    icon: Icon(
                      favoritesOnly ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 16,
                    ),
                    label: Text(favoritesOnly ? 'Избранное' : 'Все'),
                    style: TextButton.styleFrom(
                      foregroundColor: favoritesOnly ? VirilColors.gold : VirilColors.muted,
                    ),
                  ),
                ],
              ),
              if (items.isEmpty)
                GlassCard(
                  child: Column(
                    children: const [
                      Icon(Icons.search_off_rounded, color: VirilColors.muted, size: 30),
                      SizedBox(height: 8),
                      Text('Инструменты не найдены', style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text(
                        'Измени запрос или фильтр.',
                        style: TextStyle(color: VirilColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                )
              else
                for (var index = 0; index < items.length; index++)
                  _ToolCard(
                    number: ResourceItem.catalog.indexOf(items[index]) + 1,
                    item: items[index],
                    completed: store.isToolCompleted(items[index].id),
                    favorite: store.isFavorite(items[index].id),
                    onFavorite: () => store.toggleFavorite(items[index].id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResourceToolDetailScreen(item: items[index]),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.number,
    required this.item,
    required this.completed,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });

  final int number;
  final ResourceItem item;
  final bool completed;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: item.color.withValues(alpha: .3)),
              ),
              child: Icon(item.icon, color: item.color, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${number.toString().padLeft(2, '0')}  ·  ${item.category.toUpperCase()}',
                    style: TextStyle(
                      color: item.color,
                      fontSize: 8,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.35),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        completed ? Icons.check_circle_rounded : Icons.timer_outlined,
                        color: completed ? VirilColors.gold : VirilColors.muted,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        completed ? 'Пройдено' : item.duration,
                        style: TextStyle(
                          color: completed ? VirilColors.gold : VirilColors.muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavorite,
              tooltip: favorite ? 'Убрать из избранного' : 'В избранное',
              icon: Icon(
                favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: favorite ? VirilColors.gold : VirilColors.muted,
                size: 20,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: VirilColors.muted),
          ],
        ),
      ),
    );
  }
}

class ResourceToolDetailScreen extends StatefulWidget {
  const ResourceToolDetailScreen({super.key, required this.item});

  final ResourceItem item;

  @override
  State<ResourceToolDetailScreen> createState() => _ResourceToolDetailScreenState();
}

class _ResourceToolDetailScreenState extends State<ResourceToolDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final store = ResourceStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final completed = store.isToolCompleted(item.id);
        final favorite = store.isFavorite(item.id);
        return Scaffold(
          backgroundColor: VirilColors.voidBlack,
          appBar: AppBar(
            title: const Text('Инструмент развития'),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                onPressed: () => store.toggleFavorite(item.id),
                tooltip: favorite ? 'Убрать из избранного' : 'В избранное',
                icon: Icon(
                  favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: favorite ? VirilColors.gold : VirilColors.muted,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 53,
                          height: 53,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Icon(item.icon, color: item.color, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.category.toUpperCase(),
                                style: TextStyle(
                                  color: item.color,
                                  fontSize: 9,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.duration,
                                style: const TextStyle(color: VirilColors.muted, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        if (completed)
                          const Icon(Icons.verified_rounded, color: VirilColors.gold, size: 23),
                      ],
                    ),
                    const SizedBox(height: 17),
                    Text(item.title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 7),
                    Text(
                      item.description,
                      style: const TextStyle(color: VirilColors.muted, fontSize: 12, height: 1.55),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _ContentSection(
                eyebrow: 'ПОЧЕМУ ЭТО РАБОТАЕТ',
                title: 'Коротко о главном',
                icon: Icons.school_rounded,
                color: VirilColors.ice,
                child: Text(
                  item.theory,
                  style: const TextStyle(color: VirilColors.text, fontSize: 12, height: 1.65),
                ),
              ),
              const SizedBox(height: 12),
              _ContentSection(
                eyebrow: 'ТВОЙ МИНИ-ЧЕЛЛЕНДЖ',
                title: 'Попробуй выполнить',
                icon: Icons.flag_rounded,
                color: VirilColors.gold,
                child: Text(
                  item.challenge,
                  style: const TextStyle(color: VirilColors.text, fontSize: 12, height: 1.6),
                ),
              ),
              if (item.readingText != null) ...[
                const SizedBox(height: 12),
                _ContentSection(
                  eyebrow: 'МАТЕРИАЛ ДЛЯ ЧТЕНИЯ',
                  title: 'Прочитай вслух',
                  icon: Icons.menu_book_rounded,
                  color: VirilColors.gold,
                  child: SelectableText(
                    item.readingText!,
                    style: const TextStyle(color: VirilColors.text, fontSize: 13, height: 1.8),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _ContentSection(
                eyebrow: 'ПРАКТИКА',
                title: 'Закрепи навык',
                icon: Icons.handyman_rounded,
                color: VirilColors.ice,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.practice,
                      style: const TextStyle(color: VirilColors.text, fontSize: 12, height: 1.6),
                    ),
                    const SizedBox(height: 14),
                    for (var index = 0; index < item.steps.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: item.color, fontWeight: FontWeight.w900, fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.steps[index],
                                style: const TextStyle(fontSize: 11, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  await store.setToolCompleted(item.id, !completed);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        completed ? 'Инструмент возвращён в план' : 'Инструмент отмечен как пройденный',
                      ),
                    ),
                  );
                },
                icon: Icon(completed ? Icons.undo_rounded : Icons.check_circle_outline_rounded),
                label: Text(completed ? 'Отменить выполнение' : 'Я выполнил челлендж'),
                style: FilledButton.styleFrom(
                  backgroundColor: completed ? VirilColors.stone : VirilColors.gold,
                  foregroundColor: completed ? VirilColors.text : VirilColors.voidBlack,
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Отмечай инструмент пройденным после того, как действительно попробовал выполнить задание. Прогресс сохраняется на устройстве.',
                textAlign: TextAlign.center,
                style: TextStyle(color: VirilColors.muted, fontSize: 9, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 8),
              Text(
                eyebrow,
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LibraryLauncherCard extends StatelessWidget {
  const _LibraryLauncherCard({
    required this.title,
    required this.imagePath,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String imagePath;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 12),
        radius: 20,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 88,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent.withValues(alpha: .24), const Color(0xFF171D26)],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 9, offset: Offset(0, 2)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioLibraryLauncherCard extends StatelessWidget {
  const _AudioLibraryLauncherCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 12),
        radius: 20,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 112,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/section_cards/audio_library/audio-library.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF18313C), Color(0xFF111820)],
                      ),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'Аудиотека',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: Colors.black87, blurRadius: 9, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 17,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: .95),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
