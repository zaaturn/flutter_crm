import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';

import 'package:my_app/leave_management/screens/device_specific/pending_leave_update_screen.dart';
import 'package:my_app/leave_management/screens/device_specific/apply_leave_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_status_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/public_holiday_desktop.dart';

class EmployeeLeaveDashboardScreenDesktop extends StatefulWidget {
  const EmployeeLeaveDashboardScreenDesktop({super.key});

  @override
  State<EmployeeLeaveDashboardScreenDesktop> createState() =>
      _EmployeeLeaveDashboardScreenState();
}

class _EmployeeLeaveDashboardScreenState
    extends State<EmployeeLeaveDashboardScreenDesktop> {
  static const Color _bgSlate = Color(0xFFF8FAFC);
  static const Color _borderSlate = Color(0xFFE2E8F0);
  static const Color _textMain = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: _bgSlate,
      body: CustomScrollView(
        slivers: [
          _buildDesktopAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 20,
                vertical: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryHero(),
                  const SizedBox(height: 40),
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<LeaveBloc, LeaveState>(
                    builder: (context, state) {
                      final bloc = context.read<LeaveBloc>();
                      final leaves = state is MyLeavesLoaded
                          ? state.leaves
                          : bloc.myLeavesSnapshot;
                      final pendingCount = leaves
                          .where((e) => e.status.toUpperCase() == 'PENDING')
                          .length;

                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          // PENDING LEAVES (NOW MODIFIED)
                          _desktopActionCard(
                            width: isWide
                                ? (screenWidth - 128) / 3
                                : (screenWidth - 64) / 2,
                            title: "Pending Leaves",
                            subtitle:
                            "$pendingCount requests awaiting approval.",
                            icon: Icons.hourglass_top_rounded,
                            gradient: const [
                              Color(0xFFFBBF24),
                              Color(0xFFF59E0B)
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<LeaveBloc>(),
                                    child: const PendingLeaveUpdateScreen(),
                                  ),
                                ),
                              );
                            },
                          ),

                          // APPLY LEAVE
                          _desktopActionCard(
                            width: isWide
                                ? (screenWidth - 128) / 3
                                : (screenWidth - 64) / 2,
                            title: "Apply Leave",
                            subtitle: "Submit a new leave request.",
                            icon: Icons.add_moderator_rounded,
                            gradient: const [
                              Color(0xFF34D399),
                              Color(0xFF10B981)
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<LeaveBloc>(),
                                    child: const ApplyLeaveScreenDesktop(),
                                  ),
                                ),
                              );
                            },
                          ),

                          // LEAVE STATUS
                          _desktopActionCard(
                            width: isWide
                                ? (screenWidth - 128) / 3
                                : (screenWidth - 64) / 2,
                            title: "Leave Status",
                            subtitle: "View approved & rejected leaves.",
                            icon: Icons.history_edu_rounded,
                            gradient: const [
                              Color(0xFF60A5FA),
                              Color(0xFF2563EB)
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<LeaveBloc>(),
                                    child: const EmployeeLeaveStatusScreenDesktop(),
                                  ),
                                ),
                              );
                            },
                          ),

                          // HOLIDAY CALENDAR
                          _desktopActionCard(
                            width: isWide
                                ? (screenWidth - 128) / 3
                                : (screenWidth - 64) / 2,
                            title: "Holiday Calendar",
                            subtitle: "View public holidays.",
                            icon: Icons.calendar_today_rounded,
                            gradient: const [
                              Color(0xFFC084FC),
                              Color(0xFF9333EA)
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const PublicHolidayCalendarScreenDesktop(),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= APP BAR  =================
  Widget _buildDesktopAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _textMain),
        onPressed: () =>
            EmployeeDashboardNavigator.leaveBackToMain(context),
      ),
      title: const Text(
        "Leave Management Dashboard",
        style: TextStyle(
          color: _textMain,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _borderSlate, height: 1),
      ),
    );
  }

  // Placeholder - you mentioned this was unchanged
  Widget _buildSummaryHero() {
    return Container();
  }

  Widget _desktopActionCard({
    required double width,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width < 300 ? 300 : width,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderSlate),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gradient[0].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: gradient[1], size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}