import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../block/leave_bloc.dart';
import '../block/leave_event.dart';
import '../block/leave_state.dart';
import '../models/leave_request.dart';
import 'admin_leave_detail_screen.dart';

class AdminLeaveListScreen extends StatefulWidget {
  const AdminLeaveListScreen({super.key});

  @override
  State<AdminLeaveListScreen> createState() => _AdminLeaveListScreenState();
}

class _AdminLeaveListScreenState extends State<AdminLeaveListScreen> {
  String _selectedFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'

  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(LoadPendingLeaves());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[900],
        title: const Text(
          "Leave Management",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: Colors.grey[700]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<LeaveBloc, LeaveState>(
        listener: (context, state) {
          if (state is LeaveActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            );
            context.read<LeaveBloc>().add(LoadPendingLeaves());
          }
        },
        child: BlocBuilder<LeaveBloc, LeaveState>(
          builder: (context, state) {
            if (state is PendingLeavesLoading || state is LeaveInitial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade600,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading leave requests...',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is PendingLeavesLoaded) {
              final allLeaves = state.leaves;

              // Calculate counts for each status
              final pendingCount = allLeaves.where((l) =>
              l.status?.toLowerCase() == 'pending').length;
              final approvedCount = allLeaves.where((l) =>
              l.status?.toLowerCase() == 'approved').length;
              final rejectedCount = allLeaves.where((l) =>
              l.status?.toLowerCase() == 'rejected').length;

              // Filter leaves based on selected filter
              final filteredLeaves = _selectedFilter == 'all'
                  ? allLeaves
                  : allLeaves.where((l) =>
              l.status?.toLowerCase() == _selectedFilter).toList();

              return Column(
                children: [
                  // Status Filter Cards Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatusCard(
                                title: 'Pending',
                                count: pendingCount,
                                icon: Icons.pending_outlined,
                                gradient: [Colors.amber.shade400, Colors.amber.shade600],
                                isSelected: _selectedFilter == 'pending',
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = _selectedFilter == 'pending'
                                        ? 'all'
                                        : 'pending';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatusCard(
                                title: 'Approved',
                                count: approvedCount,
                                icon: Icons.check_circle_outline,
                                gradient: [Colors.green.shade400, Colors.green.shade600],
                                isSelected: _selectedFilter == 'approved',
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = _selectedFilter == 'approved'
                                        ? 'all'
                                        : 'approved';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatusCard(
                                title: 'Rejected',
                                count: rejectedCount,
                                icon: Icons.cancel_outlined,
                                gradient: [Colors.red.shade400, Colors.red.shade600],
                                isSelected: _selectedFilter == 'rejected',
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = _selectedFilter == 'rejected'
                                        ? 'all'
                                        : 'rejected';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Employee List Section
                  Expanded(
                    child: Padding(
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
                            // List Header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade100,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.people_outline,
                                      size: 20,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Employee Requests',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1a1a1a),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_selectedFilter != 'all')
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _getFilterGradient(_selectedFilter),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${filteredLeaves.length} ${_selectedFilter}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // List Content
                            Expanded(
                              child: filteredLeaves.isEmpty
                                  ? _buildEmptyState()
                                  : ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: filteredLeaves.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey.shade50,
                                  indent: 76,
                                ),
                                itemBuilder: (context, index) {
                                  final leave = filteredLeaves[index];
                                  return _EmployeeLeaveItem(
                                    leave: leave,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<LeaveBloc>(),
                                            child: AdminLeaveDetailScreen(
                                              leave: leave,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            }

            if (state is LeaveError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Oops! Something went wrong",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LeaveBloc>().add(LoadPendingLeaves());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'all'
                ? "No Leave Requests"
                : "No ${_selectedFilter.capitalize()} Requests",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? "There are no leave requests at the moment"
                : "No ${_selectedFilter} leave requests found",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getFilterGradient(String filter) {
    switch (filter) {
      case 'pending':
        return [Colors.amber.shade400, Colors.amber.shade600];
      case 'approved':
        return [Colors.green.shade400, Colors.green.shade600];
      case 'rejected':
        return [Colors.red.shade400, Colors.red.shade600];
      default:
        return [Colors.blue.shade400, Colors.blue.shade600];
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

/// -------------------------------
/// Status Card Widget (Filter Box)
/// -------------------------------
class _StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final List<Color> gradient;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.gradient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? gradient[0].withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? gradient[0] : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: gradient[0].withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? gradient[1] : const Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------------------
/// Employee Leave Item Widget
/// -------------------------------
class _EmployeeLeaveItem extends StatelessWidget {
  final LeaveRequest leave;
  final VoidCallback onTap;

  const _EmployeeLeaveItem({
    required this.leave,
    required this.onTap,
  });

  List<Color> _getStatusGradient(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return [Colors.green.shade400, Colors.green.shade600];
      case 'rejected':
        return [Colors.red.shade400, Colors.red.shade600];
      case 'pending':
        return [Colors.amber.shade400, Colors.amber.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusGradient = _getStatusGradient(leave.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Avatar with gradient
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (leave.employeeName?.isNotEmpty ?? false)
                        ? leave.employeeName![0].toUpperCase()
                        : 'E',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Employee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.employeeName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          leave.employeeId?.toString() ?? 'N/A',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badge with gradient
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: statusGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (leave.status ?? 'pending').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}