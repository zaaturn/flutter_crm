import 'package:equatable/equatable.dart';

export 'calender_event.dart';
import 'calender_event.dart';

class CalendarState extends Equatable {
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final CalendarView view;
  final bool showQuickCreate;
  final DateTime lastRefreshed;
  final Set<DateTime> highlightedDates;

  const CalendarState({
    required this.focusedMonth,
    this.selectedDate,
    this.view = CalendarView.month,
    this.showQuickCreate = false,
    required this.lastRefreshed,
    this.highlightedDates = const {},
  });

  factory CalendarState.initial() => CalendarState(
    focusedMonth: DateTime.now(),
    selectedDate: DateTime.now(),
    view: CalendarView.month,
    showQuickCreate: false,
    lastRefreshed: DateTime.now(),
  );

  CalendarState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDate,
    CalendarView? view,
    bool? showQuickCreate,
    DateTime? lastRefreshed,
    Set<DateTime>? highlightedDates,
  }) {
    return CalendarState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      view: view ?? this.view,
      showQuickCreate: showQuickCreate ?? this.showQuickCreate,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
      highlightedDates: highlightedDates ?? this.highlightedDates,
    );
  }

  @override
  List<Object?> get props => [
    focusedMonth,
    selectedDate,
    view,
    showQuickCreate,
    lastRefreshed,
    highlightedDates,
  ];
}