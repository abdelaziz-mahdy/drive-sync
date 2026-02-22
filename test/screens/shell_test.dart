import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/app_config.dart';
import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/providers/app_config_provider.dart';
import 'package:drive_sync/providers/profiles_provider.dart';
import 'package:drive_sync/screens/shell_screen.dart';
import 'package:drive_sync/services/config_store.dart';

class FakeConfigStore extends ConfigStore {
  final List<SyncProfile> _profiles;

  FakeConfigStore.withProfiles(this._profiles)
      : super(appSupportDir: '/tmp/test');

  @override
  Future<List<SyncProfile>> loadProfiles() async => _profiles;
}

class TestProfilesNotifier extends ProfilesNotifier {
  final List<SyncProfile> _profiles;

  TestProfilesNotifier(this._profiles);

  @override
  Future<List<SyncProfile>> build() async => _profiles;
}

class FakeAppConfigNotifier extends AppConfigNotifier {
  @override
  Future<AppConfig> build() async => AppConfig.defaults();
}

void main() {
  group('ShellScreen', () {
    late List<SyncProfile> testProfiles;

    setUp(() {
      testProfiles = [
        const SyncProfile(
          id: 'test-1',
          name: 'Work Documents',
          remoteName: 'gdrive',
          cloudFolder: '/work',
          localPaths: ['/home/user/work'],
          includeTypes: [],
          excludeTypes: [],
          useIncludeMode: false,
          syncMode: SyncMode.backup,
          scheduleMinutes: 30,
          enabled: true,
          respectGitignore: false,
          excludeGitDirs: true,
          customExcludes: [],
        ),
        const SyncProfile(
          id: 'test-2',
          name: 'Photos Backup',
          remoteName: 'gdrive',
          cloudFolder: '/photos',
          localPaths: ['/home/user/photos'],
          includeTypes: [],
          excludeTypes: [],
          useIncludeMode: false,
          syncMode: SyncMode.mirror,
          scheduleMinutes: 60,
          enabled: true,
          respectGitignore: false,
          excludeGitDirs: false,
          customExcludes: [],
        ),
      ];
    });

    testWidgets('renders sidebar navigation items', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final fakeStore = FakeConfigStore.withProfiles(testProfiles);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configStoreProvider.overrideWithValue(fakeStore),
            profilesProvider.overrideWith(() => TestProfilesNotifier(testProfiles)),
          ],
          child: const MaterialApp(home: ShellScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all navigation items are rendered
      // "Dashboard" appears in sidebar nav + appbar title, so findsWidgets
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Verify app title
      expect(find.text('DriveSync'), findsOneWidget);

      // Verify profiles section header
      expect(find.text('PROFILES'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders profile names in sidebar', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final fakeStore = FakeConfigStore.withProfiles(testProfiles);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configStoreProvider.overrideWithValue(fakeStore),
            profilesProvider.overrideWith(() => TestProfilesNotifier(testProfiles)),
          ],
          child: const MaterialApp(home: ShellScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify profile names are rendered (sidebar + dashboard card)
      expect(find.text('Work Documents'), findsWidgets);
      expect(find.text('Photos Backup'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows empty state when no profiles', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final fakeStore = FakeConfigStore.withProfiles([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configStoreProvider.overrideWithValue(fakeStore),
            profilesProvider.overrideWith(() => TestProfilesNotifier([])),
          ],
          child: const MaterialApp(home: ShellScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No profiles yet'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('switches content when navigation item is tapped',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final fakeStore = FakeConfigStore.withProfiles([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            configStoreProvider.overrideWithValue(fakeStore),
            profilesProvider.overrideWith(() => TestProfilesNotifier([])),
            appConfigProvider.overrideWith(() => FakeAppConfigNotifier()),
          ],
          child: const MaterialApp(home: ShellScreen()),
        ),
      );

      // Use pump() instead of pumpAndSettle() because screens contain
      // loading state animations (skeletons, indicators) that never settle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap Activity
      await tester.tap(find.text('Activity'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap Settings
      await tester.tap(find.text('Settings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify the settings screen content area changed
      expect(find.text('General'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
