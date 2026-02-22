import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/app_release.dart';

void main() {
  group('AppRelease', () {
    Map<String, dynamic> sampleGitHubJson() => {
          'tag_name': 'v1.2.3',
          'published_at': '2024-01-15T10:30:00Z',
          'body': '## Changes\n- Fixed bugs\n- Added features',
          'prerelease': false,
          'assets': [
            {
              'name': 'DriveSync-1.2.3-macos.dmg',
              'browser_download_url':
                  'https://example.com/DriveSync-1.2.3-macos.dmg',
            },
            {
              'name': 'DriveSync-1.2.3-windows.exe',
              'browser_download_url':
                  'https://example.com/DriveSync-1.2.3-windows.exe',
            },
            {
              'name': 'DriveSync-1.2.3-linux.AppImage',
              'browser_download_url':
                  'https://example.com/DriveSync-1.2.3-linux.AppImage',
            },
          ],
        };

    group('fromGitHubJson', () {
      test('parses version stripping v prefix', () {
        final release = AppRelease.fromGitHubJson(sampleGitHubJson());
        expect(release.version, '1.2.3');
        expect(release.tagName, 'v1.2.3');
      });

      test('parses published date', () {
        final release = AppRelease.fromGitHubJson(sampleGitHubJson());
        expect(release.publishedAt, DateTime.parse('2024-01-15T10:30:00Z'));
      });

      test('parses changelog from body', () {
        final release = AppRelease.fromGitHubJson(sampleGitHubJson());
        expect(release.changelog, contains('Fixed bugs'));
      });

      test('parses assets as downloadUrls map', () {
        final release = AppRelease.fromGitHubJson(sampleGitHubJson());
        expect(release.downloadUrls.length, 3);
        expect(release.downloadUrls['DriveSync-1.2.3-macos.dmg'],
            'https://example.com/DriveSync-1.2.3-macos.dmg');
      });

      test('parses prerelease flag', () {
        final release = AppRelease.fromGitHubJson(sampleGitHubJson());
        expect(release.isPreRelease, false);

        final preJson = sampleGitHubJson()..['prerelease'] = true;
        final preRelease = AppRelease.fromGitHubJson(preJson);
        expect(preRelease.isPreRelease, true);
      });

      test('handles tag without v prefix', () {
        final json = sampleGitHubJson()..['tag_name'] = '2.0.0';
        final release = AppRelease.fromGitHubJson(json);
        expect(release.version, '2.0.0');
        expect(release.tagName, '2.0.0');
      });

      test('handles empty assets', () {
        final json = sampleGitHubJson()..['assets'] = [];
        final release = AppRelease.fromGitHubJson(json);
        expect(release.downloadUrls, isEmpty);
      });
    });

    group('isNewerThan', () {
      test('newer major version', () {
        final release = AppRelease.fromGitHubJson(
            sampleGitHubJson()..['tag_name'] = 'v2.0.0');
        expect(release.isNewerThan('1.9.9'), true);
      });

      test('newer minor version', () {
        final release = AppRelease.fromGitHubJson(
            sampleGitHubJson()..['tag_name'] = 'v1.3.0');
        expect(release.isNewerThan('1.2.9'), true);
      });

      test('newer patch version', () {
        final release = AppRelease.fromGitHubJson(sampleGitHubJson());
        expect(release.isNewerThan('1.2.2'), true);
      });

      test('same version is not newer', () {
        final release = AppRelease.fromGitHubJson(sampleGitHubJson());
        expect(release.isNewerThan('1.2.3'), false);
      });

      test('older version is not newer', () {
        final release = AppRelease.fromGitHubJson(sampleGitHubJson());
        expect(release.isNewerThan('1.2.4'), false);
        expect(release.isNewerThan('2.0.0'), false);
      });
    });
  });
}
