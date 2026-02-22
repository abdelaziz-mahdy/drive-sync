import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/app_config.dart';
import 'package:drive_sync/models/app_release.dart';
import 'package:drive_sync/providers/app_config_provider.dart';
import 'package:drive_sync/screens/update/update_dialog.dart';

void main() {
  group('UpdateDialog', () {
    final testRelease = AppRelease(
      version: '1.2.0',
      tagName: 'v1.2.0',
      publishedAt: DateTime(2025, 6, 15),
      changelog: '## Changes\n- New feature A\n- Bug fix B',
      downloadUrls: {
        'DriveSync-1.2.0.dmg': 'https://example.com/download.dmg',
        'DriveSync-1.2.0.exe': 'https://example.com/download.exe',
      },
      isPreRelease: false,
    );

    testWidgets('shows version comparison', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: UpdateDialog(
                    release: testRelease,
                    currentVersion: '0.1.0',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Update Available'), findsOneWidget);
      expect(find.text('v0.1.0'), findsOneWidget);
      expect(find.text('v1.2.0'), findsOneWidget);
    });

    testWidgets('shows changelog content', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: UpdateDialog(
                    release: testRelease,
                    currentVersion: '0.1.0',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Markdown renders the list items
      expect(find.textContaining('New feature A'), findsOneWidget);
      expect(find.textContaining('Bug fix B'), findsOneWidget);
    });

    testWidgets('shows empty changelog message', (tester) async {
      final emptyRelease = AppRelease(
        version: '1.2.0',
        tagName: 'v1.2.0',
        publishedAt: DateTime(2025, 6, 15),
        changelog: '',
        downloadUrls: {},
        isPreRelease: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: UpdateDialog(
                  release: emptyRelease,
                  currentVersion: '0.1.0',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No changelog available'), findsOneWidget);
    });

    testWidgets('shows action buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: UpdateDialog(
                  release: testRelease,
                  currentVersion: '0.1.0',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Remind Me Later'), findsOneWidget);
      expect(find.text('Skip This Version'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
    });

    testWidgets('Remind Me Later dismisses dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ProviderScope(
                        overrides: [
                          appConfigProvider
                              .overrideWith(() => _TestAppConfigNotifier()),
                        ],
                        child: UpdateDialog(
                          release: testRelease,
                          currentVersion: '0.1.0',
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Update Available'), findsOneWidget);

      await tester.tap(find.text('Remind Me Later'));
      await tester.pumpAndSettle();

      expect(find.text('Update Available'), findsNothing);
    });
  });
}

class _TestAppConfigNotifier extends AppConfigNotifier {
  @override
  Future<AppConfig> build() async => AppConfig.defaults();
}
