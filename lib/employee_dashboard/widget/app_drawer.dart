import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import '../bloc/employee_dashboard_bloc.dart';
import '../bloc/employee_dashboard_state.dart';

import '../../services/secure_storage_service.dart';
import 'package:my_app/screens/welcome_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  final Color bgLight = const Color(0xFFF1F5F9);
  final Color textSecondary = const Color(0xFF64748B);
  final Color primaryIndigo = const Color(0xFF4F46E5);
  final Color accentViolet = const Color(0xFF7C3AED);
  final Color destructiveRed = const Color(0xFFE11D48);
  final Color textDark = const Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: bgLight,
      elevation: 0,
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("NAVIGATION"),
                  const SizedBox(height: 8),

                  _drawerItem(
                    icon: Icons.assignment_outlined,
                    title: "Tasks",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/tasks");
                    },
                  ),

                  _drawerItem(
                    icon: Icons.calendar_month_outlined,
                    title: "Leave Request",
                    onTap: () {
                      EmployeeDashboardNavigator.leaveDashboard(context);
                    },
                  ),

                  _drawerItem(
                    icon: Icons.receipt_long_outlined,
                    title: "Payslip",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/payslip");
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                    child: Divider(color: Colors.black12, thickness: 1),
                  ),

                  _sectionLabel("ACCOUNT"),
                  const SizedBox(height: 8),

                  _drawerItem(
                    icon: Icons.power_settings_new,
                    title: "Logout",
                    color: destructiveRed,
                    isDestructive: true,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "v1.0.4",
              style: TextStyle(
                color: textSecondary.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        final emp = state.employee;
        final username = emp?.username?.toString() ?? "";
        final displayName = username.contains("@")
            ? username.split("@").first.capitalize()
            : username.capitalize();

        final empId = emp?.employeeId?.toString() ?? "---";
        final photoUrl = emp?.profilePhoto;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 60,
            left: 20,
            right: 20,
            bottom: 30,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryIndigo, accentViolet],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white12,
                backgroundImage:
                (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? const Icon(Icons.person,
                    size: 35, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                displayName.isNotEmpty ? displayName : "Employee",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Employee ID: $empId",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    Color? color,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final activeColor = color ?? primaryIndigo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon,
                  color: isDestructive ? activeColor : textDark),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDestructive ? activeColor : textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right,
                  size: 18,
                  color: textDark.withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close dialog only
                Navigator.of(context).pop();

                // Clear storage BEFORE navigation
                await SecureStorageService().clearAll();



                // Remove entire stack safely
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const WelcomePage(),
                  ),
                      (route) => false,
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}

extension StringCasing on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
