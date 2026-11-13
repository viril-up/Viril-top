import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/viril_task.dart';

class VirilStore extends ChangeNotifier {
  VirilStore._();
  static final VirilStore instance = VirilStore._();

  static const _tasksKey = 'viril.tasks.v1';
  static const _xpKey = 'viril.xp.v1';

  SharedPreferences? _preferences;
  List<VirilTask> _tasks = [];
  int _xp = 0;
  bool _ready = false;

  List<VirilTask> get tasks => List.unmodifiable(_tasks);
  int get xp => _xp;
  int get completedCount => _tasks.where((task) => task.completed).length;
  int get pendingCount => _tasks.where((task) => !task.completed).length;
  bool get isReady => _ready;
  int get level => (_xp ~/ 100) + 1;
  int get levelProgress => _xp % 100;

  Future<void> initialize() async {
    if (_ready) return;
    _preferences = await SharedPreferences.getInstance();
    _xp = _preferences!.getInt(_xpKey) ?? 0;
    final raw = _preferences!.getString(_tasksKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _tasks = decoded
            .map((item) => VirilTask.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _tasks = [];
      }
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> addTask(String title, String domain) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;
    _tasks = [
      VirilTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: cleanTitle,
        domain: domain,
        createdAt: DateTime.now(),
      ),
      ..._tasks,
    ];
    await _saveTasks();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) return;
    final wasCompleted = _tasks[index].completed;
    _tasks[index] = _tasks[index].copyWith(completed: !wasCompleted);
    _xp = (_xp + (wasCompleted ? -10 : 10)).clamp(0, 999999);
    await _saveTasks();
    await _preferences?.setInt(_xpKey, _xp);
    notifyListeners();
  }

  Future<void> removeTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    await _preferences?.setString(
      _tasksKey,
      jsonEncode(_tasks.map((task) => task.toJson()).toList()),
    );
  }
}
