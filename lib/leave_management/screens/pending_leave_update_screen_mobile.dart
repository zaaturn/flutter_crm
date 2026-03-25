import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/models/leave_type.dart';

// Ensure this path matches your project
import 'package:my_app/leave_management/screens/device_specific/apply_leave_form.dart';

class PendingLeaveUpdateScreen extends StatefulWidget {
  const PendingLeaveUpdateScreen({super.key});

  @override
  State<PendingLeaveUpdateScreen> createState() => _PendingLeaveUpdateScreenState();
}

class _PendingLeaveUpdateScreenState extends State<PendingLeaveUpdateScreen> {
  List<LeaveType> cachedLeaveTypes = [];

  // SaaS Theme Palette
  static const _indigo = Color(0xFF5452F6);
  static const _textMain = Color(0xFF1E293B);
  static const _textMuted = Color(0xFF64748B);
  static const _bg = Colors.white;

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
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pending Requests",
          style: TextStyle(
            color: _textMain,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<LeaveBloc, LeaveState>(
        builder: (context, state) {
          // Safely cache leave types when available
          if (state is LeaveTypesLoaded) {
            cachedLeaveTypes = state.leaveTypes;
          }

          if (state is MyLeavesLoading) {
            return const Center(child: CircularProgressIndicator(color: _indigo));
          }

          if (state is MyLeavesLoaded) {
            // Safe filtering to prevent Null Check error
            final pendingLeaves = state.leaves.where((l) => l.status == "PENDING").toList();

            if (pendingLeaves.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<LeaveBloc>().add(const LoadMyLeaves(status: 'PENDING'));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: pendingLeaves.length,
                itemBuilder: (context, index) => _buildLeaveCard(pendingLeaves[index]),
              ),
            );
          }

          // Fallback for initial or error states
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequest leave) {
    final startDate = DateFormat('MMM d').format(leave.startDate);
    final endDate = DateFormat('MMM d, y').format(leave.endDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (leave.leaveTypeName ?? "General").toUpperCase(),
                  style: const TextStyle(
                    color: _indigo,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                "${leave.duration} Days",
                style: const TextStyle(
                  color: _textMain,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: _textMuted),
              const SizedBox(width: 8),
              Text(
                "$startDate — $endDate",
                style: const TextStyle(
                  color: _textMain,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Awaiting Approval",
                    style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _openEditBottomSheet(leave),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _indigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  "Edit Request",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEditBottomSheet(LeaveRequest leave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              const Text(
                "Update Application",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _textMain),
              ),
              const SizedBox(height: 8),
              const Text(
                "Modify your details before manager review",
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
              const SizedBox(height: 24),
              ApplyLeaveForm(
                leaveTypes: cachedLeaveTypes,
                existingLeave: leave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Icon(Icons.auto_awesome_motion_rounded, size: 64, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Pending Leaves",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _textMain),
            ),
            const SizedBox(height: 8),
            const Text(
              "You don't have any leave requests awaiting approval at this time.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: _indigo),
              child: const Text("Go Back", style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}