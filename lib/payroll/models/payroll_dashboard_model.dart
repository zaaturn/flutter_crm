/// KPI payload from `GET /api/payroll/dashboard/`.
///
/// Backend should aggregate **paid** rows for [totalPaidAmount] / [paidRecordsCount].
class PayrollDashboardModel {
  const PayrollDashboardModel({
    required this.totalEmployees,
    required this.newHiresThisWeek,
    required this.totalPaidAmount,
    required this.totalPaidPercentChange,
    required this.totalPending,
    required this.pendingSubtitle,
    required this.amountPaidYtd,
    required this.ytdSubtitle,
    required this.paidRecordsCount,
  });

  final int totalEmployees;
  final int newHiresThisWeek;
  /// Sum of amounts for records with status `paid` in the filtered period (backend).
  final String totalPaidAmount;
  final double totalPaidPercentChange;
  final int totalPending;
  final String pendingSubtitle;
  /// YTD total; may be currency or a count if API sends count-only mode.
  final String amountPaidYtd;
  final String ytdSubtitle;
  /// Count of `paid` records in scope (subtitle under Total Paid when non-zero).
  final int paidRecordsCount;

  static PayrollDashboardModel empty(int year) => PayrollDashboardModel(
        totalEmployees: 0,
        newHiresThisWeek: 0,
        totalPaidAmount: r'$0',
        totalPaidPercentChange: 0,
        totalPending: 0,
        pendingSubtitle: 'Scheduled for Friday',
        amountPaidYtd: r'$0',
        ytdSubtitle: 'Fiscal year $year',
        paidRecordsCount: 0,
      );

  factory PayrollDashboardModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    String pickString(List<String> keys, [String fallback = '']) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return fallback;
    }

    String formatMoney(dynamic v) {
      if (v == null) return r'$0';
      if (v is String) {
        if (v.contains(r'$') || v.contains('M') || v.contains('K')) return v;
        final n = double.tryParse(v);
        if (n == null) return v;
        return _formatUsd(n);
      }
      if (v is num) return _formatUsd(v.toDouble());
      return v.toString();
    }

    final year = parseInt(json['year'] ?? json['fiscal_year']) > 0
        ? parseInt(json['year'] ?? json['fiscal_year'])
        : DateTime.now().year;

    return PayrollDashboardModel(
      totalEmployees: parseInt(json['total_employees'] ?? json['totalEmployees']),
      newHiresThisWeek:
          parseInt(json['new_hires_this_week'] ?? json['newHiresThisWeek']),
      totalPaidAmount: formatMoney(
        json['total_paid'] ??
            json['total_paid_amount'] ??
            json['paid_amount_total'] ??
            json['paid_total'],
      ),
      totalPaidPercentChange: parseDouble(
        json['total_paid_percent_change'] ??
            json['paid_change_percent'] ??
            json['paid_percent_change'],
      ),
      totalPending:
          parseInt(json['total_pending'] ?? json['pending_count'] ?? json['totalPending']),
      pendingSubtitle: pickString(
        ['pending_note', 'pending_subtitle'],
        'Scheduled for Friday',
      ),
      amountPaidYtd: formatMoney(
        json['amount_paid_ytd'] ?? json['ytd_paid'] ?? json['paid_ytd'],
      ),
      ytdSubtitle: pickString(
        ['ytd_label', 'fiscal_year_label'],
        'Fiscal year $year',
      ),
      paidRecordsCount: parseInt(
        json['paid_records_count'] ?? json['paid_count'] ?? json['total_paid_count'],
      ),
    );
  }

  static String _formatUsd(double n) {
    if (n >= 1e6) {
      final m = n / 1e6;
      final s = m >= 10 ? m.toStringAsFixed(1) : m.toStringAsFixed(2);
      return '\$${s}M';
    }
    if (n >= 1000) {
      final s = _comma(n.round());
      return '\$$s';
    }
    final parts = n.toStringAsFixed(2).split('.');
    return '\$${_comma(int.parse(parts[0]))}.${parts[1]}';
  }

  static String _comma(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
