import 'package:my_app/dashboards/domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/models/post_seen_by_viewer.dart';
import 'package:dio/dio.dart';


abstract class PostRepository {

  Future<List<PostModel>> fetchPosts({
    int page = 1,
    String? category,
    int? pageSize,
    bool mine = false,
  });

  Future<PostModel> fetchPostById(int postId);

  Future<void> markAsRead(int postId);

  Future<void> publish(int postId);

  Future<List<PostSeenByViewer>> fetchSeenBy(int postId);

  Future<PostModel> createPost({
    String? title,
    String? link,
    required String content,
    required String category,
    bool isAllUsers,
    List<int>? targetUsers,
    List<int>? targetDepartments,
    List<int>? targetDesignations,
    List<MultipartFile>? attachments,
  });

}