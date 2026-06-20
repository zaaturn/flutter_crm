import 'package:flutter/material.dart';

import '../../../models/attendance_summary_model.dart';
import '../employee_summary_table.dart';

class EmployeeSummaryTab extends StatelessWidget {
  final AttendanceSummaryModel? data;
  final bool mobile;

  const EmployeeSummaryTab({
    super.key,
    this.data,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final model = data;
    if (model == null) {
      return const Center(child: Text('No summary data'));
    }
    return EmployeeSummaryTable(data: model, mobile: mobile);
  }
}
