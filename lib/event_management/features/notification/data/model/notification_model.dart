import '../../domain/entity/notification_entity.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.isRead,
    required super.isClickable,
    required super.createdAt,
    super.eventId,
    super.eventColor,
    super.taskId,
    super.taskTitle,
    super.taskStatus,
    super.taskPriority,
    super.taskAssignedByUsername,
    super.leaveId,
    super.postId,
    super.postCategory,
    super.postTitle,
    super.surveyId,
    super.surveyTitle,
  });

  static Map<String, dynamic>? _taskMap(Map<String, dynamic> json) {
    final t = json['task'];
    if (t is Map<String, dynamic>) return t;
    if (t is Map) return t.map((k, v) => MapEntry(k.toString(), v));
    return null;
  }

  static String? _pickStr(Map<String, dynamic>? m, String key) {
    if (m == null) return null;
    final v = m[key];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final task = _taskMap(json);
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
    return NotificationModel(
      id: json['id'].toString(),
      type: json['notif_type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      isClickable: json['is_clickable'] as bool? ?? true,
      // API usually returns UTC timestamps; normalize to device-local for UI grouping/formatting.
      createdAt: _parseCreatedAt(json['created_at']),
      eventId: json['event_id']?.toString(),
      eventColor: json['event_color'] as String?,
      taskId: json['task_id']?.toString() ?? _pickStr(task, 'id'),
      taskTitle: json['task_title'] as String? ?? _pickStr(task, 'title'),
      taskStatus: json['task_status'] as String? ?? _pickStr(task, 'status'),
      taskPriority: json['task_priority'] as String? ?? _pickStr(task, 'priority'),
      taskAssignedByUsername: json['task_assigned_by_username'] as String? ??
          _pickStr(task, 'assigned_by_username'),
      leaveId: json['leave_id']?.toString(),
      postId: json['post_id']?.toString(),
      postCategory: json['post_category']?.toString(),
      postTitle: json['post_title']?.toString(),
      surveyId: json['survey_id']?.toString(),
      surveyTitle: json['survey_title']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'notif_type': type,
    'title': title,
    'body': body,
    'is_read': isRead,
    'is_clickable': isClickable,
    'created_at': createdAt.toIso8601String(),
    if (eventId != null) 'event_id': eventId,
    if (eventColor != null) 'event_color': eventColor,
    if (taskId != null) 'task_id': taskId,
    if (taskTitle != null) 'task_title': taskTitle,
    if (taskStatus != null) 'task_status': taskStatus,
    if (taskPriority != null) 'task_priority': taskPriority,
    if (taskAssignedByUsername != null)
      'task_assigned_by_username': taskAssignedByUsername,
    if (leaveId != null) 'leave_id': leaveId,
    if (postId != null) 'post_id': postId,
    if (postCategory != null) 'post_category': postCategory,
    if (postTitle != null) 'post_title': postTitle,
    if (surveyId != null) 'survey_id': surveyId,
    if (surveyTitle != null) 'survey_title': surveyTitle,
  };

  /// Local (WebSocket / FCM-style) payload.
  factory NotificationModel.fromWebSocket(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['notif_id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: data['notif_type'] as String? ??
          data['type'] as String? ??
          'general',
      title: data['title'] as String? ?? 'New notification',
      body: data['body'] as String? ?? '',
      isRead: false,
      isClickable: data['is_clickable'] as bool? ?? true,
      createdAt: DateTime.now(),
      eventId: data['event_id']?.toString(),
      eventColor: data['color'] as String?,
      taskId: data['task_id']?.toString(),
      taskTitle: data['task_title'] as String?,
      taskStatus: data['task_status'] as String?,
      taskPriority: data['task_priority'] as String?,
      taskAssignedByUsername: data['task_assigned_by_username'] as String?,
      leaveId: data['leave_id']?.toString(),
      postId: data['post_id']?.toString(),
      postCategory: data['post_category']?.toString(),
      postTitle: data['post_title']?.toString(),
      surveyId: data['survey_id']?.toString(),
      surveyTitle: data['survey_title']?.toString(),
    );
  }
}