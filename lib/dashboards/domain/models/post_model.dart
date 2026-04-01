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
  final bool isPublished;
  final bool isPinned;
  final bool isRead;
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
    required this.isPublished,
    required this.isPinned,
    required this.isRead,
    required this.createdAt,
    required this.attachments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
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
      isPublished: (json['is_published'] as bool?) ?? false,
      isPinned: (json['is_pinned'] as bool?) ?? false,
      // Some create/list endpoints omit this field.
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      attachments: ((json['attachments'] as List?) ?? const [])
          .map((e) => PostAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}