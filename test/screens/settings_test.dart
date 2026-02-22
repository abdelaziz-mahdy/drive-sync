import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/app_config.dart';
import 'package:drive_sync/providers/app_config_provider.dart';
import 'package:drive_sync/providers/rclone_provider.dart';
import 'package:drive_sync/providers/update_provider.dart';
import 'package:drive_sync/screens/settings/settings_screen.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders three sections', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
            daemonHealthProvider.overrideWith((ref) => Stream.value(true)),
            updateAvailableProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('General'), findsOneWidget);
      expect(find.text('Rclone'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('shows theme segmented button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
            daemonHealthProvider.overrideWith((ref) => Stream.value(true)),
            updateAvailableProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('shows toggle switches', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
            daemonHealthProvider.overrideWith((ref) => Stream.value(false)),
            updateAvailableProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Launch at login'), findsOneWidget);
      expect(find.text('Show in menu bar'), findsOneWidget);
      expect(find.text('Show notifications'), findsOneWidget);
    });

    testWidgets('shows rclone connection status', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
            daemonHealthProvider.overrideWith((ref) => Stream.value(true)),
            updateAvailableProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Connected'), findsOneWidget);
    });

    testWidgets('shows app version', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider
                .overrideWith(() => _TestAppConfigNotifier()),
            daemonHealthProvider.overrideWith((ref) => Stream.value(true)),
            updateAvailableProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0.1.0'), findsOneWidget);
    });
  });
}

class _TestAppConfigNotifier extends AppConfigNotifier {
  @override
  Future<AppConfig> build() async => AppConfig.defaults();
}
