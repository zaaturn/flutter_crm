enum AnalyticsErrorKind {
  forbidden,
  unauthorized,
  network,
  validation,
  unknown,
}

class AnalyticsApiException implements Exception {
  final String message;
  final int? statusCode;
  final AnalyticsErrorKind kind;

  const AnalyticsApiException({
    required this.message,
    this.statusCode,
    this.kind = AnalyticsErrorKind.unknown,
  });

  factory AnalyticsApiException.forbidden([String? detail]) =>
      AnalyticsApiException(
        message: detail ??
            'You do not have permission to view analytics for this organization.',
        statusCode: 403,
        kind: AnalyticsErrorKind.forbidden,
      );

  factory AnalyticsApiException.unauthorized([String? detail]) =>
      AnalyticsApiException(
        message: detail ?? 'Authentication required.',
        statusCode: 401,
        kind: AnalyticsErrorKind.unauthorized,
      );

  factory AnalyticsApiException.network([String? detail]) =>
      AnalyticsApiException(
        message: detail ?? 'Network error. Please try again.',
        kind: AnalyticsErrorKind.network,
      );

  bool get isForbidden => kind == AnalyticsErrorKind.forbidden;

  @override
  String toString() => message;
}
