import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/theme/viril_colors.dart';
import '../data/resource_store.dart';

class BookItem {
  const BookItem({required this.id, required this.title, required this.author, required this.description, required this.cover, required this.file, this.genre='Саморазвитие'});
  final String id,title,author,description,cover,file,genre;
  factory BookItem.fromJson(Map<String,dynamic> j)=>BookItem(id:j['id'],title:j['title'],author:j['author']??'Автор не указан',description:j['description']??'',cover:j['cover'],file:j['file'],genre:j['genre']??'Саморазвитие');
}
class BookLibraryScreen extends StatefulWidget {
  const BookLibraryScreen({super.key});
  @override State<BookLibraryScreen> createState()=>_BookLibraryScreenState();
}
class _BookLibraryScreenState extends State<BookLibraryScreen> {
  late final Future<List<BookItem>> books = _load();
  final TextEditingController search = TextEditingController();
  String genre = 'Все';

  Future<List<BookItem>> _load() async {
    await ResourceStore.instance.initialize();
    final raw = await rootBundle.loadString('assets/resources/catalog/books.json');
    final rows = jsonDecode(raw) as List;
    final result = <BookItem>[];
    for (final row in rows) {
      final item = Map<String, dynamic>.from(row as Map);
      final descriptionFile = item['descriptionFile'];
      if (descriptionFile is String && descriptionFile.isNotEmpty) {
        item['description'] = await rootBundle.loadString(descriptionFile);
      }
      result.add(BookItem.fromJson(item));
    }
    return result;
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(
      title: const Text('Библиотека книг'),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          tooltip: 'Дневник читателя',
          icon: const Icon(Icons.edit_note_rounded),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingJournalScreen())),
        ),
      ],
    ),
    body: FutureBuilder<List<BookItem>>(
      future: books,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Text('Не удалось загрузить каталог'));
        final allBooks = snapshot.data ?? [];
        if (allBooks.isEmpty) return const Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.menu_book_rounded, color: VirilColors.gold, size: 54),
              SizedBox(height: 16),
              Text('Библиотека готова к наполнению', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text('Добавь PDF-книгу, обложку и описание в папки assets/resources, затем внеси запись в books.json.',
                textAlign: TextAlign.center, style: TextStyle(color: VirilColors.muted, height: 1.5)),
            ]),
          ),
        );

        final genres = ['Все', ...allBooks.map((book) => book.genre).toSet().toList()];
        final query = search.text.trim().toLowerCase();
        final filtered = allBooks.where((book) =>
          (genre == 'Все' || book.genre == genre) &&
          (query.isEmpty || book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) || book.description.toLowerCase().contains(query))
        ).toList();

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Найти книгу или автора',
                prefixIcon: const Icon(Icons.search_rounded, color: VirilColors.ice),
                filled: true,
                fillColor: VirilColors.stone,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: VirilColors.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: VirilColors.line)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 7, runSpacing: 3, children: [
              for (final value in genres)
                ChoiceChip(
                  label: Text(value),
                  selected: genre == value,
                  onSelected: (_) => setState(() => genre = value),
                  selectedColor: VirilColors.ice.withValues(alpha: .2),
                  backgroundColor: VirilColors.stone,
                ),
            ]),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('По этому запросу книг пока нет.', textAlign: TextAlign.center,
                  style: TextStyle(color: VirilColors.muted)),
              ),
            for (final book in filtered)
              Card(
                color: VirilColors.stone,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: VirilColors.line)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookReaderScreen(book: book))),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(book.cover, width: 88, height: 124, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 88, height: 124, color: VirilColors.stoneLight,
                            child: const Icon(Icons.menu_book, color: VirilColors.gold, size: 34))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(book.genre.toUpperCase(), style: const TextStyle(color: VirilColors.gold,
                          fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(book.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(book.author, style: const TextStyle(color: VirilColors.ice, fontSize: 11)),
                        const SizedBox(height: 8),
                        Text(book.description, maxLines: 4, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.4)),
                        const SizedBox(height: 8),
                        AnimatedBuilder(animation: ResourceStore.instance, builder: (_, __) {
                          final page = ResourceStore.instance.pageForBook(book.id);
                          return Text(page > 1 ? 'Продолжить · страница $page' : 'Начать чтение',
                            style: const TextStyle(color: VirilColors.gold, fontSize: 10, fontWeight: FontWeight.w800));
                        }),
                      ])),
                    ]),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({super.key,required this.book});
  final BookItem book;
  @override State<BookReaderScreen> createState()=>_BookReaderScreenState();
}
class _BookReaderScreenState extends State<BookReaderScreen> {
  final PdfViewerController controller=PdfViewerController();
  final TextEditingController note=TextEditingController();
  int page=1;
  @override void initState(){super.initState();page=ResourceStore.instance.pageForBook(widget.book.id);note.text=ResourceStore.instance.noteForBookPage(widget.book.id,page);}
  @override void dispose(){note.dispose();super.dispose();}
  Future<void> saveNote()async{await ResourceStore.instance.saveBookPageNote(widget.book.id,page,note.text);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Заметка сохранена')));}
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:VirilColors.voidBlack,
    appBar:AppBar(title:Text(widget.book.title,maxLines:1,overflow:TextOverflow.ellipsis),backgroundColor:Colors.transparent,actions:[
      IconButton(tooltip:'Заметка к странице',icon:const Icon(Icons.edit_note_rounded),onPressed:()=>showModalBottomSheet(context:context,isScrollControlled:true,backgroundColor:VirilColors.stone,builder:(ctx)=>Padding(
        padding:EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(ctx).viewInsets.bottom+20),
        child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Заметка · страница $page',style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:12),
          TextField(controller:note,minLines:3,maxLines:6,decoration:const InputDecoration(hintText:'Что важно запомнить?')),
          const SizedBox(height:12),FilledButton(onPressed:(){saveNote();Navigator.pop(ctx);},child:const Text('Сохранить'))
        ])))),
      PopupMenuButton<int>(tooltip:'Закладки',icon:const Icon(Icons.bookmark_add_outlined),onSelected:(value)async{if(value==-1){await ResourceStore.instance.toggleBookBookmark(widget.book.id,page);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Закладка обновлена')));}else{await controller.goToPage(pageNumber:value);}},itemBuilder:(_){final saved=ResourceStore.instance.bookmarksForBook(widget.book.id);return [PopupMenuItem<int>(value:-1,child:Text('Добавить / убрать страницу $page')),if(saved.isNotEmpty)const PopupMenuDivider(),for(final savedPage in saved)PopupMenuItem<int>(value:savedPage,child:Text('Перейти к странице $savedPage'))];})
    ]),
    body:Column(children:[
      Expanded(child:PdfViewer.asset(
        widget.book.file,
        key: ValueKey(widget.book.id),
        controller: controller,
        initialPageNumber: page,
        params: PdfViewerParams(
          backgroundColor: VirilColors.voidBlack,
          onPageChanged: (p) {
            if (p == null || !mounted) return;
            setState(() => page = p);
            ResourceStore.instance.saveBookPage(widget.book.id, p);
            note.text = ResourceStore.instance.noteForBookPage(widget.book.id, p);
          },
        ),
      )),
      SafeArea(top:false,child:Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),child:Row(children:[
        IconButton(onPressed:page>1?()=>controller.goToPage(pageNumber:page-1):null,icon:const Icon(Icons.chevron_left_rounded)),
        Expanded(child:Center(child:Text('Страница $page',style:const TextStyle(color:VirilColors.muted,fontSize:12)))),
        IconButton(onPressed:()=>controller.goToPage(pageNumber:page+1),icon:const Icon(Icons.chevron_right_rounded))
      ])))
    ])
  );
}

