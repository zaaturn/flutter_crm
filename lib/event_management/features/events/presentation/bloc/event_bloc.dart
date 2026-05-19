import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/event_management/core/entities/user.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/create_event_usecase.dart';
import 'event_event.dart';
import 'event_state.dart';

export 'event_event.dart';
export 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final CreateEventUseCase createEvent;
  final UpdateEventUseCase updateEvent;
  final DeleteEventUseCase deleteEvent;
  final FetchEventsUseCase fetchEvents;
  final GetEventByIdUseCase getEventById;
  final DetectConflictUseCase detectConflict;
  final SearchEventsUseCase searchEvents;
  final AcceptEventInviteUseCase acceptEventInvite;
  final DeclineEventInviteUseCase declineEventInvite;

  List<Event> _cachedEvents = [];

  EventBloc({
    required this.createEvent,
    required this.updateEvent,
    required this.deleteEvent,
    required this.fetchEvents,
    required this.getEventById,
    required this.detectConflict,
    required this.searchEvents,
    required this.acceptEventInvite,
    required this.declineEventInvite,
  }) : super(EventInitial()) {
    on<ExternalEventUpserted>(_onExternalUpsert);
    on<ExternalEventDeleted>(_onExternalDelete);
    on<FetchEventsRequested>(_onFetch);
    on<LoadEventByIdRequested>(_onLoadById);
    on<CreateEventRequested>(_onCreate);
    on<UpdateEventRequested>(_onUpdate);
    on<DeleteEventRequested>(_onDelete);
    on<QuickCreateEvent>(_onQuickCreate);
    on<ConflictConfirmed>(_onConflictConfirmed);
    on<SearchRequested>(_onSearch);
    on<AcceptEventInviteRequested>(_onAcceptInvite);
    on<DeclineEventInviteRequested>(_onDeclineInvite);
  }

  void _onExternalUpsert(
    ExternalEventUpserted event,
    Emitter<EventState> emit,
  ) {
    final e = event.event;
    final idx = _cachedEvents.indexWhere((x) => x.id == e.id);
    if (idx >= 0) {
      _cachedEvents = [
        ..._cachedEvents.sublist(0, idx),
        e,
        ..._cachedEvents.sublist(idx + 1),
      ];
    } else {
      _cachedEvents = [..._cachedEvents, e];
    }
    emit(EventsLoaded(List<Event>.from(_cachedEvents)));
  }

  void _onExternalDelete(
    ExternalEventDeleted event,
    Emitter<EventState> emit,
  ) {
    final before = _cachedEvents.length;
    _cachedEvents = _cachedEvents.where((e) => e.id != event.eventId).toList();
    if (_cachedEvents.length != before) {
      emit(EventDeleted(event.eventId));
      emit(EventsLoaded(List<Event>.from(_cachedEvents)));
    }
  }

  Future<void> _onFetch(
    FetchEventsRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final result = await fetchEvents(FetchEventsParams(
      startDate: event.startDate,
      endDate: event.endDate,
    ));
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (events) {
        final ids = events.map((e) => e.id).toSet();
        final extras =
            _cachedEvents.where((e) => !ids.contains(e.id)).toList();
        _cachedEvents = [...events, ...extras];
        emit(EventsLoaded(_cachedEvents));
      },
    );
  }

  Future<void> _onLoadById(
    LoadEventByIdRequested event,
    Emitter<EventState> emit,
  ) async {
    final cachedIdx = _cachedEvents.indexWhere((e) => e.id == event.eventId);
    if (cachedIdx >= 0) {
      emit(EventsLoaded(List<Event>.from(_cachedEvents)));
      return;
    }
    emit(EventLoading());
    final result = await getEventById(event.eventId);
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (e) {
        final idx = _cachedEvents.indexWhere((x) => x.id == e.id);
        if (idx >= 0) {
          _cachedEvents = [
            ..._cachedEvents.sublist(0, idx),
            e,
            ..._cachedEvents.sublist(idx + 1),
          ];
        } else {
          _cachedEvents = [..._cachedEvents, e];
        }
        emit(EventsLoaded(_cachedEvents));
      },
    );
  }

  Future<void> _onCreate(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    final conflicts = detectConflict(DetectConflictParams(
      newEvent: event.event,
      existing: _cachedEvents,
    ));

    if (conflicts.isNotEmpty) {
      emit(EventConflictDetected(conflicts, event.event));
      return;
    }

    await _doCreate(event.event, emit);
  }

  Future<void> _onConflictConfirmed(
    ConflictConfirmed event,
    Emitter<EventState> emit,
  ) async {
    await _doCreate(event.event, emit);
  }

  Future<void> _doCreate(Event event, Emitter<EventState> emit) async {
    emit(EventCreating());
    final result = await createEvent(CreateEventParams(event: event));
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (created) {
        _cachedEvents = [..._cachedEvents, created];
        emit(EventCreated(created));
        emit(EventsLoaded(_cachedEvents));
      },
    );
  }

  Future<void> _onUpdate(
    UpdateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventUpdating());
    final result = await updateEvent(UpdateEventParams(event: event.event));
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (updated) {
        _cachedEvents = _cachedEvents
            .map((e) => e.id == updated.id ? updated : e)
            .toList();
        emit(EventUpdated(updated));
        emit(EventsLoaded(_cachedEvents));
      },
    );
  }

  Future<void> _onDelete(
    DeleteEventRequested event,
    Emitter<EventState> emit,
  ) async {
    final previous = List<Event>.from(_cachedEvents);
    _cachedEvents =
        _cachedEvents.where((e) => e.id != event.eventId).toList();
    emit(EventsLoaded(_cachedEvents));

    final result = await deleteEvent(event.eventId);
    result.fold(
      (failure) {
        _cachedEvents = previous;
        emit(EventsLoaded(_cachedEvents));
      },
      (_) {
        emit(EventDeleted(event.eventId));
        emit(EventsLoaded(_cachedEvents));
      },
    );
  }

  Future<void> _onQuickCreate(
    QuickCreateEvent event,
    Emitter<EventState> emit,
  ) async {
    final now = DateTime.now();
    final startHour = now.hour + 1;

    final quickEvent = Event(
      id: '',
      title: event.title.trim(),
      description: '',
      startTime: DateTime(
        event.selectedDate.year,
        event.selectedDate.month,
        event.selectedDate.day,
        startHour,
        0,
      ),
      endTime: DateTime(
        event.selectedDate.year,
        event.selectedDate.month,
        event.selectedDate.day,
        startHour + 1,
        0,
      ),
      type: EventType.personal,
      createdBy: const User(id: '', username: '', email: ''),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    add(CreateEventRequested(event: quickEvent));
  }

  Future<void> _onSearch(
    SearchRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final result = await searchEvents(SearchEventsParams(
      query: event.query,
      eventType: event.eventType,
      startDate: event.startDate,
      endDate: event.endDate,
    ));
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (events) =>
          emit(EventSearchResults(results: events, query: event.query)),
    );
  }

  Future<void> _onAcceptInvite(
    AcceptEventInviteRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventUpdating());
    final result = await acceptEventInvite(event.eventId);
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (updated) {
        _cachedEvents = _cachedEvents
            .map((e) => e.id == updated.id ? updated : e)
            .toList();
        emit(EventUpdated(updated));
        emit(EventsLoaded(_cachedEvents));
      },
    );
  }

  Future<void> _onDeclineInvite(
    DeclineEventInviteRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventUpdating());
    final result = await declineEventInvite(event.eventId);
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (updated) {
        _cachedEvents = _cachedEvents
            .map((e) => e.id == updated.id ? updated : e)
            .toList();
        emit(EventUpdated(updated));
        emit(EventsLoaded(_cachedEvents));
      },
    );
  }
}
