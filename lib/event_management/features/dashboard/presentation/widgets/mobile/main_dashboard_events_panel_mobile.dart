import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';


import 'dashboard_today_grid_mobile.dart';
import 'dashboard_upcoming_section_mobile.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0); // Light Cream
  static const Color accentOrange = Color(0xFFF3924C);
}

class MainDashboardEventsPanelMobile extends StatefulWidget {
  const MainDashboardEventsPanelMobile({super.key});

  @override
  State<MainDashboardEventsPanelMobile> createState() => _MainDashboardEventsPanelMobileState();
}

class _MainDashboardEventsPanelMobileState extends State<MainDashboardEventsPanelMobile> {
  @override
  void initState() {
    super.initState();
    // Trigger the load exactly like your original desktop version
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardBloc>().add(DashboardLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listenWhen: (_, s) => s is EventDeleted,
      listener: (ctx, _) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Event deleted')),
        );
        try {
          // Auto-refresh the dashboard list if an event is deleted elsewhere
          ctx.read<DashboardBloc>().add(DashboardRefreshRequested());
        } catch (_) {}
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          // Show loader only on initial empty load
          final showLoader = state.isLoading &&
              state.todayEvents.isEmpty &&
              state.upcomingEvents.isEmpty;

          if (showLoader) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: ZaaturnUI.accentOrange,
                ),
              ),
            );
          }

          return Container(
            color: ZaaturnUI.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Use the Terracotta Today Grid
                DashboardTodayGridMobile(
                  events: state.todayEvents,
                ),

                const SizedBox(height: 10),

                // Use the Terracotta Upcoming Section
                DashboardUpcomingSectionMobile(
                  upcoming: state.upcomingEvents,
                ),

                // Bottom spacer for scrolling comfort
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}