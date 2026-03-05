import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

// Admin Lead
import 'admin_page/bloc/lead_bloc.dart';
import 'admin_page/repository/lead_repository.dart';

// Employee
import 'employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'employee_dashboard/repository/employee_dashboard_repository.dart';

// Leave
import 'leave_management/block/leave_bloc.dart';
import 'leave_management/services/leave_api_services.dart';

// Admin Dashboard
import 'admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'admin_dashboard/repository/admin_repository.dart';

// Calendar / Events
import 'event_management/features/presentation/bloc/event_bloc.dart';
import 'event_management/features/calendar/data/repositories/event_repository_impl.dart';
import 'event_management/features/calendar/data/datasources/event_remote_datasource_impl.dart';
import 'event_management/features/domain/usecases/create_event.dart'
as event_usecase;
import 'event_management/features/domain/usecases/update_event.dart'
as event_usecase;
import 'event_management/features/domain/usecases/delete_event.dart'
as event_usecase;
import 'event_management/features/domain/usecases/get_events.dart'
as event_usecase;

// Dashboards Feature
import 'dashboards/data/datasource/post_remote_datasource.dart';
import 'dashboards/data/datasource/user_remote_datasource.dart';
import 'dashboards/data/repositories_impl/post_repository_impl.dart';
import 'dashboards/data/repositories_impl/user_repository_impl.dart';
import 'dashboards/domain/repository/post_repository.dart';
import 'dashboards/domain/repository/user_repository.dart';
import 'dashboards/presentations/bloc/post_bloc.dart';
import 'dashboards/presentations/bloc/audience_bloc.dart';

// Core
import 'services/flutter_local_notification_service.dart';
import 'services/notification_service.dart';
import 'core/router/app_router.dart';
import 'services/api_client.dart';
import 'package:my_app/core/router/startup_gate.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  if (!kIsWeb) {
    await LocalNotificationService.initialize();
  }

  final notificationService = NotificationService();
  await notificationService.init();
  notificationService.listenForegroundMessages(navigatorKey);
  notificationService.handleNotificationTap(navigatorKey);
  await notificationService.handleInitialMessage(navigatorKey);

  // Shared API Client
  final apiClient = ApiClient();

  // Event Repository
  final eventRepo = EventRepositoryImpl(
    EventRemoteDatasourceImpl(),
  );


// Create remote datasources
  final postRemoteDataSource =
  PostRemoteDataSource(apiClient);

  final userRemoteDataSource =
  UserRemoteDataSource(apiClient);

// Create repositories
  final postRepository =
  PostRepositoryImpl(postRemoteDataSource);

  final userRepository =
  UserRepositoryImpl(userRemoteDataSource);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => LeadRepository()),
        RepositoryProvider(create: (_) => EmployeeRepository()),
        RepositoryProvider(create: (_) => LeaveApiService()),
        RepositoryProvider(create: (_) => AdminRepository()),
        RepositoryProvider<EventRepositoryImpl>.value(value: eventRepo),

        // Dashboards Repositories
        RepositoryProvider<PostRepository>.value(
          value: postRepository,
        ),
        RepositoryProvider<UserRepository>.value(
          value: userRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                LeadBloc(context.read<LeadRepository>()),
          ),
          BlocProvider<EmployeeBloc>(
            create: (context) => EmployeeBloc(
              repo: context.read<EmployeeRepository>(),
            ),
          ),
          BlocProvider<LeaveBloc>(
            create: (context) =>
                LeaveBloc(context.read<LeaveApiService>()),
          ),
          BlocProvider<AdminDashboardBloc>(
            create: (context) => AdminDashboardBloc(
              repository: context.read<AdminRepository>(),
            ),
          ),
          BlocProvider<EventBloc>(
            create: (context) => EventBloc(
              createEvent:
              event_usecase.CreateEvent(eventRepo),
              updateEvent:
              event_usecase.UpdateEvent(eventRepo),
              deleteEvent:
              event_usecase.DeleteEvent(eventRepo),
              getEvents:
              event_usecase.GetEvents(eventRepo),
            ),
          ),

          // Dashboards Blocs
          BlocProvider<PostBloc>(
            create: (context) =>
                PostBloc(context.read<PostRepository>()),
          ),
          BlocProvider<AudienceBloc>(
            create: (context) =>
                AudienceBloc(
                  userRepository: context.read<UserRepository>(),
                ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'DaxarrowTeams',
      home: StartupGate(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}