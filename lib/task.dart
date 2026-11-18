class Task {
  const Task({required this.id, required this.title, this.completed = false});
  final String id;
  final String title;
  final bool completed;

  Task copyWith({String? title, bool? completed}) => Task(
    id: id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
  };

  factory Task.fromJson(Object? json) {
    if (json is! Map<String, dynamic> ||
        json['id'] is! String ||
        (json['id'] as String).isEmpty ||
        json['title'] is! String ||
        (json['title'] as String).trim().isEmpty ||
        json['completed'] is! bool) {
      throw const FormatException('Geçersiz görev verisi.');
    }
    return Task(
      id: json['id'] as String,
      title: (json['title'] as String).trim(),
      completed: json['completed'] as bool,
    );
  }
}
