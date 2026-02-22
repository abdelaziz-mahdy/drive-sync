import 'file_change.dart';

class SyncPreview {
  final String profileId;
  final DateTime timestamp;
  final List<FileChange> filesToAdd;
  final List<FileChange> filesToUpdate;
  final List<FileChange> filesToDelete;

  const SyncPreview({
    required this.profileId,
    required this.timestamp,
    required this.filesToAdd,
    required this.filesToUpdate,
    required this.filesToDelete,
  });

  int get totalFiles =>
      filesToAdd.length + filesToUpdate.length + filesToDelete.length;

  int get totalSize => [filesToAdd, filesToUpdate, filesToDelete]
      .expand((e) => e)
      .fold(0, (s, f) => s + f.size);

  bool get hasChanges => totalFiles > 0;
}
