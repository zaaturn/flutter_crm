import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_ended_section.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_holiday_section.dart';
import '../widgets/dashboard_stat_cards.dart';
import '../widgets/dashboard_timetable_section.dart';
import '../widgets/dashboard_tomorrow_section.dart';
import '../../shared/dashboard_ui_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _contentMaxWidth = 1120.0;
  static const _wideBreakpoint = 720.0;
  static const _columnGap = 56.0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardUiTheme.pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: DashboardUiTheme.primary,
          backgroundColor: DashboardUiTheme.cardBackground,
          onRefresh: () async {
            context.read<DashboardBloc>().add(DashboardRefreshRequested());
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (ctx, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: DashboardUiTheme.primary,
                  ),
                );
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: DashboardHeader()),
                  SliverToBoxAdapter(child: DashboardStatCards(state: state)),
                  if (state.missedToday.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 28, 0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: _contentMaxWidth),
                            child: DashboardEndedSection(
                              endedEvents: state.missedToday,
                            ),
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 24, 28, 0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: _contentMaxWidth),
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final wide = c.maxWidth >= _wideBreakpoint;
                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          DashboardTimetableSection(
                                            events: state.todayEvents,
                                          ),
                                          DashboardTomorrowSection(
                                            upcoming: state.upcomingEvents,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: _columnGap),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: DashboardHolidaySection(
                                          holidays: state.monthHolidays,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DashboardTimetableSection(
                                    events: state.todayEvents,
                                  ),
                                  const SizedBox(height: 40),
                                  DashboardHolidaySection(
                                    holidays: state.monthHolidays,
                                  ),
                                  DashboardTomorrowSection(
                                    upcoming: state.upcomingEvents,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 48)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
