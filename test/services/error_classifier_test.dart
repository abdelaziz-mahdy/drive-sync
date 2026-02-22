import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/services/error_classifier.dart';

void main() {
  const classifier = ErrorClassifier();

  group('ErrorClassifier', () {
    group('auth errors', () {
      test('classifies expired token', () {
        final result = classifier.classify(
          'googleapi: Error 401: Token has been expired or revoked',
        );
        expect(result.category, RcloneErrorCategory.authExpired);
        expect(result.userMessage, contains('expired'));
      });

      test('classifies invalid_grant', () {
        final result = classifier.classify(
          'oauth2: cannot fetch token: 400 Bad Request, Body: {"error":"invalid_grant"}',
        );
        expect(result.category, RcloneErrorCategory.authExpired);
      });

      test('classifies 401 unauthorized', () {
        final result = classifier.classify(
          'HTTP Error: 401 Unauthorized',
        );
        expect(result.category, RcloneErrorCategory.authExpired);
      });

      test('classifies failed to refresh token', () {
        final result = classifier.classify(
          'Failed to refresh token: token endpoint returned error',
        );
        expect(result.category, RcloneErrorCategory.authExpired);
      });

      test('classifies token revoked', () {
        final result = classifier.classify(
          'Error: Token has been revoked by the user',
        );
        expect(result.category, RcloneErrorCategory.authExpired);
      });
    });

    group('network errors', () {
      test('classifies connection refused', () {
        final result = classifier.classify(
          'Post "http://localhost:5572": dial tcp: connection refused',
        );
        expect(result.category, RcloneErrorCategory.networkOffline);
        expect(result.userMessage, contains('Network'));
      });

      test('classifies DNS lookup failure', () {
        final result = classifier.classify(
          'dns lookup failed for www.googleapis.com',
        );
        expect(result.category, RcloneErrorCategory.networkOffline);
      });

      test('classifies connection timed out', () {
        final result = classifier.classify(
          'connection timed out while contacting server',
        );
        expect(result.category, RcloneErrorCategory.networkOffline);
      });

      test('classifies TLS handshake timeout', () {
        final result = classifier.classify(
          'net/http: TLS handshake timeout',
        );
        expect(result.category, RcloneErrorCategory.networkOffline);
      });

      test('classifies broken pipe', () {
        final result = classifier.classify(
          'write: broken pipe',
        );
        expect(result.category, RcloneErrorCategory.networkOffline);
      });
    });

    group('permission errors', () {
      test('classifies permission denied', () {
        final result = classifier.classify(
          'open /private/dir/file.txt: permission denied',
        );
        expect(result.category, RcloneErrorCategory.permissionDenied);
        expect(result.userMessage, contains('Permission'));
      });

      test('classifies 403 forbidden', () {
        final result = classifier.classify(
          'HTTP Error: 403 Forbidden - insufficient permissions',
        );
        expect(result.category, RcloneErrorCategory.permissionDenied);
      });

      test('classifies operation not permitted', () {
        final result = classifier.classify(
          'operation not permitted on file: /etc/secret',
        );
        expect(result.category, RcloneErrorCategory.permissionDenied);
      });

      test('classifies read-only file system', () {
        final result = classifier.classify(
          'write /mnt/readonly/file.txt: read-only file system',
        );
        expect(result.category, RcloneErrorCategory.permissionDenied);
      });
    });

    group('disk full errors', () {
      test('classifies no space left on device', () {
        final result = classifier.classify(
          'write /home/user/file.zip: no space left on device',
        );
        expect(result.category, RcloneErrorCategory.diskFull);
        expect(result.userMessage, contains('full'));
      });

      test('classifies disk quota exceeded', () {
        final result = classifier.classify(
          'Error: disk quota exceeded for user',
        );
        expect(result.category, RcloneErrorCategory.diskFull);
      });

      test('classifies insufficient storage', () {
        final result = classifier.classify(
          'googleapi: Error 403: The user\'s Drive storage quota has been exceeded. Insufficient storage.',
        );
        expect(result.category, RcloneErrorCategory.diskFull);
      });

      test('classifies ENOSPC', () {
        final result = classifier.classify(
          'Error copying file: ENOSPC',
        );
        expect(result.category, RcloneErrorCategory.diskFull);
      });
    });

    group('bisync conflict errors', () {
      test('classifies bisync conflict', () {
        final result = classifier.classify(
          'NOTICE: Bisync conflict detected: file.txt',
        );
        expect(result.category, RcloneErrorCategory.bisyncConflict);
        expect(result.userMessage, contains('conflict'));
      });

      test('classifies bisync critical error', () {
        final result = classifier.classify(
          'ERROR: Bisync critical error: can\'t resolve differences',
        );
        expect(result.category, RcloneErrorCategory.bisyncConflict);
      });

      test('classifies bisync aborted', () {
        final result = classifier.classify(
          'bisync aborted. Must run --resync to recover.',
        );
        expect(result.category, RcloneErrorCategory.bisyncConflict);
        expect(result.suggestion, contains('resync'));
      });

      test('classifies files changed on both sides', () {
        final result = classifier.classify(
          'ERROR: files changed on both sides: document.docx',
        );
        expect(result.category, RcloneErrorCategory.bisyncConflict);
      });
    });

    group('missing path errors', () {
      test('classifies directory not found', () {
        final result = classifier.classify(
          'directory not found: /home/user/nonexistent',
        );
        expect(result.category, RcloneErrorCategory.missingPath);
        expect(result.userMessage, contains('does not exist'));
      });

      test('classifies no such file or directory', () {
        final result = classifier.classify(
          'lstat /tmp/gone: no such file or directory',
        );
        expect(result.category, RcloneErrorCategory.missingPath);
      });

      test("classifies doesn't exist", () {
        final result = classifier.classify(
          "Failed to sync: source doesn't exist",
        );
        expect(result.category, RcloneErrorCategory.missingPath);
      });

      test('classifies failed to list', () {
        final result = classifier.classify(
          'Failed to list: path/to/remote',
        );
        expect(result.category, RcloneErrorCategory.missingPath);
      });
    });

    group('rate limit errors', () {
      test('classifies rate limit exceeded', () {
        final result = classifier.classify(
          'googleapi: Error 403: User rate limit exceeded.',
        );
        expect(result.category, RcloneErrorCategory.rateLimited);
        expect(result.userMessage, contains('rate-limiting'));
      });

      test('classifies 429 too many requests', () {
        final result = classifier.classify(
          'HTTP Error: 429 Too Many Requests',
        );
        expect(result.category, RcloneErrorCategory.rateLimited);
      });
    });

    group('unknown errors', () {
      test('classifies unrecognized error as unknown', () {
        final result = classifier.classify(
          'some completely unknown rclone error xyz123',
        );
        expect(result.category, RcloneErrorCategory.unknown);
        expect(result.userMessage, contains('unexpected'));
      });

      test('preserves raw error in all cases', () {
        const raw = 'very specific error message 12345';
        final result = classifier.classify(raw);
        expect(result.rawError, raw);
      });
    });

    group('priority ordering', () {
      test('auth takes priority over permission for access denied', () {
        // "access denied" appears in auth patterns
        final result = classifier.classify('access denied');
        expect(result.category, RcloneErrorCategory.authExpired);
      });

      test('bisync conflict takes priority over generic not found', () {
        // message contains both "bisync conflict" and could match other patterns
        final result = classifier.classify(
          'bisync conflict detected: file not found on remote',
        );
        expect(result.category, RcloneErrorCategory.bisyncConflict);
      });
    });
  });
}
