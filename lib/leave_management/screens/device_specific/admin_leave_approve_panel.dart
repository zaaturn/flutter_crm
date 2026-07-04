import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/employee_pagination_bar.dart';
import 'package:my_app/analytics/presentation/widgets/analytics_compact_stat_card.dart';
import 'package:my_app/analytics/theme/analytics_theme.dart';
import 'package:my_app/leave_management/block/leave_dashboard_bloc.dart';
import 'package:my_app/leave_management/block/leave_dashboard_event.dart';
import 'package:my_app/leave_management/block/leave_dashboard_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/screens/device_specific/leave_detail_desktop.dart';

class AdminLeaveDashboard extends StatefulWidget {
  const AdminLeaveDashboard({super.key});

  @override
  State<AdminLeaveDashboard> createState() => _AdminLeaveDashboardState();
}

class _AdminLeaveDashboardState extends State<AdminLeaveDashboard> {
  static const _pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    // Load data on start
    final bloc = context.read<LeaveDashboardBloc>();
    bloc.add(FetchAllLeaves());
    bloc.add(FetchDashboardCounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDashboardTheme.shellMint,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AdminDashboardTheme.shellMint,
        title: const Text(
          "Leave Management",
          style: TextStyle(
            color: AdminDashboardTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: BlocListener<LeaveDashboardBloc, LeaveDashboardState>(
        // Listen for Success Messages to show SnackBar
        listenWhen: (prev, curr) => curr.successMessage != null || curr.error != null,
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(state.successMessage!),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            // 🔥 Prevent SnackBar from reappearing on rebuild
            context.read<LeaveDashboardBloc>().add(ClearMessage());
          }

          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<LeaveDashboardBloc, LeaveDashboardState>(
          builder: (context, state) {
            if (state.isLoading && state.allLeaves.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return _buildMainDashboard(state);
          },
        ),
      ),
    );
  }

  Widget _buildMainDashboard(LeaveDashboardState state) {
    final all = state.filteredLeaves;
    final totalPages = all.isEmpty ? 1 : (all.length / _pageSize).ceil();
    final page = _currentPage.clamp(1, totalPages);
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize) > all.length ? all.length : start + _pageSize;
    final pageLeaves = all.isEmpty ? const <LeaveRequest>[] : all.sublist(start, end);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminDashboardTheme.shellPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Stats Row — colorful KPI tiles, matching the Analytics Overview tab
          _buildSummaryCards(
            pending: state.pending,
            approved: state.approved,
            rejected: state.rejected,
            total: state.allLeaves.length,
          ),
          const SizedBox(height: 32),

          // 2. Table Container — a separate white box below the stat cards
          AdminDashboardPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Header
                _buildTableHeader(state),

                // Data Table
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: AdminDashboardTheme.borderSoft),
                  child: DataTable(
                    headingRowHeight: 56,
                    dataRowMaxHeight: 80,
                    horizontalMargin: 24,
                    columns: const [
                      DataColumn(label: Text("EMPLOYEE", style: TextStyle(color: AdminDashboardTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("TYPE", style: TextStyle(color: AdminDashboardTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("DATES", style: TextStyle(color: AdminDashboardTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("STATUS", style: TextStyle(color: AdminDashboardTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("ACTION", style: TextStyle(color: AdminDashboardTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold))),
                    ],
                    rows: pageLeaves.map((leave) => _buildDataRow(leave)).toList(),
                  ),
                ),

                if (all.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.inbox_outlined, size: 48, color: AdminDashboardTheme.iconInactive),
                          const SizedBox(height: 16),
                          const Text("No leave requests found.", style: TextStyle(color: AdminDashboardTheme.textMuted)),
                        ],
                      ),
                    ),
                  )
                else
                  EmployeePaginationBar(
                    currentPage: page,
                    rowCount: pageLeaves.length,
                    totalCount: all.length,
                    pageSize: _pageSize,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(LeaveRequest leave) {
    return DataRow(cells: [
      DataCell(
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AdminDashboardTheme.tealLight,
              child: Text(leave.employeeName?[0].toUpperCase() ?? "E",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminDashboardTheme.teal)),
            ),
            const SizedBox(width: 12),
            Text(leave.employeeName ?? "N/A", style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      DataCell(Text(leave.displayLeaveType)),
      DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${DateFormat('MMM d').format(leave.startDate)} - ${DateFormat('MMM d').format(leave.endDate)}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("${leave.totalDays} Days", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
      DataCell(_statusBadge(leave)),
      DataCell(
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _showQuickView(leave),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminDashboardTheme.surfaceMuted,
                foregroundColor: AdminDashboardTheme.textMuted,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Review", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
              onPressed: () => _confirmDelete(leave.id!),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildTableHeader(LeaveDashboardState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Recent Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminDashboardTheme.textDark)),
          Row(
            children: ['All', 'Pending', 'Approved', 'Rejected'].map((f) {
              final value = f.toLowerCase();
              final selected = state.selectedFilter == value;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  selectedColor: AdminDashboardTheme.teal,
                  labelStyle: TextStyle(color: selected ? Colors.white : AdminDashboardTheme.textMuted, fontWeight: FontWeight.w600),
                  backgroundColor: AdminDashboardTheme.surfaceMuted,
                  onSelected: (_) {
                    setState(() => _currentPage = 1);
                    context.read<LeaveDashboardBloc>().add(FilterLeaves(value));
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards({
    required int pending,
    required int approved,
    required int rejected,
    required int total,
  }) {
    final tiles = <({String label, String value, Color color})>[
      (label: 'Total Requests', value: '$total', color: AnalyticsOverviewPalette.mutedTeal),
      (label: 'Pending', value: '$pending', color: AnalyticsOverviewPalette.mustard),
      (label: 'Approved', value: '$approved', color: AnalyticsOverviewPalette.sageGreen),
      (label: 'Rejected', value: '$rejected', color: AnalyticsOverviewPalette.berry),
    ];
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 96,
              child: AnalyticsCompactStatCard(
                label: tiles[i].label,
                value: tiles[i].value,
                background: tiles[i].color,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusBadge(LeaveRequest leave) {
    Color color = leave.isApproved ? Colors.green : (leave.isRejected ? Colors.red : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(
        leave.statusLabel,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showQuickView(LeaveRequest leave) {

    final dashboardBloc = context.read<LeaveDashboardBloc>();

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 450,
            child: BlocProvider.value(
              value: dashboardBloc,
              child: AdminLeaveApprovePanel(leave: leave),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int leaveId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Request"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
            onPressed: () {
              Navigator.pop(context);
              context.read<LeaveDashboardBloc>().add(DeleteLeaveEvent(leaveId));
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}