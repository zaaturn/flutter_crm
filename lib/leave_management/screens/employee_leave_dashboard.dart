import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../block/leave_bloc.dart';
import '../block/leave_event.dart';
import '../block/leave_state.dart';
import "package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart";
import "package:my_app/employee_dashboard/widget/bottom_nav.dart";
import 'package:my_app/leave_management/screens/pending_leave_update_screen_mobile.dart';

class EmployeeLeaveDashboardScreen extends StatefulWidget {
  const EmployeeLeaveDashboardScreen({super.key});

  @override
  State<EmployeeLeaveDashboardScreen> createState() =>
      _EmployeeLeaveDashboardScreenState();
}

class _EmployeeLeaveDashboardScreenState
    extends State<EmployeeLeaveDashboardScreen> {

  static const _indigo = Color(0xFF5452F6);
  static const _textMain = Color(0xFF1E293B);
  static const _textMuted = Color(0xFF64748B);
  static const _bg = Colors.white;

  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(LoadMyLeaves());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        centerTitle: false,
        // --- ADDED BACK BUTTON HERE ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textMain, size: 20),
          onPressed: () {
            // Explicitly navigate back to the Main Dashboard
            EmployeeDashboardNavigator.dashboard(context);
          },
        ),
        titleSpacing: 0, // Reduces space after back button
        title: const Text(
          "Leave Management",
          style: TextStyle(
            color: _textMain,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            _buildStatusOverviewCard(),

            const SizedBox(height: 32),

            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),

            const SizedBox(height: 16),

            // 1. APPLY LEAVE
            _modernDashboardTile(
              title: "Apply Leave",
              subtitle: "Request new time off",
              icon: Icons.add_moderator_rounded,
              iconColor: Colors.green,
              onTap: () => EmployeeDashboardNavigator.applyLeave(context),
            ),

            // 2. PENDING LEAVES
            _modernDashboardTile(
              title: "Manage Pending",
              subtitle: "Edit or update active requests",
              icon: Icons.pending_actions_rounded,
              iconColor: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingLeaveUpdateScreen(),
                  ),
                );
              },
            ),

            // 3. LEAVE STATUS
            _modernDashboardTile(
              title: "Leave Status",
              subtitle: "Track your history",
              icon: Icons.history_toggle_off_rounded,
              iconColor: _indigo,
              onTap: () => EmployeeDashboardNavigator.leaveStatus(context),
            ),

            // 4. HOLIDAY CALENDAR
            _modernDashboardTile(
              title: "Holiday Calendar",
              subtitle: "Upcoming company holidays",
              icon: Icons.calendar_today_rounded,
              iconColor: Colors.orange,
              onTap: () => EmployeeDashboardNavigator.holidayCalendar(context),
              isLast: true,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  // ================= STATUS OVERVIEW CARD =================

  Widget _buildStatusOverviewCard() {
    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {
        int pendingCount = 0;
        if (state is MyLeavesLoaded) {
          pendingCount = state.leaves.where((e) => e.status == "PENDING").length;
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pending Requests",
                      style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("AWAITING",
                        style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "$pendingCount",
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: _indigo,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              const Text(
                "Your leave requests are processed within 24-48 hours by your manager.",
                style: TextStyle(color: _textMuted, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= CLEAN DASHBOARD TILE =================

  Widget _modernDashboardTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
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
                      fontWeight: FontWeight.w800,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _textMuted),
          ],
        ),
      ),
    );
  }
}