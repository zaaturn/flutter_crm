import 'package:dio/dio.dart';   // ADD THIS
import '../../domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/data/datasource/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PostModel>> fetchPosts({
    int page = 1,
    String? category,
    int? pageSize,
  }) async {
    final response = await remoteDataSource.fetchPosts(
      page: page,
      category: category,
      pageSize: pageSize,
    );

    final data = response;
    final List results =
        data is List ? data : (data['results'] as List? ?? const []);

    return results
        .map((json) => PostModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<PostModel> fetchPostById(int postId) async {
    final data = await remoteDataSource.fetchPostById(postId);
    return PostModel.fromJson(Map<String, dynamic>.from(data));
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
  Future<List<dynamic>> fetchSeenBy(int postId) async {
    final data = await remoteDataSource.fetchSeenBy(postId);
    return List<dynamic>.from(data);
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
  }}