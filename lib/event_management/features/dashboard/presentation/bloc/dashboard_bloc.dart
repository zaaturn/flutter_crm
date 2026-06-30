// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD BLOC
// ─────────────────────────────────────────────────────────────────────────────
// lib/features/dashboard/presentation/bloc/dashboard_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/event_management/features/calendar/domain/entities/calendar_holiday.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import '../../domain/usecases/fetch_dashboard_usecase.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {}

class DashboardRefreshRequested extends DashboardEvent {}

/// Remove one event from cached dashboard lists (instant UI; use after delete tap).
class DashboardRemoveEventById extends DashboardEvent {
  final String eventId;
  const DashboardRemoveEventById(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

// State
class DashboardState extends Equatable {
  final List<Event> todayEvents;
  final List<Event> upcomingEvents;
  final List<Event> missedEvents;
  final List<CalendarHoliday> monthHolidays;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.todayEvents = const [],
    this.upcomingEvents = const [],
    this.missedEvents = const [],
    this.monthHolidays = const [],
    this.isLoading = false,
    this.error,
  });

  factory DashboardState.initial() => const DashboardState(isLoading: true);

  DashboardState copyWith({
    List<Event>? todayEvents,
    List<Event>? upcomingEvents,
    List<Event>? missedEvents,
    List<CalendarHoliday>? monthHolidays,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      todayEvents: todayEvents ?? this.todayEvents,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      missedEvents: missedEvents ?? this.missedEvents,
      monthHolidays: monthHolidays ?? this.monthHolidays,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Event> get missedToday {
    final now = DateTime.now();
    return missedEvents.where((e) {
      final s = e.startTime.toLocal();
      return s.year == now.year &&
          s.month == now.month &&
          s.day == now.day;
    }).toList();
  }

  @override
  List<Object?> get props => [
        todayEvents,
        upcomingEvents,
        missedEvents,
        monthHolidays,
        isLoading,
        error,
      ];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FetchDashboardUseCase fetchDashboard;

  DashboardBloc({required this.fetchDashboard})
      : super(DashboardState.initial()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardRefreshRequested>(_onLoad);
    on<DashboardRemoveEventById>(_onRemoveEventById);
  }

  void _onRemoveEventById(
    DashboardRemoveEventById event,
    Emitter<DashboardState> emit,
  ) {
    bool keep(Event e) => e.id != event.eventId;
    emit(state.copyWith(
      todayEvents: state.todayEvents.where(keep).toList(),
      upcomingEvents: state.upcomingEvents.where(keep).toList(),
      missedEvents: state.missedEvents.where(keep).toList(),
    ));
  }

  Future<void> _onLoad(
      DashboardEvent event,
      Emitter<DashboardState> emit,
      ) async {
    if (event is DashboardLoadRequested) {
      emit(state.copyWith(isLoading: true, error: null));
    } else {
      emit(state.copyWith(error: null));
    }

    try {
      final today = await fetchDashboard.getToday();
      final upcoming = await fetchDashboard.getUpcoming();
      final missed = await fetchDashboard.getMissed();
      final holidays = await fetchDashboard.getMonthHolidays(DateTime.now());

      final todayResult = today.fold((f) => <Event>[], (v) => v);
      final upcomingResult = upcoming.fold((f) => <Event>[], (v) => v);
      final missedResult = missed.fold((f) => <Event>[], (v) => v);
      final holidaysResult =
          holidays.fold((f) => <CalendarHoliday>[], (v) => v);

      emit(state.copyWith(
        todayEvents: todayResult,
        upcomingEvents: upcomingResult,
        missedEvents: missedResult,
        monthHolidays: holidaysResult,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}