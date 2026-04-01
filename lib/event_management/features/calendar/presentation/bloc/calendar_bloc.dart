import 'package:flutter_bloc/flutter_bloc.dart';
import 'calender_event.dart';
import 'calender_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarState.initial()) {
    on<DateSelected>(_onDateSelected);
    on<ViewChanged>(_onViewChanged);
    on<MonthChanged>(_onMonthChanged);
    on<CalendarRefreshRequested>(_onRefresh);
    on<HighlightDateRequested>(_onHighlight);
  }

  void _onDateSelected(DateSelected event, Emitter<CalendarState> emit) {
    emit(state.copyWith(
      selectedDate: event.date,
      showQuickCreate: true,
    ));
  }

  void _onViewChanged(ViewChanged event, Emitter<CalendarState> emit) {
    emit(state.copyWith(view: event.view));
  }

  void _onMonthChanged(MonthChanged event, Emitter<CalendarState> emit) {
    emit(state.copyWith(focusedMonth: event.month));
  }

  void _onRefresh(CalendarRefreshRequested event, Emitter<CalendarState> emit) {
    emit(state.copyWith(lastRefreshed: DateTime.now()));
  }

  void _onHighlight(HighlightDateRequested event, Emitter<CalendarState> emit) {
    final updated = Set<DateTime>.from(state.highlightedDates)..add(event.date);
    emit(state.copyWith(highlightedDates: updated));
  }
}
