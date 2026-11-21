import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});
  @override State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with SingleTickerProviderStateMixin {
  static const _presets = [3, 5, 10, 15, 20];
  int _minutes = 5;
  int _remaining = 300;
  Timer? _timer;
  bool _active = false;
  bool _breathing = false;
  late final AnimationController _breath = AnimationController(vsync: this, duration: const Duration(seconds: 4), lowerBound: .82, upperBound: 1.08);

  @override void dispose() { _timer?.cancel(); _breath.dispose(); super.dispose(); }

  void _start() {
    if (_remaining <= 0) _remaining = _minutes * 60;
    _timer?.cancel();
    setState(() { _active = true; _breathing = true; });
    _breath.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        _breath.stop();
        setState(() { _remaining = 0; _active = false; _breathing = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Практика завершена. Отличная работа!')));
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    _breath.stop();
    setState(() { _active = false; _breathing = false; });
  }

  void _reset() {
    _timer?.cancel();
    _breath.stop();
    setState(() { _active = false; _breathing = false; _remaining = _minutes * 60; });
  }

  String get _formatted => '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}';

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: VirilColors.voidBlack,
    appBar: AppBar(title: const Text('Медитация'), backgroundColor: Colors.transparent),
    body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 30), children: [
      GlassCard(child: Column(children: [
        const Text('ВРЕМЯ ДЛЯ СЕБЯ', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w900)),
        const SizedBox(height: 22),
        AnimatedBuilder(animation: _breath, builder: (context, _) => Transform.scale(
          scale: _breathing ? _breath.value : 1,
          child: Container(width: 178, height: 178,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [VirilColors.ice.withValues(alpha: .28), VirilColors.navy.withValues(alpha: .35), VirilColors.stone]),
              border: Border.all(color: VirilColors.ice.withValues(alpha: .5), width: 1.4),
              boxShadow: [BoxShadow(color: VirilColors.ice.withValues(alpha: .12), blurRadius: 28, spreadRadius: 5)]),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_formatted, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()])),
              const SizedBox(height: 5),
              Text(_active ? 'ДЫШИ СПОКОЙНО' : 'МЕДИТАЦИЯ', style: const TextStyle(color: VirilColors.ice, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
            ])),
          ),
        )),
        const SizedBox(height: 24),
        const Text('ДЛИТЕЛЬНОСТЬ', style: TextStyle(color: VirilColors.muted, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(spacing: 7, children: [for (final m in _presets)
          ChoiceChip(label: Text('$m мин'), selected: _minutes == m, onSelected: _active ? null : (_) => setState(() { _minutes = m; _remaining = m * 60; }))]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: FilledButton.icon(onPressed: _active ? _pause : _start,
            icon: Icon(_active ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(_active ? 'Пауза' : 'Начать'))),
          const SizedBox(width: 9),
          OutlinedButton(onPressed: _reset, child: const Text('Сбросить')),
        ]),
      ])),
      const SizedBox(height: 14),
      GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('ПРОСТАЯ ПРАКТИКА', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
        SizedBox(height: 12),
        _MeditationStep(number: '01', title: 'Устройся удобно', text: 'Выбери спокойное место и расслабь плечи.'),
        _MeditationStep(number: '02', title: 'Сосредоточься на дыхании', text: 'Дыши естественно, не стараясь менять ритм.'),
        _MeditationStep(number: '03', title: 'Возвращай внимание', text: 'Если отвлёкся, спокойно вернись к ощущениям дыхания.'),
        _MeditationStep(number: '04', title: 'Заверши практику', text: 'Не спеши вставать. Заметь, как ты себя чувствуешь.'),
      ])),
      const SizedBox(height: 12),
      const Text('Начинай с комфортной продолжительности. Если практика вызывает дискомфорт, можно остановиться в любой момент.',
        style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.5)),
    ]),
  );
}

class _MeditationStep extends StatelessWidget {
  const _MeditationStep({required this.number, required this.title, required this.text});
  final String number, title, text;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(number, style: const TextStyle(color: VirilColors.ice, fontSize: 11, fontWeight: FontWeight.w900)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(text, style: const TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4)),
    ])),
  ]));
}
