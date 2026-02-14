import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/model/pagenated_response.dart';
import 'package:my_app/services/api_client.dart';

abstract class IEmployeeRepository {
  Future<PaginatedResponse> getEmployees({
    int page = 1,
    String? role,
    String? search,
  });

  Future<Employee> getEmployeeDetail(int id);

  Future<Map<int, Map<String, dynamic>>> getLiveStatus();
}

class EmployeeRepository implements IEmployeeRepository {
  final ApiClient _apiClient;

  EmployeeRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // =========================
  // GET PAGINATED EMPLOYEES
  // =========================
  @override
  Future<PaginatedResponse> getEmployees({
    int page = 1,
    String? role,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': 10,
        'ordering': 'first_name',
      };

      if (role != null && role.isNotEmpty) {
        queryParams['designation'] = role;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        '${_apiClient.baseAccounts}/employeeslist/',
        queryParameters: queryParams,
      );

      return PaginatedResponse.fromJson(response);

    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }


  // =========================
  // GET EMPLOYEE DETAIL
  // =========================
  @override
  Future<Employee> getEmployeeDetail(int id) async {
    try {
      final response = await _apiClient.get(
        '${_apiClient.baseAccounts}/employeeslist/$id/',
      );

      return Employee.fromJson(response);

    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch employee detail: $e');
    }
  }


  // =========================
  // GET LIVE STATUS
  // =========================
  @override
  Future<Map<int, Map<String, dynamic>>> getLiveStatus() async {
    try {
      final response = await _apiClient.getList(
        '${_apiClient.baseEmployee}/live-status/',
      );

      final result = <int, Map<String, dynamic>>{};

      for (final item in response) {
        if (item is! Map<String, dynamic>) continue;

        final id = item['id'] as int?;
        if (id == null) continue;

        result[id] = {
          'liveStatus': _parseStatus(item['status']),
          'checkIn': item['check_in'] ?? '-',
          'checkOut': item['check_out'] ?? '-',
        };
      }

      return result;

    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch live status: $e');
    }
  }


  // =========================
  // STATUS PARSER
  // =========================
  LiveStatus _parseStatus(dynamic s) {
    switch (s) {
      case 'working':
        return LiveStatus.working;
      case 'break':
        return LiveStatus.breakTime;
      default:
        return LiveStatus.loggedOut;
    }
  }
}
