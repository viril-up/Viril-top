import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/viril_task.dart';

class VirilStore extends ChangeNotifier {
  VirilStore._();
  static final VirilStore instance = VirilStore._();

  static const _tasksKey = 'viril.tasks.v1';
  static const _xpKey = 'viril.xp.v1';
  static const _habitRewardsKey = 'viril.habit_rewards.v1';
  static const _activeDaysKey = 'viril.active_days.v1';
  static const _journalKey = 'viril.journal.v1';
  static const _gratitudeKey = 'viril.gratitude.v1';

  SharedPreferences? _preferences;
  List<VirilTask> _tasks = [];
  int _xp = 0;
  final Set<String> _habitRewards = <String>{};
  final Set<String> _activeDays = <String>{};
  final List<Map<String, String>> _journalEntries = [];
  final List<Map<String, String>> _gratitudeEntries = [];
  bool _ready = false;

  List<VirilTask> get tasks => List.unmodifiable(_tasks);
  int get xp => _xp;
  int get completedCount => _tasks.where((task) => task.completed).length;
  int get pendingCount => _tasks.where((task) => !task.completed).length;
  bool get isReady => _ready;
  int get level => (_xp ~/ 100) + 1;
  int get levelProgress => _xp % 100;
  int get activeDaysStreak {
    if (_activeDays.isEmpty) return 0;
    var day = DateTime.now();
    if (!_activeDays.contains(_dayKey(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (_activeDays.contains(_dayKey(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<Map<String, String>> get journalEntries => List.unmodifiable(_journalEntries);
  List<Map<String, String>> get gratitudeEntries => List.unmodifiable(_gratitudeEntries);

  Future<void> initialize() async {
    if (_ready) return;
    _preferences = await SharedPreferences.getInstance();
    _xp = _preferences!.getInt(_xpKey) ?? 0;
    _habitRewards.addAll(_preferences!.getStringList(_habitRewardsKey) ?? <String>[]);
    _activeDays.addAll(_preferences!.getStringList(_activeDaysKey) ?? <String>[]);
    _readEntries(_journalKey, _journalEntries);
    _readEntries(_gratitudeKey, _gratitudeEntries);
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

  void _readEntries(String key, List<Map<String, String>> target) {
    final raw = _preferences?.getString(key);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      target.addAll(decoded.map((item) => Map<String, String>.from(item as Map)));
    } catch (_) {
      target.clear();
    }
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _recordActivity() async {
    await initialize();
    _activeDays.add(_dayKey(DateTime.now()));
    await _preferences?.setStringList(_activeDaysKey, _activeDays.toList()..sort());
  }

  Future<void> addTask(String title, String domain, {String period = 'day', int xpReward = 5}) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;
    await initialize();
    _tasks = [
      VirilTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: cleanTitle,
        domain: domain,
        createdAt: DateTime.now(),
        period: period,
        xpReward: xpReward,
      ),
      ..._tasks,
    ];
    await _saveTasks();
    await _recordActivity();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    await initialize();
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) return;
    final wasCompleted = _tasks[index].completed;
    _tasks[index] = _tasks[index].copyWith(completed: !wasCompleted);
    _xp = (_xp + (wasCompleted ? -_tasks[index].xpReward : _tasks[index].xpReward)).clamp(0, 999999).toInt();
    await _saveTasks();
    await _preferences?.setInt(_xpKey, _xp);
    await _recordActivity();
    notifyListeners();
  }

  Future<void> saveJournalEntry(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;
    await initialize();
    _journalEntries.insert(0, {'text': value, 'createdAt': DateTime.now().toIso8601String()});
    await _saveEntries(_journalKey, _journalEntries);
    await _recordActivity();
    notifyListeners();
  }

  Future<void> saveGratitude(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;
    await initialize();
    _gratitudeEntries.insert(0, {'text': value, 'createdAt': DateTime.now().toIso8601String()});
    await _saveEntries(_gratitudeKey, _gratitudeEntries);
    await _recordActivity();
    notifyListeners();
  }

  Future<void> _saveEntries(String key, List<Map<String, String>> entries) async {
    await _preferences?.setString(key, jsonEncode(entries));
  }

  Future<bool> awardHabitXp(String habitId, String dayKey) async {
    await initialize();
    final rewardKey = '$habitId:$dayKey';
    if (!_habitRewards.add(rewardKey)) return false;
    _xp = (_xp + 5).clamp(0, 999999).toInt();
    await _preferences?.setStringList(_habitRewardsKey, _habitRewards.toList());
    await _preferences?.setInt(_xpKey, _xp);
    await _recordActivity();
    notifyListeners();
    return true;
  }

  Future<void> removeTask(String id) async {
    await initialize();
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
