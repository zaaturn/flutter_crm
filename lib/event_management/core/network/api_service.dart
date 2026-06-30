
import 'package:dio/dio.dart';
import 'package:my_app/services/api_client.dart' as app_api;

/// Event HTTP client — delegates to the shared [app_api.ApiClient] Dio so token
/// refresh is single-flight across the whole app.
class EventApiClient {
  EventApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.13:8000',
  );

  static Dio create() => app_api.ApiClient().dio;
}

// API endpoints constants
class ApiEndpoints {
  // Auth
  static const String login = '/api/auth/token/';
  static const String register = '/api/auth/register/';
  static const String tokenRefresh = '/api/accounts/crm/token/refresh/';
  static const String profile = '/api/auth/profile/';
  static const String users = '/api/auth/users/';


  /// Default matches [ApiClient.baseAccounts] pattern (`…/api/accounts/crm/…`).
  static const String usersAll = String.fromEnvironment(
    'USERS_ALL_PATH',
    defaultValue: '/api/accounts/crm/users/all/',
  );

  // Events
  static const String events = '/api/events/';
  static const String eventsRange = '/api/events/range/';
  static const String eventsCalendar = '/api/events/calendar/';
  static const String eventsDotMap = '/api/events/dot-map/';
  static const String eventsMyReminders = '/api/events/my-reminders/';
  static const String eventsConflictCheck = '/api/events/conflict-check/';
  static const String eventsExportIcs = '/api/events/export-ics/';
  static const String eventsToday = '/api/events/today/';
  static const String eventsUpcoming = '/api/events/upcoming/';
  static const String eventsMissed = '/api/events/missed/';

  // Notifications
  static const String notifications = '/api/notifications/';
  static const String markAllRead = '/api/notifications/mark-all-read/';

  // Reminders
  static const String reminders = '/api/reminders/';
}