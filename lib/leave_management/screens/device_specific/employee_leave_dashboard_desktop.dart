import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_top_nav.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_balance_response.dart';

import 'package:my_app/leave_management/screens/device_specific/employee_leave_v2_widgets.dart';
import 'package:my_app/leave_management/screens/device_specific/leave_balance_table_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/pending_leave_update_screen.dart';
import 'package:my_app/leave_management/screens/device_specific/apply_leave_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_status_screen_desktop.dart';

class EmployeeLeaveDashboardScreenDesktop extends StatefulWidget {
  const EmployeeLeaveDashboardScreenDesktop({super.key});

  @override
  State<EmployeeLeaveDashboardScreenDesktop> createState() =>
      _EmployeeLeaveDashboardScreenState();
}

class _EmployeeLeaveDashboardScreenState
    extends State<EmployeeLeaveDashboardScreenDesktop> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<LeaveBloc>();
      bloc.add(const LoadMyLeaves());
      bloc.add(const LoadLeaveBalances());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDashboardV2Theme.shell,
      body: Column(
        children: [
          const EmployeeDashboardV2TopNav(
            selectedIndex: 3,
            onProfileClick: _noop,
            showLogout: false,
          ),
          Expanded(
            child: BlocBuilder<LeaveBloc, LeaveState>(
              builder: (context, state) {
                final bloc = context.read<LeaveBloc>();
                final leaves = state is MyLeavesLoaded
                    ? state.leaves
                    : bloc.myLeavesSnapshot;

                final pending = leaves
                    .where((e) => e.status.toUpperCase() == 'PENDING')
                    .length;
                final approved = leaves
                    .where((e) => e.status.toUpperCase() == 'APPROVED')
                    .length;
                final rejected = leaves
                    .where((e) => e.status.toUpperCase() == 'REJECTED')
                    .length;

                final balanceResponse = state is LeaveBalancesLoaded
                    ? state.response
                    : bloc.balanceSnapshot;

                return RefreshIndicator(
                  color: EmployeeDashboardV2Theme.green,
                  onRefresh: () async {
                    bloc.add(const LoadMyLeaves());
                    bloc.add(const LoadLeaveBalances());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: EmployeeDashboardV2Theme.maxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leave Request',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: EmployeeDashboardV2Theme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Track balances, apply for leave, and view your requests.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: EmployeeDashboardV2Theme.textMuted,
                              ),
                            ),
                            if (balanceResponse != null &&
                                !balanceResponse.hasGender) ...[
                              const SizedBox(height: 14),
                              _genderBanner(),
                            ],
                            const SizedBox(height: 22),
                            _kpiGrid(
                              context: context,
                              pending: pending,
                              approved: approved,
                              rejected: rejected,
                              balanceResponse: balanceResponse,
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Quick actions',
                              style: EmployeeDashboardV2Theme.sectionTitle(),
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, c) {
                                final cols = c.maxWidth >= 900 ? 4 : 2;
                                return GridView.count(
                                  crossAxisCount: cols,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                  childAspectRatio: cols == 4 ? 1.15 : 1.05,
                                  children: [
                                    _actionCard(
                                      title: 'Pending Leaves',
                                      subtitle: '$pending awaiting approval',
                                      icon: Icons.hourglass_top_rounded,
                                      chipBg: EmployeeDashboardV2Theme.amberBg,
                                      chipFg: const Color(0xFFD97706),
                                      onTap: () => _open(
                                        context,
                                        const PendingLeaveUpdateScreen(),
                                      ),
                                    ),
                                    _actionCard(
                                      title: 'Apply Leave',
                                      subtitle: 'Submit a new request',
                                      icon: Icons.add_circle_outline_rounded,
                                      chipBg: EmployeeDashboardV2Theme.greenLight,
                                      chipFg: EmployeeDashboardV2Theme.greenMid,
                                      onTap: () => _open(
                                        context,
                                        const ApplyLeaveScreenDesktop(),
                                      ),
                                    ),
                                    _actionCard(
                                      title: 'Leave Status',
                                      subtitle: 'Approved & rejected',
                                      icon: Icons.history_edu_rounded,
                                      chipBg: const Color(0xFFEFF6FF),
                                      chipFg: const Color(0xFF2563EB),
                                      onTap: () => _open(
                                        context,
                                        const EmployeeLeaveStatusScreenDesktop(),
                                      ),
                                    ),
                                    _actionCard(
                                      title: 'Holiday Calendar',
                                      subtitle: 'Public holidays',
                                      icon: Icons.calendar_month_rounded,
                                      chipBg: const Color(0xFFF3E8FF),
                                      chipFg: const Color(0xFF9333EA),
                                      onTap: () =>
                                          EmployeeDashboardNavigator
                                              .holidayCalendar(context),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static void _noop() {}

  Widget _genderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LeaveV2Palette.brightSun.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: LeaveV2Palette.brightSun.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: LeaveV2Palette.blueWhale,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please set gender in profile for correct leave balance.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: LeaveV2Palette.blueWhale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<LeaveBloc>(),
          child: screen,
        ),
      ),
    );
  }

  void _openBalanceTable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<LeaveBloc>(),
          child: const LeaveBalanceTableScreenDesktop(),
        ),
      ),
    );
  }

  Widget _kpiGrid({
    required BuildContext context,
    required int pending,
    required int approved,
    required int rejected,
    required LeaveBalanceResponse? balanceResponse,
  }) {
    final yearTag = balanceResponse != null
        ? '${balanceResponse.year}'
        : '${DateTime.now().year}';

    return LeaveV2KpiGrid(
      filled: true,
      onTapAt: [
        null,
        null,
        null,
        () => _openBalanceTable(context),
      ],
      items: [
        LeaveV2KpiData(
          value: '$pending',
          label: 'Pending',
          tag: 'Requests',
          color: LeaveV2Palette.crusta,
          icon: Icons.pending_actions_rounded,
        ),
        LeaveV2KpiData(
          value: '$approved',
          label: 'Approved',
          tag: 'This year',
          color: LeaveV2Palette.olivine,
          icon: Icons.check_circle_outline_rounded,
        ),
        LeaveV2KpiData(
          value: '$rejected',
          label: 'Rejected',
          tag: 'This year',
          color: LeaveV2Palette.blueWhale,
          icon: Icons.cancel_outlined,
        ),
        LeaveV2KpiData(
          value: 'View',
          label: 'Leave Balance',
          tag: yearTag,
          color: LeaveV2Palette.patina,
          icon: Icons.table_chart_rounded,
        ),
      ],
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color chipBg,
    required Color chipFg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(EmployeeDashboardV2Theme.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: EmployeeDashboardV2Theme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: chipFg, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: EmployeeDashboardV2Theme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: EmployeeDashboardV2Theme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
