import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'services/firebase_push_background_handler.dart';

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
import 'package:my_app/event_management/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:my_app/event_management/features/dashboard/data/repositories/dashboard_repositories_impl.dart';
import 'package:my_app/event_management/features/dashboard/domain/usecases/fetch_dashboard_usecase.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/events/data/datasources/event_local_datasource.dart';
import 'package:my_app/event_management/features/events/data/datasources/event_remote_datasource.dart';
import 'package:my_app/event_management/features/events/data/repositories/event_repository_impl.dart';
import 'package:my_app/event_management/features/events/domain/usecases/create_event_usecase.dart';
import 'package:my_app/event_management/features/events/presentation/bloc/event_bloc.dart';
import 'package:my_app/event_management/features/notification/data/datasource/notification_datasource.dart';
import 'package:my_app/event_management/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:my_app/event_management/features/notification/domain/usecases/fetch_notification_usecases.dart';
import 'package:my_app/event_management/features/notification/domain/usecases/mark_read_usecases.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/core/network/websocket_client.dart';
import 'package:my_app/event_management/features/notification/data/model/notification_model.dart';
import 'package:my_app/event_management/features/events/data/models/event_model.dart';
import 'package:my_app/services/notification_payload_router.dart';

// Survey
import 'package:my_app/survey/bloc/survey_employee_bloc.dart';
import 'package:my_app/survey/bloc/survey_employee_event.dart';
import 'package:my_app/survey/repository/survey_repository.dart';

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
import 'core/scaffold_messenger_scope.dart';
import 'core/web_splash_remove.dart'
    if (dart.library.html) 'core/web_splash_remove_web.dart';
import 'core/auth/auth_session_redirect.dart';
import 'services/api_client.dart';

