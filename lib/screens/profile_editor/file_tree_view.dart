import 'package:flutter/material.dart';

import '../../utils/format_utils.dart';
import 'preview_state.dart';

/// Filter mode for the file preview list.
enum PreviewFilter { all, included, excluded }

/// Displays a flat list of source files with include/exclude indicators.
class FileTreeView extends StatelessWidget {
  const FileTreeView({
    super.key,
    required this.files,
    required this.includedPaths,
    required this.filter,
  });

  final List<PreviewFileEntry> files;
  final Set<String> includedPaths;
  final PreviewFilter filter;

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

    // Sort: included first, then excluded, alphabetical within each group.
    displayFiles.sort((a, b) {
      final aIncluded = includedPaths.contains(a.path);
      final bIncluded = includedPaths.contains(b.path);
      if (aIncluded != bIncluded) return aIncluded ? -1 : 1;
      return a.path.compareTo(b.path);
    });

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

    // Cap display at 200 files for performance.
    final cappedFiles = displayFiles.take(200).toList();
    final remaining = displayFiles.length - cappedFiles.length;

    return ListView.builder(
      itemCount: cappedFiles.length + (remaining > 0 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == cappedFiles.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'and $remaining more files...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final file = cappedFiles[index];
        final isIncluded = includedPaths.contains(file.path);

        return ListTile(
          dense: true,
          leading: Icon(
            isIncluded ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: isIncluded
                ? const Color(0xFF4CAF50)
                : colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          title: Text(
            file.path,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isIncluded
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.4),
              decoration: isIncluded ? null : TextDecoration.lineThrough,
            ),
            overflow: TextOverflow.ellipsis,
          ),
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
