import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

enum WorkoutPlace { home, outdoor, gym }

class ExerciseInfo {
  const ExerciseInfo(this.id, this.name, this.place, this.muscles, this.level, this.equipment, this.steps, {this.reps = '8–12', this.rest = 60, this.icon = Icons.fitness_center_rounded});
  final String id, name, muscles, level, equipment, reps;
  final WorkoutPlace place;
  final List<String> steps;
  final int rest;
  final IconData icon;
}

const _exercises = <ExerciseInfo>[
  ExerciseInfo('push-up','Отжимания',WorkoutPlace.home,'Грудь · трицепс · корпус','Начальный','Без оборудования',['Прими упор лёжа, ладони поставь немного шире плеч.','Удерживай корпус ровным, не прогибай поясницу.','Плавно опускай грудь к полу, сгибая локти.','Выжми себя вверх и вернись в исходное положение.'],icon:Icons.sports_gymnastics_rounded),
  ExerciseInfo('squat','Приседания с весом тела',WorkoutPlace.home,'Ноги · ягодицы','Начальный','Без оборудования',['Поставь стопы примерно на ширине плеч.','Отведи таз назад и согни колени.','Опускайся в комфортную глубину, сохраняя опору на всю стопу.','Плавно выпрямись.'],icon:Icons.accessibility_new_rounded),
  ExerciseInfo('plank','Планка',WorkoutPlace.home,'Мышцы корпуса','Начальный','Без оборудования',['Обопрись на предплечья и носки стоп.','Выровняй тело в одну линию.','Напряги мышцы живота и спокойно дыши.','Удерживай положение заданное время.'],reps:'20–40 сек',icon:Icons.timer_rounded),
  ExerciseInfo('lunge','Выпады назад',WorkoutPlace.home,'Ноги · ягодицы','Начальный','Без оборудования',['Встань прямо, стопы на ширине таза.','Сделай шаг одной ногой назад.','Согни оба колена настолько, насколько комфортно.','Вернись в исходное положение и поменяй ногу.'],icon:Icons.directions_walk_rounded),
  ExerciseInfo('bridge','Ягодичный мост',WorkoutPlace.home,'Ягодицы · задняя поверхность бедра','Начальный','Без оборудования',['Ляг на спину, согни колени и поставь стопы на пол.','Напряги ягодицы и подними таз.','Не переразгибай поясницу в верхней точке.','Медленно опусти таз.'],icon:Icons.self_improvement_rounded),
  ExerciseInfo('dead-bug','Мёртвый жук',WorkoutPlace.home,'Мышцы корпуса','Начальный','Без оборудования',['Ляг на спину, подними руки и согни ноги под прямым углом.','Сохраняй поясницу в устойчивом положении.','Медленно опускай противоположные руку и ногу.','Вернись и повтори на другую сторону.'],reps:'8–10 на сторону',icon:Icons.accessibility_rounded),
  ExerciseInfo('crunch','Скручивания',WorkoutPlace.home,'Прямая мышца живота','Начальный','Без оборудования',['Ляг на спину, согни колени, стопы оставь на полу.','Слегка приподними плечи за счёт мышц живота.','Не тяни голову руками.','Плавно опустись обратно.'],icon:Icons.repeat_rounded),
  ExerciseInfo('jumping-jack','Прыжки «Джампинг Джек»',WorkoutPlace.home,'Все тело · выносливость','Начальный','Без оборудования',['Встань прямо, руки опусти вдоль тела.','Небольшим прыжком расставь ноги и подними руки.','Следующим прыжком вернись в исходное положение.','Двигайся в удобном ритме.'],reps:'20–30 сек',icon:Icons.directions_run_rounded),
  ExerciseInfo('pull-up','Подтягивания',WorkoutPlace.outdoor,'Спина · бицепс','Средний','Турник',['Возьмись за перекладину хватом чуть шире плеч.','Начни движение, сводя лопатки и сгибая руки.','Поднимайся без раскачивания.','Плавно опустись под контролем.'],reps:'По возможностям',rest:90,icon:Icons.sports_martial_arts_rounded),
  ExerciseInfo('chin-up','Подтягивания обратным хватом',WorkoutPlace.outdoor,'Спина · бицепс','Средний','Турник',['Возьмись за перекладину ладонями к себе.','Напряги корпус и начни сгибать руки.','Поднимись без рывка.','Плавно опустись.'],reps:'По возможностям',rest:90,icon:Icons.sports_martial_arts_rounded),
  ExerciseInfo('walk','Быстрая ходьба',WorkoutPlace.outdoor,'Выносливость · ноги','Начальный','Удобная обувь',['Выбери безопасный ровный маршрут.','Начни с лёгкого темпа и постепенно ускорься.','Сохраняй естественный шаг и свободное дыхание.','Заверши спокойным темпом.'],reps:'10–30 мин',rest:0,icon:Icons.directions_walk_rounded),
  ExerciseInfo('run','Лёгкий бег',WorkoutPlace.outdoor,'Выносливость · ноги','Начальный','Удобная обувь',['Начни с нескольких минут спокойной ходьбы.','Переходи на лёгкий бег в разговорном темпе.','Не ускоряйся через дискомфорт.','Заверши ходьбой и восстанови дыхание.'],reps:'5–20 мин',rest:0,icon:Icons.directions_run_rounded),
  ExerciseInfo('mountain-climber','Альпинист',WorkoutPlace.outdoor,'Корпус · плечи · ноги','Средний','Без оборудования',['Прими положение высокой планки.','Поочерёдно подтягивай колени к корпусу.','Сохраняй устойчивое положение плеч и таза.','Выбирай темп, в котором контролируешь технику.'],reps:'20–30 сек',icon:Icons.directions_run_rounded),
  ExerciseInfo('bench-press','Жим штанги лёжа',WorkoutPlace.gym,'Грудь · трицепс','Средний','Скамья · штанга',['Ляг на скамью, стопы поставь на пол.','Возьмись за гриф симметрично и сними его со стоек с помощью страхующего.','Опускай гриф подконтрольно к середине груди.','Выжми вверх, не теряя устойчивости.'],rest:120,icon:Icons.fitness_center_rounded),
  ExerciseInfo('dumbbell-bench','Жим гантелей лёжа',WorkoutPlace.gym,'Грудь · трицепс','Начальный','Скамья · гантели',['Ляг на скамью и удерживай гантели над грудью.','Опускай их по обе стороны груди в комфортной амплитуде.','Не опускай локти чрезмерно глубоко.','Выжми гантели вверх без резкого сведения.'],rest:90),
  ExerciseInfo('barbell-row','Тяга штанги в наклоне',WorkoutPlace.gym,'Спина · бицепс','Средний','Штанга',['Наклони корпус с устойчивой спиной и слегка согнутыми коленями.','Удерживай гриф на вытянутых руках.','Подтяни гриф к нижней части живота.','Плавно опусти гриф.'],rest:120),
  ExerciseInfo('lat-pulldown','Тяга верхнего блока',WorkoutPlace.gym,'Широчайшие мышцы спины','Начальный','Тренажёр верхней тяги',['Сядь и зафиксируй бёдра под валиками.','Возьмись за рукоять удобным хватом.','Подтяни рукоять к верхней части груди, сводя лопатки.','Медленно верни рукоять вверх.'],rest:90),
  ExerciseInfo('leg-press','Жим ногами',WorkoutPlace.gym,'Квадрицепсы · ягодицы','Начальный','Тренажёр для жима ногами',['Установи спинку и стопы так, чтобы положение было устойчивым.','Разблокируй платформу согласно инструкции тренажёра.','Опускай платформу в комфортной амплитуде.','Выжми платформу, не блокируя колени резко.'],rest:120),
  ExerciseInfo('romanian-deadlift','Румынская тяга',WorkoutPlace.gym,'Задняя поверхность бедра · ягодицы','Средний','Штанга или гантели',['Встань устойчиво, удерживая вес перед бёдрами.','Отведи таз назад, слегка согнув колени.','Опускай вес вдоль ног, сохраняя нейтральную спину.','Подними корпус за счёт движения таза вперёд.'],rest:120),
  ExerciseInfo('biceps-curl','Сгибание рук с гантелями',WorkoutPlace.gym,'Бицепс','Начальный','Гантели',['Встань прямо, удерживая гантели у бёдер.','Сохраняй локти рядом с корпусом.','Согни руки, поднимая гантели без раскачивания.','Медленно опусти вес.'],rest:60),
  ExerciseInfo('leg-curl','Сгибание ног в тренажёре',WorkoutPlace.gym,'Задняя поверхность бедра','Начальный','Тренажёр',['Настрой валик по инструкции тренажёра.','Сохраняй таз устойчивым.','Согни ноги, подтягивая валик.','Плавно вернись в исходное положение.'],rest:75),
];

