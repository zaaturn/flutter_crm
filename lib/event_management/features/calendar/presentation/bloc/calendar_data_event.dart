import 'package:equatable/equatable.dart';

import '../../domain/entities/calendar_grid_event.dart';

abstract class CalendarDataEvent extends Equatable {
  const CalendarDataEvent();
  @override
  List<Object?> get props => [];
}

class CalendarLoadRange extends CalendarDataEvent {
  final DateTime start;
  final DateTime end;
  const CalendarLoadRange({required this.start, required this.end});
  @override
  List<Object?> get props => [start, end];
}

class CalendarLoadDotMap extends CalendarDataEvent {
  final DateTime start;
  final DateTime end;
  const CalendarLoadDotMap({required this.start, required this.end});
  @override
  List<Object?> get props => [start, end];
}

class CalendarLoadReminders extends CalendarDataEvent {
  const CalendarLoadReminders();
}

class CalendarMoveEvent extends CalendarDataEvent {
  final String eventId;
  final DateTime startTime;
  final DateTime endTime;
  const CalendarMoveEvent({
    required this.eventId,
    required this.startTime,
    required this.endTime,
  });
  @override
  List<Object?> get props => [eventId, startTime, endTime];
}

class CalendarFiltersChanged extends CalendarDataEvent {
  final String? eventType;
  final String? priority;
  final String? taskStatus;
  final bool? showCancelled;
  final String? searchQuery;
  const CalendarFiltersChanged({
    this.eventType,
    this.priority,
    this.taskStatus,
    this.showCancelled,
    this.searchQuery,
  });
}

class CalendarToggleEventType extends CalendarDataEvent {
  final String eventType;
  const CalendarToggleEventType(this.eventType);
  @override
  List<Object?> get props => [eventType];
}

class CalendarRefreshCurrentRange extends CalendarDataEvent {
  const CalendarRefreshCurrentRange();
}
