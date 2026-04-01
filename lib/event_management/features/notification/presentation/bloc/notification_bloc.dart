import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entity/notification_entity.dart';
import '../../domain/usecases/fetch_notification_usecases.dart';
import '../../domain/usecases/mark_read_usecases.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {}

class NotificationMarkRead extends NotificationEvent {
  final String notificationId;
  const NotificationMarkRead(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllRead extends NotificationEvent {}

class NotificationReceived extends NotificationEvent {
  final AppNotification notification;
  const NotificationReceived(this.notification);
  @override
  List<Object?> get props => [notification];
}

class NotificationState extends Equatable {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [notifications, isLoading, error];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FetchNotificationsUseCase fetchNotifications;
  final MarkReadUseCase markRead;

  NotificationBloc({
    required this.fetchNotifications,
    required this.markRead,
  }) : super(const NotificationState()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationMarkRead>(_onMarkRead);
    on<NotificationMarkAllRead>(_onMarkAllRead);
    on<NotificationReceived>(_onReceived);
  }

  Future<void> _onLoad(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await fetchNotifications();
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (notifications) => emit(state.copyWith(
        isLoading: false,
        error: null,
        notifications: notifications,
      )),
    );
  }

  Future<void> _onMarkRead(
    NotificationMarkRead event,
    Emitter<NotificationState> emit,
  ) async {
    final updated = state.notifications.map((n) {
      return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
    }).toList();
    emit(state.copyWith(notifications: updated));
    await markRead(event.notificationId);
  }

  void _onMarkAllRead(
    NotificationMarkAllRead event,
    Emitter<NotificationState> emit,
  ) {
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(notifications: updated));
    markRead.markAll();
  }

  void _onReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(
      notifications: [event.notification, ...state.notifications],
    ));
  }
}
