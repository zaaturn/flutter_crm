import 'package:dio/dio.dart';

import 'package:my_app/services/api_client.dart';

import '../models/payroll_dashboard_model.dart';
import '../models/payroll_employee_option.dart';
import '../models/payroll_records_page.dart';
import '../models/payroll_records_paid_filter.dart';

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

  /// Task / payroll assignee directory (admins + employees).
  static const String _employeesListPath = String.fromEnvironment(
    'EMPLOYEES_LIST_PATH',
    defaultValue: '/api/accounts/crm/employeeslist/',
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
    PayrollRecordsPaidFilter paidFilter = PayrollRecordsPaidFilter.all,
    String? search,
    int page = 1,
    int? pageSize,
  }) async {
    final q = <String, dynamic>{'page': page};
    if (year != null) q['year'] = year;
    if (month != null) q['month'] = month;
    if (search != null && search.isNotEmpty) q['search'] = search;
    if (pageSize != null) q['page_size'] = pageSize;

    switch (paidFilter) {
      case PayrollRecordsPaidFilter.all:
        break;
      case PayrollRecordsPaidFilter.paid:
        q['paid'] = true;
        break;
      case PayrollRecordsPaidFilter.unpaid:
        q['paid'] = false;
        break;
      case PayrollRecordsPaidFilter.unset:
        q['paid'] = 'unset';
        break;
    }

    final res = await _dio.get<dynamic>(
      '/api/payroll/records/',
      queryParameters: q,
    );

    return PayrollRecordsPage.fromJson(res.data);
  }

  /// Admins + employees from CRM `employeeslist/` (paginated when supported).
  Future<List<PayrollEmployeeOption>> fetchEmployeesForPicker({
    String? search,
  }) async {
    return _fetchEmployeesListDirectory(search: search);
  }

  Future<List<PayrollEmployeeOption>> _fetchEmployeesListDirectory({
    String? search,
  }) async {
    final out = <PayrollEmployeeOption>[];
    String? nextUrl = _employeesListPath;

    while (nextUrl != null) {
      final res = await _dio.get<dynamic>(
        nextUrl,
        queryParameters: nextUrl == _employeesListPath
            ? <String, dynamic>{
                if (search != null && search.trim().isNotEmpty)
                  'search': search.trim(),
              }
            : null,
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
      nextUrl = (next == null || next.toString().isEmpty)
          ? null
          : next.toString();
      if (out.length > 50000) break;
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
    final role = m['role']?.toString().trim();
    final isSu = m['is_superuser'] == true ||
        m['is_superuser'] == 1 ||
        m['is_superuser']?.toString() == 'true';
    if (isSu) {
      label = '$label · Superuser';
    } else if (role != null &&
        role.isNotEmpty &&
        role.toLowerCase() != 'employee') {
      label = '$label · $role';
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

  /// [paid]: JSON `true` / `false` / `null` (unset).
  /// [notifySalaryCredited]: write-only; when [paid] is `true`, include `true`/`false`.
  /// Omit the key when `null` (e.g. optional notify on create).
  Future<void> createPayrollRecord({
    required int employeeId,
    required int year,
    required int month,
    bool? paid,
    String? amount,
    String? note,
    bool? notifySalaryCredited,
  }) async {
    final body = <String, dynamic>{
      'employee': employeeId,
      'year': year,
      'month': month,
      'paid': paid,
    };
    if (amount != null && amount.trim().isNotEmpty) {
      body['amount'] = amount.trim();
    }
    if (note != null && note.trim().isNotEmpty) {
      body['note'] = note.trim();
    }
    if (paid == true && notifySalaryCredited != null) {
      body['notify_salary_credited'] = notifySalaryCredited;
    }

    await _dio.post<dynamic>('/api/payroll/records/', data: body);
  }

  /// [notifySalaryCredited]: `null` = omit key (e.g. amount-only PATCH).
  /// Include `true`/`false` only when [paid] is `true`.
  Future<void> patchPayrollRecord(
    int id, {
    required bool? paid,
    required String amountRaw,
    bool? notifySalaryCredited,
  }) async {
    final body = <String, dynamic>{
      'paid': paid,
      'amount': amountRaw.trim().isEmpty ? null : amountRaw.trim(),
    };
    if (paid == true && notifySalaryCredited != null) {
      body['notify_salary_credited'] = notifySalaryCredited;
    }
    await _dio.patch<dynamic>('/api/payroll/records/$id/', data: body);
  }
}
