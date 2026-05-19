import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/mobile/notification_screen_mobile.dart';

import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/dashboard_stat_card_mobile.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/dashboard_ended_section_mobile.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/dashboard_today_grid_mobile.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/dashboard_tomorrow_section_mobile.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0);
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color textDark = Color(0xFF3E2723);
}

class EventDashboardMobileScreen extends StatefulWidget {
  const EventDashboardMobileScreen({super.key});

  @override
  State<EventDashboardMobileScreen> createState() => _EventDashboardMobileScreenState();
}

class _EventDashboardMobileScreenState extends State<EventDashboardMobileScreen> {
  static const double _headerBarHeight = 70;

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
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ZaaturnUI.background,
      ),
      child: Scaffold(
        backgroundColor: ZaaturnUI.background,
        body: Stack(
          children: [

            Positioned.fill(
              child: RefreshIndicator(
                edgeOffset: statusBarHeight + _headerBarHeight,
                color: ZaaturnUI.accentOrange,
                onRefresh: () async {
                  context.read<DashboardBloc>().add(DashboardRefreshRequested());
                  await Future.delayed(const Duration(milliseconds: 450));
                },
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (ctx, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: ZaaturnUI.accentOrange));
                    }
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [

                        SliverToBoxAdapter(
                          child: SizedBox(height: statusBarHeight + _headerBarHeight),
                        ),

                        SliverToBoxAdapter(child: DashboardStatCardsMobile(state: state)),
                        SliverToBoxAdapter(child: DashboardEndedSectionMobile(endedEvents: state.missedEvents)),
                        SliverToBoxAdapter(child: DashboardTodayGridMobile(events: state.todayEvents)),
                        SliverToBoxAdapter(child: DashboardTomorrowSectionMobile(upcoming: state.upcomingEvents)),

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
                    color: ZaaturnUI.background,
                  ),
                  Container(
                    height: _headerBarHeight,
                    color: ZaaturnUI.background,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: ZaaturnUI.textDark,
                            size: 20,
                          ),
                        ),
                        Text(
                          'Dashboard',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w900,
                            color: ZaaturnUI.textDark,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        _buildNotificationIcon(context),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Today is ${DateFormat('EEEE, MMM d').format(DateTime.now())}')),
                            );
                          },
                          icon: const Icon(Icons.help_outline_rounded, color: ZaaturnUI.textDark, size: 26),
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
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (_, state) => IconButton(
        onPressed: () => _openNotifications(context),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: ZaaturnUI.textDark,
              size: 26,
            ),
            if (state.unreadCount > 0)
              Positioned(
                right: 1,
                top: 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF595E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}