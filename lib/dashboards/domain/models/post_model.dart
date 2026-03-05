import 'package:my_app/dashboards/domain/models/post_attachment.dart';

class PostModel {
  final int id;
  final String? title;
  final String content;
  final String category;
  final bool isPublished;
  final bool isPinned;
  final bool isRead;
  final DateTime createdAt;
  final List<PostAttachment> attachments;

  PostModel({
    required this.id,
    this.title,
    required this.content,
    required this.category,
    required this.isPublished,
    required this.isPinned,
    required this.isRead,
    required this.createdAt,
    required this.attachments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      isPublished: json['is_published'],
      isPinned: json['is_pinned'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      attachments: (json['attachments'] as List)
          .map((e) => PostAttachment.fromJson(e))
          .toList(),
    );
  }
}