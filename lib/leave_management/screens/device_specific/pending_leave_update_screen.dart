import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'apply_leave_form.dart';

class PendingLeaveUpdateScreen extends StatefulWidget {
  const PendingLeaveUpdateScreen({super.key});

  @override
  State<PendingLeaveUpdateScreen> createState() => _PendingLeaveUpdateScreenState();
}

class _PendingLeaveUpdateScreenState extends State<PendingLeaveUpdateScreen> {


  List<LeaveType> cachedLeaveTypes = [];

  @override
  void initState() {
    super.initState();
    final bloc = context.read<LeaveBloc>();
    bloc.add(const LoadMyLeaves(status: 'PENDING'));
    bloc.add(const LoadLeaveTypes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Manage Pending Requests",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF64748B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            Expanded(child: _buildModernTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Request Overview",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Text(
          "Review and modify your pending applications before HR processing.",
          style: TextStyle(color: Colors.blueGrey[400], fontSize: 15, letterSpacing: 0.3),
        ),
      ],
    );
  }

  Widget _buildModernTable() {
    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {

        // ✅ FIX: Cache leave types whenever loaded
        if (state is LeaveTypesLoaded) {
          cachedLeaveTypes = state.leaveTypes;
        }

        if (state is MyLeavesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2563EB),
              strokeWidth: 3,
            ),
          );
        }

        if (state is MyLeavesLoaded) {
          final leaves = state.leaves.where((l) => l.status == "PENDING").toList();
          if (leaves.isEmpty) return _buildEmptyState();

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      _headerCell("LEAVE TYPE", 2),
                      _headerCell("DURATION", 1),
                      _headerCell("TIMELINE", 2),
                      _headerCell("STATUS", 1),
                      _headerCell("ACTION", 1),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: leaves.length,
                    separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
            color: Color(0xFF2563EB),
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
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: Color(0xFF64748B),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildRow(LeaveRequest leave) {
    final range =
        "${DateFormat('MMM d').format(leave.startDate)} - ${DateFormat('MMM d, y').format(leave.endDate)}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              leave.leaveTypeName ?? "General Leave",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _badge(
                "${leave.duration} Days", Colors.blue[50]!, Colors.blue[700]!),
          ),
          Expanded(
            flex: 2,
            child: Text(
              range,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            flex: 1,
            child: _badge("Pending", Colors.amber[50]!, Colors.amber[700]!),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _openEditDialog(leave),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Edit Request",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF2563EB),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(
          text,
          style: TextStyle(
              color: textCol,
              fontWeight: FontWeight.bold,
              fontSize: 11),
        ),
      ),
    );
  }

  void _openEditDialog(LeaveRequest leave) {
    final leaveBloc = context.read<LeaveBloc>();

    showGeneralDialog(
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
                  borderRadius: BorderRadius.circular(24)),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 550,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogHeader(dialogCtx),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(32, 8, 32, 32),
                      child: BlocBuilder<LeaveBloc, LeaveState>(
                        bloc: leaveBloc,
                        builder: (context, state) {

                          // ✅ FIX: Always use cached types
                          final types = cachedLeaveTypes;

                          if (types.isNotEmpty) {
                            return ApplyLeaveForm(
                              leaveTypes: types,
                              existingLeave: leave,
                            );
                          }

                          return const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 40),
                              CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2563EB)),
                              SizedBox(height: 16),
                              Text("Synchronizing data...",
                                  style: TextStyle(
                                      color: Color(0xFF64748B))),
                              SizedBox(height: 40),
                            ],
                          );
                        },
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
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text("Edit Application",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A))),
              Text("Update your leave details below",
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B))),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.close_rounded,
                color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_rounded,
              size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text("Clear Inbox",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B))),
          const Text("No pending requests to manage.",
              style: TextStyle(
                  color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}