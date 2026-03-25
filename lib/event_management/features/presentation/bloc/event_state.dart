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
    this.calendarFormat = CalendarFormat.month,
  });

  @override
  List<Object?> get props => [events, focusedDay, calendarFormat];
}

class EventInitial extends EventState {
  EventInitial() : super(
    focusedDay: DateTime.now(),
    calendarFormat: CalendarFormat.month,
  );
}

class EventLoading extends EventState {
  EventLoading({
    List<EventEntity> events = const [],
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.month, // Changed to month
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);
}

class EventsLoaded extends EventState {
  EventsLoaded({
    required List<EventEntity> events,
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.month, // Changed to month
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);
}

class EventError extends EventState {
  final String message;
  EventError({
    required this.message,
    List<EventEntity> events = const [],
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.month, // Changed to month
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);

  @override
  List<Object?> get props => [message, ...super.props];
}

class CreateModalOpen extends EventState {
  final DateTime? selectedDateTime;
  CreateModalOpen({
    this.selectedDateTime,
    required List<EventEntity> events,
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.month, // Changed to month
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);

  @override
  List<Object?> get props => [selectedDateTime, ...super.props];
}

class DetailModalOpen extends EventState {
  final EventEntity selectedEvent;
  DetailModalOpen({
    required this.selectedEvent,
    required List<EventEntity> events,
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.month, // Changed to month
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);

  @override
  List<Object?> get props => [selectedEvent, ...super.props];
}

class EventActionSuccess extends EventState {
  final String message;
  EventActionSuccess({
    required this.message,
    required List<EventEntity> events,
    required DateTime focusedDay,
    CalendarFormat calendarFormat = CalendarFormat.month, // Changed to month
  }) : super(events: events, focusedDay: focusedDay, calendarFormat: calendarFormat);

  @override
  List<Object?> get props => [message, ...super.props];
}