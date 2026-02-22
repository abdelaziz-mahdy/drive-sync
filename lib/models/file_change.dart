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

  /// Creates a [FileChange] from rclone's `/core/transferred` response.
  ///
  /// Rclone uses lowercase keys: `name`, `size`, `completed_at`.
  factory FileChange.fromRcloneTransfer(
    Map<String, dynamic> data,
    FileChangeAction action,
  ) {
    // Support both lowercase (actual rclone) and uppercase (legacy) keys.
    final name = (data['name'] as String?) ??
        (data['Name'] as String?) ??
        (data['Remote'] as String?) ??
        '';
    final size = (data['size'] as int?) ?? (data['Size'] as int?) ?? 0;
    final modTimeStr = (data['completed_at'] as String?) ??
        (data['ModTime'] as String?);

    return FileChange(
      path: name,
      size: size,
      modTime: modTimeStr != null ? DateTime.tryParse(modTimeStr) : null,
      action: action,
    );
  }
}
