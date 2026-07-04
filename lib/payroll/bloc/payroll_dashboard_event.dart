import 'package:equatable/equatable.dart';

import '../models/payroll_records_paid_filter.dart';

abstract class PayrollDashboardEvent extends Equatable {
  const PayrollDashboardEvent();

  @override
  List<Object?> get props => [];
}

class PayrollDashboardStarted extends PayrollDashboardEvent {
  const PayrollDashboardStarted();
}

class PayrollDashboardRefreshed extends PayrollDashboardEvent {
  const PayrollDashboardRefreshed();
}

class PayrollDashboardMonthChanged extends PayrollDashboardEvent {
  const PayrollDashboardMonthChanged(this.monthIndex);
  /// 1–12.
  final int monthIndex;

  @override
  List<Object?> get props => [monthIndex];
}

class PayrollDashboardYearChanged extends PayrollDashboardEvent {
  const PayrollDashboardYearChanged(this.year);
  final int year;

  @override
  List<Object?> get props => [year];
}

class PayrollDashboardSearchSubmitted extends PayrollDashboardEvent {
  const PayrollDashboardSearchSubmitted(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class PayrollRecordsPaidFilterChanged extends PayrollDashboardEvent {
  const PayrollRecordsPaidFilterChanged(this.filter);
  final PayrollRecordsPaidFilter filter;

  @override
  List<Object?> get props => [filter];
}

class PayrollInlinePatchRequested extends PayrollDashboardEvent {
  const PayrollInlinePatchRequested({
    required this.recordId,
    required this.paid,
    required this.amountRaw,
    this.notifySalaryCredited,
  });

  final int recordId;
  final bool? paid;
  final String amountRaw;

  /// `null` = omit `notify_salary_credited` from JSON (e.g. amount-only PATCH).
  /// `true` / `false` = include when [paid] is `true`.
  final bool? notifySalaryCredited;

  @override
  List<Object?> get props => [recordId, paid, amountRaw, notifySalaryCredited];
}

class PayrollBulkUpdateRequested extends PayrollDashboardEvent {
  const PayrollBulkUpdateRequested({
    required this.employeeIds,
    required this.paid,
    required this.amountRaw,
    this.notifySalaryCredited,
    this.amountOverridesExisting = false,
  });

  final List<int> employeeIds;
  final bool? paid;
  final String amountRaw;
  final bool? notifySalaryCredited;
  /// When false, empty [amountRaw] keeps each row's current amount.
  final bool amountOverridesExisting;

  @override
  List<Object?> get props =>
      [employeeIds, paid, amountRaw, notifySalaryCredited, amountOverridesExisting];
}

class PayrollBulkMarkPaidRequested extends PayrollDashboardEvent {
  const PayrollBulkMarkPaidRequested(this.employeeIds);

  final List<int> employeeIds;

  @override
  List<Object?> get props => [employeeIds];
}

class PayrollInlineCreateRequested extends PayrollDashboardEvent {
  const PayrollInlineCreateRequested({
    required this.employeeId,
    required this.paid,
    required this.amountRaw,
    this.notifySalaryCredited,
  });

  final int employeeId;
  final bool? paid;
  final String amountRaw;

  /// When [paid] is `true`, send `true`/`false`; omit key when `null` (optional).
  final bool? notifySalaryCredited;

  @override
  List<Object?> get props => [employeeId, paid, amountRaw, notifySalaryCredited];
}
