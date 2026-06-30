import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/event_management/core/network/api_service.dart';
import 'package:my_app/event_management/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:my_app/event_management/features/calendar/domain/entities/calendar_grid_event.dart';
import 'package:my_app/event_management/features/calendar/domain/entities/calendar_holiday.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_data_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_data_event.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_data_state.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_event.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_state.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/calendar_agenda_view.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/calendar_toolbar.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/event_detail_popover.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/google_month_view.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/google_time_grid_view.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/mini_calendar_sidebar.dart';
import 'package:my_app/event_management/features/calendar/shared/calendar_date_utils.dart';
import 'package:my_app/event_management/features/calendar/shared/calendar_ui_theme.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_create_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_detail_screen_mobile.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/quick_add_sheet.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final CalendarRemoteDataSource _dataSource =
      CalendarRemoteDataSourceImpl(EventApiClient.create());
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final today = DateTime.now();
      final calBloc = context.read<CalendarBloc>();
      calBloc.add(MonthChanged(DateTime(today.year, today.month, 1)));
      calBloc.add(DateSelected(today));
      _loadForCurrentView();
      _startReminderPolling();
    });
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  void _startReminderPolling() {
    context.read<CalendarDataBloc>().add(const CalendarLoadReminders());
    _reminderTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted) return;
      context.read<CalendarDataBloc>().add(const CalendarLoadReminders());
    });
  }

  void _loadForCurrentView() {
    final cal = context.read<CalendarBloc>().state;
    final view = _viewKind(cal.view);
    final anchor = view == CalendarViewKind.month
        ? cal.focusedMonth
        : (cal.selectedDate ?? cal.focusedMonth);
    final start = CalendarDateUtils.rangeStartForView(view, anchor);
    final end = CalendarDateUtils.rangeEndForView(view, anchor);
    final dataBloc = context.read<CalendarDataBloc>();
    dataBloc.add(CalendarLoadRange(start: start, end: end));
    dataBloc.add(CalendarLoadDotMap(start: start, end: end));
    dataBloc.add(const CalendarLoadReminders());
  }

  CalendarViewKind _viewKind(CalendarView v) {
    switch (v) {
      case CalendarView.month:
        return CalendarViewKind.month;
      case CalendarView.week:
        return CalendarViewKind.week;
      case CalendarView.day:
        return CalendarViewKind.day;
      case CalendarView.agenda:
        return CalendarViewKind.agenda;
    }
  }

  void _shiftPeriod(int delta) {
    final cal = context.read<CalendarBloc>();
    final view = cal.state.view;
    final anchor = cal.state.selectedDate ?? cal.state.focusedMonth;
    DateTime next;
    switch (view) {
      case CalendarView.month:
        next = DateTime(anchor.year, anchor.month + delta, 1);
        cal.add(MonthChanged(next));
        break;
      case CalendarView.week:
        next = anchor.add(Duration(days: 7 * delta));
        cal.add(DateSelected(next));
        cal.add(MonthChanged(DateTime(next.year, next.month, 1)));
        break;
      case CalendarView.day:
        next = anchor.add(Duration(days: delta));
        cal.add(DateSelected(next));
        cal.add(MonthChanged(DateTime(next.year, next.month, 1)));
        break;
      case CalendarView.agenda:
        next = anchor.add(Duration(days: 7 * delta));
        cal.add(DateSelected(next));
        break;
    }
  }

  void _openEvent(CalendarGridEvent event) {
    if (event.isTaskApiId) {
      showCalendarEventPopover(
        context,
        event: event,
        dataSource: _dataSource,
        onChanged: () => context
            .read<CalendarDataBloc>()
            .add(const CalendarRefreshCurrentRange()),
        onEdit: () {},
      );
      return;
    }

    final mobile = AdaptiveLayout.useMobileUi(context);
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => mobile
            ? EventDetailMobileScreen(eventId: event.id)
            : EventDetailScreen(eventId: event.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = AdaptiveLayout.isWide(context);
    return Scaffold(
      backgroundColor: CalendarUiTheme.pageBackground,
      body: BlocListener<CalendarBloc, CalendarState>(
        listenWhen: (p, c) =>
            p.view != c.view ||
            p.lastRefreshed != c.lastRefreshed ||
            p.focusedMonth.year != c.focusedMonth.year ||
            p.focusedMonth.month != c.focusedMonth.month ||
            p.selectedDate != c.selectedDate,
        listener: (_, __) => _loadForCurrentView(),
        child: BlocConsumer<CalendarDataBloc, CalendarDataState>(
          listenWhen: (p, c) => c.moveError != null && c.moveError != p.moveError,
          listener: (context, state) {
            if (state.moveError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.moveError!)),
              );
            }
          },
          builder: (context, dataState) {
            return BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, calState) {
                final anchor = calState.selectedDate ?? calState.focusedMonth;
                final items = dataState.visibleItems;

                return Column(
                  children: [
                    CalendarToolbar(
                      calState: calState,
                      reminderCount: dataState.upcomingReminderCount,
                      onPrev: () => _shiftPeriod(-1),
                      onNext: () => _shiftPeriod(1),
                      onViewChanged: (v) {
                        context.read<CalendarBloc>().add(ViewChanged(v));
                      },
                      onSearch: () => _showSearch(items),
                      onRemindersTap: () => context
                          .read<CalendarDataBloc>()
                          .add(const CalendarLoadReminders()),
                      onNewEvent: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EventCreateScreen(),
                        ),
                      ),
                    ),
                    if (dataState.status == CalendarDataStatus.loading)
                      const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (wide)
                            SizedBox(
                              width: MiniCalendarSidebar.sidebarWidth,
                              child: MiniCalendarSidebar(
                                focusedMonth: calState.focusedMonth,
                                selectedDate: anchor,
                                enabledTypes: dataState.enabledEventTypes,
                                dotMap: dataState.dotMap,
                                holidaysByDate: dataState.holidaysByDate,
                                onToggleType: (type) => context
                                  .read<CalendarDataBloc>()
                                  .add(CalendarToggleEventType(type)),
                              onDateSelected: (d) {
                                  context.read<CalendarBloc>().add(DateSelected(d));
                                  context.read<CalendarBloc>().add(MonthChanged(
                                        DateTime(d.year, d.month, 1),
                                      ));
                                  if (calState.view == CalendarView.month) {
                                    context.read<CalendarBloc>().add(
                                          ViewChanged(CalendarView.day),
                                        );
                                  }
                                },
                                onMonthChanged: (m) {
                                  context.read<CalendarBloc>().add(MonthChanged(m));
                                },
                              ),
                            ),
                          Expanded(
                            child: ClipRect(
                              child: _mainView(calState, anchor, items, dataState),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _moveEvent(CalendarGridEvent e, DateTime ns, DateTime ne) {
    context.read<CalendarDataBloc>().add(
          CalendarMoveEvent(eventId: e.id, startTime: ns, endTime: ne),
        );
  }

  Widget _timeGrid({
    required List<DateTime> days,
    required List<CalendarGridEvent> items,
    required Map<String, List<CalendarHoliday>> holidaysByDate,
  }) {
    return GoogleTimeGridView(
      days: days,
      events: items,
      holidaysByDate: holidaysByDate,
      onSlotTap: (start, _) => QuickAddSheet.show(context, start),
      onEventTap: _openEvent,
      onEventMove: _moveEvent,
      onEventResize: _moveEvent,
    );
  }

  Widget _mainView(
    CalendarState calState,
    DateTime anchor,
    List<CalendarGridEvent> items,
    CalendarDataState dataState,
  ) {
    final holidaysByDate = dataState.holidaysByDate;
    final dotMap = dataState.dotMap;

    switch (calState.view) {
      case CalendarView.month:
        return GoogleMonthView(
          focusedMonth: calState.focusedMonth,
          selectedDate: anchor,
          events: items,
          dotMap: dotMap,
          holidaysByDate: holidaysByDate,
          onDayTap: (d) {
            context.read<CalendarBloc>().add(DateSelected(d));
            context.read<CalendarBloc>().add(ViewChanged(CalendarView.day));
          },
          onEventTap: _openEvent,
        );
      case CalendarView.week:
        final start = CalendarDateUtils.startOfWeek(anchor);
        final days = List.generate(7, (i) => start.add(Duration(days: i)));
        return _timeGrid(
          days: days,
          items: items,
          holidaysByDate: holidaysByDate,
        );
      case CalendarView.day:
        return _timeGrid(
          days: [CalendarDateUtils.dateOnly(anchor)],
          items: items,
          holidaysByDate: holidaysByDate,
        );
      case CalendarView.agenda:
        return CalendarAgendaView(
          events: items,
          holidaysByDate: holidaysByDate,
          onEventTap: _openEvent,
        );
    }
  }

  void _showSearch(List<CalendarGridEvent> items) {
    showSearch(
      context: context,
      delegate: _CalendarSearchDelegate(items: items, onPick: _openEvent),
    );
  }
}

class _CalendarSearchDelegate extends SearchDelegate<void> {
  _CalendarSearchDelegate({required this.items, required this.onPick});

  final List<CalendarGridEvent> items;
  final ValueChanged<CalendarGridEvent> onPick;

  @override
  String get searchFieldLabel => 'Search events…';

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(onPressed: () => query = '', icon: const Icon(Icons.close)),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _list(context);

  @override
  Widget buildSuggestions(BuildContext context) => _list(context);

  Widget _list(BuildContext context) {
    final q = query.trim().toLowerCase();
    final results = q.isEmpty
        ? items
        : items
            .where(
              (e) =>
                  e.title.toLowerCase().contains(q) ||
                  (e.location ?? '').toLowerCase().contains(q),
            )
            .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final e = results[i];
        return ListTile(
          title: Text(e.title),
          subtitle: Text(
            DateFormat('EEE, MMM d · h:mm a').format(e.startTime.toLocal()),
          ),
          onTap: () {
            close(context, null);
            onPick(e);
          },
        );
      },
    );
  }
}
