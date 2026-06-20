import 'package:dio/dio.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';

class ErrorHandler {
  static String format(Object err) {
    if (AuthSessionRedirect.isAuthFailure(
      err is DioException ? (err.error ?? err.response?.data) : err,
      statusCode: err is DioException ? err.response?.statusCode : null,
    )) {
      AuthSessionRedirect.onAuthFailure(error: err);
    }

    if (err is DioException) {
      final message = err.error?.toString() ?? '';
      if (message.contains('Session expired') ||
          message.contains('No auth token')) {
        return "Session expired. Please login again.";
      }

      final response = err.response;

      if (response != null) {
        switch (response.statusCode) {
          case 500:
            return "Server error occurred. Please refresh the page.";

          case 404:
            return "Requested data not found.";

          case 401:
            return "Session expired. Please login again.";

          case 403:
            return "You don't have permission to perform this action.";
        }
      }

      // JSON response
      if (response?.data is Map<String, dynamic>) {
        final data = response!.data as Map<String, dynamic>;

        if (data["message"] != null) return data["message"].toString();
        if (data["error"] != null) return data["error"].toString();
        if (data["detail"] != null) return data["detail"].toString();
      }

      // Plain text / HTML response
      if (response?.data is String) {
        final text = response!.data.toString();

        if (text.contains("<html") || text.contains("<!DOCTYPE")) {
          return "Server error occurred. Please refresh the page.";
        }

        return text;
      }

      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timed out. Please try again.";

        case DioExceptionType.connectionError:
          return "No internet connection.";

        default:
          return err.message ?? "Unexpected network error.";
      }
    }

    String message = err.toString();
    message = message
        .replaceAll("Exception: ", "")
        .replaceAll(RegExp(r"ApiException\\(\\d+\\): "), "");

    return message.isEmpty ? "Something went wrong." : message;
  }
}