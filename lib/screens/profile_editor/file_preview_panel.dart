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
    required this.useIncludeMode,
    required this.includeTypes,
    required this.excludeTypes,
    required this.onIncludeTypesChanged,
    required this.onExcludeTypesChanged,
    required this.onIncludeModeChanged,
    required this.excludeGitDirs,
    required this.onExcludeGitDirsChanged,
    required this.respectGitignore,
    required this.onRespectGitignoreChanged,
    required this.customExcludes,
    required this.onCustomExcludesChanged,
  });

  /// Current preview state.
  final PreviewState state;

  /// Called when user taps refresh.
  final VoidCallback onRefresh;

  /// Whether minimum config is set (remote + cloud folder + local path).
  final bool isConfigured;

  /// Current filter mode.
  final bool useIncludeMode;

  /// Currently active include types.
  final List<String> includeTypes;

  /// Currently active exclude types.
  final List<String> excludeTypes;

  /// Callbacks for modifying filter types.
  final ValueChanged<List<String>> onIncludeTypesChanged;
  final ValueChanged<List<String>> onExcludeTypesChanged;
  final ValueChanged<bool> onIncludeModeChanged;

  /// Git-related settings.
  final bool excludeGitDirs;
  final ValueChanged<bool> onExcludeGitDirsChanged;
  final bool respectGitignore;
  final ValueChanged<bool> onRespectGitignoreChanged;

  /// Custom exclude patterns.
  final List<String> customExcludes;
  final ValueChanged<List<String>> onCustomExcludesChanged;

  @override
  State<FilePreviewPanel> createState() => _FilePreviewPanelState();
}

