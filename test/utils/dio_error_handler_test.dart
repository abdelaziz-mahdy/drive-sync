import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/utils/dio_error_handler.dart';

/// Helper to create a DioException with the given type and optional response.
DioException _dioException(
  DioExceptionType type, {
  int? statusCode,
  dynamic responseData,
  Object? error,
  String? message,
}) {
  return DioException(
    type: type,
    requestOptions: RequestOptions(path: '/test'),
    response: statusCode != null
        ? Response(
            statusCode: statusCode,
            data: responseData,
            requestOptions: RequestOptions(path: '/test'),
          )
        : null,
    error: error,
    message: message,
  );
}

void main() {
  group('DioErrorHandler.userMessage', () {
    test('connectionError returns daemon unreachable message', () {
      final msg = DioErrorHandler.userMessage(
        _dioException(DioExceptionType.connectionError),
      );
      expect(msg, contains('Unable to connect'));
      expect(msg, contains('rclone daemon'));
    });

    test('connectionTimeout returns timeout message', () {
      final msg = DioErrorHandler.userMessage(
        _dioException(DioExceptionType.connectionTimeout),
      );
      expect(msg, contains('timed out'));
    });

    test('sendTimeout returns send timeout message', () {
      final msg = DioErrorHandler.userMessage(
        _dioException(DioExceptionType.sendTimeout),
      );
      expect(msg, contains('timed out'));
      expect(msg, contains('sending'));
    });

    test('receiveTimeout returns receive timeout message', () {
      final msg = DioErrorHandler.userMessage(
        _dioException(DioExceptionType.receiveTimeout),
      );
      expect(msg, contains('timed out'));
      expect(msg, contains('still be running'));
    });

    test('cancel returns cancelled message', () {
      final msg = DioErrorHandler.userMessage(
        _dioException(DioExceptionType.cancel),
      );
      expect(msg, contains('cancelled'));
    });

    test('badCertificate returns SSL message', () {
      final msg = DioErrorHandler.userMessage(
        _dioException(DioExceptionType.badCertificate),
      );
      expect(msg, contains('SSL'));
    });

    group('badResponse', () {
      test('401 returns auth failed message', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(DioExceptionType.badResponse, statusCode: 401),
        );
        expect(msg, contains('Authentication failed'));
        expect(msg, contains('401'));
      });

      test('403 returns forbidden message', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(DioExceptionType.badResponse, statusCode: 403),
        );
        expect(msg, contains('forbidden'));
      });

      test('403 with rclone error body includes error detail', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(
            DioExceptionType.badResponse,
            statusCode: 403,
            responseData: {'error': 'rate limit exceeded'},
          ),
        );
        expect(msg, contains('rate limit exceeded'));
      });

      test('404 returns endpoint not found message', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(DioExceptionType.badResponse, statusCode: 404),
        );
        expect(msg, contains('not found'));
        expect(msg, contains('404'));
      });

      test('500 returns internal error message', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(DioExceptionType.badResponse, statusCode: 500),
        );
        expect(msg, contains('internal error'));
      });

      test('500 with rclone error body includes error detail', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(
            DioExceptionType.badResponse,
            statusCode: 500,
            responseData: {'error': 'directory not found'},
          ),
        );
        expect(msg, contains('directory not found'));
      });

      test('other status code returns generic message', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(DioExceptionType.badResponse, statusCode: 502),
        );
        expect(msg, contains('502'));
      });
    });

    group('unknown type', () {
      test('connection refused returns restart message', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(
            DioExceptionType.unknown,
            error: const SocketException('Connection refused'),
          ),
        );
        expect(msg, contains('Cannot reach'));
        expect(msg, contains('restart'));
      });

      test('broken pipe returns lost connection message', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(
            DioExceptionType.unknown,
            error: 'Broken pipe',
          ),
        );
        expect(msg, contains('Lost connection'));
      });

      test('generic unknown error returns fallback message', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(
            DioExceptionType.unknown,
            error: 'something weird',
          ),
        );
        expect(msg, contains('unexpected'));
        expect(msg, contains('something weird'));
      });

      test('null error returns unknown error message', () {
        final msg = DioErrorHandler.userMessage(
          _dioException(DioExceptionType.unknown),
        );
        expect(msg, contains('unexpected'));
      });
    });
  });

  group('DioErrorHandler.isNetworkError', () {
    test('returns true for connectionError', () {
      expect(
        DioErrorHandler.isNetworkError(
          _dioException(DioExceptionType.connectionError),
        ),
        isTrue,
      );
    });

    test('returns true for connectionTimeout', () {
      expect(
        DioErrorHandler.isNetworkError(
          _dioException(DioExceptionType.connectionTimeout),
        ),
        isTrue,
      );
    });

    test('returns true for sendTimeout', () {
      expect(
        DioErrorHandler.isNetworkError(
          _dioException(DioExceptionType.sendTimeout),
        ),
        isTrue,
      );
    });

    test('returns true for receiveTimeout', () {
      expect(
        DioErrorHandler.isNetworkError(
          _dioException(DioExceptionType.receiveTimeout),
        ),
        isTrue,
      );
    });

    test('returns false for badResponse', () {
      expect(
        DioErrorHandler.isNetworkError(
          _dioException(DioExceptionType.badResponse, statusCode: 500),
        ),
        isFalse,
      );
    });

    test('returns false for cancel', () {
      expect(
        DioErrorHandler.isNetworkError(
          _dioException(DioExceptionType.cancel),
        ),
        isFalse,
      );
    });
  });

  group('DioErrorHandler.isAuthError', () {
    test('returns true for 401', () {
      expect(
        DioErrorHandler.isAuthError(
          _dioException(DioExceptionType.badResponse, statusCode: 401),
        ),
        isTrue,
      );
    });

    test('returns true for 403', () {
      expect(
        DioErrorHandler.isAuthError(
          _dioException(DioExceptionType.badResponse, statusCode: 403),
        ),
        isTrue,
      );
    });

    test('returns false for 500', () {
      expect(
        DioErrorHandler.isAuthError(
          _dioException(DioExceptionType.badResponse, statusCode: 500),
        ),
        isFalse,
      );
    });

    test('returns false for non-badResponse types', () {
      expect(
        DioErrorHandler.isAuthError(
          _dioException(DioExceptionType.connectionError),
        ),
        isFalse,
      );
    });
  });
}
