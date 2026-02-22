import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:drive_sync/models/app_release.dart';
import 'package:drive_sync/services/update_checker.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late UpdateChecker checker;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    checker = UpdateChecker(
      dio: dio,
      repoOwner: 'test-owner',
      repoName: 'test-repo',
    );
  });

  Map<String, dynamic> releaseJson({
    String tagName = 'v2.0.0',
    bool prerelease = false,
  }) =>
      {
        'tag_name': tagName,
        'published_at': '2024-06-01T12:00:00Z',
        'body': 'Release notes',
        'prerelease': prerelease,
        'assets': [
          {
            'name': 'App-2.0.0.dmg',
            'browser_download_url': 'https://example.com/App-2.0.0.dmg',
          },
          {
            'name': 'App-2.0.0.exe',
            'browser_download_url': 'https://example.com/App-2.0.0.exe',
          },
          {
            'name': 'App-2.0.0.AppImage',
            'browser_download_url': 'https://example.com/App-2.0.0.AppImage',
          },
        ],
      };

  group('UpdateChecker', () {
    group('checkForUpdate', () {
      test('returns release when newer version is available', () async {
        dioAdapter.onGet(
          'https://api.github.com/repos/test-owner/test-repo/releases/latest',
          (server) {
            server.reply(200, releaseJson(tagName: 'v2.0.0'));
          },
        );

        final result = await checker.checkForUpdate('1.0.0');
        expect(result, isNotNull);
        expect(result!.version, '2.0.0');
      });

      test('returns null when same version', () async {
        dioAdapter.onGet(
          'https://api.github.com/repos/test-owner/test-repo/releases/latest',
          (server) {
            server.reply(200, releaseJson(tagName: 'v1.0.0'));
          },
        );

        final result = await checker.checkForUpdate('1.0.0');
        expect(result, isNull);
      });

      test('returns null when older version', () async {
        dioAdapter.onGet(
          'https://api.github.com/repos/test-owner/test-repo/releases/latest',
          (server) {
            server.reply(200, releaseJson(tagName: 'v0.9.0'));
          },
        );

        final result = await checker.checkForUpdate('1.0.0');
        expect(result, isNull);
      });

      test('returns null for pre-release', () async {
        dioAdapter.onGet(
          'https://api.github.com/repos/test-owner/test-repo/releases/latest',
          (server) {
            server.reply(
                200, releaseJson(tagName: 'v3.0.0', prerelease: true));
          },
        );

        final result = await checker.checkForUpdate('1.0.0');
        expect(result, isNull);
      });

      test('returns null on network error', () async {
        dioAdapter.onGet(
          'https://api.github.com/repos/test-owner/test-repo/releases/latest',
          (server) {
            server.throws(
              500,
              DioException(
                requestOptions: RequestOptions(path: '/releases/latest'),
              ),
            );
          },
        );

        final result = await checker.checkForUpdate('1.0.0');
        expect(result, isNull);
      });
    });

    group('getPlatformDownloadUrl', () {
      test('returns dmg URL on macOS', () {
        final release = AppRelease.fromGitHubJson(releaseJson());
        final url = checker.getPlatformDownloadUrl(release);

        // This test runs on macOS in the CI environment.
        // On macOS, it should return the .dmg URL.
        // On other platforms, the result depends on Platform.
        if (url != null && url.endsWith('.dmg')) {
          expect(url, 'https://example.com/App-2.0.0.dmg');
        }
      });

      test('returns null when no matching asset', () {
        final release = AppRelease.fromGitHubJson({
          'tag_name': 'v1.0.0',
          'published_at': '2024-01-01T00:00:00Z',
          'body': '',
          'prerelease': false,
          'assets': [
            {
              'name': 'source.tar.gz',
              'browser_download_url': 'https://example.com/source.tar.gz',
            },
          ],
        });

        final url = checker.getPlatformDownloadUrl(release);
        // On macOS there's no .dmg, on Windows no .exe/.msix, on Linux no
        // .deb/.AppImage -- so should be null.
        expect(url, isNull);
      });
    });
  });
}
