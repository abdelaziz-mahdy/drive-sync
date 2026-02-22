import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/sync_history_entry.dart';
import 'package:drive_sync/models/sync_job.dart';
import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/providers/profiles_provider.dart';
import 'package:drive_sync/providers/sync_history_provider.dart';
import 'package:drive_sync/providers/sync_jobs_provider.dart';
import 'package:drive_sync/screens/activity/activity_screen.dart';

void main() {
  group('ActivityScreen', () {
    testWidgets('shows empty states when no jobs and no history',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncJobsProvider.overrideWith(() => _EmptySyncJobsNotifier()),
            syncHistoryProvider
                .overrideWith(() => _EmptySyncHistoryNotifier()),
            profilesProvider.overrideWith(() => _EmptyProfilesNotifier()),
          ],
          child: const MaterialApp(home: ActivityScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Syncs'), findsOneWidget);
      expect(find.text('No active syncs'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('No sync history yet'), findsOneWidget);
    });

    testWidgets('shows running job card when job exists', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncJobsProvider.overrideWith(() => _RunningJobNotifier()),
            syncHistoryProvider
                .overrideWith(() => _EmptySyncHistoryNotifier()),
            profilesProvider
                .overrideWith(() => _SingleProfileNotifier()),
          ],
          child: const MaterialApp(home: ActivityScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No active syncs'), findsNothing);
      expect(find.text('Test Profile'), findsOneWidget);
    });

    testWidgets('shows history entries', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncJobsProvider.overrideWith(() => _EmptySyncJobsNotifier()),
            syncHistoryProvider
                .overrideWith(() => _WithHistoryNotifier()),
            profilesProvider
                .overrideWith(() => _SingleProfileNotifier()),
          ],
          child: const MaterialApp(home: ActivityScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No sync history yet'), findsNothing);
      expect(find.text('Test Profile'), findsOneWidget);
    });
  });
}

// --- Test notifiers ---

class _EmptySyncJobsNotifier extends SyncJobsNotifier {
  @override
  Map<String, SyncJob> build() => {};
}

class _RunningJobNotifier extends SyncJobsNotifier {
  @override
  Map<String, SyncJob> build() => {
        'profile-1': SyncJob(
          jobId: 1,
          profileId: 'profile-1',
          status: SyncJobStatus.running,
          bytesTransferred: 500,
          totalBytes: 1000,
          filesTransferred: 5,
          speed: 1024 * 1024 * 2.3,
          startTime: DateTime.now(),
        ),
      };
}

class _EmptySyncHistoryNotifier extends SyncHistoryNotifier {
  @override
  Future<List<SyncHistoryEntry>> build() async => [];
}

class _WithHistoryNotifier extends SyncHistoryNotifier {
  @override
  Future<List<SyncHistoryEntry>> build() async => [
        SyncHistoryEntry(
          profileId: 'profile-1',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          status: 'success',
          filesTransferred: 10,
          bytesTransferred: 1024 * 1024,
          duration: const Duration(seconds: 45),
        ),
      ];
}

class _EmptyProfilesNotifier extends ProfilesNotifier {
  @override
  Future<List<SyncProfile>> build() async => [];
}

class _SingleProfileNotifier extends ProfilesNotifier {
  @override
  Future<List<SyncProfile>> build() async => [
        SyncProfile(
          id: 'profile-1',
          name: 'Test Profile',
          remoteName: 'gdrive',
          cloudFolder: '/sync',
          localPaths: ['/home/user/sync'],
          includeTypes: [],
          excludeTypes: [],
          useIncludeMode: true,
          syncMode: SyncMode.backup,
          scheduleMinutes: 30,
          enabled: true,
          respectGitignore: false,
          excludeGitDirs: false,
          customExcludes: [],
        ),
      ];
}
