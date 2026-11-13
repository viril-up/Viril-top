class VirilTask {
  const VirilTask({
    required this.id,
    required this.title,
    required this.domain,
    required this.createdAt,
    this.completed = false,
  });

  final String id;
  final String title;
  final String domain;
  final DateTime createdAt;
  final bool completed;

  VirilTask copyWith({bool? completed}) => VirilTask(
    id: id,
    title: title,
    domain: domain,
    createdAt: createdAt,
    completed: completed ?? this.completed,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'domain': domain,
    'createdAt': createdAt.toIso8601String(),
    'completed': completed,
  };

  factory VirilTask.fromJson(Map<String, dynamic> json) => VirilTask(
    id: json['id'] as String,
    title: json['title'] as String,
    domain: json['domain'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    completed: json['completed'] as bool? ?? false,
  );
}
