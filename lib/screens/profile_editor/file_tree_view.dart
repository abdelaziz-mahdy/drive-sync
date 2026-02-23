import 'package:flutter/material.dart';

import '../../utils/format_utils.dart';
import 'preview_state.dart';

/// Filter mode for the file preview list.
enum PreviewFilter { all, included, excluded }

/// Displays files grouped by their inclusion/exclusion reason.
class FileTreeView extends StatelessWidget {
  const FileTreeView({
    super.key,
    required this.files,
    required this.includedPaths,
    required this.filter,
    this.fileReasons = const {},
  });

  final List<PreviewFileEntry> files;
  final Set<String> includedPaths;
  final PreviewFilter filter;
  final Map<String, String> fileReasons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter files (skip dirs, apply filter mode).
    final displayFiles = files.where((f) {
      if (f.isDir) return false;
      final isIncluded = includedPaths.contains(f.path);
      switch (filter) {
        case PreviewFilter.all:
          return true;
        case PreviewFilter.included:
          return isIncluded;
        case PreviewFilter.excluded:
          return !isIncluded;
      }
    }).toList();

    if (displayFiles.isEmpty) {
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

    // Group files by reason.
    final grouped = <String, List<PreviewFileEntry>>{};
    for (final file in displayFiles) {
      final reason = fileReasons[file.path] ?? 'Included';
      grouped.putIfAbsent(reason, () => []).add(file);
    }

    // Sort groups: "Included" first, then alphabetical.
    final sortedReasons = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Included') return -1;
        if (b == 'Included') return 1;
        return a.compareTo(b);
      });

    // Sort files within each group alphabetically.
    for (final list in grouped.values) {
      list.sort((a, b) => a.path.compareTo(b.path));
    }

    // Build flat list of items (headers + files), capped at 200 files total.
    final items = <_ListItem>[];
    var totalFiles = 0;
    const maxFiles = 200;

    for (final reason in sortedReasons) {
      final groupFiles = grouped[reason]!;
      final isIncluded = reason == 'Included';
      final remaining = maxFiles - totalFiles;
      if (remaining <= 0) break;

      final cappedFiles =
          groupFiles.length > remaining ? groupFiles.sublist(0, remaining) : groupFiles;

      items.add(_ListItem.header(
        reason: reason,
        count: groupFiles.length,
        isIncluded: isIncluded,
      ));
      for (final file in cappedFiles) {
        items.add(_ListItem.file(file: file, isIncluded: isIncluded));
      }
      if (cappedFiles.length < groupFiles.length) {
        items.add(_ListItem.overflow(
          count: groupFiles.length - cappedFiles.length,
        ));
      }
      totalFiles += cappedFiles.length;
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
