import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/sync_mode.dart';

void main() {
  group('SyncMode', () {
    test('has 4 values', () {
      expect(SyncMode.values.length, 4);
    });

    test('backup has correct properties', () {
      const mode = SyncMode.backup;
      expect(mode.rcloneCommand, 'copy');
      expect(mode.rcEndpoint, '/sync/copy');
      expect(mode.direction, 'Local → Cloud');
      expect(mode.label, 'Backup');
      expect(mode.deletesOnDest, false);
    });

    test('mirror has correct properties', () {
      const mode = SyncMode.mirror;
      expect(mode.rcloneCommand, 'sync');
      expect(mode.rcEndpoint, '/sync/sync');
      expect(mode.direction, 'Cloud → Local');
      expect(mode.label, 'Mirror');
      expect(mode.deletesOnDest, true);
    });

    test('download has correct properties', () {
      const mode = SyncMode.download;
      expect(mode.rcloneCommand, 'copy');
      expect(mode.rcEndpoint, '/sync/copy');
      expect(mode.direction, 'Cloud → Local');
      expect(mode.label, 'Download');
      expect(mode.deletesOnDest, false);
    });

    test('bisync has correct properties', () {
      const mode = SyncMode.bisync;
      expect(mode.rcloneCommand, 'bisync');
      expect(mode.rcEndpoint, '/sync/bisync');
      expect(mode.direction, 'Bidirectional');
      expect(mode.label, 'Bidirectional');
      expect(mode.deletesOnDest, true);
    });

    group('serialization', () {
      test('toJson returns name string', () {
        expect(SyncMode.backup.toJson(), 'backup');
        expect(SyncMode.mirror.toJson(), 'mirror');
        expect(SyncMode.download.toJson(), 'download');
        expect(SyncMode.bisync.toJson(), 'bisync');
      });

      test('fromJson round-trips correctly', () {
        for (final mode in SyncMode.values) {
          expect(SyncMode.fromJson(mode.toJson()), mode);
        }
      });

      test('fromJson throws on invalid value', () {
        expect(() => SyncMode.fromJson('invalid'), throwsStateError);
      });
    });
  });
}
