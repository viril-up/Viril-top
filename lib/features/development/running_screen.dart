import 'dart:async';
import 'dart:ui' show FontFeature;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/viril_colors.dart';
import '../../core/widgets/glass_card.dart';

class RunningScreen extends StatefulWidget {
  const RunningScreen({super.key});
  @override State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;
  StreamSubscription<Position>? _positionSubscription;
  final List<Position> _route = [];
  final List<Map<String, dynamic>> _history = [];
  bool _running = false;
  bool _gpsReady = false;
  double _distanceMeters = 0;
  Position? _lastPosition;
  DateTime? _startedAt;

  @override void initState() {
    super.initState();
    _loadHistory();
  }

  @override void dispose() {
    _ticker?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('viril_run_history');
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      if (mounted) setState(() => _history.addAll(decoded.cast<Map<String, dynamic>>()));
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('viril_run_history', jsonEncode(_history));
  }

  Future<void> _startRun() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) _message('Разреши доступ к геолокации, чтобы записывать маршрут.');
        return;
      }
      _route.clear();
      _distanceMeters = 0;
      _lastPosition = null;
      _startedAt = DateTime.now();
      _watch
        ..reset()
        ..start();
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((position) {
        if (_lastPosition != null) {
          final segment = Geolocator.distanceBetween(
            _lastPosition!.latitude, _lastPosition!.longitude,
            position.latitude, position.longitude,
          );
          if (segment > 1 && segment < 100) _distanceMeters += segment;
        }
        _lastPosition = position;
        _route.add(position);
        if (mounted) setState(() => _gpsReady = true);
      }, onError: (_) {
        if (mounted) _message('Не удалось получить GPS-сигнал. Секундомер продолжает работать.');
      });
      if (mounted) setState(() { _running = true; _gpsReady = false; });
    } catch (_) {
      if (mounted) _message('Геолокация сейчас недоступна. Проверь разрешения устройства.');
    }
  }

  void _pauseRun() {
    _watch.stop();
    _positionSubscription?.pause();
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _resumeRun() {
    _watch.start();
    _positionSubscription?.resume();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
    setState(() { _running = true; _gpsReady = _route.isNotEmpty; });
  }

  Future<void> _openHistoryRoute(Map<String, dynamic> item) async {
    final raw = (item['route'] as List<dynamic>? ?? []);
    final points = raw.map((v) {
      final pair = v as List<dynamic>;
      return (latitude: (pair[0] as num).toDouble(), longitude: (pair[1] as num).toDouble());
    }).toList();
    if (points.length < 2) {
      _message('Для этой пробежки маршрут не был записан.');
      return;
    }
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: VirilColors.stone,
      title: const Text('Маршрут пробежки'),
      content: SizedBox(height: 190, width: double.maxFinite,
        child: CustomPaint(painter: _SavedRoutePainter(points))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Закрыть')),
        FilledButton.icon(onPressed: () async {
          final first = points.first, last = points.last;
          final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${first.latitude},${first.longitude}&destination=${last.latitude},${last.longitude}&travelmode=walking');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }, icon: const Icon(Icons.map_outlined), label: const Text('Google Maps')),
      ],
    ));
  }

  Future<void> _finishRun() async {
    _watch.stop();
    _ticker?.cancel();
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    if (_watch.elapsed.inSeconds > 0) {
      _history.insert(0, {
        'date': DateTime.now().toIso8601String(),
        'seconds': _watch.elapsed.inSeconds,
        'meters': _distanceMeters.round(),
        'points': _route.length,
        'route': _route.map((p) => [p.latitude, p.longitude]).toList(),
      });
      if (_history.length > 30) _history.removeLast();
      await _saveHistory();
    }
    if (mounted) setState(() { _running = false; _gpsReady = false; });
    _watch.reset();
    _route.clear();
    _distanceMeters = 0;
    _lastPosition = null;
  }

  Future<void> _openMap() async {
    final p = _lastPosition;
    final uri = p == null
      ? Uri.parse('https://www.google.com/maps')
      : Uri.parse('https://www.google.com/maps/search/?api=1&query=${p.latitude},${p.longitude}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      _message('Не удалось открыть Google Maps.');
    }
  }

  void _message(String value) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(value), behavior: SnackBarBehavior.floating));

  String _time(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override Widget build(BuildContext context) {
    final elapsed = _watch.elapsed;
    final pace = _distanceMeters > 0
      ? Duration(seconds: (elapsed.inSeconds / (_distanceMeters / 1000)).round())
      : Duration.zero;
    return Scaffold(
      backgroundColor: VirilColors.voidBlack,
      appBar: AppBar(title: const Text('Бег'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 30), children: [
        GlassCard(child: Column(children: [
          const Text('ТВОЯ ТРЕНИРОВКА', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(_time(elapsed), style: const TextStyle(fontSize: 43, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(height: 16),
          Row(children: [
            _RunMetric(value: '${(_distanceMeters / 1000).toStringAsFixed(2)}', unit: 'КМ', label: 'Дистанция'),
            _RunMetric(value: _route.length.toString(), unit: '', label: 'GPS-точки'),
            _RunMetric(value: _distanceMeters > 0 ? '${pace.inMinutes.toString().padLeft(2, '0')}:${(pace.inSeconds % 60).toString().padLeft(2, '0')}' : '--:--', unit: '', label: 'Темп / км'),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: FilledButton.icon(
              onPressed: _running ? _pauseRun : (_watch.elapsed.inSeconds > 0 ? _resumeRun : _startRun),
              icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(_running ? 'Пауза' : (_watch.isRunning ? 'Продолжить' : 'Начать бег')),
            )),
            const SizedBox(width: 9),
            OutlinedButton(
              onPressed: _watch.elapsed.inSeconds == 0 ? null : _finishRun,
              child: const Text('Завершить'),
            ),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.my_location_rounded, size: 14, color: _gpsReady ? VirilColors.ice : VirilColors.muted),
            const SizedBox(width: 6),
            Text(_gpsReady ? 'GPS активен · маршрут записывается' : 'GPS ожидает сигнал',
              style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
          ]),
        ])),
        const SizedBox(height: 14),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('МАРШРУТ', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(height: 132, width: double.infinity,
            decoration: BoxDecoration(color: VirilColors.navy.withValues(alpha: .55), borderRadius: BorderRadius.circular(16), border: Border.all(color: VirilColors.line)),
            child: _route.length < 2
              ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.route_rounded, color: VirilColors.muted, size: 30),
                  SizedBox(height: 7),
                  Text('Маршрут появится после получения GPS-точек', style: TextStyle(color: VirilColors.muted, fontSize: 10)),
                ]))
              : CustomPaint(painter: _RoutePainter(_route), child: const SizedBox.expand()),
          ),
          const SizedBox(height: 11),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: _openMap,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Открыть Google Maps'),
          )),
          const Text('Точная запись маршрута сохраняется в текущем сеансе на устройстве. Google Maps открывается отдельно.',
            style: TextStyle(color: VirilColors.muted, fontSize: 10, height: 1.4)),
        ])),
        const SizedBox(height: 14),
        const Text('ИСТОРИЯ ПРОБЕЖЕК', style: TextStyle(color: VirilColors.gold, fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        if (_history.isEmpty)
          const GlassCard(child: Text('Здесь появятся твои результаты после первой завершённой пробежки.', style: TextStyle(color: VirilColors.muted, fontSize: 11)))
        else
          for (final item in _history) InkWell(onTap: () => _openHistoryRoute(item), borderRadius: BorderRadius.circular(18), child: GlassCard(margin: const EdgeInsets.only(bottom: 8), child: Row(children: [
            const Icon(Icons.directions_run_rounded, color: VirilColors.lava, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateTime.tryParse(item['date'] as String? ?? '')?.toLocal().toString().substring(0, 16) ?? 'Пробежка',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              Text('${((item['meters'] as num? ?? 0) / 1000).toStringAsFixed(2)} км · ${item['points'] ?? 0} GPS-точек',
                style: const TextStyle(color: VirilColors.muted, fontSize: 10)),
            ])),
            Text(_time(Duration(seconds: item['seconds'] as int? ?? 0)),
              style: const TextStyle(color: VirilColors.gold, fontWeight: FontWeight.w900, fontSize: 12)),
            const SizedBox(width: 5), const Icon(Icons.chevron_right_rounded, color: VirilColors.muted, size: 17),
          ]))),
      ]),
    );
  }
}

