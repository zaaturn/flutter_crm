import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../block/leave_bloc.dart';
import '../block/leave_event.dart';
import '../block/leave_state.dart';
import '../models/leave_request.dart';

class EmployeeLeaveStatusScreen extends StatefulWidget {
  const EmployeeLeaveStatusScreen({super.key});

  @override
  State<EmployeeLeaveStatusScreen> createState() =>
      _EmployeeLeaveStatusScreenState();
}

class _EmployeeLeaveStatusScreenState extends State<EmployeeLeaveStatusScreen> {
  final ScrollController _scrollController = ScrollController();

  String? highlightedLeaveId;

  @override
  void initState() {
    super.initState();

    // Load leaves
    context.read<LeaveBloc>().add(const LoadMyLeaves());

    // Read notification arguments AFTER build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['leave_id'] != null) {
        highlightedLeaveId = args['leave_id'].toString();
        setState(() {});
      }
    });
  }

  String _formatOnlyDate(DateTime? date) {
    if (date == null) return "";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Leave Status",
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<LeaveBloc, LeaveState>(
        builder: (context, state) {
          if (state is MyLeavesLoading || state is LeaveInitial) {
            return const Center(child: CircularProgressIndicator());
          }


          if (state is MyLeavesLoaded) {
            final approved =
            state.leaves.where((e) => e.status == "APPROVED").toList();
            final rejected =
            state.leaves.where((e) => e.status == "REJECTED").toList();

            if (approved.isEmpty && rejected.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text(
                      "No approved or rejected leaves yet",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final allLeaves = [...approved, ...rejected];

            return ListView.builder(
              controller: _scrollController,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: allLeaves.length,
              itemBuilder: (context, index) {
                final leave = allLeaves[index];
                final isHighlighted =
                    leave.id.toString() == highlightedLeaveId;

                return _leaveTile(leave, isHighlighted);
              },
            );
          }

          if (state is LeaveError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _leaveTile(LeaveRequest leave, bool highlight) {
    final isApproved = leave.status == "APPROVED";
    final accentColor =
    isApproved ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: highlight ? accentColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? accentColor : Colors.grey.withOpacity(0.15),
          width: highlight ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accentColor, width: 6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _dateText(_formatOnlyDate(leave.startDate)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 16, color: Colors.black26),
                          ),
                          _dateText(_formatOnlyDate(leave.endDate)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isApproved
                            ? "Approved by Administration"
                            : "Request Declined",
                        style:
                        TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _statusBadge(isApproved),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateText(String date) {
    return Text(
      date,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _statusBadge(bool isApproved) {
    final color =
    isApproved ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        isApproved ? "Approved" : "Rejected",
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
