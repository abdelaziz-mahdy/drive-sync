import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:talker/talker.dart';

import 'package:drive_sync/models/sync_job.dart';
import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_preview.dart';
import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/services/gitignore_service.dart';
import 'package:drive_sync/services/rclone_service.dart';
import 'package:drive_sync/services/sync_executor.dart';

/// A fake GitignoreService that returns canned filter rules without
/// touching the file system.
class FakeGitignoreService extends GitignoreService {
  final List<String> filterRules;
  bool generateCalled = false;

  FakeGitignoreService({this.filterRules = const []});

  @override
  Future<List<String>> generateRcloneFilters(String rootPath) async {
    generateCalled = true;
    return filterRules;
  }
}

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late RcloneService rcloneService;
  late FakeGitignoreService gitignoreService;
  late SyncExecutor executor;

  SyncProfile testProfile({
    bool respectGitignore = false,
    SyncMode syncMode = SyncMode.backup,
  }) =>
      SyncProfile(
        id: 'test-id',
        name: 'Test Profile',
        remoteName: 'gdrive',
        cloudFolder: 'Documents',
        localPaths: ['/home/user/docs'],
        includeTypes: const [],
        excludeTypes: const [],
        useIncludeMode: false,
        syncMode: syncMode,
        scheduleMinutes: 30,
        enabled: true,
        respectGitignore: respectGitignore,
        excludeGitDirs: false,
        customExcludes: const [],
      );

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:5572'));
    dioAdapter = DioAdapter(dio: dio);
    rcloneService = RcloneService.withDio(dio);
    gitignoreService = FakeGitignoreService(
      filterRules: ['- node_modules/**', '- .git/**'],
    );
    executor = SyncExecutor(
      rcloneService: rcloneService,
      gitignoreService: gitignoreService,
      talker: Talker(),
      pollInterval: Duration.zero, // no delay in tests
    );
  });

  /// Helper: set up mocks for a complete sync flow that finishes after
  /// [pollCount] polls (first poll-1 return running, last returns finished).
  void mockSyncFlow({
    required SyncProfile profile,
    int jobId = 42,
    int pollCount = 2,
    bool success = true,
    String? error,
    bool dryRun = false,
    List<Map<String, dynamic>>? completedTransfers,
  }) {
    // startSync
    dioAdapter.onPost(
      profile.syncMode.rcEndpoint,
      (server) => server.reply(200, {'jobid': jobId}),
      data: Matchers.any,
    );

    // Job status polls: first (pollCount - 1) return running, last finished.
    for (var i = 0; i < pollCount; i++) {
      final isLast = i == pollCount - 1;
      dioAdapter.onPost(
        '/job/status',
        (server) => server.reply(200, {
          'jobid': jobId,
          'finished': isLast,
          'success': isLast ? success : false,
          if (isLast && error != null) 'error': error,
          'startTime': '2025-01-01T00:00:00Z',
          if (isLast) 'endTime': '2025-01-01T00:05:00Z',
        }),
        data: {'jobid': jobId},
      );
    }

    // Transfer stats (called once per poll).
    for (var i = 0; i < pollCount; i++) {
      dioAdapter.onPost(
        '/core/stats',
        (server) => server.reply(200, {
          'bytes': (i + 1) * 512,
          'totalBytes': 2048,
          'transfers': i + 1,
          'speed': 256.0,
        }),
        data: {'group': 'job/$jobId'},
      );
    }

    // Completed transfers (for dry run).
    if (dryRun) {
      dioAdapter.onPost(
        '/core/transferred',
        (server) => server.reply(200, {
          'transferred': completedTransfers ??
              [
                {
                  'name': 'file1.txt',
                  'size': 100,
                  'completed_at': '2025-01-01T00:00:00Z'
                },
                {
                  'name': 'file2.txt',
                  'size': 200,
                  'completed_at': '2025-01-01T00:00:00Z'
                },
              ],
        }),
        data: {'group': 'job/$jobId'},
      );
    }
  }

  group('SyncExecutor', () {
    group('executeSync', () {
      test('starts sync, polls status, and returns completed job', () async {
        final profile = testProfile();
        mockSyncFlow(profile: profile, pollCount: 2);

        final job = await executor.executeSync(profile);

        expect(job.jobId, 42);
        expect(job.status, SyncJobStatus.finished);
        expect(job.bytesTransferred, greaterThan(0));
        expect(job.endTime, isNotNull);
      });

      test('with dryRun collects transfers and builds preview', () async {
        final profile = testProfile();
        SyncPreview? receivedPreview;

        mockSyncFlow(profile: profile, pollCount: 1, dryRun: true);

        final job = await executor.executeSync(
          profile,
          dryRun: true,
          onDryRunComplete: (preview) => receivedPreview = preview,
        );

        expect(job.status, SyncJobStatus.finished);
        expect(receivedPreview, isNotNull);
        expect(receivedPreview!.profileId, 'test-id');
        expect(receivedPreview!.filesToAdd.length, 2);
        expect(receivedPreview!.filesToAdd[0].path, 'file1.txt');
        expect(receivedPreview!.filesToUpdate, isEmpty);
        expect(receivedPreview!.filesToDelete, isEmpty);
      });

      test('respects gitignore flag on profile', () async {
        final profile = testProfile(respectGitignore: true);
        mockSyncFlow(profile: profile, pollCount: 1);

        await executor.executeSync(profile);

        expect(gitignoreService.generateCalled, isTrue);
      });

      test('does not call gitignore when respectGitignore is false', () async {
        final profile = testProfile(respectGitignore: false);
        mockSyncFlow(profile: profile, pollCount: 1);

        await executor.executeSync(profile);

        expect(gitignoreService.generateCalled, isFalse);
      });

      test('progress callback is invoked during polling', () async {
        final profile = testProfile();
        mockSyncFlow(profile: profile, pollCount: 2);

        final progressUpdates = <SyncJob>[];

        await executor.executeSync(
          profile,
          onProgress: (job) => progressUpdates.add(job),
        );

        // We expect at least 2 updates: the initial + poll updates.
        expect(progressUpdates.length, greaterThanOrEqualTo(2));
        // First is the initial running state.
        expect(progressUpdates[0].status, SyncJobStatus.running);
        expect(progressUpdates[0].bytesTransferred, 0);
        // Last is the finished state.
        expect(progressUpdates.last.status, SyncJobStatus.finished);
      });

      test('handles job error gracefully', () async {
        final profile = testProfile();
        mockSyncFlow(
          profile: profile,
          pollCount: 1,
          success: false,
          error: 'permission denied',
        );

        final job = await executor.executeSync(profile);

        expect(job.status, SyncJobStatus.error);
        // Error is now classified into a user-friendly message
        expect(job.error, contains('Permission'));
        expect(job.endTime, isNotNull);
      });

      test('does not call onDryRunComplete when job errors', () async {
        final profile = testProfile();
        bool dryRunCallbackCalled = false;
        mockSyncFlow(
          profile: profile,
          pollCount: 1,
          dryRun: true,
          success: false,
          error: 'connection refused to remote server',
        );

        await executor.executeSync(
          profile,
          dryRun: true,
          onDryRunComplete: (_) => dryRunCallbackCalled = true,
        );

        expect(dryRunCallbackCalled, isFalse);
      });
    });

    group('error classification integration', () {
      test('classifies auth errors with user-friendly message', () async {
        final profile = testProfile();
        mockSyncFlow(
          profile: profile,
          pollCount: 1,
          success: false,
          error: 'googleapi: Error 401: Token has been expired or revoked',
        );

        final job = await executor.executeSync(profile);

        expect(job.status, SyncJobStatus.error);
        expect(job.error, contains('expired'));
        expect(job.error, contains('Re-authorize'));
      });

      test('classifies bisync conflict errors', () async {
        final profile = testProfile(syncMode: SyncMode.bisync);
        mockSyncFlow(
          profile: profile,
          pollCount: 1,
          success: false,
          error: 'bisync critical error: files changed on both sides',
        );

        final job = await executor.executeSync(profile);

        expect(job.status, SyncJobStatus.error);
        expect(job.error, contains('conflict'));
      });

      test('classifies disk full errors', () async {
        final profile = testProfile();
        mockSyncFlow(
          profile: profile,
          pollCount: 1,
          success: false,
          error: 'write /home/user/file.zip: no space left on device',
        );

        final job = await executor.executeSync(profile);

        expect(job.status, SyncJobStatus.error);
        expect(job.error, contains('full'));
        expect(job.error, contains('Free up'));
      });

      test('classifies missing path errors', () async {
        final profile = testProfile();
        mockSyncFlow(
          profile: profile,
          pollCount: 1,
          success: false,
          error: 'directory not found: /home/user/nonexistent',
        );

        final job = await executor.executeSync(profile);

        expect(job.status, SyncJobStatus.error);
        expect(job.error, contains('does not exist'));
      });

      test('classifies network errors from rclone', () async {
        final profile = testProfile();
        mockSyncFlow(
          profile: profile,
          pollCount: 1,
          success: false,
          error: 'dial tcp: connection refused',
        );

        final job = await executor.executeSync(profile);

        expect(job.status, SyncJobStatus.error);
        expect(job.error, contains('Network'));
      });

      test('classifies unknown errors gracefully', () async {
        final profile = testProfile();
        mockSyncFlow(
          profile: profile,
          pollCount: 1,
          success: false,
          error: 'some completely unknown error xyz',
        );

        final job = await executor.executeSync(profile);

        expect(job.status, SyncJobStatus.error);
        expect(job.error, contains('unexpected'));
      });
    });

    group('stopSync', () {
      test('calls rclone stopJob', () async {
        dioAdapter.onPost(
          '/job/stop',
          (server) => server.reply(200, {}),
          data: {'jobid': 42},
        );

        // Should not throw.
        await executor.stopSync(42);
      });
    });
  });
}
