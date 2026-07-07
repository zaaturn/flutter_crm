import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_balance_response.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_v2_widgets.dart';

class LeaveBalanceTableScreenDesktop extends StatefulWidget {
  const LeaveBalanceTableScreenDesktop({super.key});

  @override
  State<LeaveBalanceTableScreenDesktop> createState() =>
      _LeaveBalanceTableScreenDesktopState();
}

class _LeaveBalanceTableScreenDesktopState
    extends State<LeaveBalanceTableScreenDesktop> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LeaveBloc>().add(const LoadLeaveBalances());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDashboardV2Theme.shell,
      body: SafeArea(
        child: Column(
          children: [
            const LeaveV2TopBar(title: 'Leave Balance'),
            Expanded(
              child: BlocBuilder<LeaveBloc, LeaveState>(
                builder: (context, state) {
                  final bloc = context.read<LeaveBloc>();

                  if (state is LeaveBalancesLoading &&
                      bloc.balanceSnapshot == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: EmployeeDashboardV2Theme.green,
                      ),
                    );
                  }

                  if (state is LeaveError && bloc.balanceSnapshot == null) {
                    return _errorState(state.message, () {
                      bloc.add(const LoadLeaveBalances());
                    });
                  }

                  final response = state is LeaveBalancesLoaded
                      ? state.response
                      : bloc.balanceSnapshot;

                  if (response == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: EmployeeDashboardV2Theme.green,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: EmployeeDashboardV2Theme.green,
                    onRefresh: () async {
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
                              LeaveV2PageTitle(
                                title: 'Leave balance ${response.year}',
                                subtitle:
                                    'Remaining and used days per leave type.',
                              ),
                              if (!response.hasGender) ...[
                                const SizedBox(height: 16),
                                _genderBanner(),
                              ],
                              const SizedBox(height: 24),
                              if (response.balances.isEmpty)
                                _emptyState()
                              else
                                _balanceTable(response.balances),
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
      ),
    );
  }

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

  Widget _balanceTable(List<LeaveBalanceItem> balances) {
    return LeaveV2ContentCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(EmployeeDashboardV2Theme.cardRadius),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: EmployeeDashboardV2Theme.cardMuted,
              child: Row(
                children: [
                  _headerCell('LEAVE TYPE', 3),
                  _headerCell('ALLOCATED', 1),
                  _headerCell('USED', 1),
                  _headerCell('REMAINING', 1),
                  _headerCell('USAGE', 2),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: balances.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: EmployeeDashboardV2Theme.rowBorder,
              ),
              itemBuilder: (_, i) => _balanceRow(balances[i]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: EmployeeDashboardV2Theme.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _balanceRow(LeaveBalanceItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: EmployeeDashboardV2Theme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.remainingLabel} / ${item.allocatedLabel} days left',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: EmployeeDashboardV2Theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.allocatedLabel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: EmployeeDashboardV2Theme.textBody,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.usedLabel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: EmployeeDashboardV2Theme.textBody,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.remainingLabel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: EmployeeDashboardV2Theme.greenMid,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: item.usageFraction,
                minHeight: 8,
                backgroundColor: EmployeeDashboardV2Theme.rowBorder,
                color: LeaveV2Palette.patina,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return LeaveV2ContentCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'No leave balance found for this year.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: EmployeeDashboardV2Theme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _errorState(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: EmployeeDashboardV2Theme.textBody,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
