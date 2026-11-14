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
  static const _dailyXpKey = 'viril.daily_xp.v1';
  static const _journalKey = 'viril.journal.v1';
  static const _gratitudeKey = 'viril.gratitude.v1';

  SharedPreferences? _preferences;
  List<VirilTask> _tasks = [];
  int _xp = 0;
  final Set<String> _habitRewards = <String>{};
  final Set<String> _activeDays = <String>{};
  final Map<String, int> _dailyXp = <String, int>{};
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
  int get todayXp => xpForDay(DateTime.now());
  int get todayPercent => todayXp.clamp(0, 100).toInt();
  int get activeDaysCount => _activeDays.length;
  int get activeDaysStreak {
    if (_activeDays.isEmpty) return 0;
    var day = DateTime.now();
    if (!_activeDays.contains(dayKey(day))) day = day.subtract(const Duration(days: 1));
    var streak = 0;
    while (_activeDays.contains(dayKey(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }
  List<Map<String, String>> get journalEntries => List.unmodifiable(_journalEntries);
  List<Map<String, String>> get gratitudeEntries => List.unmodifiable(_gratitudeEntries);

  String dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  int xpForDay(DateTime date) => _dailyXp[dayKey(date)] ?? 0;
  int percentForDay(DateTime date) => xpForDay(date).clamp(0, 100);
  int domainLevel(String domain) => _tasks.where((t) => t.completed && t.domain == domain).length.clamp(0, 100).toInt();

  int averagePercent(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    if (days <= 0) return 0;
    var total = 0;
    for (var i = 0; i < days; i++) {
      total += percentForDay(start.add(Duration(days: i)));
    }
    return (total / days).round();
  }

  List<VirilTask> completedOn(DateTime date) => _tasks.where((task) =>
      task.completed && task.completedAt != null &&
      dayKey(task.completedAt!) == dayKey(date)).toList();

  Future<void> initialize() async {
    if (_ready) return;
    _preferences = await SharedPreferences.getInstance();
    _xp = _preferences!.getInt(_xpKey) ?? 0;
    _habitRewards.addAll(_preferences!.getStringList(_habitRewardsKey) ?? <String>[]);
    _activeDays.addAll(_preferences!.getStringList(_activeDaysKey) ?? <String>[]);
    final rawDaily = _preferences!.getString(_dailyXpKey);
    if (rawDaily != null) {
      try {
        final decoded = jsonDecode(rawDaily) as Map<String, dynamic>;
        _dailyXp.addAll(decoded.map((key, value) => MapEntry(key, (value as num).toInt())));
      } catch (_) { _dailyXp.clear(); }
    }
    _readEntries(_journalKey, _journalEntries);
    _readEntries(_gratitudeKey, _gratitudeEntries);
    final raw = _preferences!.getString(_tasksKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _tasks = decoded.map((item) => VirilTask.fromJson(item as Map<String, dynamic>)).toList();
      } catch (_) { _tasks = []; }
    }
    // Backfill completion dates for older task records, without inventing historical XP.
    _ready = true;
    notifyListeners();
  }

  void _readEntries(String key, List<Map<String, String>> target) {
    final raw = _preferences?.getString(key);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      target.addAll(decoded.map((item) => Map<String, String>.from(item as Map)));
    } catch (_) { target.clear(); }
  }

  Future<void> _recordActivity({int xpDelta = 0, DateTime? date}) async {
    await initialize();
    final day = date ?? DateTime.now();
    final key = dayKey(day);
    _activeDays.add(key);
    if (xpDelta != 0) _dailyXp[key] = ((_dailyXp[key] ?? 0) + xpDelta).clamp(0, 999999).toInt();
    await _preferences?.setStringList(_activeDaysKey, _activeDays.toList()..sort());
    await _preferences?.setString(_dailyXpKey, jsonEncode(_dailyXp));
  }

  Future<void> addTask(String title, String domain, {String period = 'day', int xpReward = 5}) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;
    await initialize();
    _tasks = [VirilTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: cleanTitle, domain: domain, createdAt: DateTime.now(),
      period: period, xpReward: xpReward,
    ), ..._tasks];
    await _saveTasks();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    await initialize();
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) return;
    final task = _tasks[index];
    if (task.completed) {
      final completedAt = task.completedAt ?? DateTime.now();
      _tasks[index] = task.copyWith(completed: false, clearCompletedAt: true);
      _xp = (_xp - task.xpReward).clamp(0, 999999).toInt();
      await _recordActivity(xpDelta: -task.xpReward, date: completedAt);
    } else {
      final completedAt = DateTime.now();
      _tasks[index] = task.copyWith(completed: true, completedAt: completedAt);
      _xp = (_xp + task.xpReward).clamp(0, 999999).toInt();
      await _recordActivity(xpDelta: task.xpReward, date: completedAt);
    }
    await _saveTasks();
    await _preferences?.setInt(_xpKey, _xp);
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
    final parts = dayKey.split('-').map(int.parse).toList();
    final date = DateTime(parts[0], parts[1], parts[2]);
    await _preferences?.setStringList(_habitRewardsKey, _habitRewards.toList());
    await _preferences?.setInt(_xpKey, _xp);
    await _recordActivity(xpDelta: 5, date: date);
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
    await _preferences?.setString(_tasksKey, jsonEncode(_tasks.map((task) => task.toJson()).toList()));
  }
}
