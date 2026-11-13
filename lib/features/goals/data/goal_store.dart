import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VirilGoalStep {
  VirilGoalStep({required this.id, required this.title, this.isDone = false});
  final String id;
  final String title;
  bool isDone;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isDone': isDone};
  factory VirilGoalStep.fromJson(Map<String, dynamic> json) => VirilGoalStep(
    id: json['id'] as String,
    title: json['title'] as String,
    isDone: json['isDone'] as bool? ?? false,
  );
}

class VirilGoal {
  VirilGoal({
    required this.id,
    required this.title,
    required this.durationDays,
    required this.startedAt,
    required this.steps,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final int durationDays;
  final DateTime startedAt;
  final List<VirilGoalStep> steps;
  bool isArchived;

  DateTime get deadline => startedAt.add(Duration(days: durationDays));
  int get completedSteps => steps.where((step) => step.isDone).length;
  int get progress => steps.isEmpty ? 0 : completedSteps * 100 ~/ steps.length;
  bool get isCompleted => steps.isNotEmpty && completedSteps == steps.length;
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(deadline);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'durationDays': durationDays,
    'startedAt': startedAt.toIso8601String(),
    'isArchived': isArchived,
    'steps': steps.map((step) => step.toJson()).toList(),
  };

  factory VirilGoal.fromJson(Map<String, dynamic> json) => VirilGoal(
    id: json['id'] as String,
    title: json['title'] as String,
    durationDays: json['durationDays'] as int,
    startedAt: DateTime.parse(json['startedAt'] as String),
    isArchived: json['isArchived'] as bool? ?? false,
    steps: (json['steps'] as List<dynamic>? ?? [])
        .map((item) => VirilGoalStep.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class GoalStore extends ChangeNotifier {
  GoalStore._();
  static final GoalStore instance = GoalStore._();
  static const _storageKey = 'viril.goals.v1';

  SharedPreferences? _prefs;
  final List<VirilGoal> _goals = [];
  bool _ready = false;

  List<VirilGoal> get goals => List.unmodifiable(_goals);
  List<VirilGoal> get activeGoals => _goals.where((goal) => !goal.isArchived).toList();
  int get completedGoals => _goals.where((goal) => goal.isCompleted).length;

  Future<void> initialize() async {
    if (_ready) return;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_storageKey);
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as List<dynamic>;
        _goals.addAll(data.map((item) => VirilGoal.fromJson(item as Map<String, dynamic>)));
      } catch (_) {
        _goals.clear();
      }
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> addGoal(String title, int durationDays) async {
    final value = title.trim();
    if (value.isEmpty) return;
    _goals.insert(0, VirilGoal(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: value,
      durationDays: durationDays,
      startedAt: DateTime.now(),
      steps: [],
    ));
    await _save();
    notifyListeners();
  }

  Future<void> addStep(String goalId, String title) async {
    final value = title.trim();
    if (value.isEmpty) return;
    final goal = _find(goalId);
    if (goal == null) return;
    goal.steps.add(VirilGoalStep(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: value,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> toggleStep(String goalId, String stepId) async {
    final goal = _find(goalId);
    if (goal == null) return;
    final index = goal.steps.indexWhere((step) => step.id == stepId);
    if (index < 0) return;
    goal.steps[index].isDone = !goal.steps[index].isDone;
    await _save();
    notifyListeners();
  }

  Future<void> removeStep(String goalId, String stepId) async {
    final goal = _find(goalId);
    if (goal == null) return;
    goal.steps.removeWhere((step) => step.id == stepId);
    await _save();
    notifyListeners();
  }

  Future<void> archiveGoal(String goalId) async {
    final goal = _find(goalId);
    if (goal == null) return;
    goal.isArchived = true;
    await _save();
    notifyListeners();
  }

  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((goal) => goal.id == goalId);
    await _save();
    notifyListeners();
  }

  VirilGoal? _find(String id) {
    for (final goal in _goals) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  Future<void> _save() async {
    await _prefs?.setString(
      _storageKey,
      jsonEncode(_goals.map((goal) => goal.toJson()).toList()),
    );
  }
}
