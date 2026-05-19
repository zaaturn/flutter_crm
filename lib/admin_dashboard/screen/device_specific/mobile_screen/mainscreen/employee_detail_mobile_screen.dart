import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

import '../widget/employee_detail/employee_detail_mobile_body.dart';
import '../widget/employee_detail/employee_detail_mobile_theme.dart';
import '../widget/employee_detail/employee_detail_mobile_top_bar.dart';

class EmployeeDetailMobileScreen extends StatelessWidget {
  const EmployeeDetailMobileScreen({super.key, required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDetailMobileTheme.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EmployeeDetailMobileTopBar(
              title: 'Employee profile',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: EmployeeDetailMobileBody(employee: employee),
            ),
          ],
        ),
      ),
    );
  }
}
