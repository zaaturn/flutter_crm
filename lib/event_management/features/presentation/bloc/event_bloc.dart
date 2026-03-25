import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/event_entity.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/update_event.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEvents _getEvents;
  final CreateEvent _createEvent;
  final UpdateEvent _updateEvent;
  final DeleteEvent _deleteEvent;

  EventBloc({
    required GetEvents getEvents,
    required CreateEvent createEvent,
    required UpdateEvent updateEvent,
    required DeleteEvent deleteEvent,
  })  : _getEvents = getEvents,
        _createEvent = createEvent,
        _updateEvent = updateEvent,
        _deleteEvent = deleteEvent,
        super(EventInitial()) {

    on<FetchEventsRequested>(_onFetch);
    on<CreateEventRequested>(_onCreate);
    on<UpdateEventRequested>(_onUpdate);
    on<DeleteEventRequested>(_onDelete);
    on<SlotTapped>(_onSlotTapped);
    on<EventTapped>(_onEventTapped);
    on<ModalDismissed>(_onModalDismissed);
    on<NavigateCalendar>(_onNavigateCalendar);
    on<FormatChanged>(_onFormatChanged);
    on<ChangeCalendarFormat>(_onFormatChanged);
  }

  Future<void> _onFetch(FetchEventsRequested event, Emitter<EventState> emit) async {
    emit(EventLoading(events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));

    final result = await _getEvents(GetEventsParams(
      start: DateFormat('yyyy-MM-dd').format(event.start),
      end: DateFormat('yyyy-MM-dd').format(event.end),
    ));

    if (emit.isDone) return;

    // ✅ FIX: Handling result inside the async flow properly
    result.fold(
          (failure) => emit(EventError(message: failure.message, events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat)),
          (events) => emit(EventsLoaded(events: events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat)),
    );
  }

  Future<void> _onCreate(CreateEventRequested event, Emitter<EventState> emit) async {
    emit(EventLoading(events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));
    final result = await _createEvent(event.event);

    if (emit.isDone) return;

    // ✅ FIX: Use if/else or ensure fold is synchronous with emit
    result.fold(
          (failure) => emit(EventError(message: failure.message, events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat)),
          (created) {
        final updated = [...state.events, created];
        emit(EventActionSuccess(message: 'Event created', events: updated, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));

        // Double check emitter before second call
        if (!emit.isDone) {
          emit(EventsLoaded(events: updated, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));
        }
      },
    );
  }

  Future<void> _onUpdate(UpdateEventRequested event, Emitter<EventState> emit) async {
    emit(EventLoading(events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));
    final result = await _updateEvent(event.event);

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(EventError(message: failure.message, events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat)),
          (updated) {
        final list = state.events.map((e) => e.id == updated.id ? updated : e).toList();
        emit(EventActionSuccess(message: 'Event updated', events: list, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));

        if (!emit.isDone) {
          emit(EventsLoaded(events: list, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));
        }
      },
    );
  }

  Future<void> _onDelete(DeleteEventRequested event, Emitter<EventState> emit) async {
    emit(EventLoading(events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));
    final intId = int.tryParse(event.id.toString()) ?? 0;
    final result = await _deleteEvent(intId);

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(EventError(message: failure.message, events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat)),
          (_) {
        final list = state.events.where((e) => e.id.toString() != event.id.toString()).toList();
        emit(EventActionSuccess(message: 'Event deleted', events: list, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));

        if (!emit.isDone) {
          emit(EventsLoaded(events: list, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));
        }
      },
    );
  }

  // --- UI STATE HANDLERS (Non-Async) ---
  void _onNavigateCalendar(NavigateCalendar event, Emitter<EventState> emit) {
    emit(EventsLoaded(events: state.events, focusedDay: event.newDate, calendarFormat: state.calendarFormat));
  }

  void _onFormatChanged(dynamic event, Emitter<EventState> emit) {
    emit(EventsLoaded(events: state.events, focusedDay: state.focusedDay, calendarFormat: event.format));
  }

  void _onSlotTapped(SlotTapped event, Emitter<EventState> emit) {
    emit(CreateModalOpen(selectedDateTime: event.dateTime, events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));
  }

  void _onEventTapped(EventTapped event, Emitter<EventState> emit) {
    emit(DetailModalOpen(selectedEvent: event.event, events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));
  }

  void _onModalDismissed(ModalDismissed event, Emitter<EventState> emit) {
    emit(EventsLoaded(events: state.events, focusedDay: state.focusedDay, calendarFormat: state.calendarFormat));
  }
}