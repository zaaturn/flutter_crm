import 'package:equatable/equatable.dart';

// ── Calendar Views ─────────────────────────────────────────────────────────────
enum CalendarView { month, week, day, agenda }

// ── Events ────────────────────────────────────────────────────────────────────
abstract class CalendarEvent extends Equatable {
  const CalendarEvent();
  @override
  List<Object?> get props => [];
}

class DateSelected extends CalendarEvent {
  final DateTime date;
  const DateSelected(this.date);
  @override
  List<Object?> get props => [date];
}

class ViewChanged extends CalendarEvent {
  final CalendarView view;
  const ViewChanged(this.view);
  @override
  List<Object?> get props => [view];
}

class MonthChanged extends CalendarEvent {
  final DateTime month;
  const MonthChanged(this.month);
  @override
  List<Object?> get props => [month];
}

class CalendarRefreshRequested extends CalendarEvent {}

class HighlightDateRequested extends CalendarEvent {
  final DateTime date;
  const HighlightDateRequested(this.date);
  @override
  List<Object?> get props => [date];
}