import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Proper Package Imports
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';

class EmployeeLeaveStatusScreenDesktop extends StatefulWidget {
  const EmployeeLeaveStatusScreenDesktop({super.key});

  @override
  State<EmployeeLeaveStatusScreenDesktop> createState() =>
      _EmployeeLeaveStatusScreenState();
}

class _EmployeeLeaveStatusScreenState extends State<EmployeeLeaveStatusScreenDesktop> {
  final ScrollController _scrollController = ScrollController();
  String? highlightedLeaveId;

  // SaaS Desktop Design Tokens
  static const Color _bgSlate = Color(0xFFF8FAFC);
  static const Color _borderSlate = Color(0xFFE2E8F0);
  static const Color _textMain = Color(0xFF0F172A);
  static const Color _indigo = Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(const LoadMyLeaves());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['leave_id'] != null) {
        setState(() => highlightedLeaveId = args['leave_id'].toString());
      }
    });
  }

  String _formatOnlyDate(DateTime? date) {
    if (date == null) return "--";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: _bgSlate,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text("Leave History", style: TextStyle(color: _textMain, fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _borderSlate, height: 1),
        ),
      ),
      body: BlocBuilder<LeaveBloc, LeaveState>(
        builder: (context, state) {
          if (state is MyLeavesLoading || state is LeaveInitial) {
            return const Center(child: CircularProgressIndicator());
          }


          if (state is MyLeavesLoaded) {
            final approved = state.leaves.where((e) => e.status == "APPROVED").toList();
            final rejected = state.leaves.where((e) => e.status == "REJECTED").toList();
            final allLeaves = [...approved, ...rejected];

            if (allLeaves.isEmpty) return _buildEmptyState();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 60 : 20, vertical: 40),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderStats(approved.length, rejected.length),
                      const SizedBox(height: 32),
                      _buildDesktopTable(allLeaves),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is LeaveError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
    );
  }

  // ================= DESKTOP UI COMPONENTS =================

  Widget _buildHeaderStats(int approved, int rejected) {
    return Row(
      children: [
        _statCard("Approved", approved.toString(), const Color(0xFF10B981)),
        const SizedBox(width: 20),
        _statCard("Rejected", rejected.toString(), const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _statCard(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderSlate),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textMain)),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<LeaveRequest> leaves) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderSlate),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
          dataRowHeight: 70,
          horizontalMargin: 24,
          columns: const [
            DataColumn(label: Text("DATES", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("DURATION", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("REMARKS", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: leaves.map((leave) {
            final isHighlighted = leave.id.toString() == highlightedLeaveId;
            return DataRow(
              selected: isHighlighted,
              color: isHighlighted ? MaterialStateProperty.all(_indigo.withOpacity(0.05)) : null,
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatOnlyDate(leave.startDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Icon(Icons.arrow_right_alt, size: 16, color: Colors.grey),
                      Text(_formatOnlyDate(leave.endDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                DataCell(Text("${leave.endDate.difference(leave.startDate).inDays + 1} Days")),
                DataCell(_statusBadge(leave.status == "APPROVED")),
                DataCell(
                  Text(
                    leave.status == "APPROVED" ? "Approved by Admin" : "Criteria not met",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
    final color = isApproved ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        isApproved ? "Approved" : "Rejected",
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded, size: 80, color: _borderSlate),
          const SizedBox(height: 16),
          const Text("No processed applications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textMain)),
          const Text("Your leave history will appear here once reviewed.", style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}