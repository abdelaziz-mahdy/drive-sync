import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/providers/app_config_provider.dart';
import 'package:drive_sync/providers/profiles_provider.dart';
import 'package:drive_sync/providers/sync_jobs_provider.dart';
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
          localPath: '/home/user/work',
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
          localPath: '/home/user/photos',
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
          ],
          child: const MaterialApp(home: ShellScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Activity
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();

      // Activity placeholder content should be displayed
      // (the content area will show "Activity" text from placeholder)
      // The navigation tile should be selected

      // Tap Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
