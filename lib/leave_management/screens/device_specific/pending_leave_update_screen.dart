import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_v2_widgets.dart';

import 'pending_edit_leave_loader.dart';

class PendingLeaveUpdateScreen extends StatefulWidget {
  const PendingLeaveUpdateScreen({super.key});

  @override
  State<PendingLeaveUpdateScreen> createState() =>
      _PendingLeaveUpdateScreenState();
}

class _PendingLeaveUpdateScreenState extends State<PendingLeaveUpdateScreen> {
  List<LeaveType> cachedLeaveTypes = [];

  static String _durationLabel(LeaveRequest leave) {
    final d = leave.duration.trim().toUpperCase();
    if (d == 'HALF') return 'Half day';
    if (d == 'FULL') return 'Full day';
    if (leave.totalDays > 0) return '${leave.totalDays} days';
    return leave.duration;
  }

  static (Color bg, Color fg) _statusColors(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return (EmployeeDashboardV2Theme.greenLight, EmployeeDashboardV2Theme.greenMid);
      case 'REJECTED':
        return (const Color(0xFFFEE2E2), const Color(0xFFDC2626));
      case 'CANCELLED':
        return (EmployeeDashboardV2Theme.slateBg, EmployeeDashboardV2Theme.textMuted);
      default:
        return (EmployeeDashboardV2Theme.amberBg, const Color(0xFFD97706));
    }
  }

  @override
  void initState() {
    super.initState();
    final bloc = context.read<LeaveBloc>();
    bloc.add(const LoadMyLeaves());
    bloc.add(const LoadLeaveTypes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDashboardV2Theme.shell,
      body: SafeArea(
        child: Column(
          children: [
            const LeaveV2TopBar(title: 'Pending Leaves'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: EmployeeDashboardV2Theme.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LeaveV2PageTitle(
                          title: 'Your requests',
                          subtitle:
                              'Edit is only available while status is PENDING.',
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: BlocListener<LeaveBloc, LeaveState>(
                            listenWhen: (prev, current) =>
                                current is LeaveTypesLoaded,
                            listener: (context, state) {
                              if (state is LeaveTypesLoaded) {
                                setState(
                                    () => cachedLeaveTypes = state.leaveTypes);
                              }
                            },
                            child: _buildModernTable(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTable() {
    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {
        if (state is LeaveTypesLoaded) {
          cachedLeaveTypes = state.leaveTypes;
        }

        if (state is MyLeavesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: EmployeeDashboardV2Theme.green,
              strokeWidth: 3,
            ),
          );
        }

        if (state is MyLeavesLoaded) {
          final leaves = List<LeaveRequest>.from(state.leaves)
            ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

          if (leaves.isEmpty) return _buildEmptyState();

          return LeaveV2ContentCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: EmployeeDashboardV2Theme.cardMuted,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(EmployeeDashboardV2Theme.cardRadius),
                    ),
                  ),
                  child: Row(
                    children: [
                      _headerCell('LEAVE TYPE', 2),
                      _headerCell('DURATION', 1),
                      _headerCell('TIMELINE', 2),
                      _headerCell('STATUS', 1),
                      _headerCell('ACTION', 1),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: leaves.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: EmployeeDashboardV2Theme.rowBorder,
                    ),
                    itemBuilder: (context, index) =>
                        _buildRow(leaves[index]),
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(
            color: EmployeeDashboardV2Theme.green,
            strokeWidth: 3,
          ),
        );
      },
    );
  }

  Widget _headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: EmployeeDashboardV2Theme.textMuted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildRow(LeaveRequest leave) {
    final range =
        '${DateFormat('MMM d').format(leave.startDate)} – ${DateFormat('MMM d, y').format(leave.endDate)}';
    final pending = leave.status.toUpperCase() == 'PENDING';
    final colors = _statusColors(leave.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              leave.displayLeaveType,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: EmployeeDashboardV2Theme.textDark,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _badge(
              _durationLabel(leave),
              const Color(0xFFEFF6FF),
              const Color(0xFF2563EB),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              range,
              style: GoogleFonts.plusJakartaSans(
                color: EmployeeDashboardV2Theme.textBody,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _badge(leave.statusLabel, colors.$1, colors.$2),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: pending
                  ? TextButton(
                      onPressed: () => _openEditDialog(leave),
                      style: TextButton.styleFrom(
                        backgroundColor: EmployeeDashboardV2Theme.greenLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: EmployeeDashboardV2Theme.greenMid,
                        ),
                      ),
                    )
                  : Tooltip(
                      message: 'Only PENDING requests can be edited.',
                      child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.edit_outlined,
                          color: EmployeeDashboardV2Theme.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textCol) {
    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: textCol,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  void _openEditDialog(LeaveRequest leave) {
    if (leave.id == null) return;

    final leaveBloc = context.read<LeaveBloc>();

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (dialogCtx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim1),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 550,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogHeader(dialogCtx),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                      child: PendingEditLeaveLoader(
                        initialLeave: leave,
                        seedLeaveTypes: List<LeaveType>.from(cachedLeaveTypes),
                        leaveBloc: leaveBloc,
                        useRootNavigatorForPop: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit leave',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: EmployeeDashboardV2Theme.textDark,
                ),
              ),
              Text(
                'Resubmit updates your PENDING request.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(
              Icons.close_rounded,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 80,
            color: EmployeeDashboardV2Theme.textMuted.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            'No leave requests',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: EmployeeDashboardV2Theme.textDark,
            ),
          ),
          Text(
            'Your leave requests will appear here.',
            style: GoogleFonts.plusJakartaSans(
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
