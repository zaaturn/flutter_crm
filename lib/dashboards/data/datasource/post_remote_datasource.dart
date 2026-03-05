import 'package:dio/dio.dart';
import 'package:my_app/services/api_client.dart';

class PostRemoteDataSource {
  final ApiClient apiClient;

  PostRemoteDataSource(this.apiClient);

  Future<dynamic> fetchPosts(int page) {
    return apiClient.get(
      '/api/posts/',
      queryParameters: {
        'page': page,
      },
    );
  }

  Future<void> markAsRead(int id) async {
    await apiClient.post(
      '/api/posts/$id/mark_read/',
    );
  }

  Future<void> createPost({
    required String caption,
    String? link,
    required String category,
    MultipartFile? file,
  }) async {

    Map<String, dynamic> formMap = {
      "title": "Shared item",
      "content": "${caption.trim()}\n${link ?? ""}",
      "category": category,
    };

    if (file != null) {
      formMap["attachments"] = [file];
    }

    final form = FormData.fromMap(formMap);

    await apiClient.post(
      "/api/posts/",
      body: form,
    );
  }
}