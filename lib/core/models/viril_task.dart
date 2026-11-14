class VirilTask {
  const VirilTask({
    required this.id, required this.title, required this.domain,
    required this.createdAt, this.completed = false, this.completedAt,
    this.period = 'day', this.xpReward = 10,
  });
  final String id;
  final String title;
  final String domain;
  final DateTime createdAt;
  final bool completed;
  final DateTime? completedAt;
  final String period;
  final int xpReward;

  VirilTask copyWith({bool? completed, DateTime? completedAt, bool clearCompletedAt = false, String? period, int? xpReward}) => VirilTask(
    id: id, title: title, domain: domain, createdAt: createdAt,
    completed: completed ?? this.completed,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    period: period ?? this.period, xpReward: xpReward ?? this.xpReward,
  );

  Map<String, Object?> toJson() => {
    'id': id, 'title': title, 'domain': domain, 'createdAt': createdAt.toIso8601String(),
    'completed': completed, 'completedAt': completedAt?.toIso8601String(),
    'period': period, 'xpReward': xpReward,
  };

  factory VirilTask.fromJson(Map<String, dynamic> json) => VirilTask(
    id: json['id'] as String, title: json['title'] as String,
    domain: json['domain'] as String? ?? 'Другое',
    createdAt: DateTime.parse(json['createdAt'] as String),
    completed: json['completed'] as bool? ?? false,
    completedAt: json['completedAt'] == null ? null : DateTime.tryParse(json['completedAt'] as String),
    period: json['period'] as String? ?? 'day', xpReward: json['xpReward'] as int? ?? 10,
  );
}
