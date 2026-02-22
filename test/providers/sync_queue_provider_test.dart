import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/sync_job.dart';
import 'package:drive_sync/models/sync_queue_entry.dart';
import 'package:drive_sync/providers/sync_queue_provider.dart';

void main() {
  group('SyncQueueState', () {
    test('isIdle returns true when queue empty and no active job', () {
      const state = SyncQueueState();
      expect(state.isIdle, true);
    });

    test('isIdle returns false when queue has entries', () {
      final state = SyncQueueState(
        queue: [
          SyncQueueEntry(profileId: 'p1', enqueuedAt: DateTime.now()),
        ],
      );
      expect(state.isIdle, false);
    });

    test('isIdle returns false when there is an active job', () {
      final state = SyncQueueState(
        activeJob: SyncJob(
          jobId: 1,
          profileId: 'p1',
          status: SyncJobStatus.running,
          bytesTransferred: 0,
          totalBytes: 0,
          filesTransferred: 0,
          speed: 0,
          startTime: DateTime.now(),
        ),
      );
      expect(state.isIdle, false);
    });

    test('hasActiveJob returns true for running job', () {
      final state = SyncQueueState(
        activeJob: SyncJob(
          jobId: 1,
          profileId: 'p1',
          status: SyncJobStatus.running,
          bytesTransferred: 0,
          totalBytes: 0,
          filesTransferred: 0,
          speed: 0,
          startTime: DateTime.now(),
        ),
      );
      expect(state.hasActiveJob, true);
    });

    test('hasActiveJob returns true for queued job', () {
      final state = SyncQueueState(
        activeJob: SyncJob(
          jobId: -1,
          profileId: 'p1',
          status: SyncJobStatus.queued,
          bytesTransferred: 0,
          totalBytes: 0,
          filesTransferred: 0,
          speed: 0,
          startTime: DateTime.now(),
        ),
      );
      expect(state.hasActiveJob, true);
    });

    test('hasActiveJob returns false for finished job', () {
      final state = SyncQueueState(
        activeJob: SyncJob(
          jobId: 1,
          profileId: 'p1',
          status: SyncJobStatus.finished,
          bytesTransferred: 100,
          totalBytes: 100,
          filesTransferred: 5,
          speed: 0,
          startTime: DateTime.now(),
        ),
      );
      expect(state.hasActiveJob, false);
    });

    test('hasActiveJob returns false when no active job', () {
      const state = SyncQueueState();
      expect(state.hasActiveJob, false);
    });

    test('isQueued returns true for queued profile', () {
      final state = SyncQueueState(
        queue: [
          SyncQueueEntry(profileId: 'p1', enqueuedAt: DateTime.now()),
          SyncQueueEntry(profileId: 'p2', enqueuedAt: DateTime.now()),
        ],
      );
      expect(state.isQueued('p1'), true);
      expect(state.isQueued('p2'), true);
      expect(state.isQueued('p3'), false);
    });

    test('isRunning returns true for the active running profile', () {
      final state = SyncQueueState(
        activeJob: SyncJob(
          jobId: 1,
          profileId: 'p1',
          status: SyncJobStatus.running,
          bytesTransferred: 0,
          totalBytes: 0,
          filesTransferred: 0,
          speed: 0,
          startTime: DateTime.now(),
        ),
      );
      expect(state.isRunning('p1'), true);
      expect(state.isRunning('p2'), false);
    });

    test('isActiveOrQueued returns true for running or queued profiles', () {
      final state = SyncQueueState(
        queue: [
          SyncQueueEntry(profileId: 'p2', enqueuedAt: DateTime.now()),
        ],
        activeJob: SyncJob(
          jobId: 1,
          profileId: 'p1',
          status: SyncJobStatus.running,
          bytesTransferred: 0,
          totalBytes: 0,
          filesTransferred: 0,
          speed: 0,
          startTime: DateTime.now(),
        ),
      );
      expect(state.isActiveOrQueued('p1'), true);
      expect(state.isActiveOrQueued('p2'), true);
      expect(state.isActiveOrQueued('p3'), false);
    });

    test('queuePositionOf returns 1-based position', () {
      final state = SyncQueueState(
        queue: [
          SyncQueueEntry(profileId: 'p1', enqueuedAt: DateTime.now()),
          SyncQueueEntry(profileId: 'p2', enqueuedAt: DateTime.now()),
          SyncQueueEntry(profileId: 'p3', enqueuedAt: DateTime.now()),
        ],
      );
      expect(state.queuePositionOf('p1'), 1);
      expect(state.queuePositionOf('p2'), 2);
      expect(state.queuePositionOf('p3'), 3);
      expect(state.queuePositionOf('p4'), -1);
    });

    test('copyWith replaces fields correctly', () {
      final original = SyncQueueState(
        queue: [
          SyncQueueEntry(profileId: 'p1', enqueuedAt: DateTime.now()),
        ],
        activeJob: SyncJob(
          jobId: 1,
          profileId: 'p1',
          status: SyncJobStatus.running,
          bytesTransferred: 0,
          totalBytes: 0,
          filesTransferred: 0,
          speed: 0,
          startTime: DateTime.now(),
        ),
      );

      final cleared = original.copyWith(clearActiveJob: true);
      expect(cleared.activeJob, isNull);
      expect(cleared.queue.length, 1);

      final newQueue = original.copyWith(queue: []);
      expect(newQueue.queue, isEmpty);
      expect(newQueue.activeJob, isNotNull);
    });
  });

  group('SyncJobStatus', () {
    test('queued value exists', () {
      expect(SyncJobStatus.queued, isNotNull);
      expect(SyncJobStatus.queued.index, 0);
    });

    test('isQueued getter works', () {
      final job = SyncJob(
        jobId: -1,
        profileId: 'p1',
        status: SyncJobStatus.queued,
        bytesTransferred: 0,
        totalBytes: 0,
        filesTransferred: 0,
        speed: 0,
        startTime: DateTime.now(),
      );
      expect(job.isQueued, true);
      expect(job.isRunning, false);
    });
  });
}
