import 'package:dio/dio.dart';

/// Converts [DioException]s into user-friendly error messages.
///
/// This is a stateless utility — all methods are static.
class DioErrorHandler {
  const DioErrorHandler._();

  /// Convert a [DioException] to a short, user-facing message.
  static String userMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return 'Unable to connect to the rclone daemon. '
            'Make sure DriveSync is running and try again.';

      case DioExceptionType.connectionTimeout:
        return 'Connection to the rclone daemon timed out. '
            'The daemon may be overloaded or unresponsive.';

      case DioExceptionType.sendTimeout:
        return 'Request to rclone timed out while sending data. '
            'Try again or check your system resources.';

      case DioExceptionType.receiveTimeout:
        return 'Waiting for rclone response timed out. '
            'The operation may still be running in the background.';

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return 'The request was cancelled.';

      case DioExceptionType.badCertificate:
        return 'SSL certificate error when connecting to rclone. '
            'This is unexpected for a localhost connection.';

      case DioExceptionType.unknown:
        return _handleUnknown(error);
    }
  }

  /// Whether the [DioException] represents a network connectivity problem
  /// (as opposed to a server-side error).
  static bool isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  /// Whether the [DioException] indicates an auth problem (HTTP 401/403).
  static bool isAuthError(DioException error) {
    if (error.type != DioExceptionType.badResponse) return false;
    final statusCode = error.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

  /// Produce a user-facing message from an HTTP error response.
  static String _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final body = response?.data;

    // Try to extract rclone's error field from JSON response.
    String? rcloneError;
    if (body is Map<String, dynamic>) {
      rcloneError = body['error'] as String?;
    }

    switch (statusCode) {
      case 401:
        return 'Authentication failed (401). '
            'Check the rclone RC username and password.';
      case 403:
        return 'Access forbidden (403). '
            '${rcloneError ?? 'The rclone daemon rejected the request.'}';
      case 404:
        return 'Endpoint not found (404). '
            'The rclone version may be too old for this feature.';
      case 500:
        return 'rclone internal error (500). '
            '${rcloneError ?? 'Check rclone logs for details.'}';
      default:
        final detail = rcloneError ?? 'HTTP $statusCode';
        return 'rclone returned an error: $detail';
    }
  }

  /// Handle unknown / unclassified Dio errors.
  static String _handleUnknown(DioException error) {
    final message = error.error?.toString() ?? error.message ?? '';

    // Common OS-level network errors that show up as "unknown" type.
    final lower = message.toLowerCase();
    if (lower.contains('connection refused') ||
        lower.contains('no route to host') ||
        lower.contains('network is unreachable')) {
      return 'Cannot reach the rclone daemon. '
          'It may not be running. Try restarting DriveSync.';
    }
    if (lower.contains('broken pipe') || lower.contains('connection reset')) {
      return 'Lost connection to the rclone daemon. '
          'It may have crashed. Try restarting DriveSync.';
    }

    return 'An unexpected network error occurred: '
        '${message.isNotEmpty ? message : 'unknown error'}';
  }
}
