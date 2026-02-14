import 'package:get_it/get_it.dart';

// Datasource interface
import 'package:my_app/event_management/features/calendar/data/datasources/event_remote_datasource.dart';

// Datasource impl
import 'package:my_app/event_management/features/calendar/data/datasources/event_remote_datasource_impl.dart';

// Repository impl
import 'package:my_app/event_management/features/calendar/data/repositories/event_repository_impl.dart';

// Repository interface
import 'package:my_app/event_management/features/domain/repositories/event_repository.dart';

// Usecases
import 'package:my_app/event_management/features/domain/usecases/create_event.dart';
import 'package:my_app/event_management/features/domain/usecases/delete_event.dart';
import 'package:my_app/event_management/features/domain/usecases/get_events.dart';
import 'package:my_app/event_management/features/domain/usecases/update_event.dart';

// Bloc
import 'package:my_app/event_management/features/presentation/bloc/event_bloc.dart';





final getIt = GetIt.instance;

/// Call once from main() before runApp().
Future<void> setupEventInjection() async {
  // ── Data ──────────────────────────
  getIt.registerLazySingleton<EventRemoteDatasource>(
        () => EventRemoteDatasourceImpl(),
  );

  getIt.registerLazySingleton<EventRepository>(
        () => EventRepositoryImpl(getIt<EventRemoteDatasource>()),
  );

  // ── Domain (use-cases) ────────────
  getIt.registerLazySingleton<GetEvents>(
        () => GetEvents(getIt<EventRepository>()),
  );

  getIt.registerLazySingleton<CreateEvent>(
        () => CreateEvent(getIt<EventRepository>()),
  );

  getIt.registerLazySingleton<UpdateEvent>(
        () => UpdateEvent(getIt<EventRepository>()),
  );

  getIt.registerLazySingleton<DeleteEvent>(
        () => DeleteEvent(getIt<EventRepository>()),
  );

  // ── Presentation (Bloc) ───────────
  getIt.registerFactory<EventBloc>(
        () => EventBloc(
      getEvents: getIt<GetEvents>(),
      createEvent: getIt<CreateEvent>(),
      updateEvent: getIt<UpdateEvent>(),
      deleteEvent: getIt<DeleteEvent>(),
    ),
  );
}
