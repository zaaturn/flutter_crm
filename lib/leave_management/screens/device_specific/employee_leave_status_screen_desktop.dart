import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_v2_widgets.dart';

class EmployeeLeaveStatusScreenDesktop extends StatefulWidget {
  const EmployeeLeaveStatusScreenDesktop({super.key});

  @override
  State<EmployeeLeaveStatusScreenDesktop> createState() =>
      _EmployeeLeaveStatusScreenState();
}

class _EmployeeLeaveStatusScreenState
    extends State<EmployeeLeaveStatusScreenDesktop> {
  String? highlightedLeaveId;

  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(const LoadMyLeaves());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['leave_id'] != null) {
        setState(() => highlightedLeaveId = args['leave_id'].toString());
      }
    });
  }

  String _formatOnlyDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDashboardV2Theme.shell,
      body: SafeArea(
        child: Column(
          children: [
            const LeaveV2TopBar(title: 'Leave Status'),
            Expanded(
              child: BlocBuilder<LeaveBloc, LeaveState>(
                builder: (context, state) {
                  if (state is MyLeavesLoading || state is LeaveInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: EmployeeDashboardV2Theme.green,
                      ),
                    );
                  }

                  if (state is MyLeavesLoaded) {
                    final approved = state.leaves
                        .where((e) => e.status == 'APPROVED')
                        .toList();
                    final rejected = state.leaves
                        .where((e) => e.status == 'REJECTED')
                        .toList();
                    final allLeaves = [...approved, ...rejected];

                    if (allLeaves.isEmpty) {
                      return _buildEmptyState();
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: EmployeeDashboardV2Theme.maxContentWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const LeaveV2PageTitle(
                                title: 'Leave History',
                                subtitle:
                                    'Approved and rejected requests from your account.',
                              ),
                              const SizedBox(height: 28),
                              _buildDesktopTable(allLeaves),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is LeaveError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(List<LeaveRequest> leaves) {
    return LeaveV2ContentCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(EmployeeDashboardV2Theme.cardRadius),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            EmployeeDashboardV2Theme.cardMuted,
          ),
          dataRowHeight: 70,
          horizontalMargin: 24,
          columns: [
            DataColumn(
              label: Text(
                'DATES',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'DURATION',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'STATUS',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'REMARKS',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
            ),
          ],
          rows: leaves.map((leave) {
            final isHighlighted = leave.id.toString() == highlightedLeaveId;
            final isApproved = leave.status == 'APPROVED';
            return DataRow(
              selected: isHighlighted,
              color: isHighlighted
                  ? WidgetStateProperty.all(
                      EmployeeDashboardV2Theme.greenLight,
                    )
                  : null,
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatOnlyDate(leave.startDate),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: EmployeeDashboardV2Theme.textDark,
                        ),
                      ),
                      Icon(
                        Icons.arrow_right_alt,
                        size: 16,
                        color: EmployeeDashboardV2Theme.textMuted,
                      ),
                      Text(
                        _formatOnlyDate(leave.endDate),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: EmployeeDashboardV2Theme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    '${leave.endDate.difference(leave.startDate).inDays + 1} Days',
                    style: GoogleFonts.plusJakartaSans(
                      color: EmployeeDashboardV2Theme.textBody,
                    ),
                  ),
                ),
                DataCell(_statusBadge(isApproved)),
                DataCell(
                  Text(
                    isApproved
                        ? 'Approved by Admin'
                        : 'Criteria not met',
                    style: GoogleFonts.plusJakartaSans(
                      color: EmployeeDashboardV2Theme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _statusBadge(bool isApproved) {
    final color = isApproved
        ? EmployeeDashboardV2Theme.greenMid
        : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        isApproved ? 'Approved' : 'Rejected',
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 80,
            color: EmployeeDashboardV2Theme.textMuted.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            'No processed applications',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: EmployeeDashboardV2Theme.textDark,
            ),
          ),
          Text(
            'Your leave history will appear here once reviewed.',
            style: GoogleFonts.plusJakartaSans(
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
