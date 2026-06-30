import 'package:equatable/equatable.dart';

import '../../domain/entities/calendar_grid_event.dart';
import '../../domain/entities/calendar_holiday.dart';

enum CalendarDataStatus { initial, loading, success, failure }

class CalendarDataState extends Equatable {
  final CalendarDataStatus status;
  final List<CalendarGridEvent> events;
  final List<CalendarGridEvent> taskDeadlines;
  final List<CalendarHoliday> holidays;
  final Map<String, List<String>> dotMap;
  final List<CalendarReminderItem> reminders;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final String? error;
  final String? moveError;
  final String eventTypeFilter;
  final Set<String> enabledEventTypes;
  final String priorityFilter;
  final String taskStatusFilter;
  final bool showCancelled;
  final bool showHolidays;
  final String searchQuery;

  const CalendarDataState({
    this.status = CalendarDataStatus.initial,
    this.events = const [],
    this.taskDeadlines = const [],
    this.holidays = const [],
    this.dotMap = const {},
    this.reminders = const [],
    this.rangeStart,
    this.rangeEnd,
    this.error,
    this.moveError,
    this.eventTypeFilter = 'all',
    this.enabledEventTypes = const {
      'meeting',
      'task',
      'reminder',
      'personal',
    },
    this.priorityFilter = 'all',
    this.taskStatusFilter = 'all',
    this.showCancelled = false,
    this.showHolidays = true,
    this.searchQuery = '',
  });

  List<CalendarHoliday> get visibleHolidays => holidays;

  Map<String, List<CalendarHoliday>> get holidaysByDate {
    final map = <String, List<CalendarHoliday>>{};
    for (final h in holidays) {
      map.putIfAbsent(h.date, () => []).add(h);
    }
    return map;
  }

  List<CalendarGridEvent> get visibleItems {
    Iterable<CalendarGridEvent> items = [...events, ...taskDeadlines];
    if (!showCancelled) {
      items = items.where((e) => !e.isCancelled);
    }
    items = items.where((e) {
      final t = e.isTaskDeadline ? 'task' : e.eventType.toLowerCase();
      return enabledEventTypes.contains(t);
    });
    if (eventTypeFilter != 'all') {
      items = items.where(
        (e) => e.eventType.toLowerCase() == eventTypeFilter.toLowerCase(),
      );
    }
    if (priorityFilter != 'all') {
      items = items.where(
        (e) => (e.priority ?? '').toLowerCase() == priorityFilter.toLowerCase(),
      );
    }
    if (taskStatusFilter != 'all') {
      items = items.where(
        (e) =>
            (e.taskStatus ?? '').toLowerCase() ==
            taskStatusFilter.toLowerCase(),
      );
    }
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) {
        return e.title.toLowerCase().contains(q) ||
            (e.location ?? '').toLowerCase().contains(q);
      });
    }
    return items.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  int get upcomingReminderCount =>
      reminders.where((r) => !r.isOverdue).length;

  CalendarDataState copyWith({
    CalendarDataStatus? status,
    List<CalendarGridEvent>? events,
    List<CalendarGridEvent>? taskDeadlines,
    List<CalendarHoliday>? holidays,
    Map<String, List<String>>? dotMap,
    List<CalendarReminderItem>? reminders,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    String? error,
    String? moveError,
    String? eventTypeFilter,
    Set<String>? enabledEventTypes,
    String? priorityFilter,
    String? taskStatusFilter,
    bool? showCancelled,
    bool? showHolidays,
    String? searchQuery,
    bool clearError = false,
    bool clearMoveError = false,
  }) {
    return CalendarDataState(
      status: status ?? this.status,
      events: events ?? this.events,
      taskDeadlines: taskDeadlines ?? this.taskDeadlines,
      holidays: holidays ?? this.holidays,
      dotMap: dotMap ?? this.dotMap,
      reminders: reminders ?? this.reminders,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      error: clearError ? null : (error ?? this.error),
      moveError: clearMoveError ? null : (moveError ?? this.moveError),
      eventTypeFilter: eventTypeFilter ?? this.eventTypeFilter,
      enabledEventTypes: enabledEventTypes ?? this.enabledEventTypes,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      taskStatusFilter: taskStatusFilter ?? this.taskStatusFilter,
      showCancelled: showCancelled ?? this.showCancelled,
      showHolidays: showHolidays ?? this.showHolidays,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        events,
        taskDeadlines,
        holidays,
        dotMap,
        reminders,
        rangeStart,
        rangeEnd,
        error,
        moveError,
        eventTypeFilter,
        enabledEventTypes,
        priorityFilter,
        taskStatusFilter,
        showCancelled,
        showHolidays,
        searchQuery,
      ];
}
