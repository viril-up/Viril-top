import 'package:flutter/material.dart';
import '../../core/widgets/viril_staggered_list.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import 'data/resource_store.dart';
import 'models/resource_item.dart';
import 'books/book_library_screen.dart';
import 'videos/video_library_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});
  @override State<ResourcesScreen> createState()=>_ResourcesScreenState();
}
class _ResourcesScreenState extends State<ResourcesScreen> {
  static const categories=['Все','Обучение','Практики','База знаний','Психология','Интеллект','Философия','Здоровье','Коммуникация','Карьера','Финансы','Творчество','История','Наука','Факты','Откровения','Время','Отношения','Медиаграмотность','Лидерство'];
  final search=TextEditingController();
  String category='Все';
  final Set<String> filters={};
  bool favoritesOnly=false;
  @override void initState(){super.initState();ResourceStore.instance.initialize();search.addListener(()=>setState((){}));}
  @override void dispose(){search.dispose();super.dispose();}
  Future<void> openFilters()async{
    final selected=Set<String>.from(filters);
    await showModalBottomSheet<void>(context:context,isScrollControlled:true,sheetAnimationStyle:const AnimationStyle(duration:Duration(milliseconds:340),reverseDuration:Duration(milliseconds:260),curve:Curves.easeOutCubic,reverseCurve:Curves.easeInCubic),backgroundColor:VirilColors.stone,
      shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(26))),
      builder:(sheet)=>StatefulBuilder(builder:(ctx,refresh)=>SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(20,18,20,24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Expanded(child:Text('Фильтры ресурсов',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900))),TextButton(onPressed:()=>refresh(()=>selected.clear()),child:const Text('Сбросить'))]),
        const SizedBox(height:12),const Text('ТЕМАТИКА',style:TextStyle(color:VirilColors.gold,fontSize:10,letterSpacing:1.4,fontWeight:FontWeight.w800)),
        const SizedBox(height:8),Wrap(spacing:8,runSpacing:2,children:[for(final c in categories.where((x)=>x!='Все'))FilterChip(label:Text(c),selected:selected.contains(c),onSelected:(v)=>refresh(()=>v?selected.add(c):selected.remove(c)))]),
        const SizedBox(height:14),const Text('ТИП МАТЕРИАЛА',style:TextStyle(color:VirilColors.gold,fontSize:10,letterSpacing:1.4,fontWeight:FontWeight.w800)),
        const SizedBox(height:8),Wrap(spacing:8,children:[for(final t in ['Книги','Видео','Статьи','Аудио','Упражнения','Подборки'])FilterChip(label:Text(t),selected:selected.contains('Тип:$t'),onSelected:(v)=>refresh(()=>v?selected.add('Тип:$t'):selected.remove('Тип:$t')))]),
        const SizedBox(height:16),SizedBox(width:double.infinity,child:FilledButton(onPressed:(){setState((){filters..clear()..addAll(selected);});Navigator.pop(sheet);},child:Text('Показать материалы · ${selected.length} фильтров')))
      ])))));
  }
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:ResourceStore.instance,builder:(context,_){
    final store=ResourceStore.instance;final q=search.text.trim().toLowerCase();
    final topics=filters.where((e)=>!e.startsWith('Тип:')).toSet();
    final types=filters.where((e)=>e.startsWith('Тип:')).map((e)=>e.substring(4)).toSet();
    final items=ResourceItem.catalog.where((i)=>(category=='Все'||i.category==category)&&(topics.isEmpty||topics.contains(i.category))&&(types.isEmpty||types.contains(i.category)||types.contains('Упражнения')&&i.category=='Практики')&&(!favoritesOnly||store.isFavorite(i.id))&&(q.isEmpty||i.title.toLowerCase().contains(q)||i.subtitle.toLowerCase().contains(q)||i.description.toLowerCase().contains(q))).toList();
    return VirilStaggeredList(pageIndex: 2, padding:const EdgeInsets.fromLTRB(20,8,20,120),children:[
      const SectionTitle('Ресурсы',subtitle:'Твоя личная библиотека инструментов и знаний'),
      Row(children:[
        Expanded(child:Container(decoration:BoxDecoration(color:VirilColors.stone.withValues(alpha:.9),borderRadius:BorderRadius.circular(17),border:Border.all(color:VirilColors.line)),
          child:TextField(controller:search,style:const TextStyle(color:VirilColors.text,fontSize:13),decoration:InputDecoration(hintText:'Поиск по библиотеке...',hintStyle:const TextStyle(color:VirilColors.muted,fontSize:12),prefixIcon:const Icon(Icons.search_rounded,color:VirilColors.ice),suffixIcon:q.isEmpty?null:IconButton(onPressed:search.clear,icon:const Icon(Icons.close_rounded,color:VirilColors.muted)),border:InputBorder.none,contentPadding:const EdgeInsets.symmetric(vertical:15))))),
        const SizedBox(width:8),Container(decoration:BoxDecoration(color:VirilColors.stone,borderRadius:BorderRadius.circular(15),border:Border.all(color:filters.isEmpty?VirilColors.line:VirilColors.ice)),child:IconButton(onPressed:openFilters,tooltip:'Фильтры',icon:Icon(Icons.tune_rounded,color:filters.isEmpty?VirilColors.ice:VirilColors.gold)))
      ]),
      const SizedBox(height:14),SizedBox(height:40,child:ListView(scrollDirection:Axis.horizontal,children:[for(final c in ['Все','Обучение','Практики','База знаний'])Padding(padding:const EdgeInsets.only(right:7),child:ChoiceChip(label:Text(c),selected:category==c,onSelected:(_)=>setState(()=>category=c),selectedColor:VirilColors.ice.withValues(alpha:.2),backgroundColor:VirilColors.stone,side:BorderSide(color:category==c?VirilColors.ice:VirilColors.line),labelStyle:TextStyle(color:category==c?VirilColors.ice:VirilColors.muted,fontSize:11,fontWeight:FontWeight.w700)))])),
      const SizedBox(height:14),InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const BookLibraryScreen())),borderRadius:BorderRadius.circular(22),child:Container(padding:const EdgeInsets.all(17),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:const LinearGradient(colors:[Color(0xFF202A36),Color(0xFF151C26)]),border:Border.all(color:VirilColors.line)),child:Row(children:[
        Container(width:52,height:62,decoration:BoxDecoration(color:VirilColors.navyLight.withValues(alpha:.55),borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.menu_book_rounded,color:VirilColors.gold,size:29)),
        const SizedBox(width:14),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('БИБЛИОТЕКА КНИГ',style:TextStyle(color:VirilColors.gold,fontSize:9,letterSpacing:1.5,fontWeight:FontWeight.w900)),SizedBox(height:5),
          Text('Читай. Осмысливай. Сохраняй.',style:TextStyle(fontSize:15,fontWeight:FontWeight.w900)),SizedBox(height:4),
          Text('Твоя личная коллекция книг и заметок',style:TextStyle(color:VirilColors.muted,fontSize:10))
        ])),const Icon(Icons.arrow_forward_ios_rounded,color:VirilColors.gold,size:16)
      ]))),
      const SizedBox(height:12),InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const VideoLibraryScreen())),borderRadius:BorderRadius.circular(20),child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:VirilColors.stone,borderRadius:BorderRadius.circular(20),border:Border.all(color:VirilColors.ice.withValues(alpha:.25))),child:Row(children:[
        Container(width:44,height:44,decoration:BoxDecoration(color:VirilColors.ice.withValues(alpha:.12),borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.play_circle_outline_rounded,color:VirilColors.ice,size:25)),
        const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('ВИДЕОТЕКА ЗНАНИЙ',style:TextStyle(color:VirilColors.ice,fontSize:9,letterSpacing:1.4,fontWeight:FontWeight.w900)),
          SizedBox(height:4),Text('Короткие видео, большие идеи',style:TextStyle(fontSize:13,fontWeight:FontWeight.w800)),
          SizedBox(height:3),Text('Познавательные ролики и жизненные уроки',style:TextStyle(color:VirilColors.muted,fontSize:10))
        ])),const Icon(Icons.arrow_forward_ios_rounded,color:VirilColors.ice,size:14)
      ]))),
      const SizedBox(height:14),Row(children:[Expanded(child:Text('${items.length} МАТЕРИАЛОВ',style:const TextStyle(color:VirilColors.gold,letterSpacing:1.6,fontSize:9,fontWeight:FontWeight.w800))),TextButton.icon(onPressed:()=>setState(()=>favoritesOnly=!favoritesOnly),icon:Icon(favoritesOnly?Icons.bookmark_rounded:Icons.bookmark_border_rounded,size:17),label:Text(favoritesOnly?'Избранное':'Все материалы'),style:TextButton.styleFrom(foregroundColor:favoritesOnly?VirilColors.gold:VirilColors.muted))]),
      if(items.isEmpty)GlassCard(child:Column(children:[const Icon(Icons.search_off_rounded,color:VirilColors.muted,size:30),const SizedBox(height:8),const Text('Ничего не найдено',style:TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:4),const Text('Измени запрос или выбери другую категорию.',style:TextStyle(color:VirilColors.muted,fontSize:11))])) else for(final item in items)_ResourceCard(item:item,favorite:store.isFavorite(item.id),hasNote:store.noteFor(item.id).isNotEmpty,onFavorite:()=>store.toggleFavorite(item.id),onOpen:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ResourceDetailScreen(item:item))))
    ]);
  });
}
class _ResourceCard extends StatelessWidget{
  const _ResourceCard({required this.item,required this.favorite,required this.hasNote,required this.onFavorite,required this.onOpen});
  final ResourceItem item;final bool favorite,hasNote;final VoidCallback onFavorite,onOpen;
  @override Widget build(BuildContext context)=>InkWell(onTap:onOpen,borderRadius:BorderRadius.circular(23),child:GlassCard(margin:const EdgeInsets.only(bottom:12),child:Row(children:[
    Container(width:50,height:50,decoration:BoxDecoration(color:item.color.withValues(alpha:.13),borderRadius:BorderRadius.circular(16),border:Border.all(color:item.color.withValues(alpha:.3))),child:Icon(item.icon,color:item.color,size:25)),
    const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(item.category.toUpperCase(),style:TextStyle(color:item.color,fontSize:8,letterSpacing:1.4,fontWeight:FontWeight.w800)),const SizedBox(height:4),
      Text(item.title,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w800)),const SizedBox(height:4),
      Text(item.subtitle,style:const TextStyle(color:VirilColors.muted,fontSize:10,height:1.35)),
      if(hasNote)const Padding(padding:EdgeInsets.only(top:5),child:Text('ЕСТЬ ТВОЯ ЗАМЕТКА',style:TextStyle(color:VirilColors.ice,fontSize:8,letterSpacing:1)))
    ])),IconButton(onPressed:onFavorite,icon:Icon(favorite?Icons.bookmark_rounded:Icons.bookmark_border_rounded,color:favorite?VirilColors.gold:VirilColors.muted))
  ])));
}

