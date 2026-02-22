import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/services/rclone_daemon_manager.dart';

void main() {
  late Directory tempDir;
  late RcloneDaemonManager manager;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('rclone_daemon_test_');
    manager = RcloneDaemonManager(appSupportDir: tempDir.path);
  });

  tearDown(() {
    manager.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('RcloneDaemonManager', () {
    group('pidFilePath', () {
      test('returns correct path', () {
        expect(manager.pidFilePath, '${tempDir.path}/rclone.pid');
      });
    });

    group('isRcloneInstalled', () {
      test('returns a boolean value', () async {
        // This is an integration test - depends on system state.
        final result = await manager.isRcloneInstalled();
        expect(result, isA<bool>());
      });
    });

    group('getRclonePath', () {
      test('returns a string or null', () async {
        final result = await manager.getRclonePath();
        // If rclone is installed, we get a path; otherwise null.
        if (result != null) {
          expect(result, contains('rclone'));
        }
      });
    });

    group('isRunning', () {
      test('returns false when no process and no PID file', () {
        expect(manager.isRunning, false);
      });

      test('returns false when PID file has invalid content', () {
        File(manager.pidFilePath).writeAsStringSync('not-a-number');
        expect(manager.isRunning, false);
      });

      test('returns false when PID file references dead process', () {
        // Use a PID that is very unlikely to be alive.
        File(manager.pidFilePath).writeAsStringSync('999999999');
        expect(manager.isRunning, false);
      });
    });

    group('cleanupStale', () {
      test('does nothing when no PID file exists', () async {
        // Should complete without errors.
        await manager.cleanupStale();
        expect(File(manager.pidFilePath).existsSync(), false);
      });

      test('removes PID file for dead process', () async {
        File(manager.pidFilePath).writeAsStringSync('999999999');
        await manager.cleanupStale();
        expect(File(manager.pidFilePath).existsSync(), false);
      });

      test('removes PID file with invalid content', () async {
        File(manager.pidFilePath).writeAsStringSync('invalid');
        await manager.cleanupStale();
        expect(File(manager.pidFilePath).existsSync(), false);
      });
    });

    group('dispose', () {
      test('can be called safely when no process is running', () {
        // Should not throw.
        manager.dispose();
      });
    });
  });
}
