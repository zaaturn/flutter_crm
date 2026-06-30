import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/dashboard_stat_card_mobile.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/dashboard_ended_section_mobile.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/dashboard_timetable_section_mobile.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/dashboard_holiday_section_mobile.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/dashboard_tomorrow_section_mobile.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/mobile/notification_screen_mobile.dart';

class EventDashboardMobileScreen extends StatefulWidget {
  const EventDashboardMobileScreen({super.key});

  @override
  State<EventDashboardMobileScreen> createState() =>
      _EventDashboardMobileScreenState();
}

class _EventDashboardMobileScreenState extends State<EventDashboardMobileScreen> {
  static const double _headerBarHeight = 68;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadRequested());
  }

  void _openNotifications(BuildContext context) {
    try {
      final bloc = context.read<NotificationBloc>();
      bloc.add(NotificationLoadRequested());
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const NotificationScreenMobile(),
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications unavailable')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: DashboardUiTheme.pageBackground,
      ),
      child: Scaffold(
        backgroundColor: DashboardUiTheme.pageBackground,
        body: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                edgeOffset: statusBarHeight + _headerBarHeight,
                color: DashboardUiTheme.primary,
                backgroundColor: DashboardUiTheme.cardBackground,
                onRefresh: () async {
                  context.read<DashboardBloc>().add(DashboardRefreshRequested());
                  await Future.delayed(const Duration(milliseconds: 450));
                },
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (ctx, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: DashboardUiTheme.primary,
                        ),
                      );
                    }
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(height: statusBarHeight + _headerBarHeight),
                        ),
                        SliverToBoxAdapter(
                          child: DashboardStatCardsMobile(state: state),
                        ),
                        SliverToBoxAdapter(
                          child: DashboardEndedSectionMobile(
                            endedEvents: state.missedToday,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                            child: DashboardTimetableSectionMobile(
                              events: state.todayEvents,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
                            child: DashboardHolidaySectionMobile(
                              holidays: state.monthHolidays,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: DashboardTomorrowSectionMobile(
                              upcoming: state.upcomingEvents,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    height: statusBarHeight,
                    color: DashboardUiTheme.pageBackground,
                  ),
                  Container(
                    height: _headerBarHeight,
                    color: DashboardUiTheme.pageBackground,
                    child: BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, notifState) => DashboardTopBar(
                        leading: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: DashboardUiTheme.textDark,
                            size: 20,
                          ),
                        ),
                        onNotifications: () => _openNotifications(context),
                        notificationBadge: notifState.unreadCount > 0,
                      ),
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
}
