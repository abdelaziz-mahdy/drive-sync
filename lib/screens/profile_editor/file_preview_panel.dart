import 'package:flutter/material.dart';

import '../../utils/format_utils.dart';
import '../../widgets/skeleton_loader.dart';
import 'file_tree_view.dart';
import 'preview_state.dart';

/// Live preview panel showing which files will sync vs be excluded.
class FilePreviewPanel extends StatefulWidget {
  const FilePreviewPanel({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.isConfigured,
  });

  /// Current preview state.
  final PreviewState state;

  /// Called when user taps refresh.
  final VoidCallback onRefresh;

  /// Whether minimum config is set (remote + cloud folder + local path).
  final bool isConfigured;

  @override
  State<FilePreviewPanel> createState() => _FilePreviewPanelState();
}

class _FilePreviewPanelState extends State<FilePreviewPanel> {
  bool _showExcluded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ps = widget.state;

    if (!widget.isConfigured) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.preview, size: 48,
                  color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'Set Remote, Cloud Folder, and Local Path to preview files',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (ps.isLoadingFiles) {
      return SkeletonLoader(
        child: Column(
          children: List.generate(8, (_) => const SkeletonListTile()),
        ),
      );
    }

    if (ps.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 8),
              Text(
                ps.error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (ps.allFiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open, size: 48,
                  color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'No files found at this location',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    // Files exist but none included by dry-run (all excluded by filters)
    if (ps.includedPaths.isEmpty && !ps.isLoadingPreview) {
      // Still show the full panel with summary showing 0 included
    }

    return Column(
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 14,
                  color: Color(0xFF4CAF50)),
              const SizedBox(width: 4),
              Text(
                '${ps.includedCount} files (${FormatUtils.formatSize(ps.includedSize)})',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(width: 12),
              Icon(Icons.cancel, size: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Text(
                '${ps.excludedCount} excluded',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              if (ps.isLoadingPreview)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: widget.onRefresh,
                  tooltip: 'Refresh preview',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),

        // Show excluded toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Switch(
                value: _showExcluded,
                onChanged: (v) => setState(() => _showExcluded = v),
              ),
              Text('Show excluded files', style: theme.textTheme.bodySmall),
            ],
          ),
        ),

        // File tree
        Expanded(
          child: FileTreeView(
            files: ps.allFiles,
            includedPaths: ps.includedPaths,
            showExcluded: _showExcluded,
          ),
        ),
      ],
    );
  }
}
