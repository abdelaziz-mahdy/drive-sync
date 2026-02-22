import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/sync_history_entry.dart';

void main() {
  group('SyncHistoryEntry', () {
    test('constructor creates instance', () {
      final entry = SyncHistoryEntry(
        profileId: 'p1',
        timestamp: DateTime(2024, 1, 15, 10, 30),
        status: 'success',
        filesTransferred: 5,
        bytesTransferred: 10240,
        duration: const Duration(seconds: 30),
      );
      expect(entry.profileId, 'p1');
      expect(entry.status, 'success');
      expect(entry.filesTransferred, 5);
      expect(entry.bytesTransferred, 10240);
      expect(entry.duration, const Duration(seconds: 30));
      expect(entry.error, isNull);
    });

    group('serialization', () {
      test('round-trip fromJson/toJson', () {
        final entry = SyncHistoryEntry(
          profileId: 'p1',
          timestamp: DateTime(2024, 1, 15, 10, 30),
          status: 'success',
          filesTransferred: 5,
          bytesTransferred: 10240,
          duration: const Duration(seconds: 30),
        );
        final json = entry.toJson();
        final entry2 = SyncHistoryEntry.fromJson(json);
        expect(entry2.profileId, entry.profileId);
        expect(entry2.status, entry.status);
        expect(entry2.filesTransferred, entry.filesTransferred);
        expect(entry2.bytesTransferred, entry.bytesTransferred);
        expect(entry2.duration, entry.duration);
        expect(entry2.error, isNull);
      });

      test('Duration serializes as milliseconds int', () {
        final entry = SyncHistoryEntry(
          profileId: 'p1',
          timestamp: DateTime.now(),
          status: 'success',
          filesTransferred: 0,
          bytesTransferred: 0,
          duration: const Duration(seconds: 45),
        );
        final json = entry.toJson();
        expect(json['duration'], 45000);
      });

      test('round-trips with error field', () {
        final entry = SyncHistoryEntry(
          profileId: 'p1',
          timestamp: DateTime.now(),
          status: 'error',
          filesTransferred: 0,
          bytesTransferred: 0,
          duration: const Duration(milliseconds: 500),
          error: 'connection timeout',
        );
        final json = entry.toJson();
        final entry2 = SyncHistoryEntry.fromJson(json);
        expect(entry2.error, 'connection timeout');
        expect(entry2.duration, const Duration(milliseconds: 500));
      });
    });
  });
}
