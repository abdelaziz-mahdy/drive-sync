import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/file_change.dart';

void main() {
  group('FileChangeAction', () {
    test('has 3 values', () {
      expect(FileChangeAction.values.length, 3);
    });
  });

  group('FileChange', () {
    test('fromRcloneTransfer parses correctly', () {
      final data = {
        'Name': 'documents/report.pdf',
        'Size': 1024000,
        'ModTime': '2024-01-15T10:30:00Z',
      };
      final change =
          FileChange.fromRcloneTransfer(data, FileChangeAction.add);
      expect(change.path, 'documents/report.pdf');
      expect(change.size, 1024000);
      expect(change.modTime, isNotNull);
      expect(change.action, FileChangeAction.add);
    });

    test('fromRcloneTransfer handles missing ModTime', () {
      final data = {
        'Name': 'file.txt',
        'Size': 100,
      };
      final change =
          FileChange.fromRcloneTransfer(data, FileChangeAction.delete);
      expect(change.path, 'file.txt');
      expect(change.size, 100);
      expect(change.modTime, isNull);
      expect(change.action, FileChangeAction.delete);
    });

    test('fromRcloneTransfer handles zero size', () {
      final data = {
        'Name': 'empty.txt',
        'Size': 0,
      };
      final change =
          FileChange.fromRcloneTransfer(data, FileChangeAction.update);
      expect(change.size, 0);
    });
  });
}
