import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

class AudioLibraryScreen extends StatelessWidget {
  const AudioLibraryScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(title: const Text('Аудиотека'), backgroundColor: Colors.transparent),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), children: [
      GlassCard(child: Column(children: [
        Container(width: 76, height: 76, decoration: BoxDecoration(
          shape: BoxShape.circle, color: VirilColors.ice.withValues(alpha: .12),
          border: Border.all(color: VirilColors.ice.withValues(alpha: .4))),
          child: const Icon(Icons.headphones_rounded, color: VirilColors.ice, size: 36)),
        const SizedBox(height: 14),
        const Text('ТВОЯ АУДИОТЕКА', style: TextStyle(color: VirilColors.gold, fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Здесь будут собраны аудиоматериалы Viril: полезные лекции, практики, медитации и аудиокниги.',
          textAlign: TextAlign.center, style: TextStyle(color: VirilColors.muted, fontSize: 11, height: 1.5)),
        const SizedBox(height: 16),
        const _ComingSoonTag(),
      ])),
    ]),
  );
}

class _ComingSoonTag extends StatelessWidget {
  const _ComingSoonTag();
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(color: VirilColors.ice.withValues(alpha: .1), borderRadius: BorderRadius.circular(30),
      border: Border.all(color: VirilColors.ice.withValues(alpha: .35))),
    child: const Text('СКОРО ПОЯВИТСЯ', style: TextStyle(color: VirilColors.ice, fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
  );
}
