enum FileChangeAction { add, update, delete }

class FileChange {
  final String path;
  final int size;
  final DateTime? modTime;
  final FileChangeAction action;

  const FileChange({
    required this.path,
    required this.size,
    this.modTime,
    required this.action,
  });

  factory FileChange.fromRcloneTransfer(
    Map<String, dynamic> data,
    FileChangeAction action,
  ) {
    return FileChange(
      path: (data['Name'] as String?) ?? data['Remote'] as String? ?? '',
      size: (data['Size'] as int?) ?? 0,
      modTime: data['ModTime'] != null
          ? DateTime.tryParse(data['ModTime'] as String)
          : null,
      action: action,
    );
  }
}
