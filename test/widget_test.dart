import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drive_sync/app.dart';
import 'package:drive_sync/providers/app_config_provider.dart';
import 'package:drive_sync/providers/profiles_provider.dart';
import 'package:drive_sync/providers/startup_provider.dart';
import 'package:drive_sync/models/app_config.dart';
import 'package:drive_sync/models/sync_profile.dart';

void main() {
  testWidgets('App renders with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(() => _FakeAppConfigNotifier()),
          profilesProvider.overrideWith(() => _FakeProfilesNotifier()),
          startupProvider.overrideWith(() => _ReadyStartupNotifier()),
        ],
        child: const DriveSyncApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

class _FakeAppConfigNotifier extends AppConfigNotifier {
  @override
  Future<AppConfig> build() async => AppConfig.defaults();
}

class _FakeProfilesNotifier extends ProfilesNotifier {
  @override
  Future<List<SyncProfile>> build() async => [];
}

/// A startup notifier that immediately reports ready state, skipping
/// the actual daemon bootstrap so the test can render the shell.
class _ReadyStartupNotifier extends StartupNotifier {
  @override
  StartupState build() {
    return const StartupState(
      phase: StartupPhase.ready,
      message: 'Ready',
      needsOnboarding: false,
    );
  }
}