class ReadingJournalScreen extends StatefulWidget{
  const ReadingJournalScreen({super.key});
  @override State<ReadingJournalScreen> createState()=>_ReadingJournalScreenState();
}
class _ReadingJournalScreenState extends State<ReadingJournalScreen>{
  late final TextEditingController controller=TextEditingController(text:ResourceStore.instance.journal);
  @override void dispose(){controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:VirilColors.voidBlack,appBar:AppBar(title:const Text('Дневник читателя'),backgroundColor:Colors.transparent),
    body:ListView(padding:const EdgeInsets.all(20),children:[
      const Text('МЫСЛИ, КОТОРЫЕ СТОИТ СОХРАНИТЬ',style:TextStyle(color:VirilColors.gold,fontSize:10,letterSpacing:1.5,fontWeight:FontWeight.w800)),
      const SizedBox(height:10),const Text('Записывай идеи, выводы и вопросы, к которым захочешь вернуться.',style:TextStyle(color:VirilColors.muted,height:1.5)),
      const SizedBox(height:16),TextField(controller:controller,minLines:14,maxLines:30,decoration:InputDecoration(hintText:'Сегодня я прочитал(а)…\\n\\nГлавная мысль…\\n\\nЧто хочу применить…',filled:true,fillColor:VirilColors.stone,border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:const BorderSide(color:VirilColors.line)))),
      const SizedBox(height:14),FilledButton.icon(onPressed:()async{await ResourceStore.instance.saveJournal(controller.text);if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Дневник сохранён')));},icon:const Icon(Icons.save_rounded),label:const Text('Сохранить записи'))
    ]));
}
