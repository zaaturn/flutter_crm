import 'package:dio/dio.dart';

abstract class PostEvent {}

class FetchPosts extends PostEvent {
  final String? category;
  final int? pageSize;
  final bool mine;
  FetchPosts({this.category, this.pageSize, this.mine = false});
}

class LoadMorePosts extends PostEvent {
  final String? category;
  final int? pageSize;
  final bool mine;
  LoadMorePosts({this.category, this.pageSize, this.mine = false});
}

class MarkPostAsRead extends PostEvent {
  final int postId;
  MarkPostAsRead(this.postId);
}

class CreatePostEvent extends PostEvent {
  final String? title;
  final String? link;
  final String content;
  final String category;
  final List<MultipartFile> attachments;

  final List<int> userIds;
  final List<int> departmentIds;
  final List<int> designationIds;
  final bool isAllUsers;
  final bool publishAfterCreate;

  CreatePostEvent({
    this.title,
    this.link,
    required this.content,
    required this.category,
    this.attachments = const [],
    this.userIds = const [],
    this.departmentIds = const [],
    this.designationIds = const [],
    this.isAllUsers = false,
    this.publishAfterCreate = false,
  });
}

class FetchPostById extends PostEvent {
  final int postId;
  FetchPostById(this.postId);
}

class PublishPostRequested extends PostEvent {
  final int postId;
  PublishPostRequested(this.postId);
}