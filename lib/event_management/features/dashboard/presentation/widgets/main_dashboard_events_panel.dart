import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';

import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/dashboard_today_grid.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/dashboard_upcoming_section.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/mobile/main_dashboard_events_panel_mobile.dart';

/// Today + upcoming lists using [DashboardBloc] — same data as Event Management dashboard.
class MainDashboardEventsPanel extends StatefulWidget {
  /// Tighter horizontal padding for narrow side panels (~360px).
  final bool compact;

  const MainDashboardEventsPanel({super.key, this.compact = false});

  @override
  State<MainDashboardEventsPanel> createState() => _MainDashboardEventsPanelState();
}

class _MainDashboardEventsPanelState extends State<MainDashboardEventsPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardBloc>().add(DashboardLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (AdaptiveLayout.useMobileUi(context)) {
      // Mobile terracotta/cream panel (keeps desktop panel unchanged).
      return const MainDashboardEventsPanelMobile();
    }

    final h = widget.compact ? 8.0 : 16.0;
    final todayPad = EdgeInsets.fromLTRB(h, 18, h, 0);
    final upcomingPad = EdgeInsets.fromLTRB(h, 22, h, 0);

    return BlocListener<EventBloc, EventState>(
      listenWhen: (_, s) => s is EventDeleted,
      listener: (ctx, _) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Event deleted')),
        );
        try {
          ctx.read<DashboardBloc>().add(DashboardRefreshRequested());
        } catch (_) {}
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final showLoader = state.isLoading &&
              state.todayEvents.isEmpty &&
              state.upcomingEvents.isEmpty;

          if (showLoader) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardTodayGrid(
                events: state.todayEvents,
                sectionPadding: todayPad,
              ),
              DashboardUpcomingSection(
                upcoming: state.upcomingEvents,
                sectionPadding: upcomingPad,
              ),
            ],
          );
        },
      ),
    );
  }
}
