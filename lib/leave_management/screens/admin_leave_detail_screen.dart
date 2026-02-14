import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/leave_request.dart';
import '../block/leave_bloc.dart';
import '../block/leave_event.dart';

class AdminLeaveDetailScreen extends StatelessWidget {
  final LeaveRequest leave;

  const AdminLeaveDetailScreen({
    super.key,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[900],
        title: const Text(
          "Leave Request Details",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getStatusGradient(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Applied on ${leave.appliedAt.toString().split(' ')[0]}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Employee Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                (leave.employeeName?.isNotEmpty ?? false)
                                    ? leave.employeeName![0].toUpperCase()
                                    : "E",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leave.employeeName ?? "Unknown",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1a1a1a),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Employee",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Leave Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Leave Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _modernInfoRow(
                        Icons.category_outlined,
                        "Leave Type",
                        leave.displayLeaveType ?? "-",
                        Colors.purple,
                      ),
                      _modernInfoRow(
                        Icons.calendar_today_outlined,
                        "Start Date",
                        leave.startDate.toString().split(' ')[0],
                        Colors.green,
                      ),
                      _modernInfoRow(
                        Icons.event_outlined,
                        "End Date",
                        leave.endDate.toString().split(' ')[0],
                        Colors.orange,
                      ),
                      _modernInfoRow(
                        Icons.access_time_outlined,
                        "Total Days",
                        "${leave.totalDays} days",
                        Colors.blue,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reason Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              size: 20,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Reason",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1a1a1a),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          (leave.reason?.isNotEmpty ?? false)
                              ? leave.reason!
                              : "No reason provided",
                          style: TextStyle(
                            fontSize: 15,
                            color: (leave.reason?.isNotEmpty ?? false)
                                ? Colors.grey[800]
                                : Colors.grey[500],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      // Action Buttons
      bottomNavigationBar: leave.isPending
          ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.read<LeaveBloc>().add(
                      RejectLeaveEvent(
                        leaveId: leave.id!,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Reject",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.read<LeaveBloc>().add(
                      ApproveLeaveEvent(
                        leaveId: leave.id!,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Approve",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }

  // Modern Info Row with Icon
  Widget _modernInfoRow(
      IconData icon,
      String label,
      String value,
      Color color, {
        bool isLast = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1a1a1a),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get status gradient colors
  List<Color> _getStatusGradient() {
    if (leave.isPending) {
      return [Colors.amber.shade400, Colors.amber.shade600];
    } else if (leave.statusLabel.toLowerCase().contains('approve')) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (leave.statusLabel.toLowerCase().contains('reject')) {
      return [Colors.red.shade400, Colors.red.shade600];
    }
    return [Colors.grey.shade400, Colors.grey.shade600];
  }

  // Get status icon
  IconData _getStatusIcon() {
    if (leave.isPending) {
      return Icons.pending_outlined;
    } else if (leave.statusLabel.toLowerCase().contains('approve')) {
      return Icons.check_circle_outline;
    } else if (leave.statusLabel.toLowerCase().contains('reject')) {
      return Icons.cancel_outlined;
    }
    return Icons.info_outline;
  }
}