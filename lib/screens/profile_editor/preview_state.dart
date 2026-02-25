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

/// Pre-computed summary stats to avoid re-iterating all files on every build.
@immutable
class PreviewStats {
  final int includedCount;
  final int excludedCount;
  final int includedSize;
  final int excludedSize;

  /// Extension counts (ext → file count) across all files.
  final Map<String, int> extCounts;

  /// Extension sizes (ext → total bytes) across all files.
  final Map<String, int> extSizes;

  /// Pattern IDs detected in the file listing (for recommendation generation).
  final Set<String> matchedRecPatternIds;

  const PreviewStats({
    this.includedCount = 0,
    this.excludedCount = 0,
    this.includedSize = 0,
    this.excludedSize = 0,
    this.extCounts = const {},
    this.extSizes = const {},
    this.matchedRecPatternIds = const {},
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

  /// Pre-computed stats to avoid O(n) on every build.
  final PreviewStats stats;

  const PreviewState({
    this.allFiles = const [],
    this.includedPaths = const {},
    this.isLoadingFiles = false,
    this.isLoadingPreview = false,
    this.error,
    this.sourceLabel = '',
    this.fileReasons = const {},
    this.stats = const PreviewStats(),
  });

  bool get isReady => allFiles.isNotEmpty && !isLoadingFiles;

  // Convenience accessors from pre-computed stats.
  int get includedCount => stats.includedCount;
  int get excludedCount => stats.excludedCount;
  int get includedSize => stats.includedSize;
  int get excludedSize => stats.excludedSize;

  PreviewState copyWith({
    List<PreviewFileEntry>? allFiles,
    Set<String>? includedPaths,
    bool? isLoadingFiles,
    bool? isLoadingPreview,
    String? error,
    bool clearError = false,
    String? sourceLabel,
    Map<String, String>? fileReasons,
    PreviewStats? stats,
  }) {
    return PreviewState(
      allFiles: allFiles ?? this.allFiles,
      includedPaths: includedPaths ?? this.includedPaths,
      isLoadingFiles: isLoadingFiles ?? this.isLoadingFiles,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      error: clearError ? null : (error ?? this.error),
      sourceLabel: sourceLabel ?? this.sourceLabel,
      fileReasons: fileReasons ?? this.fileReasons,
      stats: stats ?? this.stats,
    );
  }
}
