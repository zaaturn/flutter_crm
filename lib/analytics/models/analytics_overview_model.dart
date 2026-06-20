import '../utils/analytics_money.dart';

class AnalyticsOverviewModel {
  final String? asOf;
  final int totalEmployees;
  final int checkedInToday;
  final int onLeaveToday;
  final int notCheckedInToday;
  final int pendingLeaveRequests;
  final int approvedLeavesThisMonth;
  final int pendingTasks;
  final int completedTasksThisMonth;
  final int crmClientsTotal;
  final int billingClientsTotal;
  final String? billingMonth;
  final int invoicesIssued;
  final int invoicesPaid;
  final String? amountInvoiced;
  final String? amountReceived;
  final String? amountPending;
  final String? payrollMonth;
  final int payrollPaidCount;
  final String? payrollAmountPaid;
  final Map<String, dynamic> raw;

  const AnalyticsOverviewModel({
    this.asOf,
    this.totalEmployees = 0,
    this.checkedInToday = 0,
    this.onLeaveToday = 0,
    this.notCheckedInToday = 0,
    this.pendingLeaveRequests = 0,
    this.approvedLeavesThisMonth = 0,
    this.pendingTasks = 0,
    this.completedTasksThisMonth = 0,
    this.crmClientsTotal = 0,
    this.billingClientsTotal = 0,
    this.billingMonth,
    this.invoicesIssued = 0,
    this.invoicesPaid = 0,
    this.amountInvoiced,
    this.amountReceived,
    this.amountPending,
    this.payrollMonth,
    this.payrollPaidCount = 0,
    this.payrollAmountPaid,
    this.raw = const {},
  });

  factory AnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    final data = _unwrap(json);
    final employees = _map(data['employees']);
    final leave = _map(data['leave']);
    final tasks = _map(data['tasks']);
    final clients = _map(data['clients']);
    final billing = _map(data['billing']);
    final payroll = _map(data['payroll']);

    return AnalyticsOverviewModel(
      asOf: data['as_of']?.toString(),
      totalEmployees: _int(employees['total']),
      checkedInToday: _int(employees['checked_in_today']),
      onLeaveToday: _int(employees['on_leave_today']),
      notCheckedInToday: _int(employees['not_checked_in_today']),
      pendingLeaveRequests: _int(leave['pending_requests']),
      approvedLeavesThisMonth: _int(leave['approved_this_month']),
      pendingTasks: _int(tasks['pending_or_in_progress']),
      completedTasksThisMonth: _int(tasks['completed_this_month']),
      crmClientsTotal: _int(clients['crm_total']),
      billingClientsTotal: _int(clients['billing_total']),
      billingMonth: billing['month']?.toString(),
      invoicesIssued: _int(billing['invoices_issued']),
      invoicesPaid: _int(billing['invoices_paid']),
      amountInvoiced: _str(billing['amount_invoiced']),
      amountReceived: _str(billing['amount_received']),
      amountPending: _str(billing['amount_pending']),
      payrollMonth: payroll['month']?.toString(),
      payrollPaidCount: _int(payroll['paid_count']),
      payrollAmountPaid: _str(payroll['amount_paid']),
      raw: data,
    );
  }

  String formatReceived() => AnalyticsMoney.format(amountReceived);
  String formatPayrollPaid() => AnalyticsMoney.format(payrollAmountPaid);

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final nested = json['data'] ?? json['overview'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
