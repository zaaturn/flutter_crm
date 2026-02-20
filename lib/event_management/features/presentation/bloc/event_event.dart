import 'package:equatable/equatable.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/event_entity.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}


class FetchEventsRequested extends EventEvent {
  final DateTime start;
  final DateTime end;

  FetchEventsRequested({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

class NavigateCalendar extends EventEvent {
  final DateTime newDate;
  NavigateCalendar(this.newDate);

  @override
  List<Object?> get props => [newDate];
}


class FormatChanged extends EventEvent {
  final CalendarFormat format;
  FormatChanged(this.format);

  @override
  List<Object?> get props => [format];
}


class SlotTapped extends EventEvent {
  final DateTime dateTime;
  SlotTapped(this.dateTime);

  @override
  List<Object?> get props => [dateTime];
}

class EventTapped extends EventEvent {
  final EventEntity event;
  EventTapped(this.event);

  @override
  List<Object?> get props => [event];
}


class ModalDismissed extends EventEvent {
  ModalDismissed();
}

/// CRUD operations
class CreateEventRequested extends EventEvent {
  final EventEntity event;
  CreateEventRequested(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateEventRequested extends EventEvent {
  final EventEntity event;
  UpdateEventRequested(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteEventRequested extends EventEvent {
  final String id;
  DeleteEventRequested(this.id);

  @override
  List<Object?> get props => [id];
}