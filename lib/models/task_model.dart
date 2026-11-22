
class Task{
  final int? id;
  final String title;
  final String category;
  final bool isComplete;
  final DateTime? dueDate;

  Task({
    this.id,
    required this.title,
    required this.category,
    this.isComplete = false,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'isComplete': isComplete ? 1 : 0,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      isComplete: map['isComplete'] == 1,
      dueDate: map['dueDate'] == null
      ? null
      : DateTime.parse(map['dueDate'] as String),
    );
  }
}