// Client
import 'package:my_app/client tracker/features/clients/bloc/client_bloc.dart';
import 'package:my_app/client tracker/features/clients/repository/client_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = true;

  await Hive.initFlutter();

  // Firebase Init
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    debugPrint('Firebase.initializeApp failed: $e\n$st');
  }

  // Top-level background handler is for mobile isolates; on web it can error or block startup.
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Shared API Client
  AuthSessionRedirect.bindNavigator(() => navigatorKey);
  final apiClient = ApiClient();

  final eventRemote = EventRemoteDataSourceImpl(apiClient.dio);
  final eventLocal = EventLocalDataSourceImpl();
  final eventRepo = EventRepositoryImpl(eventRemote, eventLocal);

  final notificationDataSource = NotificationDataSourceImpl(apiClient.dio);
  final notificationRepository =
      NotificationRepositoryImpl(notificationDataSource);

  // Create remote datasources
  final postRemoteDataSource = PostRemoteDataSource(apiClient);
  final userRemoteDataSource = UserRemoteDataSource(apiClient);

  // Create repositories
  final postRepository = PostRepositoryImpl(postRemoteDataSource);
  final userRepository = UserRepositoryImpl(userRemoteDataSource);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => LeadRepository()),
        RepositoryProvider(create: (_) => EmployeeRepository()),
        RepositoryProvider(create: (_) => LeaveApiService()),
        RepositoryProvider(create: (_) => AdminRepository()),
        RepositoryProvider(create: (_) => ClientRepository()),
        RepositoryProvider<PostRepository>.value(value: postRepository),
        RepositoryProvider<UserRepository>.value(value: userRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LeadBloc(context.read<LeadRepository>()),
          ),
          BlocProvider<EmployeeBloc>(
            create: (context) => EmployeeBloc(
              repo: context.read<EmployeeRepository>(),
            ),
          ),
          BlocProvider<LeaveBloc>(
            create: (context) => LeaveBloc(context.read<LeaveApiService>()),
          ),
          BlocProvider<AdminDashboardBloc>(
            create: (context) => AdminDashboardBloc(
              repository: context.read<AdminRepository>(),
            ),
          ),
          BlocProvider<EventBloc>(
            create: (_) => EventBloc(
              createEvent: CreateEventUseCase(eventRepo),
              updateEvent: UpdateEventUseCase(eventRepo),
              deleteEvent: DeleteEventUseCase(eventRepo),
              fetchEvents: FetchEventsUseCase(eventRepo),
              getEventById: GetEventByIdUseCase(eventRepo),
              detectConflict: DetectConflictUseCase(),
              searchEvents: SearchEventsUseCase(eventRepo),
              acceptEventInvite: AcceptEventInviteUseCase(eventRepo),
              declineEventInvite: DeclineEventInviteUseCase(eventRepo),
            ),
          ),
          BlocProvider<CalendarBloc>(create: (_) => CalendarBloc()),
          BlocProvider<DashboardBloc>(
            create: (_) => DashboardBloc(
              fetchDashboard: FetchDashboardUseCase(
                DashboardRepositoryImpl(eventRepo),
              ),
            ),
          ),
          BlocProvider<NotificationBloc>(
            create: (_) => NotificationBloc(
              fetchNotifications:
                  FetchNotificationsUseCase(notificationRepository),
              markRead: MarkReadUseCase(notificationRepository),
            ),
          ),
          BlocProvider<ClientBloc>(
            create: (context) => ClientBloc(context.read<ClientRepository>()),
          ),
          BlocProvider<PostBloc>(
            create: (context) => PostBloc(context.read<PostRepository>()),
          ),
          BlocProvider<AudienceBloc>(
            create: (context) => AudienceBloc(
              userRepository: context.read<UserRepository>(),
            ),
          ),
          BlocProvider<SurveyEmployeeBloc>(
            create: (_) => SurveyEmployeeBloc(
              repository: SurveyRepository(),
            )..add(const SurveyEmployeeLoadActive()),
          ),
        ],
        child: const _RealtimeWsBootstrap(
          child: _NotificationAppResumeRefresh(
            child: _GlobalLoaderOverlay(child: MyApp()),
          ),
        ),
      ),
    ),
  );

  // Native splash (flutter_native_splash) stays up until Flutter paints. Local notifications +
  // FCM `getInitialMessage()` can block `main()` — run them after the first frame instead.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    removeWebHtmlSplashOverlay();
    unawaited(_initPushNotificationsAfterFirstFrame());
  });
}

Future<void> _initPushNotificationsAfterFirstFrame() async {
  try {
    if (kIsWeb) {
      // Web: tray = firebase-messaging-sw.js only; foreground onMessage refreshes in-app notifications.
      // Avoid duplicate listeners: NotificationService replaces prior onMessage/onTokenRefresh subscriptions.
      final notificationService = NotificationService();
      await notificationService.init(navigatorKey);
      notificationService.listenForegroundMessages(navigatorKey);
      notificationService.handleNotificationTap(navigatorKey);
      notificationService.listenForTokenRefresh(owner: 'web');
      await notificationService.handleInitialMessage(navigatorKey);
      return;
    }

    await LocalNotificationService.initialize();
    final notificationService = NotificationService();
    await notificationService.init(navigatorKey);
    notificationService.listenForegroundMessages(navigatorKey);
    notificationService.handleNotificationTap(navigatorKey);
    notificationService.listenForTokenRefresh(owner: 'mobile');
    await notificationService.handleInitialMessage(navigatorKey);
  } catch (e, st) {
    debugPrint('Push notification setup failed: $e\n$st');
  }
}

/// Refreshes `GET /api/notifications/` when the app returns to foreground.
class _NotificationAppResumeRefresh extends StatefulWidget {
  final Widget child;

  const _NotificationAppResumeRefresh({required this.child});

  @override
  State<_NotificationAppResumeRefresh> createState() =>
      _NotificationAppResumeRefreshState();
}

