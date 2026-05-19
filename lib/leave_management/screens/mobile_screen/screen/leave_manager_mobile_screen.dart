import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_dashboard_model.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/screens/admin_leave_detail_screen.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';

import '../widget/leave_manager_bottom_nav.dart';
import '../widget/leave_manager_requests_section.dart';
import '../widget/leave_manager_summary_section.dart';
import '../widget/leave_manager_top_bar.dart';

class LeaveManagerMobileScreen extends StatefulWidget {
  const LeaveManagerMobileScreen({super.key});

  @override
  State<LeaveManagerMobileScreen> createState() => _LeaveManagerMobileScreenState();
}

class _LeaveManagerMobileScreenState extends State<LeaveManagerMobileScreen> {
  static const Color _bgScreen = Color(0xFFFAF3E0);
  static const Color _terracotta = Color(0xFFC05E41);

  LeaveManagerNavTab _tab = LeaveManagerNavTab.dashboard;
  LeaveDashboardModel? _dashboard;
  bool _dashboardLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(LoadPendingLeaves());
    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    setState(() => _dashboardLoading = true);
    try {
      final d = await context.read<LeaveApiService>().getDashboardCounts();
      if (mounted) setState(() => _dashboard = d);
    } catch (_) {
      if (mounted) setState(() => _dashboard = null);
    } finally {
      if (mounted) setState(() => _dashboardLoading = false);
    }
  }

  Future<void> _onPullToRefresh() async {
    context.read<LeaveBloc>().add(LoadPendingLeaves());
    await _refreshDashboard();
  }

  List<LeaveRequest> _sorted(List<LeaveRequest> raw) {
    return [...raw]..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
  }

  List<LeaveRequest> _filtered(List<LeaveRequest> all, LeaveManagerNavTab tab) {
    switch (tab) {
      case LeaveManagerNavTab.dashboard:
        return _sorted(all).take(10).toList();
      case LeaveManagerNavTab.pending:
        return _sorted(all.where((e) => e.isPending).toList());
      case LeaveManagerNavTab.approved:
        return _sorted(all.where((e) => e.isApproved).toList());
      case LeaveManagerNavTab.rejected:
        return _sorted(all.where((e) => e.isRejected).toList());
    }
  }

  /// Distinct employees with an approved leave that covers [today] (local date).
  int _onLeaveNow(List<LeaveRequest> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final onLeaveEmployees = <int>{};
    for (final l in all) {
      if (!l.isApproved) continue;
      final start = DateTime(l.startDate.year, l.startDate.month, l.startDate.day);
      final end = DateTime(l.endDate.year, l.endDate.month, l.endDate.day);
      if (!today.isBefore(start) && !today.isAfter(end)) {
        onLeaveEmployees.add(l.employeeId);
      }
    }
    return onLeaveEmployees.length;
  }

  int _pendingFromList(List<LeaveRequest> all) => all.where((e) => e.isPending).length;

  void _openLeave(LeaveRequest leave) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminLeaveDetailScreen(leave: leave),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeaveBloc, LeaveState>(
      listenWhen: (p, c) => c is LeaveActionSuccess,
      listener: (context, state) {
        if (state is LeaveActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          _refreshDashboard();
        }
      },
      child: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, adminState) {
          return Scaffold(
            backgroundColor: _bgScreen,
            bottomNavigationBar: LeaveManagerBottomNav(
              selected: _tab,
              onSelect: (t) => setState(() => _tab = t),
            ),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  LeaveManagerTopBar(
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: BlocBuilder<LeaveBloc, LeaveState>(
                      builder: (context, state) {
                        if (state is LeaveError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF1A1C1E)),
                              ),
                            ),
                          );
                        }

                        if (state is PendingLeavesLoading ||
                            state is LeaveInitial ||
                            state is LeaveSubmitting ||
                            state is LeaveActionSuccess ||
                            _dashboardLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: _terracotta,
                            ),
                          );
                        }

                        final allLeaves = state is PendingLeavesLoaded
                            ? state.leaves
                            : <LeaveRequest>[];

                        // Prefer list-derived pending so the stat matches what the admin sees
                        // (dashboard API can disagree with `/api/leaves/all/`).
                        final active = _pendingFromList(allLeaves);
                        final approvedStat = _dashboard?.approved ??
                            allLeaves.where((e) => e.isApproved).length;
                        final onLeave = _onLeaveNow(allLeaves);

                        final filtered = _filtered(allLeaves, _tab);
                        final listTitle = switch (_tab) {
                          LeaveManagerNavTab.dashboard => 'Recent Requests',
                          LeaveManagerNavTab.pending => 'Pending',
                          LeaveManagerNavTab.approved => 'Approved',
                          LeaveManagerNavTab.rejected => 'Rejected',
                        };

                        return RefreshIndicator(
                          color: _terracotta,
                          onRefresh: _onPullToRefresh,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.fromLTRB(
                              0,
                              20,
                              0,
                              24 + MediaQuery.paddingOf(context).bottom + 72,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_tab == LeaveManagerNavTab.dashboard) ...[
                                  LeaveManagerSummarySection(
                                    activeRequests: active,
                                    approvedCount: approvedStat,
                                    onLeaveCount: onLeave,
                                  ),
                                  const SizedBox(height: 28),
                                ],
                                LeaveManagerRequestsSection(
                                  title: listTitle,
                                  leaves: filtered,
                                  showViewAll: _tab == LeaveManagerNavTab.dashboard,
                                  onViewAll: () =>
                                      setState(() => _tab = LeaveManagerNavTab.pending),
                                  onOpenDetail: _openLeave,
                                  onOpenReview: _openLeave,
                                  emptyMessage: switch (_tab) {
                                    LeaveManagerNavTab.pending =>
                                    'No pending requests.',
                                    LeaveManagerNavTab.approved =>
                                    'No approved requests in this list.',
                                    LeaveManagerNavTab.rejected =>
                                    'No rejected requests in this list.',
                                    _ => 'No recent requests.',
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}