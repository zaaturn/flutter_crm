import 'package:my_app/tasks/task_status_utils.dart';

class TaskModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? attachment;
  final String? dueDate;
  final int? assignedTo;
  final String? assignedToName;
  final int? assignedBy;
  final String? assignedByName;
  final bool isApproved;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.attachment,
    this.dueDate,
    this.assignedTo,
    this.assignedToName,
    this.assignedBy,
    this.assignedByName,
    this.isApproved = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: normalizeTaskStatusForApi(json['status']?.toString() ?? 'PENDING'),
      priority: json['priority']?.toString() ?? 'LOW',
      attachment: json['attachment']?.toString(),
      dueDate: json['due_date']?.toString(),
      assignedTo: _nullableInt(json['assigned_to']),
      assignedToName: json['assigned_to_name']?.toString(),
      assignedBy: _nullableInt(json['assigned_by']),
      assignedByName: json['assigned_by_name']?.toString(),
      isApproved: json['is_approved'] == true,
    );
  }

  static int? _nullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// Who assigned this task — primary label for employee "my tasks" views.
  String get assignedByLabel {
    final name = assignedByName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return '—';
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? attachment,
    String? dueDate,
    int? assignedTo,
    String? assignedToName,
    int? assignedBy,
    String? assignedByName,
    bool? isApproved,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attachment: attachment ?? this.attachment,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedByName: assignedByName ?? this.assignedByName,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
