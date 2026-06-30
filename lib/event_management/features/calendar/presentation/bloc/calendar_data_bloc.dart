import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/calendar_remote_datasource.dart';
import '../../domain/entities/calendar_grid_event.dart';
import 'calendar_data_event.dart';
import 'calendar_data_state.dart';

class CalendarDataBloc extends Bloc<CalendarDataEvent, CalendarDataState> {
  CalendarDataBloc({required CalendarRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const CalendarDataState()) {
    on<CalendarLoadRange>(_onLoadRange);
    on<CalendarLoadDotMap>(_onLoadDotMap);
    on<CalendarLoadReminders>(_onLoadReminders);
    on<CalendarMoveEvent>(_onMoveEvent);
    on<CalendarFiltersChanged>(_onFiltersChanged);
    on<CalendarToggleEventType>(_onToggleEventType);
    on<CalendarRefreshCurrentRange>(_onRefreshCurrent);
  }

  final CalendarRemoteDataSource _dataSource;
  int _loadGeneration = 0;

  Future<void> _onLoadRange(
    CalendarLoadRange event,
    Emitter<CalendarDataState> emit,
  ) async {
    final generation = ++_loadGeneration;
    emit(state.copyWith(
      status: CalendarDataStatus.loading,
      rangeStart: event.start,
      rangeEnd: event.end,
      clearError: true,
    ));
    try {
      final data = await _dataSource.getCalendarRange(
        start: event.start,
        end: event.end,
        includeHolidays: true,
      );
      if (generation != _loadGeneration) return;
      emit(state.copyWith(
        status: CalendarDataStatus.success,
        events: data.events,
        taskDeadlines: data.taskDeadlines,
        holidays: data.holidays,
      ));
    } catch (e) {
      if (generation != _loadGeneration) return;
      emit(state.copyWith(
        status: CalendarDataStatus.failure,
        error: _messageFrom(e),
      ));
    }
  }

  Future<void> _onLoadDotMap(
    CalendarLoadDotMap event,
    Emitter<CalendarDataState> emit,
  ) async {
    final generation = _loadGeneration;
    try {
      final dots = await _dataSource.getDotMap(
        start: event.start,
        end: event.end,
      );
      if (generation != _loadGeneration) return;
      emit(state.copyWith(dotMap: dots));
    } catch (_) {}
  }

  Future<void> _onLoadReminders(
    CalendarLoadReminders event,
    Emitter<CalendarDataState> emit,
  ) async {
    try {
      final rows = await _dataSource.getMyReminders();
      emit(state.copyWith(reminders: rows));
    } catch (_) {}
  }

  Future<void> _onMoveEvent(
    CalendarMoveEvent event,
    Emitter<CalendarDataState> emit,
  ) async {
    if (event.eventId.startsWith('task_')) {
      emit(state.copyWith(moveError: 'Task deadlines cannot be moved here.'));
      return;
    }
    emit(state.copyWith(clearMoveError: true));
    try {
      final updated = await _dataSource.moveEvent(
        eventId: event.eventId,
        startTime: event.startTime,
        endTime: event.endTime,
      );
      final events = state.events.map((e) {
        return e.id == updated.id ? updated : e;
      }).toList();
      emit(state.copyWith(events: events));
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response?.statusCode == 409 && data is Map) {
        final titles = (data['conflicts'] as List? ?? [])
            .map((c) => c is Map ? c['title']?.toString() : null)
            .whereType<String>()
            .join(', ');
        emit(state.copyWith(
          moveError: titles.isEmpty
              ? 'Scheduling conflict detected.'
              : 'Conflict with: $titles',
        ));
      } else {
        emit(state.copyWith(moveError: _messageFrom(e)));
      }
    } catch (e) {
      emit(state.copyWith(moveError: _messageFrom(e)));
    }
  }

  void _onFiltersChanged(
    CalendarFiltersChanged event,
    Emitter<CalendarDataState> emit,
  ) {
    emit(state.copyWith(
      eventTypeFilter: event.eventType ?? state.eventTypeFilter,
      priorityFilter: event.priority ?? state.priorityFilter,
      taskStatusFilter: event.taskStatus ?? state.taskStatusFilter,
      showCancelled: event.showCancelled ?? state.showCancelled,
      searchQuery: event.searchQuery ?? state.searchQuery,
    ));
  }

  void _onToggleEventType(
    CalendarToggleEventType event,
    Emitter<CalendarDataState> emit,
  ) {
    final next = Set<String>.from(state.enabledEventTypes);
    if (next.contains(event.eventType)) {
      if (next.length > 1) next.remove(event.eventType);
    } else {
      next.add(event.eventType);
    }
    emit(state.copyWith(
      enabledEventTypes: next,
      eventTypeFilter: 'all',
    ));
  }

  Future<void> _onRefreshCurrent(
    CalendarRefreshCurrentRange event,
    Emitter<CalendarDataState> emit,
  ) async {
    final start = state.rangeStart;
    final end = state.rangeEnd;
    if (start == null || end == null) return;
    add(CalendarLoadRange(start: start, end: end));
    add(CalendarLoadDotMap(start: start, end: end));
    add(const CalendarLoadReminders());
  }

  String _messageFrom(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final detail = data['detail'] ?? data['message'];
        if (detail != null) return detail.toString();
      }
      return e.message ?? 'Request failed';
    }
    return e.toString();
  }
}
