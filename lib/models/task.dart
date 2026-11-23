/// Modelo inmutable y serializable para el almacenamiento local.
class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'Personal',
    this.dueDate,
    this.completed = false,
  });
  final String id, title, description, category;
  final DateTime? dueDate;
  final bool completed;
  Task toggle() => Task(
    id: id,
    title: title,
    description: description,
    category: category,
    dueDate: dueDate,
    completed: !completed,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'dueDate': dueDate?.toIso8601String(),
    'completed': completed,
  };
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? 'Personal',
    dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
    completed: json['completed'] as bool? ?? false,
  );
}
