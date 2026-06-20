class CrmTask {
  final int id;
  final String title;
  final String description;
  final String? dueDate;
  final String priority;
  final String status;
  final int? assignedTo;
  final String? assignedToName;
  final int? assignedBy;
  final String? assignedByName;
  final bool isApproved;
  final String? attachment;

  const CrmTask({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = 'MEDIUM',
    this.status = 'PENDING',
    this.assignedTo,
    this.assignedToName,
    this.assignedBy,
    this.assignedByName,
    this.isApproved = false,
    this.attachment,
  });

  factory CrmTask.fromJson(Map<String, dynamic> json) {
    return CrmTask(
      id: _int(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dueDate: json['due_date']?.toString(),
      priority: (json['priority']?.toString() ?? 'MEDIUM').toUpperCase(),
      status: (json['status']?.toString() ?? 'PENDING').toUpperCase(),
      assignedTo: _nullableInt(json['assigned_to']),
      assignedToName: json['assigned_to_name']?.toString(),
      assignedBy: _nullableInt(json['assigned_by']),
      assignedByName: json['assigned_by_name']?.toString(),
      isApproved: json['is_approved'] == true,
      attachment: json['attachment']?.toString(),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
