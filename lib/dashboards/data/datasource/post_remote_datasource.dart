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
    List<int>? userIds,
    List<int>? departmentIds,
    List<int>? designationIds,
  }) async {

    FormData form = FormData();

    form.fields.add(MapEntry("title", "Shared item"));
    form.fields.add(MapEntry("content", "${caption.trim()}\n${link ?? ""}"));
    form.fields.add(MapEntry("category", category));

    /// USERS
    if (userIds != null) {
      for (var id in userIds) {
        form.fields.add(MapEntry("target_users", id.toString()));
      }
    }

    /// DEPARTMENTS
    if (departmentIds != null) {
      for (var id in departmentIds) {
        form.fields.add(MapEntry("target_departments", id.toString()));
      }
    }

    /// DESIGNATIONS
    if (designationIds != null) {
      for (var id in designationIds) {
        form.fields.add(MapEntry("target_designations", id.toString()));
      }
    }

    /// FILE
    if (file != null) {
      form.files.add(
        MapEntry(
          "attachments",
          file,
        ),
      );
    }

    await apiClient.post(
      "/api/posts/",
      body: form,
    );
  }
}