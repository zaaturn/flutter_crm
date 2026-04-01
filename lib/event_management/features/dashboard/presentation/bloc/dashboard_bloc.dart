// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD BLOC
// ─────────────────────────────────────────────────────────────────────────────
// lib/features/dashboard/presentation/bloc/dashboard_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

// State
class DashboardState extends Equatable {
  final List<Event> todayEvents;
  final List<Event> upcomingEvents;
  final List<Event> missedEvents;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.todayEvents = const [],
    this.upcomingEvents = const [],
    this.missedEvents = const [],
    this.isLoading = false,
    this.error,
  });

  factory DashboardState.initial() => const DashboardState(isLoading: true);

  DashboardState copyWith({
    List<Event>? todayEvents,
    List<Event>? upcomingEvents,
    List<Event>? missedEvents,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      todayEvents: todayEvents ?? this.todayEvents,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      missedEvents: missedEvents ?? this.missedEvents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [todayEvents, upcomingEvents, missedEvents, isLoading, error];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FetchDashboardUseCase fetchDashboard;

  DashboardBloc({required this.fetchDashboard})
      : super(DashboardState.initial()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
      DashboardEvent event,
      Emitter<DashboardState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final results = await Future.wait([
      fetchDashboard.getToday(),
      fetchDashboard.getUpcoming(),
      fetchDashboard.getMissed(),
    ]);

    final today    = results[0];
    final upcoming = results[1];
    final missed   = results[2];

    final todayResult    = today.fold((f) => <Event>[], (v) => v);
    final upcomingResult = upcoming.fold((f) => <Event>[], (v) => v);
    final missedResult   = missed.fold((f) => <Event>[], (v) => v);

    emit(state.copyWith(
      todayEvents: todayResult,
      upcomingEvents: upcomingResult,
      missedEvents: missedResult,
      isLoading: false,
    ));
  }
}