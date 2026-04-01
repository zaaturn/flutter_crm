
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ServerException(
      this.message, {
        this.statusCode,
        this.errors,
      });

  @override
  String toString() =>
      'ServerException($statusCode): $message'
          '${errors != null ? ' | errors: $errors' : ''}';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache read/write error']);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);

  @override
  String toString() => 'AuthException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => 'NotFoundException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>> fieldErrors;

  const ValidationException(
      this.message, {
        this.fieldErrors = const {},
      });

  @override
  String toString() => 'ValidationException: $message | $fieldErrors';
}