import 'package:dio/dio.dart';

abstract class PostEvent {}

class FetchPosts extends PostEvent {}

class LoadMorePosts extends PostEvent {}

class MarkPostAsRead extends PostEvent {
  final int postId;
  MarkPostAsRead(this.postId);
}

class CreatePostEvent extends PostEvent {
  final String title;
  final String description;
  final String category;
  final MultipartFile? file;

  final List<int> userIds;
  final List<int> departmentIds;
  final List<int> designationIds;

  CreatePostEvent({
    required this.title,
    required this.description,
    required this.category,
    this.file,
    this.userIds = const [],
    this.departmentIds = const [],
    this.designationIds = const [],
  });
}