class _Program {
  const _Program(this.name, this.subtitle, this.days);
  final String name, subtitle;
  final List<(String, List<String>)> days;
}

const _programs = <_Program>[
  _Program('Тренировка всего тела', '3 раза в неделю · базовая программа', [
    ('День A', ['Приседания с весом тела','Отжимания','Тяга штанги в наклоне','Планка']),
    ('День B', ['Выпады назад','Жим гантелей лёжа','Тяга верхнего блока','Мёртвый жук']),
    ('День C', ['Приседания с весом тела','Жим штанги лёжа','Румынская тяга','Планка']),
  ]),
  _Program('Толкай · тяни · ноги', '3 тренировочных дня · зал', [
    ('Толкай', ['Жим штанги лёжа','Жим гантелей лёжа','Сгибание рук с гантелями']),
    ('Тяни', ['Подтягивания','Тяга штанги в наклоне','Тяга верхнего блока']),
    ('Ноги', ['Приседания с весом тела','Жим ногами','Румынская тяга','Сгибание ног в тренажёре']),
  ]),
  _Program('Верх · низ', '4 дня в неделю · зал', [
    ('Верх A', ['Жим штанги лёжа','Тяга штанги в наклоне','Тяга верхнего блока']),
    ('Низ A', ['Приседания с весом тела','Жим ногами','Румынская тяга']),
    ('Верх B', ['Жим гантелей лёжа','Подтягивания','Сгибание рук с гантелями']),
    ('Низ B', ['Выпады назад','Сгибание ног в тренажёре','Ягодичный мост']),
  ]),
  _Program('Домашняя программа', '2 дня в неделю · без оборудования', [
    ('Дом A', ['Отжимания','Приседания с весом тела','Планка','Ягодичный мост']),
    ('Дом B', ['Выпады назад','Мёртвый жук','Скручивания','Прыжки «Джампинг Джек»']),
  ]),
  _Program('Улица и турник', '2–3 дня в неделю · базовый уровень', [
    ('День A', ['Подтягивания','Отжимания','Приседания с весом тела','Планка']),
    ('День B', ['Подтягивания обратным хватом','Выпады назад','Альпинист','Быстрая ходьба']),
  ]),
];

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});
  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  WorkoutPlace _place = WorkoutPlace.home;
  String _query = '';
  int _completed = 0;
  String? _activeProgram;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() { _completed = p.getInt('viril_workout_completed') ?? 0; _activeProgram = p.getString('viril_active_program'); });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _exercises.where((e) => e.place == _place && ('${e.name} ${e.muscles}'.toLowerCase().contains(_query.toLowerCase()))).toList();
    return Scaffold(
      backgroundColor: VirilColors.voidBlack,
      appBar: AppBar(title: const Text('Тренировки'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          GlassCard(child: Row(children: [
            const Icon(Icons.bolt_rounded, color: VirilColors.gold, size: 25),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ТВОЯ ТРЕНИРОВОЧНАЯ СИСТЕМА', style: TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text('Выполнено упражнений: $_completed', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ])),
          ])),
          const SizedBox(height: 22),
          const _SectionLabel('ГОТОВЫЕ ПРОГРАММЫ'),
          const SizedBox(height: 10),
          SizedBox(height: 132, child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final p in _programs) SizedBox(width: 235, child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showProgram(p),
                child: GlassCard(
                  padding: const EdgeInsets.all(15),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.view_week_rounded, color: VirilColors.gold, size: 22),
                    const Spacer(),
                    Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(p.subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
                    if (_activeProgram == p.name) const Text('АКТИВНАЯ ПРОГРАММА', style: TextStyle(color: VirilColors.gold, fontSize: 8, fontWeight: FontWeight.w900)),
                  ]),
                ),
              ),
            )),
          ])),
          const SizedBox(height: 22),
          const _SectionLabel('КАТАЛОГ УПРАЖНЕНИЙ'),
          const SizedBox(height: 10),
          SegmentedButton<WorkoutPlace>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: WorkoutPlace.home, label: Text('Дом'), icon: Icon(Icons.home_rounded)),
              ButtonSegment(value: WorkoutPlace.outdoor, label: Text('Улица'), icon: Icon(Icons.park_rounded)),
              ButtonSegment(value: WorkoutPlace.gym, label: Text('Зал'), icon: Icon(Icons.fitness_center_rounded)),
            ],
            selected: {_place},
            onSelectionChanged: (s) => setState(() { _place = s.first; _query = ''; }),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Найти упражнение',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true, fillColor: VirilColors.stone,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          for (final e in filtered) _ExerciseTile(exercise: e, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: e)))),
          if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(25), child: Text('Упражнения не найдены', textAlign: TextAlign.center, style: TextStyle(color: VirilColors.muted))),
        ],
      ),
    );
  }

  void _showProgram(_Program program) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: VirilColors.stone,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(program.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(program.subtitle, style: const TextStyle(color: VirilColors.muted, fontSize: 12)),
          const SizedBox(height: 16),
          for (final day in program.days) Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(day.$1, style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(day.$2.join('  ·  '), style: const TextStyle(fontSize: 12, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 6),
          SizedBox(width: double.infinity, child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VirilColors.gold, foregroundColor: VirilColors.voidBlack),
            onPressed: () async {
              final p = await SharedPreferences.getInstance();
              await p.setString('viril_active_program', program.name);
              if (mounted) setState(() => _activeProgram = program.name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Выбрать программу'),
          )),
        ]),
      )),
    );
  }
}

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});
  final ExerciseInfo exercise;
  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int _sets = 3, _done = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _running = false;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _finishSet() async {
    setState(() { _done = (_done + 1).clamp(0, _sets).toInt(); _seconds = _done < _sets ? widget.exercise.rest : 0; _running = _seconds > 0; });
    if (_running) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        if (_seconds <= 1) { t.cancel(); setState(() { _seconds = 0; _running = false; }); }
        else setState(() => _seconds--);
      });
    }
    if (_done >= _sets) {
      final p = await SharedPreferences.getInstance();
      final old = p.getInt('viril_workout_completed') ?? 0;
      await p.setInt('viril_workout_completed', old + 1);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Упражнение отмечено как выполненное')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    return Scaffold(
      backgroundColor: VirilColors.voidBlack,
      appBar: AppBar(title: Text(e.name), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 30), children: [
        GlassCard(padding: const EdgeInsets.all(10), child: Column(children: [
          SizedBox(height: 205, child: AnimatedExerciseFigure(kind: e.id)),
          Text(e.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(e.muscles, style: const TextStyle(color: VirilColors.muted, fontSize: 11)),
          const SizedBox(height: 12),
          Wrap(spacing: 7, children: [
            _InfoChip(e.level), _InfoChip(e.equipment), _InfoChip(e.reps),
          ]),
        ])),
        const SizedBox(height: 18),
        const _SectionLabel('ТЕХНИКА ВЫПОЛНЕНИЯ'),
        const SizedBox(height: 9),
        for (var i = 0; i < e.steps.length; i++) Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 25, height: 25, alignment: Alignment.center, decoration: BoxDecoration(color: VirilColors.gold.withValues(alpha: .13), borderRadius: BorderRadius.circular(8)), child: Text('${i+1}', style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w800, fontSize: 11))),
            const SizedBox(width: 10),
            Expanded(child: Text(e.steps[i], style: const TextStyle(fontSize: 12, height: 1.45, color: VirilColors.text))),
          ]),
        ),
        const SizedBox(height: 10),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ТВОЯ СЕССИЯ', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Row(children: [
            const Expanded(child: Text('Количество подходов', style: TextStyle(fontSize: 12))),
            IconButton(onPressed: _sets > 1 ? () => setState(() => _sets--) : null, icon: const Icon(Icons.remove_circle_outline)),
            Text('$_sets', style: const TextStyle(fontWeight: FontWeight.w900)),
            IconButton(onPressed: _sets < 8 ? () => setState(() => _sets++) : null, icon: const Icon(Icons.add_circle_outline)),
          ]),
          Row(children: [
            Expanded(child: Text('Выполнено: $_done из $_sets', style: const TextStyle(fontSize: 12))),
            Text('${(_done / _sets * 100).round()}%', style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _done / _sets, color: VirilColors.gold, backgroundColor: VirilColors.line, minHeight: 6, borderRadius: BorderRadius.circular(8)),
          if (_seconds > 0) Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Center(child: Text('Отдых: ${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2,'0')}', style: const TextStyle(color: VirilColors.gold, fontSize: 24, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: VirilColors.gold, foregroundColor: VirilColors.voidBlack),
            onPressed: _done < _sets ? _finishSet : null,
            icon: const Icon(Icons.check_rounded),
            label: Text(_done < _sets ? 'Отметить подход' : 'Все подходы выполнены'),
          )),
        ])),
        const SizedBox(height: 12),
        const Text('Работай в комфортном диапазоне, не выполняй движение через боль и при необходимости попроси тренера проверить технику.', style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.5)),
      ]),
    );
  }
}

