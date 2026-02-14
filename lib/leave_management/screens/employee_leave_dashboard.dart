import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../block/leave_bloc.dart';
import '../block/leave_event.dart';
import '../block/leave_state.dart';
import "package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart";

class EmployeeLeaveDashboardScreen extends StatefulWidget {
  const EmployeeLeaveDashboardScreen({super.key});

  @override
  State<EmployeeLeaveDashboardScreen> createState() =>
      _EmployeeLeaveDashboardScreenState();
}

class _EmployeeLeaveDashboardScreenState
    extends State<EmployeeLeaveDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(LoadMyLeaves());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[900],
        title: const Text(
          "My Leaves",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: BlocBuilder<LeaveBloc, LeaveState>(
                builder: (context, state) {
                  int pendingCount = 0;

                  if (state is MyLeavesLoaded) {
                    pendingCount = state.leaves
                        .where((e) => e.status == "PENDING")
                        .length;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.pending_actions,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$pendingCount",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Pending Requests",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Dashboard Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<LeaveBloc, LeaveState>(
                builder: (context, state) {
                  int pendingCount = 0;

                  if (state is MyLeavesLoaded) {
                    pendingCount = state.leaves
                        .where((e) => e.status == "PENDING")
                        .length;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _modernDashboardTile(
                        title: "Pending Leaves",
                        subtitle: "$pendingCount requests awaiting approval",
                        icon: Icons.hourglass_top,
                        gradient: [Colors.amber.shade400, Colors.amber.shade600],
                        onTap: () {
                          EmployeeDashboardNavigator.leaveDashboard(context);

                        },
                      ),

                      _modernDashboardTile(
                        title: "Apply Leave",
                        subtitle: "Request a new leave",
                        icon: Icons.add_circle_outline,
                        gradient: [Colors.green.shade400, Colors.green.shade600],
                        onTap: () {
                          EmployeeDashboardNavigator.applyLeave(context);
                        },
                      ),

                      _modernDashboardTile(
                        title: "Leave Status",
                        subtitle: "Approved / Rejected history",
                        icon: Icons.assignment_outlined,
                        gradient: [Colors.blue.shade400, Colors.blue.shade600],
                        onTap: () {
                          EmployeeDashboardNavigator.leaveStatus(context);
                        },
                      ),


                      _modernDashboardTile(
                        title: "Public Holiday Calendar",
                        subtitle: "View company holidays",
                        icon: Icons.calendar_month,
                        gradient: [Colors.purple.shade400, Colors.purple.shade600],
                        onTap: () {
                          EmployeeDashboardNavigator.holidayCalendar(context);
                        },
                        isLast: true,
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= MODERN DASHBOARD TILE =================

  Widget _modernDashboardTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: gradient[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}