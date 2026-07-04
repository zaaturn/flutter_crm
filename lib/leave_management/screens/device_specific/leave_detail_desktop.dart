import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/leave_management/block/leave_dashboard_bloc.dart';
import 'package:my_app/leave_management/block/leave_dashboard_event.dart';
import 'package:my_app/leave_management/block/leave_dashboard_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';

class AdminLeaveApprovePanel extends StatelessWidget {
  final LeaveRequest leave;

  const AdminLeaveApprovePanel({super.key, required this.leave});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Body / Details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmployeeInfo(),
                  const SizedBox(height: 24),
                  _buildLeaveDetails(),
                  const SizedBox(height: 24),
                  const Text(
                    "Reason",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    leave.reason,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Only show Approve/Reject buttons if the status is PENDING
          if (leave.status.toUpperCase() == 'PENDING')
            _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Leave Request Detail",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AdminDashboardTheme.tealLight,
          child: Text(
            leave.employeeName?[0].toUpperCase() ?? "E",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AdminDashboardTheme.teal,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              leave.employeeName ?? "Unknown Employee",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Applied on: ${DateFormat('MMM dd, yyyy').format(leave.appliedAt)}",
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaveDetails() {
    // Format the date range: e.g., "Mar 27 - Mar 27, 2026"
    final String dateRange =
        "${DateFormat('MMM dd').format(leave.startDate)} - ${DateFormat('MMM dd, yyyy').format(leave.endDate)}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _detailItem("Type", leave.displayLeaveType),
              _detailItem("Duration", "${leave.totalDays} Days"),
              _detailItem("Status", leave.statusLabel),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFE2E8F0)),
          // Full Date Range Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                "Dates: $dateRange",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<LeaveDashboardBloc, LeaveDashboardState>(
      builder: (context, state) {
        final isProcessing = state.processingId == leave.id;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              // Reject Button
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isProcessing ? null : () {
                    context.read<LeaveDashboardBloc>().add(
                      RejectLeaveEvent(leaveId: leave.id!),
                    );
                  },
                  child: const Text(
                    "Reject Request",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Approve Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: isProcessing ? null : () {
                    context.read<LeaveDashboardBloc>().add(
                      ApproveLeaveEvent(leaveId: leave.id!),
                    );
                  },
                  child: isProcessing
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Approve Request",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}