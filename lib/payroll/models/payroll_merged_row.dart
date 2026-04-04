import 'package:equatable/equatable.dart';

import 'payroll_employee_option.dart';
import 'payroll_record_model.dart';

/// One table row: always an employee; optional existing payroll [recordId].
class PayrollMergedRow extends Equatable {
  const PayrollMergedRow({
    required this.employeeId,
    required this.recordId,
    required this.employeeName,
    required this.jobTitle,
    required this.paid,
    required this.amountRaw,
    required this.amountDisplay,
    required this.updatedDateLabel,
    required this.avatarInitials,
  });

  final int employeeId;
  final int? recordId;
  final String employeeName;
  final String jobTitle;
  /// `null` = Select; `false` = Pending; `true` = Paid.
  final bool? paid;
  final String amountRaw;
  final String amountDisplay;
  final String updatedDateLabel;
  final String avatarInitials;

  /// Prefer [emp] for name / subtitle / avatar: list & PATCH responses often omit
  /// nested `employee`, which would otherwise show as "—" in the table.
  factory PayrollMergedRow.fromRecord(
    PayrollRecordModel r,
    PayrollEmployeeOption emp,
  ) {
    final name = emp.label;
    final subtitle = emp.subtitle ?? '';
    return PayrollMergedRow(
      employeeId: emp.id,
      recordId: r.id == 0 ? null : r.id,
      employeeName: name,
      jobTitle: subtitle,
      paid: r.paid,
      amountRaw: r.amountRaw,
      amountDisplay: r.amountDisplay,
      updatedDateLabel: r.updatedDateLabel,
      avatarInitials: _initialsFromLabel(name),
    );
  }

  factory PayrollMergedRow.placeholder(PayrollEmployeeOption e) {
    final initials = _initialsFromLabel(e.label);
    return PayrollMergedRow(
      employeeId: e.id,
      recordId: null,
      employeeName: e.label,
      jobTitle: e.subtitle ?? '',
      paid: null,
      amountRaw: '',
      amountDisplay: r'$0.00',
      updatedDateLabel: '—',
      avatarInitials: initials,
    );
  }

  static String _initialsFromLabel(String name) {
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2
          ? s.substring(0, 2).toUpperCase()
          : s.toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props =>
      [employeeId, recordId, paid, amountRaw, updatedDateLabel];
}