class _RunMetric extends StatelessWidget {
  const _RunMetric({required this.value, required this.unit, required this.label});
  final String value, unit, label;
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
    if (unit.isNotEmpty) Text(unit, style: const TextStyle(color: VirilColors.gold, fontSize: 8, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3),
    Text(label, style: const TextStyle(color: VirilColors.muted, fontSize: 9)),
  ]));
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(List<Position> points) : points = List.of(points);
  final List<Position> points;
  @override void paint(Canvas canvas, Size size) {
    final minLat = points.map((p) => p.latitude).reduce((a,b) => a < b ? a : b);
    final maxLat = points.map((p) => p.latitude).reduce((a,b) => a > b ? a : b);
    final minLon = points.map((p) => p.longitude).reduce((a,b) => a < b ? a : b);
    final maxLon = points.map((p) => p.longitude).reduce((a,b) => a > b ? a : b);
    final dx = (maxLon - minLon).abs() < .000001 ? .000001 : maxLon - minLon;
    final dy = (maxLat - minLat).abs() < .000001 ? .000001 : maxLat - minLat;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final x = 14 + (p.longitude - minLon) / dx * (size.width - 28);
      final y = size.height - 14 - (p.latitude - minLat) / dy * (size.height - 28);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, Paint()..color = VirilColors.lava..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }
  @override bool shouldRepaint(covariant _RoutePainter oldDelegate) => true;
}


class _SavedRoutePainter extends CustomPainter {
  _SavedRoutePainter(this.points);
  final List<({double latitude, double longitude})> points;
  @override void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minLat = points.map((p) => p.latitude).reduce((a,b) => a < b ? a : b);
    final maxLat = points.map((p) => p.latitude).reduce((a,b) => a > b ? a : b);
    final minLon = points.map((p) => p.longitude).reduce((a,b) => a < b ? a : b);
    final maxLon = points.map((p) => p.longitude).reduce((a,b) => a > b ? a : b);
    final dx = (maxLon - minLon).abs() < .000001 ? .000001 : maxLon - minLon;
    final dy = (maxLat - minLat).abs() < .000001 ? .000001 : maxLat - minLat;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final x = 12 + (p.longitude - minLon) / dx * (size.width - 24);
      final y = size.height - 12 - (p.latitude - minLat) / dy * (size.height - 24);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, Paint()..color = VirilColors.lava..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }
  @override bool shouldRepaint(covariant _SavedRoutePainter oldDelegate) => true;
}
