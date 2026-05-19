import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/models/leave_type.dart';
import 'package:my_app/leave_management/screens/device_specific/pending_edit_leave_loader.dart';

class PendingLeaveUpdateScreen extends StatefulWidget {
  const PendingLeaveUpdateScreen({super.key});

  @override
  State<PendingLeaveUpdateScreen> createState() =>
      _PendingLeaveUpdateScreenState();
}

class _PendingLeaveUpdateScreenState extends State<PendingLeaveUpdateScreen> {
  List<LeaveType> cachedLeaveTypes = [];

  static const _terracotta = Color(0xFFC05E41);
  static const _textMain = Color(0xFF3E2723);
  static const _textMuted = Color(0xFF8D6E63);
  static const _bg = Color(0xFFFAF3E0);
  static const _card = Color(0xFFEADBC8);

  static String _durationLabel(LeaveRequest leave) {
    final d = leave.duration.trim().toUpperCase();
    if (d == 'HALF') return 'Half day';
    if (d == 'FULL') return 'Full day';
    if (leave.totalDays > 0) return '${leave.totalDays} days';
    return leave.duration;
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
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bg,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My leaves',
          style: TextStyle(
            color: _textMain,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocListener<LeaveBloc, LeaveState>(
        listenWhen: (prev, current) => current is LeaveTypesLoaded,
        listener: (context, state) {
          if (state is LeaveTypesLoaded) {
            setState(() => cachedLeaveTypes = state.leaveTypes);
          }
        },
        child: BlocBuilder<LeaveBloc, LeaveState>(
          builder: (context, state) {
            if (state is LeaveTypesLoaded) {
              cachedLeaveTypes = state.leaveTypes;
            }

            if (state is MyLeavesLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: _terracotta));
            }

            if (state is MyLeavesLoaded) {
              final leaves = List<LeaveRequest>.from(state.leaves)
                ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

              if (leaves.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<LeaveBloc>().add(const LoadMyLeaves());
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: leaves.length,
                  itemBuilder: (context, index) =>
                      _buildLeaveCard(leaves[index]),
                ),
              );
            }

            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequest leave) {
    final startDate = DateFormat('MMM d').format(leave.startDate);
    final endDate = DateFormat('MMM d, y').format(leave.endDate);
    final pending = leave.status.toUpperCase() == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _terracotta.withOpacity(0.12)),
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
                  color: _terracotta.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (leave.leaveTypeName ?? 'General').toUpperCase(),
                  style: const TextStyle(
                    color: _terracotta,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                _durationLabel(leave),
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
              const Icon(Icons.calendar_today_rounded,
                  size: 16, color: _textMuted),
              const SizedBox(width: 8),
              Text(
                '$startDate — $endDate',
                style: const TextStyle(
                  color: _textMain,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Status: ${leave.statusLabel}',
            style: const TextStyle(
              color: _textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (pending)
                ElevatedButton(
                  onPressed: () => _openEditBottomSheet(leave),
                  style: ElevatedButton.styleFrom(
                        backgroundColor: _terracotta,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                )
              else
                Tooltip(
                  message: 'Only PENDING requests can be edited.',
                  child: OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textMuted,
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEditBottomSheet(LeaveRequest leave) {
    if (leave.id == null) return;

    final leaveBloc = context.read<LeaveBloc>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Update leave',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Resubmit updates your PENDING request.',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
              const SizedBox(height: 24),
              PendingEditLeaveLoader(
                initialLeave: leave,
                seedLeaveTypes: List<LeaveType>.from(cachedLeaveTypes),
                leaveBloc: leaveBloc,
                useRootNavigatorForPop: false,
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
              child: Icon(Icons.event_busy_rounded,
                  size: 64, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            const Text(
              'No leave requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nothing from my-leaves yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: _terracotta),
              child: const Text('Go back',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
