class TaskModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? attachment;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.attachment,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      priority: json['priority']?.toString() ?? 'LOW',
      attachment: json['attachment'],
    );
  }


  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? attachment,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attachment: attachment ?? this.attachment,
    );
  }
}