class _FilePreviewPanelState extends State<FilePreviewPanel> {
  PreviewFilter _filter = PreviewFilter.all;

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
        // Source label
        if (ps.sourceLabel.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: colorScheme.primaryContainer,
            child: Text(
              ps.sourceLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

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

        // Smart recommendations
        if (ps.allFiles.isNotEmpty)
          _buildRecommendations(theme, colorScheme),

        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SegmentedButton<PreviewFilter>(
            segments: const [
              ButtonSegment(
                value: PreviewFilter.all,
                label: Text('All'),
              ),
              ButtonSegment(
                value: PreviewFilter.included,
                label: Text('Included'),
                icon: Icon(Icons.check_circle, size: 14),
              ),
              ButtonSegment(
                value: PreviewFilter.excluded,
                label: Text('Excluded'),
                icon: Icon(Icons.cancel, size: 14),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (v) => setState(() => _filter = v.first),
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(
                theme.textTheme.labelSmall,
              ),
            ),
          ),
        ),

        // Quick extension filters
        if (ps.allFiles.isNotEmpty) _buildExtensionChips(theme, colorScheme),

        // File tree
        Expanded(
          child: FileTreeView(
            files: ps.allFiles,
            includedPaths: ps.includedPaths,
            filter: _filter,
            fileReasons: ps.fileReasons,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(ThemeData theme, ColorScheme colorScheme) {
    final files = widget.state.allFiles;
    final recommendations = <_Recommendation>[];

    // Detect .git directories/files.
    final hasGitFiles = files.any((f) =>
        f.path == '.git' ||
        f.path.startsWith('.git/') ||
        f.path.contains('/.git/') ||
        f.path.contains('/.git'));
    if (hasGitFiles && !widget.excludeGitDirs) {
      recommendations.add(_Recommendation(
        icon: Icons.source,
        label: 'Exclude .git directories',
        description: '.git folders detected',
        onApply: () => widget.onExcludeGitDirsChanged(true),
      ));
    }

    // Detect .gitignore.
    final hasGitignore =
        files.any((f) => f.name == '.gitignore' || f.path.endsWith('.gitignore'));
    if (hasGitignore && !widget.respectGitignore) {
      recommendations.add(_Recommendation(
        icon: Icons.description,
        label: 'Respect .gitignore rules',
        description: '.gitignore found',
        onApply: () => widget.onRespectGitignoreChanged(true),
      ));
    }

    // Detect common excludable patterns.
    final hasNodeModules = files.any((f) =>
        f.path.contains('node_modules/') || f.path == 'node_modules');
    if (hasNodeModules &&
        !widget.customExcludes.any((p) => p.contains('node_modules'))) {
      recommendations.add(_Recommendation(
        icon: Icons.folder_delete,
        label: 'Exclude node_modules',
        description: 'node_modules detected',
        onApply: () => widget
            .onCustomExcludesChanged([...widget.customExcludes, 'node_modules/']),
      ));
    }

    final hasBuildDir = files.any((f) =>
        f.path.startsWith('build/') ||
        f.path.contains('/build/') ||
        f.path == 'build');
    if (hasBuildDir &&
        !widget.customExcludes.any((p) => p.contains('build'))) {
      recommendations.add(_Recommendation(
        icon: Icons.construction,
        label: 'Exclude build directories',
        description: 'build/ detected',
        onApply: () =>
            widget.onCustomExcludesChanged([...widget.customExcludes, 'build/']),
      ));
    }

    final hasDsStore = files.any((f) => f.name == '.DS_Store');
    if (hasDsStore &&
        !widget.customExcludes.any((p) => p.contains('.DS_Store'))) {
      recommendations.add(_Recommendation(
        icon: Icons.hide_source,
        label: 'Exclude .DS_Store',
        description: 'macOS metadata files detected',
        onApply: () => widget
            .onCustomExcludesChanged([...widget.customExcludes, '.DS_Store']),
      ));
    }

    final hasCacheDir = files.any((f) =>
        f.path.startsWith('.cache/') ||
        f.path.contains('/.cache/') ||
        f.path.startsWith('__pycache__/') ||
        f.path.contains('/__pycache__/'));
    if (hasCacheDir &&
        !widget.customExcludes.any(
            (p) => p.contains('.cache') || p.contains('__pycache__'))) {
      recommendations.add(_Recommendation(
        icon: Icons.cached,
        label: 'Exclude cache directories',
        description: 'Cache folders detected',
        onApply: () => widget.onCustomExcludesChanged(
            [...widget.customExcludes, '.cache/', '__pycache__/']),
      ));
    }

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 14,
                  color: colorScheme.tertiary),
              const SizedBox(width: 4),
              Text(
                'Suggestions',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: recommendations.map((rec) {
              return ActionChip(
                avatar: Icon(rec.icon, size: 14),
                label: Text(rec.label, style: theme.textTheme.labelSmall),
                tooltip: rec.description,
                onPressed: rec.onApply,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionChips(ThemeData theme, ColorScheme colorScheme) {
    // Collect unique extensions with counts from non-directory files.
    final extCounts = <String, int>{};
    for (final f in widget.state.allFiles) {
      if (f.isDir) continue;
      final lastDot = f.path.lastIndexOf('.');
      if (lastDot < 0 || lastDot == f.path.length - 1) continue;
      final ext = f.path.substring(lastDot + 1).toLowerCase();
      extCounts[ext] = (extCounts[ext] ?? 0) + 1;
    }
    if (extCounts.isEmpty) return const SizedBox.shrink();

    // Sort by count descending.
    final sortedExts = extCounts.keys.toList()
      ..sort((a, b) => extCounts[b]!.compareTo(extCounts[a]!));

    final activeTypes = widget.useIncludeMode
        ? widget.includeTypes
        : widget.excludeTypes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quick filter:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              // Include/Exclude mode toggle
              InkWell(
                onTap: () =>
                    widget.onIncludeModeChanged(!widget.useIncludeMode),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    widget.useIncludeMode ? 'Include mode' : 'Exclude mode',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: widget.useIncludeMode
                          ? const Color(0xFF4CAF50)
                          : colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: sortedExts.map((ext) {
              final isActive = activeTypes.contains(ext);
              return FilterChip(
                label: Text(
                  '.$ext (${extCounts[ext]})',
                  style: theme.textTheme.labelSmall,
                ),
                selected: isActive,
                onSelected: (_) {
                  if (isActive) {
                    // Remove from active list.
                    final updated =
                        activeTypes.where((e) => e != ext).toList();
                    if (widget.useIncludeMode) {
                      widget.onIncludeTypesChanged(updated);
                    } else {
                      widget.onExcludeTypesChanged(updated);
                    }
                  } else {
                    // Add to active list.
                    final updated = [...activeTypes, ext];
                    if (widget.useIncludeMode) {
                      widget.onIncludeTypesChanged(updated);
                    } else {
                      widget.onExcludeTypesChanged(updated);
                    }
                  }
                },
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                showCheckmark: false,
                selectedColor: widget.useIncludeMode
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                    : colorScheme.errorContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _Recommendation {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onApply;

  const _Recommendation({
    required this.icon,
    required this.label,
    required this.description,
    required this.onApply,
  });
}
