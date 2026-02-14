import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';

extension StringCap on String {
  String capitalize() => isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}

class DashboardSidebar extends StatefulWidget {

  final VoidCallback? onNavigateLeave;
  final VoidCallback? onNavigateTask;
  final VoidCallback? onLogout;

  const DashboardSidebar({
    super.key,
    this.onNavigateLeave,
    this.onNavigateTask,
    this.onLogout,
  });

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  int selected = 0;

  static const Color primaryBlue = Color(0xFF137FEC);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color sidebarBg = Color(0xFFF8FAFC);

  void _confirmLogout(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    final bool isApple = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

    if (isApple) {
      showCupertinoDialog(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () => navigator.pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => _handleFinalLogout(navigator),
              child: const Text("Logout"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text("Cancel", style: TextStyle(color: textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () => _handleFinalLogout(navigator),
              child: const Text("Logout"),
            ),
          ],
        ),
      );
    }
  }

  void _handleFinalLogout(NavigatorState navigator) {
    navigator.pop();
    // Safety check: wait for the dialog to close before triggering navigation
    Future.microtask(() {
      if (!mounted) return;
      widget.onLogout?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: sidebarBg.withOpacity(0.8),
        border: Border(right: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          _buildLogoHeader(),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildNavItem("Dashboard", Icons.grid_view_rounded, 0, () {}),
                  _buildNavItem("My Tasks", Icons.task_alt_rounded, 1, () => widget.onNavigateTask?.call()),
                  _buildNavItem("Time Logs", Icons.schedule_rounded, 2, () {}),
                  _buildNavItem("Leave", Icons.calendar_month_rounded, 3, () => widget.onNavigateLeave?.call()),
                  _buildNavItem("Events", Icons.event_rounded, 4, () => EmployeeDashboardNavigator.events(context)),
                ],
              ),
            ),
          ),
          _buildUserFooterSection(),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            "Daxarrow.",
            style: TextStyle(
              color: textMain,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, int index, VoidCallback onTap) {
    final bool isSelected = selected == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          setState(() => selected = index);
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : textMuted,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserFooterSection() {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      buildWhen: (prev, curr) => mounted,
      builder: (context, state) {
        final emp = state.employee;
        final username = emp?.username?.toString() ?? "";
        final displayName = username.contains("@")
            ? username.split("@").first.capitalize()
            : username.capitalize();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: const Icon(Icons.person_rounded, color: primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isNotEmpty ? displayName : "User Name",
                          style: const TextStyle(
                            color: textMain,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "ID: ${emp?.employeeId ?? '---'}",
                          style: const TextStyle(color: textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _confirmLogout(context),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    "Logout System",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}