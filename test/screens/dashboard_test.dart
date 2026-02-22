import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/providers/database_provider.dart';
import 'package:drive_sync/providers/profiles_provider.dart';
import 'package:drive_sync/screens/dashboard/dashboard_screen.dart';
import 'package:drive_sync/screens/dashboard/profile_card.dart';

import '../database/test_database.dart';

class TestProfilesNotifier extends ProfilesNotifier {
  final List<SyncProfile> _profiles;

  TestProfilesNotifier(this._profiles);

  @override
  Future<List<SyncProfile>> build() async => _profiles;
}

void main() {
  group('ProfileCard', () {
    late SyncProfile testProfile;

    setUp(() {
      testProfile = SyncProfile(
        id: 'test-1',
        name: 'Work Documents',
        remoteName: 'gdrive',
        cloudFolder: '/work',
        localPaths: ['/home/user/work'],
        includeTypes: const [],
        excludeTypes: const [],
        useIncludeMode: false,
        syncMode: SyncMode.backup,
        scheduleMinutes: 30,
        enabled: true,
        respectGitignore: false,
        excludeGitDirs: true,
        customExcludes: const [],
        lastSyncTime: DateTime.now().subtract(const Duration(hours: 2)),
        lastSyncStatus: 'success',
      );
    });

    testWidgets('renders profile name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 350,
                child: ProfileCard(profile: testProfile),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Work Documents'), findsOneWidget);
    });

    testWidgets('renders sync mode label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 350,
                child: ProfileCard(profile: testProfile),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Backup'), findsOneWidget);
    });

    testWidgets('renders source and destination paths', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 350,
                child: ProfileCard(profile: testProfile),
              ),
            ),
          ),
        ),
      );

      expect(find.text('/home/user/work'), findsOneWidget);
      expect(find.text('gdrive:/work'), findsOneWidget);
    });

    testWidgets('renders last sync time', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 350,
                child: ProfileCard(profile: testProfile),
              ),
            ),
          ),
        ),
      );

      expect(find.text('2 hours ago'), findsOneWidget);
    });

    testWidgets('renders "Never synced" when no last sync time',
        (tester) async {
      const neverSyncedProfile = SyncProfile(
        id: 'test-never',
        name: 'Never Synced',
        remoteName: 'gdrive',
        cloudFolder: '/test',
        localPaths: ['/home/user/test'],
        includeTypes: [],
        excludeTypes: [],
        useIncludeMode: false,
        syncMode: SyncMode.backup,
        scheduleMinutes: 30,
        enabled: true,
        respectGitignore: false,
        excludeGitDirs: true,
        customExcludes: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 350,
                child: ProfileCard(profile: neverSyncedProfile),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Never synced'), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 350,
                child: ProfileCard(profile: testProfile),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sync Now'), findsOneWidget);
      expect(find.text('Dry Run'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });
  });

  group('DashboardScreen', () {
    testWidgets('shows empty state when no profiles', (tester) async {
      final db = createTestDatabase();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            profilesProvider.overrideWith(() => TestProfilesNotifier([])),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Sync Profiles'), findsOneWidget);
      expect(
          find.text('Create your first sync profile'), findsOneWidget);

      await db.close();
    });

    testWidgets('shows profile cards when profiles exist', (tester) async {
      final profiles = [
        const SyncProfile(
          id: 'test-1',
          name: 'Work Docs',
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
      ];
      final db = createTestDatabase();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            profilesProvider
                .overrideWith(() => TestProfilesNotifier(profiles)),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Work Docs'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);

      await db.close();
    });
  });
}
