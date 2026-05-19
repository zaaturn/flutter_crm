import 'package:equatable/equatable.dart';

/// Employee (or user) row for payroll record creation picker.
class PayrollEmployeeOption extends Equatable {
  const PayrollEmployeeOption({
    required this.id,
    required this.label,
    this.subtitle,
  });

  final int id;
  final String label;
  final String? subtitle;

  @override
  List<Object?> get props => [id, label, subtitle];
}
