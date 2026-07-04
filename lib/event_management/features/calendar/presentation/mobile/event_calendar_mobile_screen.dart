import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:my_app/event_management/core/network/api_service.dart';
import 'package:my_app/event_management/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:my_app/event_management/features/calendar/domain/entities/calendar_grid_event.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_data_bloc.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_data_event.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_data_state.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_state.dart';
import 'package:my_app/event_management/features/calendar/presentation/mobile/mobile_calendar_theme.dart';
import 'package:my_app/event_management/features/calendar/presentation/mobile/widgets/mobile_calendar_header.dart';
import 'package:my_app/event_management/features/calendar/presentation/mobile/widgets/mobile_calendar_month_view.dart';
import 'package:my_app/event_management/features/calendar/presentation/mobile/widgets/mobile_calendar_schedule_view.dart';
import 'package:my_app/event_management/features/calendar/presentation/mobile/widgets/mobile_calendar_view_switcher.dart';
import 'package:my_app/event_management/features/calendar/presentation/mobile/widgets/mobile_calendar_week_day_views.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/event_detail_popover.dart';
import 'package:my_app/event_management/features/calendar/presentation/mobile/widgets/mobile_calendar_week_grid.dart';
import 'package:my_app/event_management/features/calendar/shared/calendar_date_utils.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_create_screen_mobile.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_detail_screen_mobile.dart';
import 'package:my_app/event_management/features/events/presentation/utils/event_snackbar.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/quick_add_sheet.dart';

/// Mobile calendar — Month / Week / Day / Schedule with full CRUD via existing screens.
class EventCalendarMobileScreen extends StatefulWidget {
  const EventCalendarMobileScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<EventCalendarMobileScreen> createState() =>
      _EventCalendarMobileScreenState();
}

class _EventCalendarMobileScreenState extends State<EventCalendarMobileScreen> {
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

  void _shiftPeriod(int delta) {
    final cal = context.read<CalendarBloc>();
    final view = cal.state.view;
    final anchor = cal.state.selectedDate ?? cal.state.focusedMonth;
    DateTime next;
    switch (view) {
      case CalendarView.month:
        final target = DateTime(anchor.year, anchor.month + delta, 1);
        final lastDay = DateTime(target.year, target.month + 1, 0).day;
        final day = anchor.day.clamp(1, lastDay);
        cal.add(MonthChanged(target));
        cal.add(DateSelected(DateTime(target.year, target.month, day)));
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

  void _goToday() {
    final today = DateTime.now();
    context.read<CalendarBloc>()
      ..add(MonthChanged(DateTime(today.year, today.month, 1)))
      ..add(DateSelected(today));
  }

  void _openCreate([DateTime? prefill]) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EventCreateScreenMobile(prefillDate: prefill),
      ),
    );
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

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailMobileScreen(eventId: event.id),
      ),
    );
  }

  void _moveEvent(CalendarGridEvent e, DateTime ns, DateTime ne) {
    context.read<CalendarDataBloc>().add(
          CalendarMoveEvent(eventId: e.id, startTime: ns, endTime: ne),
        );
  }

  String _subtitle(CalendarState cal, List<CalendarGridEvent> items) {
    final anchor = cal.selectedDate ?? cal.focusedMonth;
    switch (cal.view) {
      case CalendarView.month:
        final count = items.where((e) {
          final s = e.startTime.toLocal();
          return CalendarDateUtils.isSameDay(
            DateTime(s.year, s.month, s.day),
            anchor,
          );
        }).length;
        return count == 1 ? '1 event selected' : '$count events selected';
      case CalendarView.week:
        final start = anchor.subtract(Duration(days: anchor.weekday % 7));
        final end = start.add(const Duration(days: 6));
        final fmt = DateFormat('MMM d');
        return '${fmt.format(start)} – ${fmt.format(end)}';
      case CalendarView.day:
        return DateFormat('EEE, MMM d').format(anchor).toUpperCase();
      case CalendarView.agenda:
        return 'Agenda';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MobileCalendarTheme.background,
      body: SafeArea(
        child: BlocListener<CalendarBloc, CalendarState>(
          listenWhen: (p, c) =>
              p.view != c.view ||
              p.lastRefreshed != c.lastRefreshed ||
              p.focusedMonth.year != c.focusedMonth.year ||
              p.focusedMonth.month != c.focusedMonth.month ||
              p.selectedDate != c.selectedDate,
          listener: (_, __) => _loadForCurrentView(),
          child: BlocConsumer<CalendarDataBloc, CalendarDataState>(
            listenWhen: (p, c) =>
                c.moveError != null && c.moveError != p.moveError,
            listener: (context, state) {
              if (state.moveError != null) {
                EventSnackBars.show(state.moveError!);
              }
            },
            builder: (context, dataState) {
              return BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, calState) {
                  final anchor = calState.selectedDate ?? calState.focusedMonth;
                  final items = dataState.visibleItems;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MobileCalendarHeader(
                        focusedMonth: calState.focusedMonth,
                        subtitle: _subtitle(calState, items),
                        onToday: _goToday,
                        onPrevious: () => _shiftPeriod(-1),
                        onNext: () => _shiftPeriod(1),
                        onBack: widget.showBackButton
                            ? () => Navigator.of(context).pop()
                            : null,
                      ),
                      MobileCalendarViewSwitcher(
                        view: calState.view,
                        onChanged: (v) =>
                            context.read<CalendarBloc>().add(ViewChanged(v)),
                      ),
                      if (dataState.status == CalendarDataStatus.loading)
                        const LinearProgressIndicator(
                          minHeight: 2,
                          color: MobileCalendarTheme.terracotta,
                        ),
                      Expanded(
                        child: _body(calState, anchor, items, dataState),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: FloatingActionButton(
          onPressed: () => _openCreate(anchorOrNull(context)),
          backgroundColor: MobileCalendarTheme.terracotta,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  DateTime? anchorOrNull(BuildContext context) {
    return context.read<CalendarBloc>().state.selectedDate;
  }

  Widget _body(
    CalendarState calState,
    DateTime anchor,
    List<CalendarGridEvent> items,
    CalendarDataState dataState,
  ) {
    final holidaysByDate = dataState.holidaysByDate;
    final dotMap = dataState.dotMap;

    switch (calState.view) {
      case CalendarView.month:
        return MobileCalendarMonthView(
          focusedMonth: calState.focusedMonth,
          selectedDate: anchor,
          events: items,
          dotMap: dotMap,
          onDayTap: (d) => context.read<CalendarBloc>().add(DateSelected(d)),
          onEventTap: _openEvent,
        );
      case CalendarView.week:
        return MobileCalendarWeekView(
          anchor: anchor,
          selectedDate: anchor,
          events: items,
          holidaysByDate: holidaysByDate,
          onDayTap: (d) =>
              context.read<CalendarBloc>().add(DateSelected(d)),
          onSlotTap: (start, _) => QuickAddSheet.show(context, start),
          onEventTap: _openEvent,
          onEventMove: _moveEvent,
        );
      case CalendarView.day:
        return MobileCalendarWeekGrid(
          days: [CalendarDateUtils.dateOnly(anchor)],
          events: items,
          holidaysByDate: holidaysByDate,
          onSlotTap: (start, _) => QuickAddSheet.show(context, start),
          onEventTap: _openEvent,
          onEventMove: _moveEvent,
        );
      case CalendarView.agenda:
        return MobileCalendarScheduleView(
          events: items,
          holidaysByDate: holidaysByDate,
          onEventTap: _openEvent,
        );
    }
  }
}
