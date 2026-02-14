class Task {
  final int id;
  final String title;
  final String description;
  final String priority;
  final String dueDate;
  final String assignedToName;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.assignedToName,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      assignedToName:
      json['assigned_to_name']?.toString() ?? 'Unassigned',
      status: json['status']
          ?.toString()
          .trim()
          .toLowerCase() ??
          'pending',
    );
  }
}



