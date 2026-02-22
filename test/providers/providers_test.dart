import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/providers/sync_jobs_provider.dart';
import 'package:drive_sync/providers/theme_provider.dart';
import 'package:drive_sync/providers/app_config_provider.dart';
import 'package:drive_sync/models/sync_job.dart';
import 'package:drive_sync/models/app_config.dart';
import 'package:flutter/material.dart';

void main() {
  group('SyncJobsNotifier', () {
    test('starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final jobs = container.read(syncJobsProvider);
      expect(jobs, isEmpty);
    });

    test('addJob adds a job', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(syncJobsProvider.notifier);
      final job = SyncJob(
        jobId: 1,
        profileId: 'p1',
        status: SyncJobStatus.running,
        bytesTransferred: 0,
        totalBytes: 100,
        filesTransferred: 0,
        speed: 0.0,
        startTime: DateTime.now(),
      );
      notifier.addJob(job);
      expect(container.read(syncJobsProvider).length, 1);
      expect(container.read(syncJobsProvider)['p1']?.jobId, 1);
    });

    test('removeJob removes a job', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(syncJobsProvider.notifier);
      notifier.addJob(SyncJob(
        jobId: 1,
        profileId: 'p1',
        status: SyncJobStatus.running,
        bytesTransferred: 0,
        totalBytes: 100,
        filesTransferred: 0,
        speed: 0.0,
        startTime: DateTime.now(),
      ));
      notifier.removeJob('p1');
      expect(container.read(syncJobsProvider), isEmpty);
    });

    test('hasRunningJob returns correct value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(syncJobsProvider.notifier);
      expect(notifier.hasRunningJob('p1'), false);
      notifier.addJob(SyncJob(
        jobId: 1,
        profileId: 'p1',
        status: SyncJobStatus.running,
        bytesTransferred: 0,
        totalBytes: 100,
        filesTransferred: 0,
        speed: 0.0,
        startTime: DateTime.now(),
      ));
      expect(notifier.hasRunningJob('p1'), true);
    });

    test('hasAnyRunningJobs tracks running state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(syncJobsProvider.notifier);
      expect(notifier.hasAnyRunningJobs, false);
      notifier.addJob(SyncJob(
        jobId: 1,
        profileId: 'p1',
        status: SyncJobStatus.running,
        bytesTransferred: 0,
        totalBytes: 100,
        filesTransferred: 0,
        speed: 0.0,
        startTime: DateTime.now(),
      ));
      expect(notifier.hasAnyRunningJobs, true);
    });

    test('updateJob replaces a job', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(syncJobsProvider.notifier);
      notifier.addJob(SyncJob(
        jobId: 1,
        profileId: 'p1',
        status: SyncJobStatus.running,
        bytesTransferred: 0,
        totalBytes: 100,
        filesTransferred: 0,
        speed: 0.0,
        startTime: DateTime.now(),
      ));
      notifier.updateJob(
        'p1',
        SyncJob(
          jobId: 1,
          profileId: 'p1',
          status: SyncJobStatus.finished,
          bytesTransferred: 100,
          totalBytes: 100,
          filesTransferred: 5,
          speed: 1000.0,
          startTime: DateTime.now(),
        ),
      );
      expect(
        container.read(syncJobsProvider)['p1']?.status,
        SyncJobStatus.finished,
      );
    });
  });

  group('themeModeProvider', () {
    test('defaults to system when config not loaded', () {
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWith(() => _MockAppConfigNotifier()),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(themeModeProvider), ThemeMode.system);
    });
  });
}

// Simple mock that returns defaults
class _MockAppConfigNotifier extends AppConfigNotifier {
  @override
  Future<AppConfig> build() async => AppConfig.defaults();
}
