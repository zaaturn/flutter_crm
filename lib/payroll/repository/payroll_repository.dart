import '../models/payroll_dashboard_model.dart';
import '../models/payroll_employee_option.dart';
import '../models/payroll_records_page.dart';
import '../models/payroll_records_paid_filter.dart';
import '../services/payroll_api_service.dart';

class PayrollRepository {
  PayrollRepository({PayrollApiService? api}) : _api = api ?? PayrollApiService();

  final PayrollApiService _api;

  Future<PayrollDashboardModel> loadDashboard({
    int? year,
    int? month,
  }) =>
      _api.fetchDashboard(year: year, month: month);

  Future<PayrollRecordsPage> loadRecords({
    int? year,
    int? month,
    PayrollRecordsPaidFilter paidFilter = PayrollRecordsPaidFilter.all,
    String? search,
    int page = 1,
    int? pageSize,
  }) =>
      _api.fetchRecords(
        year: year,
        month: month,
        paidFilter: paidFilter,
        search: search,
        page: page,
        pageSize: pageSize,
      );

  Future<List<PayrollEmployeeOption>> fetchEmployeesForPicker({
    String? search,
  }) =>
      _api.fetchEmployeesForPicker(search: search);

  Future<void> createPayrollRecord({
    required int employeeId,
    required int year,
    required int month,
    bool? paid,
    String? amount,
    String? note,
  }) =>
      _api.createPayrollRecord(
        employeeId: employeeId,
        year: year,
        month: month,
        paid: paid,
        amount: amount,
        note: note,
      );

  Future<void> patchPayrollRecord(
    int id, {
    required bool? paid,
    required String amountRaw,
  }) =>
      _api.patchPayrollRecord(id, paid: paid, amountRaw: amountRaw);
}
