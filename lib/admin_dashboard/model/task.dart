class Task {
  final int id;
  final String title;
  final String description;
  final String priority;
  final String dueDate;
  final String assignedToName;
  final String status;
  final bool isApproved;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.assignedToName,
    required this.status,
    required this.isApproved,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      assignedToName: json['assigned_to_name']?.toString() ?? 'Unassigned',
      status: json['status']?.toString().trim().toLowerCase() ?? 'pending',
      isApproved: json['is_approved'] ?? false,
    );
  }

  Task copyWith({String? status, bool? isApproved}) {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      assignedToName: assignedToName,
      status: status ?? this.status,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}