class Task {
  final int id;
  final String title;
  final String description;
  final String? dueDate;
  final String priority;
  final String status;
  final int? assignedTo;
  final String assignedToName;
  final int? assignedBy;
  final String? assignedByName;
  final bool isApproved;
  final String? attachment;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.priority,
    required this.status,
    this.assignedTo,
    required this.assignedToName,
    this.assignedBy,
    this.assignedByName,
    required this.isApproved,
    this.attachment,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dueDate: json['due_date']?.toString(),
      priority: json['priority']?.toString() ?? 'MEDIUM',
      status: json['status']?.toString().trim().toLowerCase() ?? 'pending',
      assignedTo: _nullableInt(json['assigned_to']),
      assignedToName: json['assigned_to_name']?.toString() ?? 'Unassigned',
      assignedBy: _nullableInt(json['assigned_by']),
      assignedByName: json['assigned_by_name']?.toString(),
      isApproved: json['is_approved'] == true,
      attachment: json['attachment']?.toString(),
    );
  }

  static int? _nullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Task copyWith({
    String? title,
    String? description,
    String? dueDate,
    String? priority,
    String? assignedToName,
    String? assignedByName,
    String? status,
    bool? isApproved,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedBy: assignedBy,
      assignedByName: assignedByName ?? this.assignedByName,
      isApproved: isApproved ?? this.isApproved,
      attachment: attachment,
    );
  }
}
