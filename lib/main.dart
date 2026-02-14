import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
import 'event_management/features/presentation/bloc/event_event.dart';
import 'event_management/features/calendar/data/repositories/event_repository_impl.dart';
import 'event_management/features/calendar/data/datasources/event_remote_datasource_impl.dart';
import 'event_management/features/domain/usecases/create_event.dart';
import 'event_management/features/domain/usecases/update_event.dart';
import 'event_management/features/domain/usecases/delete_event.dart';
import 'event_management/features/domain/usecases/get_events.dart';

// Core
import 'services/flutter_local_notification_service.dart';
import 'services/notification_service.dart';
import 'core/router/app_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ─────────────────────────────────────────────
// BACKGROUND HANDLER (REQUIRED)
// ─────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────
  // LOAD ENV
  // ─────────────────────────────────────────────
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env file loaded");
  } catch (e) {
    debugPrint("❌ .env load failed: $e");
  }

  // ─────────────────────────────────────────────
  // FIREBASE INIT
  // ─────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  // ─────────────────────────────────────────────
  // LOCAL NOTIFICATION INIT (ANDROID / IOS)
  // ─────────────────────────────────────────────
  if (!kIsWeb) {
    await LocalNotificationService.initialize();
  }

  // ─────────────────────────────────────────────
  // 🔔 NOTIFICATION SERVICE (THIS WAS MISSING)
  // ─────────────────────────────────────────────
  final notificationService = NotificationService();

  await notificationService.init();
  notificationService.listenForegroundMessages();
  notificationService.handleNotificationTap(navigatorKey);
  await notificationService.handleInitialMessage(navigatorKey);

  // ─────────────────────────────────────────────
  // EVENT REPOSITORY
  // ─────────────────────────────────────────────
  final eventRepo = EventRepositoryImpl(
    EventRemoteDatasourceImpl(),
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => LeadRepository()),
        RepositoryProvider(create: (_) => EmployeeRepository()),
        RepositoryProvider(create: (_) => LeaveApiService()),
        RepositoryProvider(create: (_) => AdminRepository()),
        RepositoryProvider<EventRepositoryImpl>.value(value: eventRepo),
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

          // ─────────────────────────────────────
          // EVENT BLOC
          // ─────────────────────────────────────
          BlocProvider<EventBloc>(
            create: (context) => EventBloc(
              createEvent: CreateEvent(eventRepo),
              updateEvent: UpdateEvent(eventRepo),
              deleteEvent: DeleteEvent(eventRepo),
              getEvents: GetEvents(eventRepo),
            )..add(
              FetchEventsRequested(
                start: DateTime.now()
                    .subtract(const Duration(days: 30)),
                end: DateTime.now()
                    .add(const Duration(days: 30)),
              ),
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
      title: 'CRM App',
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
