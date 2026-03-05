import '../../domain/models/post_model.dart';
import 'package:my_app/dashboards/domain/repository/post_repository.dart';
import 'package:my_app/dashboards/data/datasource/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PostModel>> fetchPosts({int page = 1}) async {
    final response = await remoteDataSource.fetchPosts(page);

    final List results = response.data['results'];

    return results.map((json) => PostModel.fromJson(json)).toList();
  }

  @override
  Future<void> markAsRead(int postId) async {
    await remoteDataSource.markAsRead(postId);
  }

  @override
  Future<void> createPost({
    required String caption,
    String? link,
    required String category,
  }) async {
    await remoteDataSource.createPost(
      caption: caption,
      link: link,
      category: category,
    );
  }
}