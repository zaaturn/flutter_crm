import 'package:my_app/services/api_client.dart';

class UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSource(this.apiClient);

  Future<dynamic> getUsers({
    String? department,
    String? designation,
    String? search,
  }) async {
    final response = await apiClient.get(
      '${apiClient.baseAccounts}/employees/',
      queryParameters: {
        if (department != null) 'department': department,
        if (designation != null) 'designation': designation,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    print("USERS RESPONSE: $response");
    return response;
  }

  Future<dynamic> getDepartments({String? search}) async {
    final response = await apiClient.get(
      '${apiClient.baseAccounts}/users/departments/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    print("DEPARTMENT RESPONSE: $response");
    return response;
  }

  Future<dynamic> getDesignations({String? search}) async {
    final response = await apiClient.get(
      '${apiClient.baseAccounts}/users/designations/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    print("DESIGNATION RESPONSE: $response");
    return response;
  }
}