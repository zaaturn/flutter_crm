import 'package:dio/dio.dart';
import 'package:my_app/services/api_client.dart';

class PostRemoteDataSource {
  final ApiClient apiClient;

  PostRemoteDataSource(this.apiClient);

  static const String _base = '/api/shared/posts/';

  Future<dynamic> fetchPosts({
    required int page,
    String? category,
    int? pageSize,
    bool mine = false,
  }) async {
    final qp = <String, dynamic>{
      'page': page,
      'ordering': '-created_at',
      if (category != null && category.trim().isNotEmpty) 'category': category,
      if (pageSize != null) 'page_size': pageSize,
      if (mine) 'mine': 'true',
    };
    final response = await apiClient.dio.get(_base, queryParameters: qp);
    return response.data;
  }

  Future<Map<String, dynamic>> fetchPostById(int id) {
    return apiClient.get('$_base$id/');
  }

  Future<void> markAsRead(int id) async {
    await apiClient.post('$_base$id/mark_read/');
  }

  Future<void> publish(int id) async {
    await apiClient.patch('$_base$id/publish/');
  }

  Future<Map<String, dynamic>> fetchSeenBy(int id) async {
    return apiClient.get('$_base$id/seen_by/');
  }

  Future<Map<String, dynamic>> createPost({
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

    FormData form = FormData();

    if (title != null && title.trim().isNotEmpty) {
      form.fields.add(MapEntry("title", title.trim()));
    }
    if (link != null && link.trim().isNotEmpty) {
      form.fields.add(MapEntry("link", link.trim()));
    }
    form.fields.add(MapEntry("content", content.trim()));
    form.fields.add(MapEntry("category", category));
    form.fields.add(MapEntry("is_all_users", isAllUsers ? "true" : "false"));

    /// USERS
    if (targetUsers != null) {
      for (var id in targetUsers) {
        form.fields.add(MapEntry("target_users", id.toString()));
      }
    }

    /// DEPARTMENTS
    if (targetDepartments != null) {
      for (var id in targetDepartments) {
        form.fields.add(MapEntry("target_departments", id.toString()));
      }
    }

    /// DESIGNATIONS
    if (targetDesignations != null) {
      for (var id in targetDesignations) {
        form.fields.add(MapEntry("target_designations", id.toString()));
      }
    }

    /// ATTACHMENTS (multiple)
    if (attachments != null) {
      for (final f in attachments) {
        form.files.add(MapEntry("attachments", f));
      }
    }

    return await apiClient.post(
      _base,
      body: form,
    );
  }
}