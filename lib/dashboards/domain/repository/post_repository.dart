import 'package:my_app/dashboards/domain/models/post_model.dart';

abstract class PostRepository {

  Future<List<PostModel>> fetchPosts({int page = 1});

  Future<void> markAsRead(int postId);

  Future<void> createPost({
    required String caption,
    String? link,
    required String category,
  });

}