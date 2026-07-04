/// In-memory expiry notice flag for non-web platforms.
class SessionExpiryNoticeStorage {
  SessionExpiryNoticeStorage._();

  static bool _shown = false;

  static bool get wasShown => _shown;

  static void markShown() => _shown = true;

  static void clear() => _shown = false;
}
