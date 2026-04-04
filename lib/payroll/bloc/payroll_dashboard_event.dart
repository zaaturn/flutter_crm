import 'package:equatable/equatable.dart';

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

class PayrollInlinePatchRequested extends PayrollDashboardEvent {
  const PayrollInlinePatchRequested({
    required this.recordId,
    required this.paid,
    required this.amountRaw,
  });

  final int recordId;
  final bool? paid;
  final String amountRaw;

  @override
  List<Object?> get props => [recordId, paid, amountRaw];
}

class PayrollInlineCreateRequested extends PayrollDashboardEvent {
  const PayrollInlineCreateRequested({
    required this.employeeId,
    required this.paid,
    required this.amountRaw,
  });

  final int employeeId;
  final bool? paid;
  final String amountRaw;

  @override
  List<Object?> get props => [employeeId, paid, amountRaw];
}