class AnimatedExerciseFigure extends StatefulWidget {
  const AnimatedExerciseFigure({super.key, required this.kind});
  final String kind;
  @override
  State<AnimatedExerciseFigure> createState() => _AnimatedExerciseFigureState();
}

class _AnimatedExerciseFigureState extends State<AnimatedExerciseFigure> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..repeat();
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (_, __) => CustomPaint(
      painter: _GoldFigurePainter(_controller.value, widget.kind),
      child: const SizedBox.expand(),
    ),
  );
}

class _GoldFigurePainter extends CustomPainter {
  _GoldFigurePainter(this.t, this.kind);
  final double t;
  final String kind;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 6;
    final phase = (math.sin(t * math.pi * 2) + 1) / 2;
    final gold = Paint()..color = VirilColors.gold..style = PaintingStyle.stroke..strokeWidth = 7..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final glow = Paint()..color = VirilColors.gold.withValues(alpha: .12)..style = PaintingStyle.stroke..strokeWidth = 18..strokeCap = StrokeCap.round;
    final dot = Paint()..color = VirilColors.gold;
    canvas.drawCircle(Offset(cx, cy + 12), 72 + phase * 4, Paint()..color = VirilColors.gold.withValues(alpha: .035));
    final isFloor = kind == 'push-up' || kind == 'plank' || kind == 'dead-bug' || kind == 'crunch' || kind == 'mountain-climber';
    final isPull = kind == 'pull-up' || kind == 'chin-up';
    final base = isFloor ? cy + 25 : cy + 68;
    final lift = phase * 19;
    final head = isFloor ? Offset(cx + (kind == 'dead-bug' ? -53 : -48), base - 44 - lift) : Offset(cx, base - 105 - lift);
    final shoulder = isFloor ? Offset(cx - 13, base - 29 - lift) : Offset(cx, base - 75 - lift);
    final hip = isFloor ? Offset(cx + 48, base - 10 + lift * .25) : Offset(cx, base - 4 + lift * .2);
    final elbowL = isFloor ? Offset(cx - 52, base - 8 + lift * .25) : Offset(cx - 31 - phase * 7, base - 43 - lift * .3);
    final handL = isFloor ? Offset(cx - 66, base + 18 + lift * .2) : Offset(cx - 42 - phase * 10, base - 9 - lift * .25);
    final elbowR = isFloor ? Offset(cx - 2, base - 8 + lift * .25) : Offset(cx + 31 + phase * 7, base - 43 - lift * .3);
    final handR = isFloor ? Offset(cx - 7, base + 18 + lift * .2) : Offset(cx + 42 + phase * 10, base - 9 - lift * .25);
    final kneeL = isFloor ? Offset(cx + 80, base + 5 - lift * .3) : Offset(cx - 20, base + 37 + lift * .3);
    final footL = isFloor ? Offset(cx + 105, base + 18 - lift * .3) : Offset(cx - 30, base + 83);
    final kneeR = isFloor ? Offset(cx + 103, base + 6 + lift * .3) : Offset(cx + 20, base + 37 - lift * .3);
    final footR = isFloor ? Offset(cx + 128, base + 18 + lift * .3) : Offset(cx + 30, base + 83);
    void line(Offset a, Offset b) { canvas.drawLine(a,b,glow); canvas.drawLine(a,b,gold); }
    canvas.drawCircle(head, 12, dot);
    line(shoulder, hip);
    line(shoulder, elbowL); line(elbowL, handL);
    line(shoulder, elbowR); line(elbowR, handR);
    if (isPull) {
      line(Offset(cx - 60, cy - 92), Offset(cx + 60, cy - 92));
      line(Offset(cx - 60, cy - 92), Offset(cx - 60, cy - 75));
      line(Offset(cx + 60, cy - 92), Offset(cx + 60, cy - 75));
    }
    line(hip, kneeL); line(kneeL, footL);
    line(hip, kneeR); line(kneeR, footR);
    final floorPaint = Paint()..color = VirilColors.gold.withValues(alpha: .22)..strokeWidth = 1.3;
    canvas.drawLine(Offset(cx - 130, cy + 94), Offset(cx + 130, cy + 94), floorPaint);
  }

  @override
  bool shouldRepaint(covariant _GoldFigurePainter old) => old.t != t || old.kind != kind;
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.onTap});
  final ExerciseInfo exercise;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(17), onTap: onTap,
    child: GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      margin: const EdgeInsets.only(bottom: 9),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: VirilColors.gold.withValues(alpha: .1), borderRadius: BorderRadius.circular(13)), child: Icon(exercise.icon, color: VirilColors.gold, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(exercise.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(exercise.muscles, style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
          const SizedBox(height: 3),
          Text('${exercise.level} · ${exercise.reps}', style: const TextStyle(color: VirilColors.goldSoft, fontSize: 9)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: VirilColors.muted),
      ]),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Chip(label: Text(text, style: const TextStyle(fontSize: 9)), visualDensity: VisualDensity.compact, backgroundColor: VirilColors.stoneLight, side: BorderSide.none, padding: EdgeInsets.zero);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: VirilColors.gold, fontSize: 9, letterSpacing: 1.8, fontWeight: FontWeight.w900));
}
