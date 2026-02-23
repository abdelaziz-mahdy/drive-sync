import 'package:flutter/foundation.dart';

/// Represents a single file entry from the source listing.
@immutable
class PreviewFileEntry {
  final String path;
  final String name;
  final int size;
  final bool isDir;

  const PreviewFileEntry({
    required this.path,
    required this.name,
    required this.size,
    required this.isDir,
  });
}

/// State for the live preview panel.
@immutable
class PreviewState {
  final List<PreviewFileEntry> allFiles;
  final Set<String> includedPaths;
  final bool isLoadingFiles;
  final bool isLoadingPreview;
  final String? error;

  /// Label describing the source of files (e.g. "Local files" or "Cloud files").
  final String sourceLabel;

  /// Maps each file path to the reason it was included or excluded.
  final Map<String, String> fileReasons;

  const PreviewState({
    this.allFiles = const [],
    this.includedPaths = const {},
    this.isLoadingFiles = false,
    this.isLoadingPreview = false,
    this.error,
    this.sourceLabel = '',
    this.fileReasons = const {},
  });

  bool get isReady => allFiles.isNotEmpty && !isLoadingFiles;

  int get includedCount =>
      allFiles.where((f) => !f.isDir && includedPaths.contains(f.path)).length;

  int get excludedCount =>
      allFiles.where((f) => !f.isDir && !includedPaths.contains(f.path)).length;

  int get includedSize => allFiles
      .where((f) => !f.isDir && includedPaths.contains(f.path))
      .fold(0, (sum, f) => sum + f.size);

  int get excludedSize => allFiles
      .where((f) => !f.isDir && !includedPaths.contains(f.path))
      .fold(0, (sum, f) => sum + f.size);

  PreviewState copyWith({
    List<PreviewFileEntry>? allFiles,
    Set<String>? includedPaths,
    bool? isLoadingFiles,
    bool? isLoadingPreview,
    String? error,
    bool clearError = false,
    String? sourceLabel,
    Map<String, String>? fileReasons,
  }) {
    return PreviewState(
      allFiles: allFiles ?? this.allFiles,
      includedPaths: includedPaths ?? this.includedPaths,
      isLoadingFiles: isLoadingFiles ?? this.isLoadingFiles,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      error: clearError ? null : (error ?? this.error),
      sourceLabel: sourceLabel ?? this.sourceLabel,
      fileReasons: fileReasons ?? this.fileReasons,
    );
  }
}
