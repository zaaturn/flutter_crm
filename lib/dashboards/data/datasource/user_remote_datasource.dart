import 'package:flutter/foundation.dart';
import 'package:my_app/services/api_client.dart';

class UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSource(this.apiClient);

  Future<List<dynamic>> _fetchListOrAllPages(
    String firstUrl, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // Some endpoints return a bare array; others are DRF paginated.
    try {
      return await apiClient.getList(firstUrl, queryParameters: queryParameters);
    } catch (_) {
      return _fetchAllPages(firstUrl, queryParameters: queryParameters);
    }
  }

  /// Loads every page of a DRF-style `{ results, next }` list (or a bare array).
  Future<List<dynamic>> _fetchAllPages(
    String firstUrl, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final List<dynamic> out = [];
    String? url = firstUrl;
    Map<String, dynamic>? qp = queryParameters;
    var guard = 0;

    while (url != null && url.isNotEmpty && guard++ < 200) {
      final Map<String, dynamic> res =
          await apiClient.get(url, queryParameters: qp);
      qp = null;

      final results = res['results'];
      if (results is List) {
        out.addAll(results);
      }

      final next = res['next'];
      if (next is String && next.isNotEmpty) {
        url = next;
      } else {
        break;
      }
    }

    return out;
  }

  /// Employee list for CRM targeting (Share / audience). Walks pagination so the
  /// UI is not stuck with the first page only. Not the event `users/all` picker.
  Future<List<dynamic>> getUsers({
    String? department,
    String? designation,
    String? search,
  }) async {
    final qp = <String, dynamic>{
      if (department != null) 'department': department,
      if (designation != null) 'designation': designation,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    // Keep in sync with the admin employee list API (`employeeslist/`).
    if (kDebugMode) {
      debugPrint('[Audience] GET users employeeslist/ qp=$qp');
    }
    return _fetchAllPages(
      '${apiClient.baseAccounts}/employeeslist/',
      queryParameters: qp.isEmpty ? null : qp,
    );
  }

  Future<List<dynamic>> getDepartments({String? search}) async {
    final qp = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
    };
    if (kDebugMode) {
      debugPrint('[Audience] GET departments qp=$qp');
    }
    return _fetchListOrAllPages(
      '${apiClient.baseAccounts}/users/departments/',
      queryParameters: qp.isEmpty ? null : qp,
    );
  }

  Future<List<dynamic>> getDesignations({String? search}) async {
    final qp = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
    };
    if (kDebugMode) {
      debugPrint('[Audience] GET designations qp=$qp');
    }
    return _fetchListOrAllPages(
      '${apiClient.baseAccounts}/users/designations/',
      queryParameters: qp.isEmpty ? null : qp,
    );
  }
}
