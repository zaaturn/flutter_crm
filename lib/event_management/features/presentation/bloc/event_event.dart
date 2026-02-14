import 'package:equatable/equatable.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/event_entity.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

/// Initial fetch of events
/// Removed 'const' because it takes dynamic DateTime values at runtime
class FetchEventsRequested extends EventEvent {
  final DateTime start;
  final DateTime end;

  FetchEventsRequested({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

/// Changes the focused date (for Today, Back, Forward buttons)
class NavigateCalendar extends EventEvent {
  final DateTime newDate;
  NavigateCalendar(this.newDate);

  @override
  List<Object?> get props => [newDate];
}

/// Changes the view format (Month, Week, Day)
class FormatChanged extends EventEvent {
  final CalendarFormat format;
  FormatChanged(this.format);

  @override
  List<Object?> get props => [format];
}

/// UI Interaction events
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

/// Removed 'const' to prevent "Const class cannot become non-const" error
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