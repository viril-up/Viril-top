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
  late final Future<List<BookItem>> books= _load();
  Future<List<BookItem>> _load() async {
    final raw=await rootBundle.loadString('assets/resources/catalog/books.json');
    return (jsonDecode(raw) as List).map((e)=>BookItem.fromJson(e as Map<String,dynamic>)).toList();
  }
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:VirilColors.voidBlack,appBar:AppBar(title:const Text('Библиотека книг'),backgroundColor:Colors.transparent,actions:[IconButton(tooltip:'Дневник читателя',icon:const Icon(Icons.edit_note_rounded),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const ReadingJournalScreen()))) ]),
    body:FutureBuilder<List<BookItem>>(future:books,builder:(context,s){
      if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
      if(s.hasError)return const Center(child:Text('Не удалось загрузить каталог'));
      final list=s.data??[];
      if(list.isEmpty)return const Center(child:Padding(padding:EdgeInsets.all(28),child:Column(mainAxisSize:MainAxisSize.min,children:[
        Icon(Icons.menu_book_rounded,color:VirilColors.gold,size:54),SizedBox(height:16),
        Text('Библиотека готова к наполнению',textAlign:TextAlign.center,style:TextStyle(fontSize:19,fontWeight:FontWeight.w800)),
        SizedBox(height:8),Text('Добавь PDF-книгу, обложку и описание в папки assets/resources, затем внеси запись в books.json.',textAlign:TextAlign.center,style:TextStyle(color:VirilColors.muted,height:1.5))
      ])));
      return ListView.builder(padding:const EdgeInsets.all(18),itemCount:list.length,itemBuilder:(context,i){
        final b=list[i];
        return Card(color:VirilColors.stone,margin:const EdgeInsets.only(bottom:14),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20),side:const BorderSide(color:VirilColors.line)),
          child:InkWell(borderRadius:BorderRadius.circular(20),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>BookReaderScreen(book:b))),
            child:Padding(padding:const EdgeInsets.all(13),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
              ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.asset(b.cover,width:88,height:124,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(width:88,height:124,color:VirilColors.stoneLight,child:const Icon(Icons.menu_book,color:VirilColors.gold,size:34)))),
              const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(b.genre.toUpperCase(),style:const TextStyle(color:VirilColors.gold,fontSize:9,letterSpacing:1.3,fontWeight:FontWeight.w800)),
                const SizedBox(height:6),Text(b.title,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800)),
                const SizedBox(height:4),Text(b.author,style:const TextStyle(color:VirilColors.ice,fontSize:11)),
                const SizedBox(height:8),Text(b.description,maxLines:4,overflow:TextOverflow.ellipsis,style:const TextStyle(color:VirilColors.muted,fontSize:11,height:1.4)),
                const SizedBox(height:8),AnimatedBuilder(animation:ResourceStore.instance,builder:(_,__)=>Text(ResourceStore.instance.pageForBook(b.id)>1?'Продолжить · страница ${ResourceStore.instance.pageForBook(b.id)}':'Начать чтение',style:const TextStyle(color:VirilColors.gold,fontSize:10,fontWeight:FontWeight.w800)))
              ]))
            ]))));
      });
    }),
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
  double brightness=1;
  int page=1;
  Color pageColor=const Color(0xFFFFFFFF);
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
      Padding(padding:const EdgeInsets.fromLTRB(14,8,14,10),child:Row(children:[
        const Icon(Icons.brightness_6_outlined,color:VirilColors.gold,size:17),
        Expanded(child:Slider(value:brightness,min:.45,max:1.35,onChanged:(v)=>setState(()=>brightness=v))),
        PopupMenuButton<Color>(tooltip:'Цвет страницы',icon:const Icon(Icons.palette_outlined,color:VirilColors.ice),onSelected:(c)=>setState(()=>pageColor=c),itemBuilder:(_)=>const[
          PopupMenuItem(value:Color(0xFFFFFFFF),child:Text('Белая')),
          PopupMenuItem(value:Color(0xFFF4EBD8),child:Text('Тёплая')),
          PopupMenuItem(value:Color(0xFF242832),child:Text('Тёмная'))
        ])
      ])),
      Expanded(child:Container(color:pageColor,child:ColorFiltered(
        colorFilter:ColorFilter.matrix([brightness,0,0,0,0,0,brightness,0,0,0,0,0,brightness,0,0,0,0,0,1,0]),
        child:PdfViewer.asset(widget.book.file,controller:controller,initialPageNumber:page,params:PdfViewerParams(onPageChanged:(p){
          if(p==null||!mounted)return;setState(()=>page=p);ResourceStore.instance.saveBookPage(widget.book.id,p);note.text=ResourceStore.instance.noteForBookPage(widget.book.id,p);
        }))
      ))),
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
