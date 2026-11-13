import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VirilHabit {
  VirilHabit({required this.id, required this.title, required this.iconCode, Set<String>? completedDays})
      : completedDays = completedDays ?? <String>{};

  final String id;
  final String title;
  final int iconCode;
  final Set<String> completedDays;

  bool get completedToday => completedDays.contains(_dayKey(DateTime.now()));

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'iconCode': iconCode,
    'completedDays': completedDays.toList(),
  };

  factory VirilHabit.fromJson(Map<String, dynamic> json) => VirilHabit(
    id: json['id'] as String,
    title: json['title'] as String,
    iconCode: json['iconCode'] as int? ?? 0xe1a3,
    completedDays: Set<String>.from(json['completedDays'] as List<dynamic>? ?? []),
  );
}

String _dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class HabitStore extends ChangeNotifier {
  HabitStore._();
  static final HabitStore instance = HabitStore._();
  static const _storageKey = 'viril.habits.v1';

  SharedPreferences? _prefs;
  final List<VirilHabit> _habits = [];
  bool _ready = false;

  List<VirilHabit> get habits => List.unmodifiable(_habits);
  bool get isReady => _ready;
  int get completedToday => _habits.where((h) => h.completedToday).length;
  int get todayPercent => _habits.isEmpty ? 0 : (completedToday * 100 ~/ _habits.length);

  Future<void> initialize() async {
    if (_ready) return;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as List<dynamic>;
        _habits.addAll(data.map((e) => VirilHabit.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        _habits.clear();
      }
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> addHabit(String title, {int iconCode = 0xe1a3}) async {
    final value = title.trim();
    if (value.isEmpty) return;
    _habits.add(VirilHabit(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: value,
      iconCode: iconCode,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> toggleToday(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index < 0) return;
    final habit = _habits[index];
    final key = _dayKey(DateTime.now());
    if (!habit.completedDays.add(key)) habit.completedDays.remove(key);
    await _save();
    notifyListeners();
  }

  Future<void> removeHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _save();
    notifyListeners();
  }

  int streakFor(VirilHabit habit) {
    var day = DateTime.now();
    if (!habit.completedDays.contains(_dayKey(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (habit.completedDays.contains(_dayKey(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int weekCount(VirilHabit habit) {
    final today = DateTime.now();
    var count = 0;
    for (var i = 0; i < 7; i++) {
      if (habit.completedDays.contains(_dayKey(today.subtract(Duration(days: i))))) count++;
    }
    return count;
  }

  Future<void> _save() async {
    await _prefs?.setString(_storageKey, jsonEncode(_habits.map((h) => h.toJson()).toList()));
  }
}
