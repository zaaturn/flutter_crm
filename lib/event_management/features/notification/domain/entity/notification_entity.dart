import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final bool isClickable;
  final DateTime createdAt;
  final String? eventId;
  final String? eventColor;
  final String? taskId;
  final String? taskTitle;
  final String? taskStatus;
  final String? taskPriority;
  final String? taskAssignedByUsername;
  final String? leaveId;
  final String? postId;
  final String? postCategory;
  final String? postTitle;
  final String? surveyId;
  final String? surveyTitle;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.isClickable,
    required this.createdAt,
    this.eventId,
    this.eventColor,
    this.taskId,
    this.taskTitle,
    this.taskStatus,
    this.taskPriority,
    this.taskAssignedByUsername,
    this.leaveId,
    this.postId,
    this.postCategory,
    this.postTitle,
    this.surveyId,
    this.surveyTitle,
  });

  bool get hasEvent => eventId != null && eventId!.isNotEmpty;
  bool get hasTask => taskId != null && taskId!.isNotEmpty;
  bool get hasLeave => leaveId != null && leaveId!.isNotEmpty;
  bool get hasPost => postId != null && postId!.isNotEmpty;
  bool get hasSurvey => surveyId != null && surveyId!.isNotEmpty;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime _parseCreatedAt(dynamic raw) {
      final s = raw?.toString();
      if (s == null || s.isEmpty) return DateTime.now();
      try {
        final dt = DateTime.parse(s);
        return dt.isUtc ? dt.toLocal() : dt;
      } catch (_) {
        return DateTime.now();
      }
    }
    return AppNotification(
      id: json['id'].toString(),
      type: json['notif_type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      isRead: json['is_read'] ?? false,
      isClickable: json['is_clickable'] ?? true,
      createdAt: _parseCreatedAt(json['created_at']),
      eventId: json['event_id']?.toString(),
      eventColor: json['event_color'],
      taskId: json['task_id']?.toString(),
      taskTitle: json['task_title'],
      taskStatus: json['task_status'],
      taskPriority: json['task_priority'],
      taskAssignedByUsername: json['task_assigned_by_username'],
      leaveId: json['leave_id']?.toString(),
      postId: json['post_id']?.toString(),
      postCategory: json['post_category'],
      postTitle: json['post_title'],
      surveyId: json['survey_id']?.toString(),
      surveyTitle: json['survey_title']?.toString(),
    );
  }

  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    bool? isRead,
    bool? isClickable,
    DateTime? createdAt,
    String? eventId,
    String? eventColor,
    String? taskId,
    String? taskTitle,
    String? taskStatus,
    String? taskPriority,
    String? taskAssignedByUsername,
    String? leaveId,
    String? postId,
    String? postCategory,
    String? postTitle,
    String? surveyId,
    String? surveyTitle,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      isClickable: isClickable ?? this.isClickable,
      createdAt: createdAt ?? this.createdAt,
      eventId: eventId ?? this.eventId,
      eventColor: eventColor ?? this.eventColor,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      taskStatus: taskStatus ?? this.taskStatus,
      taskPriority: taskPriority ?? this.taskPriority,
      taskAssignedByUsername: taskAssignedByUsername ?? this.taskAssignedByUsername,
      leaveId: leaveId ?? this.leaveId,
      postId: postId ?? this.postId,
      postCategory: postCategory ?? this.postCategory,
      postTitle: postTitle ?? this.postTitle,
      surveyId: surveyId ?? this.surveyId,
      surveyTitle: surveyTitle ?? this.surveyTitle,
    );
  }

  @override
  List<Object?> get props => [id, isRead, isClickable];
}