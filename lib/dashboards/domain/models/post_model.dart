import 'package:my_app/dashboards/domain/models/post_attachment.dart';

class PostModel {
  final int id;
  final String? title;
  final String? link;
  final String content;
  final String category;
  final String? createdByFullName;
  final String? createdByUsername;
  final String? createdByDesignation;
  final String? createdByProfilePhoto;
  final int? createdById;
  final bool isPublished;
  final bool isPinned;
  final bool isRead;
  final int? viewCount;
  final bool canSeeViewers;
  final DateTime createdAt;
  final List<PostAttachment> attachments;

  PostModel({
    required this.id,
    this.title,
    this.link,
    required this.content,
    required this.category,
    this.createdByFullName,
    this.createdByUsername,
    this.createdByDesignation,
    this.createdByProfilePhoto,
    this.createdById,
    required this.isPublished,
    required this.isPinned,
    required this.isRead,
    this.viewCount,
    this.canSeeViewers = false,
    required this.createdAt,
    required this.attachments,
  });

  bool isAuthoredBy({
    String? userId,
    String? username,
    String? email,
  }) {
    if (createdById != null && userId != null && userId.isNotEmpty) {
      return createdById.toString() == userId;
    }

    final author = (createdByUsername ?? '').trim().toLowerCase();
    if (author.isEmpty) return false;

    final candidates = <String>{
      if (username != null && username.trim().isNotEmpty)
        username.trim().toLowerCase(),
      if (email != null && email.trim().isNotEmpty) email.trim().toLowerCase(),
    };
    return candidates.contains(author);
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final viewCount = _parseViewCount(
      json['view_count'] ??
          json['views_count'] ??
          json['views'] ??
          json['seen_count'] ??
          json['read_count'],
    );
    final canSeeViewers =
        _jsonTruthy(json['can_see_viewers']) || viewCount != null;

    return PostModel(
      id: (json['id'] as int?) ?? int.tryParse('${json['id']}') ?? 0,
      title: json['title'] as String?,
      link: json['link'] as String?,
      content: (json['content'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      createdByFullName: json['created_by_full_name'] as String?,
      createdByUsername: json['created_by_username'] as String?,
      createdByDesignation: json['created_by_designation'] as String?,
      createdByProfilePhoto: json['created_by_profile_photo'] as String?,
      createdById: _parseCreatedById(json['created_by']),
      isPublished: (json['is_published'] as bool?) ?? false,
      isPinned: (json['is_pinned'] as bool?) ?? false,
      isRead: (json['is_read'] as bool?) ?? false,
      viewCount: viewCount,
      canSeeViewers: canSeeViewers,
      createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      attachments: parsePostAttachments(json['attachments']),
    );
  }

  PostModel copyWith({
    int? id,
    String? title,
    String? link,
    String? content,
    String? category,
    String? createdByFullName,
    String? createdByUsername,
    String? createdByDesignation,
    String? createdByProfilePhoto,
    int? createdById,
    bool? isPublished,
    bool? isPinned,
    bool? isRead,
    int? viewCount,
    bool? canSeeViewers,
    DateTime? createdAt,
    List<PostAttachment>? attachments,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      content: content ?? this.content,
      category: category ?? this.category,
      createdByFullName: createdByFullName ?? this.createdByFullName,
      createdByUsername: createdByUsername ?? this.createdByUsername,
      createdByDesignation: createdByDesignation ?? this.createdByDesignation,
      createdByProfilePhoto: createdByProfilePhoto ?? this.createdByProfilePhoto,
      createdById: createdById ?? this.createdById,
      isPublished: isPublished ?? this.isPublished,
      isPinned: isPinned ?? this.isPinned,
      isRead: isRead ?? this.isRead,
      viewCount: viewCount ?? this.viewCount,
      canSeeViewers: canSeeViewers ?? this.canSeeViewers,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
    );
  }
}

int? _parseCreatedById(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is String) return int.tryParse(raw);
  if (raw is Map) {
    final id = raw['id'];
    if (id is int) return id;
    return int.tryParse('$id');
  }
  return int.tryParse('$raw');
}

bool _jsonTruthy(dynamic value) {
  if (value == true || value == 1) return true;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
  }
  return false;
}

int? _parseViewCount(dynamic value) {
  if (value == null) return null;
  return int.tryParse('$value');
}