/// Establishes a WebSocket connection and applies server-side event/notification
/// changes into the in-memory blocs so mobile/desktop stay in sync.
class _RealtimeWsBootstrap extends StatefulWidget {
  final Widget child;
  const _RealtimeWsBootstrap({required this.child});

  @override
  State<_RealtimeWsBootstrap> createState() => _RealtimeWsBootstrapState();
}

class _RealtimeWsBootstrapState extends State<_RealtimeWsBootstrap> {
  final WebSocketClient _ws = WebSocketClient();
  StreamSubscription<Map<String, dynamic>>? _sub;

  @override
  void initState() {
    super.initState();
    // Optional realtime channel — failures are handled inside WebSocketClient.
    unawaited(_ws.connect().catchError((_) {}));
    _sub = _ws.stream.listen(
      _onMessage,
      onError: (_) {},
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ws.disconnect();
    super.dispose();
  }

  void _onMessage(Map<String, dynamic> raw) {
    if (!mounted) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final data = Map<String, dynamic>.from(raw);
    final type = (data['type'] ?? data['notif_type'] ?? '').toString().toLowerCase();

    // Notifications (WS payloads are often already shaped like local push payloads).
    final looksLikeNotification =
        data.containsKey('title') ||
        data.containsKey('body') ||
        data.containsKey('notif_type') ||
        data.containsKey('notif_id');
    if (looksLikeNotification) {
      try {
        final notif = NotificationModel.fromWebSocket(data);
        ctx.read<NotificationBloc>().add(NotificationReceived(notif));
      } catch (_) {}
    }

    // Task / leave notification routing from WebSocket payloads.
    final notifType = type.isNotEmpty ? type : (data['notif_type']?.toString() ?? '');
    if (notifType == 'task_updated' ||
        notifType == 'task_due_reminder' ||
        notifType == 'leave_status' ||
        data.containsKey('task_id') ||
        data.containsKey('leave_id')) {
      NotificationPayloadRouter.handleWithContext(ctx, data);
      return;
    }

    // Event sync: support a few common payload shapes.
    try {
      final action = (data['action'] ?? '').toString().toLowerCase();
      final eventId = (data['event_id'] ?? data['id'])?.toString();
      final eventRaw = data['event'];

      if (eventId != null &&
          (type.contains('event') || action.isNotEmpty) &&
          (action == 'deleted' ||
              action == 'delete' ||
              action == 'removed' ||
              action == 'remove' ||
              type.contains('deleted') ||
              type.contains('delete'))) {
        ctx.read<EventBloc>().add(ExternalEventDeleted(eventId));
        return;
      }

      if (eventRaw is Map) {
        final eventJson = Map<String, dynamic>.from(
          eventRaw.map((k, v) => MapEntry(k.toString(), v)),
        );
        final ev = EventModel.fromJson(eventJson);
        ctx.read<EventBloc>().add(ExternalEventUpserted(ev));
        return;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _NotificationAppResumeRefreshState
    extends State<_NotificationAppResumeRefresh> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ApiClient().ensureSessionValid(redirectOnFailure: true));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = navigatorKey.currentContext;
        if (ctx == null || !ctx.mounted) return;
        try {
          ctx.read<NotificationBloc>().add(NotificationLoadRequested());
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Global API loading mask **above** [MaterialApp] so the [Navigator] subtree is never
/// replaced with a [SizedBox] or rebuilt in a way that leaves `_history` empty (Flutter 3.22+).
class _GlobalLoaderOverlay extends StatelessWidget {
  final Widget child;

  const _GlobalLoaderOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ApiClient.loader,
      child: child,
      builder: (_, loading, app) {
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.topLeft,
          children: [
            app!,
            if (loading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'DaxarrowTeams',
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        fontFamilyFallback: const [
          'MaterialIcons',
          'NotoSansSymbols2',
          'NotoSans',
          'DMMono',
        ],
      ),
      home: const MobileSplashEntry(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}