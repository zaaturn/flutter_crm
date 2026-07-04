import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/employee_card_mobile.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/mobile_employee_section.dart';

/// Live attendance — working / break / logged out (not the staff directory).
class LiveAttendanceMobileScreen extends StatelessWidget {
  const LiveAttendanceMobileScreen({
    super.key,
    required this.employees,
    required this.totalEmployeeCount,
  });

  final List<Employee> employees;
  final int totalEmployeeCount;

  @override
  Widget build(BuildContext context) {
    const lightCream = Color(0xFFFAF9F6);
    const darkSlate = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: lightCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: darkSlate),
        title: Text(
          'Live Attendance',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: darkSlate,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: MobileEmployeeSection(
          totalEmployeeCount: totalEmployeeCount,
          employees: employees,
          onEmployeeTap: (employee) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmployeeCardMobile(employee: employee),
              ),
            );
          },
        ),
      ),
    );
  }
}
