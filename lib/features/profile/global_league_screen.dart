import 'package:flutter/material.dart';
import '../../core/data/viril_store.dart';
import '../../core/theme/viril_colors.dart';
import 'data/league_data.dart';
import 'league_path_screen.dart';

class GlobalLeagueScreen extends StatefulWidget {
 const GlobalLeagueScreen({super.key});
 @override State<GlobalLeagueScreen> createState()=>_GlobalLeagueScreenState();
}
class _GlobalLeagueScreenState extends State<GlobalLeagueScreen>{
 int tab=0;
 @override Widget build(BuildContext context)=>AnimatedBuilder(
  animation:VirilStore.instance,builder:(context,_){
   final s=VirilStore.instance; final league=LeagueSystem.forXp(s.xp); final now=DateTime.now();
   return Scaffold(
    appBar:AppBar(title:const Text('Глобальная лига'),),
    body:ListView(padding:const EdgeInsets.fromLTRB(17,8,17,35),children:[
     _podium(),const SizedBox(height:16),
     _season(now,league.name,s.xp),const SizedBox(height:13),
     _pathButton(context,s.xp,league),const SizedBox(height:17),
     Row(children:[
      _Tab(label:'Топ 100 мира',selected:tab==0,onTap:()=>setState(()=>tab=0)),
      const SizedBox(width:6),_Tab(label:'Рекорды сезонов',selected:tab==1,onTap:()=>setState(()=>tab=1)),
      const SizedBox(width:6),_Tab(label:'Мой результат',selected:tab==2,onTap:()=>setState(()=>tab=2)),
     ]),const SizedBox(height:15),
     if(tab==0)_empty(Icons.public_rounded,'Мировой рейтинг скоро откроется','Раздел ТОП-100 и пьедестал сохранены. Реальные игроки, места и XP появятся после подключения игровых аккаунтов и общего сервера.'),
     if(tab==1)_empty(Icons.emoji_events_rounded,'История сезонов появится позже','Рекорды будут сохраняться после запуска серверных сезонов.'),
     if(tab==2)_result(s.xp,LeagueSystem.globalLevelForXp(s.xp),league.name),
    ]));
  });
 Widget _podium()=>Container(padding:const EdgeInsets.fromLTRB(12,17,12,15),
  decoration:BoxDecoration(borderRadius:BorderRadius.circular(23),
   gradient:const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xFF342D20),Color(0xFF171923),Color(0xFF11151F)]),
   border:Border.all(color:VirilColors.gold.withValues(alpha:.55))),
  child:Column(children:[
   const Text('ЗАЛ СЛАВЫ · ТЕКУЩИЙ СЕЗОН',style:TextStyle(color:VirilColors.gold,fontSize:10,letterSpacing:1.7,fontWeight:FontWeight.w900)),
   const SizedBox(height:17),Row(crossAxisAlignment:CrossAxisAlignment.end,children:[
    Expanded(child:_Place(rank:2,label:'СЕРЕБРО',height:104,color:const Color(0xFFB7C0C9),delay:250)),
    Expanded(child:_Place(rank:1,label:'ЗОЛОТО',height:137,color:VirilColors.gold,delay:0)),
    Expanded(child:_Place(rank:3,label:'БРОНЗА',height:88,color:const Color(0xFFB9784E),delay:450)),
   ]),const SizedBox(height:12),
   const Text('Места и имена появятся после запуска серверного рейтинга.',textAlign:TextAlign.center,style:TextStyle(color:VirilColors.muted,fontSize:10)),
  ]));
 Widget _season(DateTime now,String league,int xp)=>Container(padding:const EdgeInsets.all(15),
  decoration:BoxDecoration(color:VirilColors.stone,borderRadius:BorderRadius.circular(18),border:Border.all(color:VirilColors.line)),
  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(_month(now.month)+' ${now.year}',style:const TextStyle(color:VirilColors.gold,fontWeight:FontWeight.w900,letterSpacing:1.1)),
   const SizedBox(height:10),Row(children:[
    const Icon(Icons.military_tech_rounded,color:VirilColors.gold,size:27),const SizedBox(width:9),
    Expanded(child:Text('ТВОЯ ЛИГА · ${league.toUpperCase()}',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w900))),
    Text('$xp XP',style:const TextStyle(color:VirilColors.gold,fontWeight:FontWeight.w900)),
   ])
  ]));
 Widget _pathButton(BuildContext context,int xp,LeagueDefinition league)=>InkWell(
  borderRadius:BorderRadius.circular(17),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const LeaguePathScreen())),
  child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(
   borderRadius:BorderRadius.circular(17),gradient:const LinearGradient(colors:[Color(0xFF332C20),Color(0xFF191B25)]),
   border:Border.all(color:VirilColors.gold.withValues(alpha:.6))),
   child:Row(children:[
    Container(width:43,height:43,decoration:BoxDecoration(shape:BoxShape.circle,color:VirilColors.gold.withValues(alpha:.12),border:Border.all(color:VirilColors.gold.withValues(alpha:.6))),
     child:const Icon(Icons.route_rounded,color:VirilColors.gold)),
    const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text('ПУТЬ 60 ГЛОБАЛЬНЫХ ЛИГ',style:TextStyle(color:VirilColors.gold,fontSize:10,letterSpacing:.9,fontWeight:FontWeight.w900)),
     const SizedBox(height:4),Text('5 эпох · 180 уровней · сейчас: ${league.name} · ${LeagueSystem.globalLevelForXp(xp)} уровень',style:const TextStyle(color:VirilColors.muted,fontSize:9)),
    ])),const Icon(Icons.arrow_forward_ios_rounded,color:VirilColors.gold,size:15),
   ])));
 Widget _empty(IconData icon,String title,String body)=>Container(padding:const EdgeInsets.all(24),
  decoration:BoxDecoration(color:VirilColors.stone,borderRadius:BorderRadius.circular(18),border:Border.all(color:VirilColors.line)),
  child:Column(children:[Icon(icon,color:VirilColors.gold,size:35),const SizedBox(height:12),
   Text(title,textAlign:TextAlign.center,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:15)),
   const SizedBox(height:7),Text(body,textAlign:TextAlign.center,style:const TextStyle(color:VirilColors.muted,fontSize:11,height:1.5))]));
 Widget _result(int xp,int level,String league)=>Container(padding:const EdgeInsets.all(18),
  decoration:BoxDecoration(color:VirilColors.stone,borderRadius:BorderRadius.circular(18),border:Border.all(color:VirilColors.gold.withValues(alpha:.35))),
  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const Text('ТВОЙ ЛОКАЛЬНЫЙ РЕЗУЛЬТАТ',style:TextStyle(color:VirilColors.gold,fontWeight:FontWeight.w900,letterSpacing:1.2,fontSize:10)),
   const SizedBox(height:14),_row('Лига',league),_row('Уровень','$level'),_row('Накопленный XP','$xp'),_row('Место в мире','Не рассчитано'),
   const SizedBox(height:8),const Text('Это данные текущего устройства, они ещё не синхронизированы с глобальным рейтингом.',style:TextStyle(color:VirilColors.muted,fontSize:10,height:1.45))
  ]));
 Widget _row(String label,String value)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[
  Expanded(child:Text(label,style:const TextStyle(color:VirilColors.muted,fontSize:12))),
  Text(value,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13))
 ]));
 static String _month(int m)=>const ['ЯНВАРЬ','ФЕВРАЛЬ','МАРТ','АПРЕЛЬ','МАЙ','ИЮНЬ','ИЮЛЬ','АВГУСТ','СЕНТЯБРЬ','ОКТЯБРЬ','НОЯБРЬ','ДЕКАБРЬ'][m-1];
}
class _Place extends StatelessWidget{
 const _Place({required this.rank,required this.label,required this.height,required this.color,required this.delay});
 final int rank,height,delay;final String label;final Color color;
 @override Widget build(BuildContext context)=>TweenAnimationBuilder<double>(
  tween:Tween(begin:.25,end:1),duration:Duration(milliseconds:850+delay),curve:Curves.easeOutBack,
  builder:(context,v,child)=>Opacity(opacity:v.clamp(0,1),child:Transform.translate(offset:Offset(0,(1-v)*22),child:child)),
  child:Column(mainAxisAlignment:MainAxisAlignment.end,children:[
   Icon(Icons.emoji_events_rounded,color:color,size:rank==1?32:25),const SizedBox(height:5),
   Text('—',style:TextStyle(color:color,fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:5),
   Container(height:height.toDouble(),margin:const EdgeInsets.symmetric(horizontal:4),
    decoration:BoxDecoration(borderRadius:const BorderRadius.vertical(top:Radius.circular(10)),
     gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[color.withValues(alpha:.38),color.withValues(alpha:.08)]),
     border:Border.all(color:color.withValues(alpha:.65))),
    child:Center(child:Text('$rank',style:TextStyle(color:color,fontSize:27,fontWeight:FontWeight.w900)))),
   const SizedBox(height:7),Text(label,style:TextStyle(color:color,fontSize:8,letterSpacing:.8,fontWeight:FontWeight.w900)),
   const SizedBox(height:3),const Text('ОЖИДАНИЕ',style:TextStyle(color:VirilColors.muted,fontSize:7))
  ]));
}
class _Tab extends StatelessWidget{
 const _Tab({required this.label,required this.selected,required this.onTap});
 final String label;final bool selected;final VoidCallback onTap;
 @override Widget build(BuildContext context)=>Expanded(child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(12),
  child:Container(height:48,alignment:Alignment.center,padding:const EdgeInsets.symmetric(horizontal:4),
   decoration:BoxDecoration(color:selected?VirilColors.gold.withValues(alpha:.16):VirilColors.stone,borderRadius:BorderRadius.circular(12),
    border:Border.all(color:selected?VirilColors.gold:VirilColors.line)),
   child:Text(label,textAlign:TextAlign.center,style:TextStyle(fontSize:9,fontWeight:FontWeight.w800,color:selected?VirilColors.gold:VirilColors.muted)))));
}
