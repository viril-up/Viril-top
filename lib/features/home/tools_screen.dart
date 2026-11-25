import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

class ToolsLauncherCard extends StatelessWidget {
  const ToolsLauncherCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        radius: 14,
        child: SizedBox(
          height: 48,
          child: Row(children: [
          const Icon(Icons.grid_view_rounded, color: VirilColors.ice, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Инструменты', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          )),
          const Icon(Icons.chevron_right_rounded, color: VirilColors.muted, size: 17),
          ]),
        ),
      ),
    ),
  );
}

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Инструменты'),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: const [
        PomodoroTool(),
        SizedBox(height: 12),
        _FutureToolsNote(),
      ],
    ),
  );
}

class _FutureToolsNote extends StatelessWidget {
  const _FutureToolsNote();

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(14),
    child: Row(children: [
      const Icon(Icons.add_circle_outline_rounded, color: VirilColors.muted, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Новые инструменты появятся здесь',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text('Это отдельный раздел, который можно будет постепенно дополнять.',
          style: TextStyle(color: VirilColors.muted, fontSize: 9)),
      ])),
    ]),
  );
}

class PomodoroTool extends StatefulWidget {
  const PomodoroTool({super.key});

  @override
  State<PomodoroTool> createState() => _PomodoroToolState();
}

class _PomodoroToolState extends State<PomodoroTool> {
  static const _workDuration = Duration(minutes: 25);
  static const _restDuration = Duration(minutes: 5);
  Timer? _timer;
  Duration _remaining = _workDuration;
  bool _running = false;
  bool _isWorkSession = true;
  int _completedWorkSessions = 0;

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_remaining == Duration.zero) {
      _remaining = _isWorkSession ? _workDuration : _restDuration;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        if (_isWorkSession) _completedWorkSessions++;
        setState(() {
          _isWorkSession = !_isWorkSession;
          _remaining = _isWorkSession ? _workDuration : _restDuration;
        });
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remaining = _workDuration;
      _running = false;
      _isWorkSession = true;
      _completedWorkSessions = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    final phase = _isWorkSession ? 'Время для работы' : 'Время для отдыха';
    final phaseColor = _isWorkSession ? VirilColors.ice : VirilColors.gold;
    final totalSeconds = (_isWorkSession ? _workDuration : _restDuration).inSeconds;
    final progress = 1 - (_remaining.inSeconds / totalSeconds);
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.timer_rounded, color: VirilColors.ice, size: 21),
          const SizedBox(width: 8),
          const Expanded(child: Text('Pomodoro', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
          Text('ЦИКЛ 25 / 5', style: TextStyle(color: VirilColors.muted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .8)),
        ]),
        const SizedBox(height: 7),
        const Text('25 минут сосредоточенной работы, затем 5 минут отдыха. После отдыха следующий рабочий цикл начнётся автоматически.',
          style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.45)),
        const SizedBox(height: 22),
        Center(child: Column(children: [
          Text(phase, style: TextStyle(color: phaseColor, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('$minutes:$seconds', style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 12),
          SizedBox(width: 220, child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: VirilColors.line,
              valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
            ),
          )),
          const SizedBox(height: 9),
          Text('Завершено рабочих циклов: $_completedWorkSessions',
            style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
        ])),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt_rounded, size: 17),
            label: const Text('Сбросить'),
          )),
          const SizedBox(width: 10),
          Expanded(child: FilledButton.icon(
            onPressed: _toggle,
            icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 17),
            label: Text(_running ? 'Пауза' : 'Старт'),
          )),
        ]),
      ]),
    );
  }
}
