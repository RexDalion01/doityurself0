
class Task{
  final int? id;
  final String title;
  final String category;
  final bool isComplete;
  final DateTime? dueDate;
  final String priority;
  final String description;

  Task({
    this.id,
    required this.title,
    required this.category,
    this.isComplete = false,
    this.dueDate,
    this.priority = 'Medium',
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isComplete': isComplete ? 1 : 0,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      category: map['category'],
      isComplete: map['isComplete'] == 1,
      dueDate: map['dueDate'] == null
        ? null
        : DateTime.parse(map['dueDate'] as String),
      priority: map['priority'] ?? 'Medium',
    );
  }
}