import 'package:dio/dio.dart';

class ErrorHandler {
  static String format(Object err) {
    if (err is DioException) {
      final response = err.response;

      // If backend sends structured JSON
      if (response?.data is Map<String, dynamic>) {
        final data = response!.data as Map<String, dynamic>;

        if (data["message"] != null) {
          return data["message"].toString();
        }

        if (data["error"] != null) {
          return data["error"].toString();
        }

        if (data["detail"] != null) {
          return data["detail"].toString();
        }
      }

      // If backend sends plain text
      if (response?.data is String) {
        return response!.data.toString();
      }

      // Network level issues
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

    // Non-Dio errors
    String message = err.toString();
    message = message
        .replaceAll("Exception: ", "")
        .replaceAll(RegExp(r"ApiException\\(\\d+\\): "), "");

    return message.isEmpty ? "Something went wrong." : message;
  }
}