import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_bento_card.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_header.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_kpi_strip.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_time_tracker.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_top_nav.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_weekly_activity.dart';
import 'package:my_app/employee_dashboard/widget/shared_posts_section.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';

import 'package:my_app/screens/welcome_screen.dart';
import 'package:my_app/screens/device_specific/profile_screen_desktop.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';

class EmployeeDashboardDesktop extends StatefulWidget {
  const EmployeeDashboardDesktop({super.key});

  @override
  State<EmployeeDashboardDesktop> createState() =>
      _EmployeeDashboardDesktopState();
}

class _EmployeeDashboardDesktopState extends State<EmployeeDashboardDesktop> {
  Timer? _autoCheckoutTimer;
  StreamSubscription<RemoteMessage>? _fcmSubscription;
  late EmployeeBloc _employeeBloc;

  bool _showProfilePanel = false;
  final ScrollController _scrollController = ScrollController();

  void _toggleProfilePanel() {
    setState(() => _showProfilePanel = !_showProfilePanel);
  }

  @override
  void initState() {
    super.initState();
    _employeeBloc = context.read<EmployeeBloc>();
    _employeeBloc.add(LoadDashboard());
    _employeeBloc.add(StartTaskPolling());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<NotificationBloc>().add(NotificationLoadRequested());
        context.read<DashboardBloc>().add(DashboardLoadRequested());
      } catch (_) {}
    });

    _fcmSubscription = FirebaseMessaging.onMessage.listen((message) {
      if (message.data['type'] == 'TASK_ASSIGNED') {
        _employeeBloc.add(LoadDashboard());
      }
    });
  }

  @override
  void dispose() {
    _autoCheckoutTimer?.cancel();
    _fcmSubscription?.cancel();
    _scrollController.dispose();
    _employeeBloc.add(StopTaskPolling());
    super.dispose();
  }

  Future<void> _logout() async {
    await ApiClient().logout();
    await SecureStorageService().clearAll();
    _employeeBloc.add(StopTaskPolling());
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmployeeDashboardV2Theme.shell,
      body: Stack(
        children: [
          Column(
            children: [
              EmployeeDashboardV2TopNav(
                onProfileClick: _toggleProfilePanel,
                onLogout: _logout,
              ),
              Expanded(
                child: BlocBuilder<EmployeeBloc, EmployeeState>(
                  builder: (context, state) {
                    if (state.loading && state.attendance == null) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: EmployeeDashboardV2Theme.green,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: EmployeeDashboardV2Theme.green,
                      onRefresh: () async {
                        _employeeBloc.add(LoadDashboard());
                        try {
                          context.read<DashboardBloc>().add(DashboardRefreshRequested());
                          context.read<NotificationBloc>().add(NotificationLoadRequested());
                        } catch (_) {}
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: EmployeeDashboardV2Theme.maxContentWidth,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const EmployeeDashboardV2Header(),
                                const SizedBox(height: 22),
                                const EmployeeDashboardV2KpiStrip(),
                                const SizedBox(height: 22),
                                _bentoGrid(state),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_showProfilePanel)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleProfilePanel,
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.35)),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutQuart,
            right: _showProfilePanel ? 0 : -420,
            top: 0,
            bottom: 0,
            child: Container(
              width: 420,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 40,
                    offset: const Offset(-10, 0),
                  ),
                ],
              ),
              child: const ProfileScreenDesktop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bentoGrid(EmployeeState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;

        if (!wide) {
          return Column(
            children: [
              EmployeeDashboardV2BentoCard(child: const EmployeeDashboardV2TimeTracker()),
              const SizedBox(height: 20),
              SizedBox(
                height: 360,
                child: EmployeeDashboardV2BentoCard(
                  child: const EmployeeDashboardV2WeeklyActivity(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 360,
                child: _activeTasksCard(state),
              ),
              const SizedBox(height: 20),
              _scheduleCard(),
              const SizedBox(height: 20),
              _sharedItemsCard(),
              const SizedBox(height: 20),
              _upcomingEventsCard(),
            ],
          );
        }

        return Column(
          children: [
            EmployeeDashboardV2BentoCard(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
              child: const EmployeeDashboardV2TimeTracker(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 480,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: _activeTasksCard(state),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: EmployeeDashboardV2BentoCard(
                      child: const EmployeeDashboardV2WeeklyActivity(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _scheduleCard()),
                  const SizedBox(width: 20),
                  Expanded(child: _sharedItemsCard()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _upcomingEventsCard(),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String title, {String? subtitle, Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: EmployeeDashboardV2Theme.sectionTitle()),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle, style: EmployeeDashboardV2Theme.sectionSubtitle()),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _activeTasksCard(EmployeeState state) {
    return EmployeeDashboardV2BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Active tasks', style: EmployeeDashboardV2Theme.sectionTitle()),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: EmployeeDashboardV2Theme.greenLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${state.tasks.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: EmployeeDashboardV2Theme.greenMid,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => EmployeeDashboardNavigator.tasks(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: EmployeeDashboardV2Theme.greenMid,
                ),
                child: Text(
                  'View all',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _v2TaskPreviewList(state.tasks)),
        ],
      ),
    );
  }

  Widget _v2TaskPreviewList(List tasks) {
    // Keep the dashboard card neat like the HTML mock: show a few rows,
    // and let the user open the full "My Tasks" screen for everything.
    final shown = tasks.take(4).toList();

    if (shown.isEmpty) {
      return Center(
        child: Text(
          'No active tasks',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: EmployeeDashboardV2Theme.textMuted,
          ),
        ),
      );
    }

    // Prevent RenderFlex overflow on shorter screens by using a bounded list.
    return ListView.separated(
      primary: false,
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: shown.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => InkWell(
        onTap: () => EmployeeDashboardNavigator.tasks(context),
        borderRadius: BorderRadius.circular(16),
        child: _v2TaskRow(shown[i]),
      ),
    );
  }

  Widget _v2TaskRow(dynamic task) {
    final title = (task.title ?? '').toString().trim();
    final desc = (task.description ?? '').toString().trim();
    final priority = (task.priority ?? '').toString().toUpperCase();
    final due = (task.dueDate ?? '').toString().trim();

    final priorityMeta = switch (priority) {
      'HIGH' => (label: 'High', fg: const Color(0xFFDC2626), bg: const Color(0xFFFEF2F2)),
      'MEDIUM' => (label: 'Medium', fg: const Color(0xFFD97706), bg: const Color(0xFFFFFBEB)),
      _ => (label: 'Low', fg: const Color(0xFF2563EB), bg: const Color(0xFFEFF6FF)),
    };

    final initials = title.isEmpty
        ? 'TK'
        : title
            .split(RegExp(r'\s+'))
            .where((p) => p.trim().isNotEmpty)
            .take(2)
            .map((p) => p.trim()[0].toUpperCase())
            .join()
            .padRight(2, title[0].toUpperCase())
            .substring(0, 2);

    final dueLabel = () {
      if (due.isEmpty) return '—';
      final parsed = DateTime.tryParse(due);
      if (parsed == null) return '—';
      final d = parsed.toLocal();
      final now = DateTime.now();
      final todayOnly = DateTime(now.year, now.month, now.day);
      final dueOnly = DateTime(d.year, d.month, d.day);
      if (dueOnly == todayOnly) return 'Today';
      return DateFormat('MMM d').format(dueOnly);
    }();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmployeeDashboardV2Theme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: EmployeeDashboardV2Theme.greenMid.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Untitled task' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: EmployeeDashboardV2Theme.textDark,
                  ),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: EmployeeDashboardV2Theme.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityMeta.bg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        priorityMeta.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: priorityMeta.fg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F3),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: EmployeeDashboardV2Theme.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dueLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: EmployeeDashboardV2Theme.textBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: EmployeeDashboardV2Theme.greenMid,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              initials,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard() {
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());
    return EmployeeDashboardV2BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Today's Schedule", subtitle: today),
          const SizedBox(height: 8),
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              final events = state.todayEvents;
              if (events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  child: Center(
                    child: Text(
                      'No events today',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: EmployeeDashboardV2Theme.textMuted,
                      ),
                    ),
                  ),
                );
              }

              // Flat list (no inner cards) to match v2 bento.
              final shown = events.take(3).toList();
              return ListView.separated(
                primary: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shown.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 14,
                  thickness: 1,
                  color: EmployeeDashboardV2Theme.rowBorder,
                ),
                itemBuilder: (_, i) {
                  final e = shown[i];
                  final start = e.startTime.toLocal();
                  final time = e.isAllDay ? 'All day' : DateFormat.jm().format(start);
                  return Row(
                    children: [
                      SizedBox(
                        width: 66,
                        child: Text(
                          time,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: EmployeeDashboardV2Theme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: EmployeeDashboardV2Theme.textBody,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sharedItemsCard() {
    return InkWell(
      onTap: () => EmployeeDashboardNavigator.feed(context),
      borderRadius: BorderRadius.circular(EmployeeDashboardV2Theme.cardRadius),
      child: EmployeeDashboardV2BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Shared Items', style: EmployeeDashboardV2Theme.sectionTitle()),
                ),
                Text(
                  'View all',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: EmployeeDashboardV2Theme.greenMid,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const SharedPostsSection(
              hideHeader: true,
              scrollable: true,
              v2Flat: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _upcomingEventsCard() {
    return InkWell(
      onTap: () => EmployeeDashboardNavigator.events(context),
      borderRadius: BorderRadius.circular(EmployeeDashboardV2Theme.cardRadius),
      child: EmployeeDashboardV2BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Upcoming Events', subtitle: 'Coming up soon'),
          const SizedBox(height: 8),
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              // Flat list: no inner card boxes.
              final now = DateTime.now().toLocal();
              final todayStart = DateTime(now.year, now.month, now.day);
              final list = state.upcomingEvents.where((e) {
                final local = e.startTime.toLocal();
                final d = DateTime(local.year, local.month, local.day);
                return d.isAfter(todayStart);
              }).toList()
                ..sort((a, b) => a.startTime.compareTo(b.startTime));

              final shown = list.take(3).toList();
              if (shown.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  child: Center(
                    child: Text(
                      'No upcoming events',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: EmployeeDashboardV2Theme.textMuted,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                primary: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shown.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 14,
                  thickness: 1,
                  color: EmployeeDashboardV2Theme.rowBorder,
                ),
                itemBuilder: (_, i) {
                  final e = shown[i];
                  final start = e.startTime.toLocal();
                  final dateLabel = DateFormat('EEE, MMM d').format(start);
                  final time = e.isAllDay ? 'All day' : DateFormat.jm().format(start);
                  return Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: EmployeeDashboardV2Theme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 70,
                        child: Text(
                          time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: EmployeeDashboardV2Theme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: EmployeeDashboardV2Theme.textBody,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}
