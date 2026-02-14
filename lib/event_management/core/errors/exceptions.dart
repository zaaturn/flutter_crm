class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message (status $statusCode)';
}

/// The server returned an unexpected status code.
class ServerException extends AppException {
  const ServerException({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

/// The device has no internet / DNS failed / connection refused.
class NetworkException extends AppException {
  const NetworkException({String message = 'No internet connection.'})
      : super(message: message);
}

/// JSON could not be parsed into the expected model.
class ParseException extends AppException {
  const ParseException({required String message})
      : super(message: message);
}

/// A 404 from the backend.
class NotFoundException extends AppException {
  const NotFoundException({String message = 'Resource not found.'})
      : super(message: message, statusCode: 404);
}

/// Validation errors returned by Django (400).
class ValidationException extends AppException {
  final Map<String, dynamic> errors;

  const ValidationException({required this.errors})
      : super(message: 'Validation failed', statusCode: 400);
}
