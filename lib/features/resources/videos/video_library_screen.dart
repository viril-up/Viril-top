import 'package:flutter/material.dart';
import '../../../core/theme/viril_colors.dart';

class VideoLibraryScreen extends StatelessWidget {
  const VideoLibraryScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:VirilColors.voidBlack,
    appBar:AppBar(title:const Text('Видеотека знаний'),backgroundColor:Colors.transparent),
    body:Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(width:76,height:76,decoration:BoxDecoration(color:VirilColors.ice.withValues(alpha:.12),borderRadius:BorderRadius.circular(24),border:Border.all(color:VirilColors.ice.withValues(alpha:.35))),child:const Icon(Icons.play_circle_outline_rounded,color:VirilColors.ice,size:42)),
      const SizedBox(height:18),const Text('Пространство для коротких знаний',textAlign:TextAlign.center,style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
      const SizedBox(height:8),const Text('Здесь будут появляться короткие видео о мышлении, психологии, привычках, общении, науке и важных жизненных навыках.',textAlign:TextAlign.center,style:TextStyle(color:VirilColors.muted,height:1.55)),
      const SizedBox(height:16),const Text('ПАПКА ДЛЯ ВИДЕО: assets/resources/videos/',style:TextStyle(color:VirilColors.gold,fontSize:10,fontWeight:FontWeight.w800))
    ])))
  );
}
