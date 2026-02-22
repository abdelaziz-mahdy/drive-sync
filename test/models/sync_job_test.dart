import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/sync_job.dart';

void main() {
  group('SyncJobStatus', () {
    test('has 3 values', () {
      expect(SyncJobStatus.values.length, 3);
    });
  });

  group('SyncJob', () {
    test('fromRcResponse parses running job', () {
      final data = {
        'jobid': 42,
        'finished': false,
        'success': true,
        'error': '',
        'startTime': '2024-01-15T10:30:00Z',
        'duration': 5.0,
        'progress': {
          'bytes': 5000,
          'totalBytes': 10000,
          'files': 2,
          'speed': 1000.0,
        },
      };
      final job = SyncJob.fromRcResponse(profileId: 'p1', data: data);
      expect(job.jobId, 42);
      expect(job.profileId, 'p1');
      expect(job.status, SyncJobStatus.running);
      expect(job.bytesTransferred, 5000);
      expect(job.totalBytes, 10000);
      expect(job.filesTransferred, 2);
      expect(job.speed, 1000.0);
      expect(job.isRunning, true);
    });

    test('fromRcResponse parses finished job', () {
      final data = {
        'jobid': 43,
        'finished': true,
        'success': true,
        'error': '',
        'startTime': '2024-01-15T10:30:00Z',
        'endTime': '2024-01-15T10:35:00Z',
        'duration': 300.0,
        'progress': {
          'bytes': 10000,
          'totalBytes': 10000,
          'files': 5,
          'speed': 33.33,
        },
      };
      final job = SyncJob.fromRcResponse(profileId: 'p1', data: data);
      expect(job.status, SyncJobStatus.finished);
      expect(job.isRunning, false);
      expect(job.endTime, isNotNull);
    });

    test('fromRcResponse parses error job', () {
      final data = {
        'jobid': 44,
        'finished': true,
        'success': false,
        'error': 'permission denied',
        'startTime': '2024-01-15T10:30:00Z',
        'endTime': '2024-01-15T10:30:05Z',
        'duration': 5.0,
      };
      final job = SyncJob.fromRcResponse(profileId: 'p1', data: data);
      expect(job.status, SyncJobStatus.error);
      expect(job.error, 'permission denied');
    });

    test('progress calculates correctly', () {
      final job = SyncJob(
        jobId: 1,
        profileId: 'p1',
        status: SyncJobStatus.running,
        bytesTransferred: 250,
        totalBytes: 1000,
        filesTransferred: 1,
        speed: 100,
        startTime: DateTime.now(),
      );
      expect(job.progress, 0.25);
    });

    test('progress is 0 when totalBytes is 0', () {
      final job = SyncJob(
        jobId: 1,
        profileId: 'p1',
        status: SyncJobStatus.running,
        bytesTransferred: 0,
        totalBytes: 0,
        filesTransferred: 0,
        speed: 0,
        startTime: DateTime.now(),
      );
      expect(job.progress, 0);
    });

    test('copyWith works correctly', () {
      final job = SyncJob(
        jobId: 1,
        profileId: 'p1',
        status: SyncJobStatus.running,
        bytesTransferred: 0,
        totalBytes: 100,
        filesTransferred: 0,
        speed: 0,
        startTime: DateTime.now(),
      );
      final updated = job.copyWith(
        status: SyncJobStatus.finished,
        bytesTransferred: 100,
      );
      expect(updated.status, SyncJobStatus.finished);
      expect(updated.bytesTransferred, 100);
      expect(updated.jobId, 1);
    });
  });
}
