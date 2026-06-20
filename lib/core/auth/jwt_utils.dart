import 'dart:convert';

/// Lightweight JWT helpers (no external package).
class JwtUtils {
  JwtUtils._();

  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      final mod = payload.length % 4;
      if (mod > 0) payload += '=' * (4 - mod);
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = jsonDecode(decoded);
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      return null;
    }
  }

  static DateTime? expiry(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;
    final exp = payload['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true).toLocal();
    }
    if (exp is num) {
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true)
          .toLocal();
    }
    return null;
  }

  /// True when [token] has an `exp` claim in the past.
  static bool isExpired(String token, {Duration leeway = const Duration(seconds: 30)}) {
    final at = expiry(token);
    if (at == null) return false;
    return DateTime.now().isAfter(at.subtract(leeway));
  }
}
