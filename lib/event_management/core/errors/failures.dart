/// Base class – all concrete failures extend this.
abstract class Failure {
  final String message;
  const Failure({required this.message});
}

/// Network / connectivity problems.
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No internet connection.'})
      : super(message: message);
}

/// The backend returned a 5xx or an unexpected status.
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

/// JSON parse error.
class ParseFailure extends Failure {
  const ParseFailure({required String message}) : super(message: message);
}

/// 404 – item was deleted / never existed.
class NotFoundFailure extends Failure {
  const NotFoundFailure({String message = 'Resource not found.'})
      : super(message: message);
}

/// DRF validation errors (400).  Carries the raw map for field-level display.
class ValidationFailure extends Failure {
  final Map<String, dynamic> errors;
  const ValidationFailure({required this.errors})
      : super(message: 'Validation failed');
}