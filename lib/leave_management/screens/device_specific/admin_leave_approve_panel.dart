import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: const Color(0xFFF8FAFC), // Modern light grey background
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        title: const Text(
          "Leave Management",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<LeaveDashboardBloc>().add(FetchAllLeaves()),
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
        ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Stats Row
          _buildSummaryCards(
            pending: state.pending,
            approved: state.approved,
            rejected: state.rejected,
          ),
          const SizedBox(height: 32),

          // 2. Table Container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Header
                _buildTableHeader(state),

                // Data Table
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: const Color(0xFFF1F5F9)),
                  child: DataTable(
                    headingRowHeight: 56,
                    dataRowMaxHeight: 80,
                    horizontalMargin: 24,
                    columns: const [
                      DataColumn(label: Text("EMPLOYEE", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("TYPE", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("DATES", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("STATUS", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("ACTION", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold))),
                    ],
                    rows: state.filteredLeaves.map((leave) => _buildDataRow(leave)).toList(),
                  ),
                ),

                if (state.filteredLeaves.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text("No leave requests found.", style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
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
              backgroundColor: Colors.indigo.shade50,
              child: Text(leave.employeeName?[0].toUpperCase() ?? "E",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
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
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF475569),
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
          const Text("Recent Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Row(
            children: ['All', 'Pending', 'Approved', 'Rejected'].map((f) {
              final value = f.toLowerCase();
              final selected = state.selectedFilter == value;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  selectedColor: Colors.indigo.shade600,
                  labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  backgroundColor: const Color(0xFFF1F5F9),
                  onSelected: (_) => context.read<LeaveDashboardBloc>().add(FilterLeaves(value)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards({required int pending, required int approved, required int rejected}) {
    return Row(
      children: [
        _statCard("Pending", pending.toString(), Colors.orange, Icons.hourglass_empty),
        const SizedBox(width: 24),
        _statCard("Approved", approved.toString(), Colors.green, Icons.check_circle_outline),
        const SizedBox(width: 24),
        _statCard("Rejected", rejected.toString(), Colors.red, Icons.cancel_outlined),
      ],
    );
  }

  Widget _statCard(String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            )
          ],
        ),
      ),
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