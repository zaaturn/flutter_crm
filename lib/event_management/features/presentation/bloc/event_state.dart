import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/event_entity.dart';

@immutable
abstract class EventState extends Equatable {
  final List<EventEntity> events;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;

  const EventState({
    this.events = const [],
    required this.focusedDay,
    this.calendarFormat = CalendarFormat.week,
  });

  @override
  List<Object?> get props => [events, focusedDay, calendarFormat];
}

class EventInitial extends EventState {
  // REMOVED const: focusedDay: DateTime.now() is dynamic.
  EventInitial() : super(focusedDay: DateTime.now());
}

class EventLoading extends EventState {
  // REMOVED const from constructor
  EventLoading({
    List<EventEntity> events = const [],
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.week,
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);
}

class EventsLoaded extends EventState {
  // REMOVED const from constructor
  EventsLoaded({
    required List<EventEntity> events,
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.week,
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);
}

class EventError extends EventState {
  final String message;
  // REMOVED const from constructor
  EventError({
    required this.message,
    List<EventEntity> events = const [],
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.week,
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);

  @override
  List<Object?> get props => [message, ...super.props];
}

class CreateModalOpen extends EventState {
  final DateTime? selectedDateTime;
  // REMOVED const from constructor
  CreateModalOpen({
    this.selectedDateTime,
    required List<EventEntity> events,
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.week,
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);

  @override
  List<Object?> get props => [selectedDateTime, ...super.props];
}

class DetailModalOpen extends EventState {
  final EventEntity selectedEvent;
  // REMOVED const from constructor
  DetailModalOpen({
    required this.selectedEvent,
    required List<EventEntity> events,
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.week,
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);

  @override
  List<Object?> get props => [selectedEvent, ...super.props];
}

class EventActionSuccess extends EventState {
  final String message;
  // REMOVED const from constructor
  EventActionSuccess({
    required this.message,
    required List<EventEntity> events,
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.week,
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);

  @override
  List<Object?> get props => [message, ...super.props];
}