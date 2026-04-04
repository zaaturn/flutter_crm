import 'package:dio/dio.dart';

import 'package:my_app/services/api_client.dart';

import '../models/payroll_dashboard_model.dart';
import '../models/payroll_employee_option.dart';
import '../models/payroll_records_page.dart';

class PayrollApiException implements Exception {
  PayrollApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// HTTP layer: `/api/payroll/` (Bearer via [ApiClient] interceptors).
class PayrollApiService {
  PayrollApiService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  /// Same default as event module: `…/api/accounts/crm/users/all/`.
  static const String _usersAllPath = String.fromEnvironment(
    'USERS_ALL_PATH',
    defaultValue: '/api/accounts/crm/users/all/',
  );

  /// When true, ask CRM to include staff/superusers in the directory (ignored if unsupported).
  static const bool _usersAllIncludeStaff = bool.fromEnvironment(
    'PAYROLL_USERS_ALL_INCLUDE_STAFF',
    defaultValue: true,
  );

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw PayrollApiException('Unexpected payroll response shape');
  }

  Future<PayrollDashboardModel> fetchDashboard({
    int? year,
    int? month,
  }) async {
    final q = <String, dynamic>{};
    if (year != null) q['year'] = year;
    if (month != null) q['month'] = month;

    final res = await _dio.get<dynamic>(
      '/api/payroll/dashboard/',
      queryParameters: q.isEmpty ? null : q,
    );

    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return PayrollDashboardModel.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    }
    return PayrollDashboardModel.fromJson(_asMap(data));
  }

  Future<PayrollRecordsPage> fetchRecords({
    int? year,
    int? month,
    String? status,
    String? search,
    int page = 1,
    int? pageSize,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (year != null) q['year'] = year;
    if (month != null) q['month'] = month;
    if (status != null && status.isNotEmpty) q['status'] = status;
    if (search != null && search.isNotEmpty) q['search'] = search;
    if (pageSize != null) q['page_size'] = pageSize;

    final res = await _dio.get<dynamic>(
      '/api/payroll/records/',
      queryParameters: q,
    );

    return PayrollRecordsPage.fromJson(res.data);
  }

  /// All CRM users for one row per person (paginated `users/all/`).
  Future<List<PayrollEmployeeOption>> fetchEmployeesForPicker({
    String? search,
  }) async {
    return _fetchCrmUsersAll(search: search);
  }

  Future<List<PayrollEmployeeOption>> _fetchCrmUsersAll({
    String? search,
  }) async {
    var page = 1;
    final out = <PayrollEmployeeOption>[];

    while (true) {
      final res = await _dio.get<dynamic>(
        _usersAllPath,
        queryParameters: <String, dynamic>{
          'page': page,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          if (_usersAllIncludeStaff) ...<String, dynamic>{
            'include_staff': true,
            'include_superusers': true,
          },
        },
      );

      final data = res.data;
      if (data is List) {
        for (final e in data) {
          if (e is! Map) continue;
          final opt = _userMapToOption(Map<String, dynamic>.from(e));
          if (opt != null) out.add(opt);
        }
        break;
      }

      if (data is! Map) break;
      final map = Map<String, dynamic>.from(data);
      final results = map['results'] as List? ?? [];
      for (final e in results) {
        if (e is! Map) continue;
        final opt = _userMapToOption(Map<String, dynamic>.from(e));
        if (opt != null) out.add(opt);
      }

      final next = map['next'];
      if (next == null || next.toString().isEmpty) break;
      page++;
      if (page > 200) break;
    }

    return out;
  }

  PayrollEmployeeOption? _userMapToOption(Map<String, dynamic> m) {
    final id = _parseIntId(m['id'] ?? m['pk']);
    if (id == null || id <= 0) return null;

    final fn = m['first_name']?.toString().trim() ?? '';
    final ln = m['last_name']?.toString().trim() ?? '';
    var label = '$fn $ln'.trim();
    if (label.isEmpty) {
      label = (m['username'] ?? m['name'] ?? m['email'] ?? 'User #$id')
          .toString();
    }
    return PayrollEmployeeOption(
      id: id,
      label: label,
      subtitle: m['email']?.toString(),
    );
  }

  int? _parseIntId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// [paid]: `null` = omit field; `false` pending; `true` paid.
  Future<void> createPayrollRecord({
    required int employeeId,
    required int year,
    required int month,
    bool? paid,
    String? amount,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'employee': employeeId,
      'year': year,
      'month': month,
    };
    if (paid != null) {
      body['paid'] = paid;
    }
    if (amount != null && amount.trim().isNotEmpty) {
      body['amount'] = amount.trim();
    }
    if (note != null && note.trim().isNotEmpty) {
      body['note'] = note.trim();
    }

    await _dio.post<dynamic>('/api/payroll/records/', data: body);
  }

  /// Sends [paid] and [amount] (null amount clears). Use `paid: null` to unset paid.
  Future<void> patchPayrollRecord(
    int id, {
    required bool? paid,
    required String amountRaw,
  }) async {
    final body = <String, dynamic>{
      'paid': paid,
      'amount': amountRaw.trim().isEmpty ? null : amountRaw.trim(),
    };
    await _dio.patch<dynamic>('/api/payroll/records/$id/', data: body);
  }
}
