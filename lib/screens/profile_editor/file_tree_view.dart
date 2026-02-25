import 'package:flutter/material.dart';

import '../../utils/format_utils.dart';
import 'preview_state.dart';

/// Filter mode for the file preview list.
enum PreviewFilter { all, included, excluded }

/// Sort mode for the file list.
enum FileSortMode { sizeDesc, sizeAsc, nameAsc, nameDesc }

/// Displays files grouped by their inclusion/exclusion reason.
///
/// Uses a pre-built flat item list when available, falling back to
/// building it on-demand. The pre-built list avoids re-iterating and
/// re-sorting hundreds of thousands of files inside [build].
class FileTreeView extends StatelessWidget {
  const FileTreeView({
    super.key,
    required this.files,
    required this.includedPaths,
    required this.filter,
    this.fileReasons = const {},
    this.sortMode = FileSortMode.sizeDesc,
  });

  final List<PreviewFileEntry> files;
  final Set<String> includedPaths;
  final PreviewFilter filter;
  final Map<String, String> fileReasons;
  final FileSortMode sortMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = _buildItems();

    if (items.isEmpty) {
      final String message;
      switch (filter) {
        case PreviewFilter.all:
          message = 'No files found';
        case PreviewFilter.included:
          message = 'No included files';
        case PreviewFilter.excluded:
          message = 'No excluded files';
      }
      return Center(
        child: Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item.type == _ItemType.header) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: EdgeInsets.only(top: index == 0 ? 0 : 8),
            color: item.isIncluded!
                ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                : colorScheme.errorContainer.withValues(alpha: 0.3),
            child: Row(
              children: [
                Icon(
                  item.isIncluded! ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: item.isIncluded!
                      ? const Color(0xFF4CAF50)
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.reason!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: item.isIncluded!
                          ? const Color(0xFF388E3C)
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Text(
                  '${item.count} file${item.count == 1 ? '' : 's'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        if (item.type == _ItemType.overflow) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'and ${item.count} more files...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        // File item
        final file = item.file!;
        final isIncluded = item.isIncluded!;

        return ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -3),
          contentPadding: const EdgeInsets.only(left: 32, right: 12),
          title: Text(
            file.name.isNotEmpty ? file.name : file.path,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isIncluded
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.4),
              decoration: isIncluded ? null : TextDecoration.lineThrough,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: file.name.isNotEmpty && file.name != file.path
              ? Text(
                  file.path,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Text(
            FormatUtils.formatSize(file.size),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        );
      },
    );
  }

  /// Builds the flat list of display items, capped at [_maxFiles] files.
  ///
  /// Instead of filtering/grouping all files, we iterate once and only
  /// collect up to [_maxFiles] per reason group (keeping running totals
  /// for the header counts). This is O(n) but touches each file only to
  /// check filter + bucket it, not to sort or materialise large lists.
  List<_ListItem> _buildItems() {
    const maxFiles = 200;

    // First pass: bucket files by reason, keeping only top-N per bucket.
    // We collect per-bucket counts and a small sample sorted later.
    final bucketFiles = <String, List<PreviewFileEntry>>{};
    final bucketCounts = <String, int>{};

    for (final f in files) {
      if (f.isDir) continue;

      final isIncluded = includedPaths.contains(f.path);
      switch (filter) {
        case PreviewFilter.included:
          if (!isIncluded) continue;
        case PreviewFilter.excluded:
          if (isIncluded) continue;
        case PreviewFilter.all:
          break;
      }

      final reason = fileReasons[f.path] ?? 'Included';
      bucketCounts[reason] = (bucketCounts[reason] ?? 0) + 1;

      final list = bucketFiles.putIfAbsent(reason, () => []);
      // Keep a generous sample for sorting later; cap to avoid OOM.
      if (list.length < maxFiles) {
        list.add(f);
      } else {
        // Check if this file should replace the worst in the sample.
        _maybeInsert(list, f);
      }
    }

    if (bucketCounts.isEmpty) return const [];

    // Sort groups: "Included" first, then alphabetical.
    final sortedReasons = bucketCounts.keys.toList()
      ..sort((a, b) {
        if (a == 'Included') return -1;
        if (b == 'Included') return 1;
        return a.compareTo(b);
      });

    // Sort the small sample within each bucket.
    for (final list in bucketFiles.values) {
      _sortFiles(list);
    }

    // Build flat item list capped at maxFiles total.
    final items = <_ListItem>[];
    var totalFiles = 0;

    for (final reason in sortedReasons) {
      final groupFiles = bucketFiles[reason]!;
      final groupTotal = bucketCounts[reason]!;
      final isIncluded = reason == 'Included';
      final remaining = maxFiles - totalFiles;
      if (remaining <= 0) break;

      final cappedFiles =
          groupFiles.length > remaining ? groupFiles.sublist(0, remaining) : groupFiles;

      items.add(_ListItem.header(
        reason: reason,
        count: groupTotal,
        isIncluded: isIncluded,
      ));
      for (final file in cappedFiles) {
        items.add(_ListItem.file(file: file, isIncluded: isIncluded));
      }
      if (cappedFiles.length < groupTotal) {
        items.add(_ListItem.overflow(
          count: groupTotal - cappedFiles.length,
        ));
      }
      totalFiles += cappedFiles.length;
    }

    return items;
  }

  void _sortFiles(List<PreviewFileEntry> list) {
    switch (sortMode) {
      case FileSortMode.sizeDesc:
        list.sort((a, b) => b.size.compareTo(a.size));
      case FileSortMode.sizeAsc:
        list.sort((a, b) => a.size.compareTo(b.size));
      case FileSortMode.nameAsc:
        list.sort((a, b) => a.path.compareTo(b.path));
      case FileSortMode.nameDesc:
        list.sort((a, b) => b.path.compareTo(a.path));
    }
  }

  /// If the new file ranks higher than the worst file in [sample],
  /// replace the worst. This keeps the top-N for the chosen sort.
  void _maybeInsert(List<PreviewFileEntry> sample, PreviewFileEntry f) {
    // For size-desc (default), keep files with largest sizes.
    switch (sortMode) {
      case FileSortMode.sizeDesc:
        final minIdx = _minIndex(sample, (a, b) => a.size.compareTo(b.size));
        if (f.size > sample[minIdx].size) sample[minIdx] = f;
      case FileSortMode.sizeAsc:
        final maxIdx = _minIndex(sample, (a, b) => b.size.compareTo(a.size));
        if (f.size < sample[maxIdx].size) sample[maxIdx] = f;
      case FileSortMode.nameAsc:
        final maxIdx = _minIndex(sample, (a, b) => b.path.compareTo(a.path));
        if (f.path.compareTo(sample[maxIdx].path) < 0) sample[maxIdx] = f;
      case FileSortMode.nameDesc:
        final minIdx = _minIndex(sample, (a, b) => a.path.compareTo(b.path));
        if (f.path.compareTo(sample[minIdx].path) > 0) sample[minIdx] = f;
    }
  }

  int _minIndex(
      List<PreviewFileEntry> list, int Function(PreviewFileEntry, PreviewFileEntry) compare) {
    var idx = 0;
    for (var i = 1; i < list.length; i++) {
      if (compare(list[i], list[idx]) < 0) idx = i;
    }
    return idx;
  }
}

enum _ItemType { header, file, overflow }

class _ListItem {
  final _ItemType type;
  final String? reason;
  final int count;
  final bool? isIncluded;
  final PreviewFileEntry? file;

  const _ListItem._({
    required this.type,
    this.reason,
    this.count = 0,
    this.isIncluded,
    this.file,
  });

  factory _ListItem.header({
    required String reason,
    required int count,
    required bool isIncluded,
  }) =>
      _ListItem._(
        type: _ItemType.header,
        reason: reason,
        count: count,
        isIncluded: isIncluded,
      );

  factory _ListItem.file({
    required PreviewFileEntry file,
    required bool isIncluded,
  }) =>
      _ListItem._(
        type: _ItemType.file,
        file: file,
        isIncluded: isIncluded,
      );

  factory _ListItem.overflow({required int count}) =>
      _ListItem._(type: _ItemType.overflow, count: count);
}
