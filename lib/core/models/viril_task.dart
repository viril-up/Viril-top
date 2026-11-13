class VirilTask {
  const VirilTask({
    required this.id,
    required this.title,
    required this.domain,
    required this.createdAt,
    this.completed = false,
    this.period = 'day',
    this.xpReward = 10,
  });

  final String id;
  final String title;
  // Kept for compatibility with existing development-module tasks.
  final String domain;
  final DateTime createdAt;
  final bool completed;
  final String period;
  final int xpReward;

  VirilTask copyWith({bool? completed, String? period, int? xpReward}) => VirilTask(
    id: id,
    title: title,
    domain: domain,
    createdAt: createdAt,
    completed: completed ?? this.completed,
    period: period ?? this.period,
    xpReward: xpReward ?? this.xpReward,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'domain': domain,
    'createdAt': createdAt.toIso8601String(),
    'completed': completed,
    'period': period,
    'xpReward': xpReward,
  };

  factory VirilTask.fromJson(Map<String, dynamic> json) => VirilTask(
    id: json['id'] as String,
    title: json['title'] as String,
    domain: json['domain'] as String? ?? 'Другое',
    createdAt: DateTime.parse(json['createdAt'] as String),
    completed: json['completed'] as bool? ?? false,
    period: json['period'] as String? ?? 'day',
    xpReward: json['xpReward'] as int? ?? 10,
  );
}
