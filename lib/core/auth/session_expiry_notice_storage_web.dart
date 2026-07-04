import 'dart:html' as html;

/// Persists expiry notice across full page reloads on web.
class SessionExpiryNoticeStorage {
  SessionExpiryNoticeStorage._();

  static const _key = 'daxarrow_session_expiry_notice';

  static bool get wasShown =>
      html.window.sessionStorage[_key] == '1';

  static void markShown() {
    html.window.sessionStorage[_key] = '1';
  }

  static void clear() {
    html.window.sessionStorage.remove(_key);
  }
}
