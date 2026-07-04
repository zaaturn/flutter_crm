import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app/event_management/core/network/api_service.dart';
import 'package:my_app/event_management/core/network/websocket_client.dart';
import 'package:my_app/event_management/core/services/notification_service.dart';
import 'package:my_app/event_management/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/dashboard/data/repositories/dashboard_repositories_impl.dart';
import 'package:my_app/event_management/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:my_app/event_management/features/dashboard/domain/usecases/fetch_dashboard_usecase.dart';
import 'package:my_app/event_management/features/events/data/datasources/event_local_datasource.dart';
import 'package:my_app/event_management/features/events/data/datasources/event_remote_datasource.dart';
import 'package:my_app/event_management/features/events/data/repositories/event_repository_impl.dart';
import 'package:my_app/event_management/features/events/domain/repositories/event_repository.dart';
import 'package:my_app/event_management/features/events/domain/usecases/create_event_usecase.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/notification/data/datasource/notification_datasource.dart';
import 'package:my_app/event_management/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:my_app/event_management/features/notification/domain/repository/notification_repository.dart';
import 'package:my_app/event_management/features/notification/domain/usecases/fetch_notification_usecases.dart';
import 'package:my_app/event_management/features/notification/domain/usecases/mark_read_usecases.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> configureEventManagementDependencies({Dio? dio}) async {
  final d = dio ?? EventApiClient.create();

  if (!sl.isRegistered<Dio>(instanceName: 'events')) {
    sl.registerLazySingleton<Dio>(() => d, instanceName: 'events');
  }

  sl.registerLazySingleton<WebSocketClient>(() => WebSocketClient());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(sl<Dio>(instanceName: 'events')),
  );
  sl.registerLazySingleton<EventLocalDataSource>(EventLocalDataSourceImpl.new);
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton<CalendarRemoteDataSource>(
    () => CalendarRemoteDataSourceImpl(sl<Dio>(instanceName: 'events')),
  );

  sl.registerLazySingleton(() => CreateEventUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEventUseCase(sl()));
  sl.registerLazySingleton(() => DeleteEventUseCase(sl()));
  sl.registerLazySingleton(() => FetchEventsUseCase(sl()));
  sl.registerLazySingleton(() => DetectConflictUseCase());
  sl.registerLazySingleton(() => SearchEventsUseCase(sl()));
  sl.registerLazySingleton(() => GetEventByIdUseCase(sl()));
  sl.registerLazySingleton(() => AcceptEventInviteUseCase(sl()));
  sl.registerLazySingleton(() => DeclineEventInviteUseCase(sl()));

  sl.registerFactory(
    () => EventBloc(
      createEvent: sl(),
      updateEvent: sl(),
      deleteEvent: sl(),
      fetchEvents: sl(),
      getEventById: sl(),
      detectConflict: sl(),
      searchEvents: sl(),
      acceptEventInvite: sl(),
      declineEventInvite: sl(),
      calendarConflictSource: sl<CalendarRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => FetchDashboardUseCase(sl()));
  sl.registerFactory(() => DashboardBloc(fetchDashboard: sl()));

  sl.registerLazySingleton<NotificationDataSource>(
    () => NotificationDataSourceImpl(sl<Dio>(instanceName: 'events')),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => FetchNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkReadUseCase(sl()));
  sl.registerFactory(
    () => NotificationBloc(
      fetchNotifications: sl(),
      markRead: sl(),
    ),
  );

  sl.registerFactory(() => CalendarBloc());
}
