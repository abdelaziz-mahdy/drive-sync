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
      path: data['Name'] as String,
      size: data['Size'] as int,
      modTime: data['ModTime'] != null
          ? DateTime.parse(data['ModTime'] as String)
          : null,
      action: action,
    );
  }
}
