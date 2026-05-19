import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../block/leave_bloc.dart';
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

class _EmployeeLeaveDashboardScreenState extends State<EmployeeLeaveDashboardScreen> {
  // Base Colors
  static const _textMain = Color(0xFF3E2723);
  static const _textMuted = Color(0xFF8D6E63);
  static const _bg = Color(0xFFFAF3E0);
  static const _card = Color(0xFFEADBC8);
  static const _terracotta = Color(0xFFC05E41);
  static const _accentOrange = Color(0xFFF3924C);


  static const _matcha = Color(0xFF8FB78F);
  static const _azure = Color(0xFFB4CCCF);
  static const _pastelPink = Color(0xFFF3B3CD);
  static const _lavender = Color(0xFFC4C3E3);
  static const _sage = Color(0xFFA3B66B);


  static const _deepMatcha = Color(0xFF2D4F2D);
  static const _navyContrast = Color(0xFF0C2C47);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textMain, size: 20),
          onPressed: () => EmployeeDashboardNavigator.leaveBackToMain(context),
        ),
        title: Text(
          "Leave Management",
          style: GoogleFonts.manrope(
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
            Text(
              "Quick Actions",
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 16),
            _modernDashboardTile(
              title: "Apply Leave",
              subtitle: "Request new time off",
              icon: Icons.add_moderator_rounded,
              tileColor: _lavender,
              onTap: () => EmployeeDashboardNavigator.applyLeave(context),
            ),
            _modernDashboardTile(
              title: "Manage Pending",
              subtitle: "Edit or update active requests",
              icon: Icons.pending_actions_rounded,
              tileColor: _pastelPink,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingLeaveUpdateScreen(),
                  ),
                );
              },
            ),
            _modernDashboardTile(
              title: "Leave Status",
              subtitle: "Track your history",
              icon: Icons.history_toggle_off_rounded,
              tileColor: _sage,
              onTap: () => EmployeeDashboardNavigator.leaveStatus(context),
            ),
            _modernDashboardTile(
              title: "Holiday Calendar",
              subtitle: "Upcoming company holidays",
              icon: Icons.calendar_today_rounded,
              tileColor: _azure,
              onTap: () => EmployeeDashboardNavigator.holidayCalendar(context),
              isLast: true,
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget _buildStatusOverviewCard() {
    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {
        final bloc = context.read<LeaveBloc>();
        final leaves = state is MyLeavesLoaded ? state.leaves : bloc.myLeavesSnapshot;
        final pendingCount = leaves.where((e) => e.status.toUpperCase() == 'PENDING').length;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // Matcha card (requested)

            color: _matcha,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _deepMatcha.withValues(alpha: 0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                // Reduce "white blur" by keeping shadow subtle + tighter
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Pending Requests",
                      style: GoogleFonts.manrope(
                          color: _deepMatcha,
                          fontWeight: FontWeight.w700,
                          fontSize: 14
                      )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      // Keep it readable on green: use light chip + strong text
                      color: Colors.white.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      "AWAITING",
                      style: GoogleFonts.manrope(
                        color: _navyContrast,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$pendingCount',
                style: GoogleFonts.manrope(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.25)),
              const SizedBox(height: 16),
              Text(
                "Your leave requests are processed within 24-48 hours by your manager.",
                style: GoogleFonts.manrope(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modernDashboardTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color tileColor,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    // We use a dark navy or deep matcha for strong contrast to remove the "blur"
    const Color contentColor = _navyContrast;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: Colors.white.withOpacity(0.3), // Clearer icon box
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: contentColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w900, // Thicker font
                      color: contentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: contentColor.withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: contentColor.withOpacity(0.4), size: 16),
          ],
        ),
      ),
    );
  }
}