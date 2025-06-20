// models/task.dart
class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;
  final String priority; // 'high' or 'low'
  final int userId;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    required this.priority,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date_time': dateTime.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
      'priority': priority,
      'user_id': userId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['date_time']),
      isCompleted: map['is_completed'] == 1,
      priority: map['priority'],
      userId: map['user_id'],
    );
  }
}