class ResourceDetailScreen extends StatefulWidget {
  const ResourceDetailScreen({super.key,required this.item});
  final ResourceItem item;
  @override State<ResourceDetailScreen> createState()=>_ResourceDetailScreenState();
}
class _ResourceDetailScreenState extends State<ResourceDetailScreen>{
  late final TextEditingController note=TextEditingController(text:ResourceStore.instance.noteFor(widget.item.id));
  @override void dispose(){note.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final item=widget.item;
    return Scaffold(backgroundColor:VirilColors.voidBlack,appBar:AppBar(title:const Text('Материал'),backgroundColor:Colors.transparent),
      body:ListView(padding:const EdgeInsets.fromLTRB(20,8,20,30),children:[
        GlassCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(width:56,height:56,decoration:BoxDecoration(color:item.color.withValues(alpha:.14),borderRadius:BorderRadius.circular(17)),child:Icon(item.icon,color:item.color,size:29)),
          const SizedBox(height:16),Text(item.category.toUpperCase(),style:TextStyle(color:item.color,fontSize:9,letterSpacing:1.7,fontWeight:FontWeight.w800)),
          const SizedBox(height:6),Text(item.title,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),
          const SizedBox(height:8),Text(item.description,style:const TextStyle(color:VirilColors.muted,fontSize:12,height:1.55)),
          if(item.duration!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text(item.duration!,style:const TextStyle(color:VirilColors.gold,fontSize:11,fontWeight:FontWeight.w700)))
        ])),
        const SizedBox(height:20),const Text('ПОРЯДОК РАБОТЫ',style:TextStyle(color:VirilColors.gold,fontSize:10,letterSpacing:1.8,fontWeight:FontWeight.w800)),
        const SizedBox(height:10),for(var i=0;i<item.steps.length;i++)GlassCard(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(14),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Container(width:27,height:27,alignment:Alignment.center,decoration:BoxDecoration(color:item.color.withValues(alpha:.15),borderRadius:BorderRadius.circular(9)),child:Text('${i+1}',style:TextStyle(color:item.color,fontWeight:FontWeight.w900))),
          const SizedBox(width:11),Expanded(child:Text(item.steps[i],style:const TextStyle(fontSize:12,height:1.45)))
        ])),
        const SizedBox(height:12),GlassCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('ТВОИ ЗАМЕТКИ',style:TextStyle(color:VirilColors.gold,fontSize:10,letterSpacing:1.6,fontWeight:FontWeight.w800)),
          const SizedBox(height:9),TextField(controller:note,minLines:3,maxLines:7,style:const TextStyle(color:VirilColors.text,fontSize:12,height:1.45),decoration:InputDecoration(hintText:'Запиши свои мысли, выводы или вопросы...',hintStyle:const TextStyle(color:VirilColors.muted,fontSize:11),filled:true,fillColor:VirilColors.voidBlack.withValues(alpha:.45),border:OutlineInputBorder(borderRadius:BorderRadius.circular(14)))),
          const SizedBox(height:12),Row(children:[
            Expanded(child:OutlinedButton.icon(onPressed:()=>ResourceStore.instance.toggleFavorite(item.id),icon:const Icon(Icons.bookmark_border_rounded),label:const Text('В избранное'))),
            const SizedBox(width:9),Expanded(child:FilledButton.icon(onPressed:()async{await ResourceStore.instance.saveNote(item.id,note.text);if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Заметка сохранена на устройстве')));},icon:const Icon(Icons.save_rounded),label:const Text('Сохранить')))
          ])
        ]))
      ]));
  }
}
