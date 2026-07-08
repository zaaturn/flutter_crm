import 'package:dio/dio.dart';
import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/models/post_sort.dart';
import 'package:my_app/dashboards/domain/models/post_seen_by_viewer.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/data/datasource/post_remote_datasource.dart';
import 'package:my_app/services/secure_storage_service.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PostModel>> fetchPosts({
    int page = 1,
    String? category,
    int? pageSize,
    bool mine = false,
  }) async {
    final response = await remoteDataSource.fetchPosts(
      page: page,
      category: category,
      pageSize: pageSize,
      mine: mine,
    );

    final results = _extractPostRows(response);

    var posts = sortPostsNewestFirst(
      results
          .map(PostModel.fromJson)
          .where((post) => post.id > 0)
          .toList(),
    );

    posts = await _applyViewerAccess(posts);

    if (mine) {
      posts = await _filterMine(posts);
    }

    return posts;
  }

  Future<PostModel> _applyViewerAccessToPost(PostModel post) async {
    final posts = await _applyViewerAccess([post]);
    return posts.first;
  }

  Future<List<PostModel>> _applyViewerAccess(List<PostModel> posts) async {
    return posts
        .map(
          (post) => post.copyWith(
            canSeeViewers: true,
            viewCount: post.viewCount ?? 0,
          ),
        )
        .toList();
  }

  Future<List<PostModel>> _filterMine(List<PostModel> posts) async {
    final storage = SecureStorageService();
    final userId = await storage.readUserId();
    final user = await storage.readUser();
    final username = user?['username']?.toString();
    final email = user?['email']?.toString();

    return posts
        .where(
          (post) => post.isAuthoredBy(
            userId: userId,
            username: username,
            email: email,
          ),
        )
        .toList();
  }

  @override
  Future<PostModel> fetchPostById(int postId) async {
    final data = await remoteDataSource.fetchPostById(postId);
    final post = PostModel.fromJson(Map<String, dynamic>.from(data));
    return _applyViewerAccessToPost(post);
  }

  @override
  Future<void> markAsRead(int postId) async {
    await remoteDataSource.markAsRead(postId);
  }

  @override
  Future<void> publish(int postId) async {
    await remoteDataSource.publish(postId);
  }

  @override
  Future<List<PostSeenByViewer>> fetchSeenBy(int postId) async {
    final data = await remoteDataSource.fetchSeenBy(postId);
    return parsePostSeenByResponse(data);
  }

  @override
  Future<PostModel> createPost({
    String? title,
    String? link,
    required String content,
    required String category,
    bool isAllUsers = false,
    List<int>? targetUsers,
    List<int>? targetDepartments,
    List<int>? targetDesignations,
    List<MultipartFile>? attachments,
  }) async {
    final data = await remoteDataSource.createPost(
      title: title,
      link: link,
      content: content,
      category: category,
      isAllUsers: isAllUsers,
      targetUsers: targetUsers,
      targetDepartments: targetDepartments,
      targetDesignations: targetDesignations,
      attachments: attachments,
    );
    return PostModel.fromJson(Map<String, dynamic>.from(data));
  }
}

List<Map<String, dynamic>> _extractPostRows(dynamic data) {
  if (data is List) {
    return data.map(_asJsonMap).whereType<Map<String, dynamic>>().toList();
  }
  if (data is Map) {
    final map = _asJsonMap(data);
    if (map == null) return const [];
    for (final key in const ['results', 'data', 'items', 'posts']) {
      final value = map[key];
      if (value is List) {
        return value.map(_asJsonMap).whereType<Map<String, dynamic>>().toList();
      }
    }
  }
  return const [];
}

Map<String, dynamic>? _asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}