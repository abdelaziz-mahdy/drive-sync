import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/file_change.dart';
import 'package:drive_sync/models/sync_preview.dart';

void main() {
  FileChange makeChange(String path, int size) {
    return FileChange(
      path: path,
      size: size,
      action: FileChangeAction.add,
    );
  }

  group('SyncPreview', () {
    test('totalFiles sums all lists', () {
      final preview = SyncPreview(
        profileId: 'p1',
        timestamp: DateTime.now(),
        filesToAdd: [makeChange('a.txt', 100), makeChange('b.txt', 200)],
        filesToUpdate: [makeChange('c.txt', 300)],
        filesToDelete: [makeChange('d.txt', 50)],
      );
      expect(preview.totalFiles, 4);
    });

    test('totalSize sums all file sizes', () {
      final preview = SyncPreview(
        profileId: 'p1',
        timestamp: DateTime.now(),
        filesToAdd: [makeChange('a.txt', 100)],
        filesToUpdate: [makeChange('b.txt', 200)],
        filesToDelete: [makeChange('c.txt', 50)],
      );
      expect(preview.totalSize, 350);
    });

    test('hasChanges is true when files exist', () {
      final preview = SyncPreview(
        profileId: 'p1',
        timestamp: DateTime.now(),
        filesToAdd: [makeChange('a.txt', 100)],
        filesToUpdate: [],
        filesToDelete: [],
      );
      expect(preview.hasChanges, true);
    });

    test('hasChanges is false when all lists empty', () {
      final preview = SyncPreview(
        profileId: 'p1',
        timestamp: DateTime.now(),
        filesToAdd: [],
        filesToUpdate: [],
        filesToDelete: [],
      );
      expect(preview.hasChanges, false);
    });

    test('totalFiles is 0 when no changes', () {
      final preview = SyncPreview(
        profileId: 'p1',
        timestamp: DateTime.now(),
        filesToAdd: [],
        filesToUpdate: [],
        filesToDelete: [],
      );
      expect(preview.totalFiles, 0);
      expect(preview.totalSize, 0);
    });
  });
}
