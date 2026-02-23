import 'package:flutter/material.dart';

import '../../utils/format_utils.dart';
import '../../widgets/skeleton_loader.dart';
import 'file_tree_view.dart';
import 'preview_state.dart';

/// Extension category definitions for grouping file types.
const _extensionCategories = <String, List<String>>{
  'Documents': ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'odt', 'ods', 'odp', 'rtf', 'txt', 'md', 'csv', 'tsv'],
  'Code': ['dart', 'py', 'js', 'ts', 'jsx', 'tsx', 'java', 'kt', 'swift', 'go', 'rs', 'c', 'cc', 'cpp', 'h', 'hpp', 'cs', 'rb', 'php', 'pl', 'sh', 'bash', 'sql', 'r', 'ex', 'exs', 'eex', 'lua', 'scala', 'zig'],
  'Web': ['html', 'htm', 'css', 'scss', 'sass', 'less', 'svg', 'xml', 'json', 'yaml', 'yml', 'toml', 'wasm'],
  'Images': ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'ico', 'tiff', 'tif', 'raw', 'heic', 'heif', 'avif'],
  'Media': ['mp4', 'mp3', 'wav', 'avi', 'mkv', 'mov', 'flv', 'wmv', 'flac', 'aac', 'ogg', 'webm', 'm4a', 'm4v'],
  'Archives': ['zip', 'tar', 'gz', 'bz2', 'xz', '7z', 'rar', 'dmg', 'iso', 'deb', 'rpm', 'apk', 'jar'],
  'Build & Cache': ['pyc', 'o', 'a', 'so', 'dll', 'dylib', 'exe', 'class', 'pdb', 'obj', 'lib'],
  'Config': ['properties', 'plist', 'gradle', 'podspec', 'xcconfig', 'cmake', 'fxml', 'nib', 'strings', 'xcworkspace'],
  'Fonts': ['ttf', 'otf', 'woff', 'woff2', 'eot'],
};

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

  final PreviewState state;
  final VoidCallback onRefresh;
  final bool isConfigured;
  final bool useIncludeMode;
  final List<String> includeTypes;
  final List<String> excludeTypes;
  final ValueChanged<List<String>> onIncludeTypesChanged;
  final ValueChanged<List<String>> onExcludeTypesChanged;
  final ValueChanged<bool> onIncludeModeChanged;
  final bool excludeGitDirs;
  final ValueChanged<bool> onExcludeGitDirsChanged;
  final bool respectGitignore;
  final ValueChanged<bool> onRespectGitignoreChanged;
  final List<String> customExcludes;
  final ValueChanged<List<String>> onCustomExcludesChanged;

  @override
  State<FilePreviewPanel> createState() => _FilePreviewPanelState();
}

class _FilePreviewPanelState extends State<FilePreviewPanel> {
  PreviewFilter _filter = PreviewFilter.all;
  FileSortMode _sortMode = FileSortMode.sizeDesc;

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

        // Filter tabs + sort
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
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
              const SizedBox(width: 4),
              PopupMenuButton<FileSortMode>(
                icon: const Icon(Icons.sort, size: 18),
                tooltip: 'Sort files',
                initialValue: _sortMode,
                onSelected: (v) => setState(() => _sortMode = v),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: FileSortMode.sizeDesc,
                    child: Text('Size (largest first)'),
                  ),
                  PopupMenuItem(
                    value: FileSortMode.sizeAsc,
                    child: Text('Size (smallest first)'),
                  ),
                  PopupMenuItem(
                    value: FileSortMode.nameAsc,
                    child: Text('Name (A-Z)'),
                  ),
                  PopupMenuItem(
                    value: FileSortMode.nameDesc,
                    child: Text('Name (Z-A)'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Quick filter bar (compact)
        if (ps.allFiles.isNotEmpty)
          _buildQuickFilterBar(theme, colorScheme),

        // File tree
        Expanded(
          child: FileTreeView(
            files: ps.allFiles,
            includedPaths: ps.includedPaths,
            filter: _filter,
            fileReasons: ps.fileReasons,
            sortMode: _sortMode,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Smart recommendations
  // ---------------------------------------------------------------------------

  Widget _buildRecommendations(ThemeData theme, ColorScheme colorScheme) {
    final files = widget.state.allFiles;
    final recommendations = <_Recommendation>[];

    final hasGitFiles = files.any((f) =>
        f.path == '.git' ||
        f.path.startsWith('.git/') ||
        f.path.contains('/.git/') ||
        f.path.contains('/.git'));
    if (hasGitFiles && !widget.excludeGitDirs) {
      recommendations.add(_Recommendation(
        icon: Icons.source,
        label: 'Exclude .git',
        description: '.git folders detected',
        onApply: () => widget.onExcludeGitDirsChanged(true),
      ));
    }

    final hasGitignore =
        files.any((f) => f.name == '.gitignore' || f.path.endsWith('.gitignore'));
    if (hasGitignore && !widget.respectGitignore) {
      recommendations.add(_Recommendation(
        icon: Icons.description,
        label: 'Use .gitignore',
        description: '.gitignore found',
        onApply: () => widget.onRespectGitignoreChanged(true),
      ));
    }

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
        label: 'Exclude build/',
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
        description: 'macOS metadata detected',
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
        label: 'Exclude caches',
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

  // ---------------------------------------------------------------------------
  // Quick filter bar - compact category chips + manage button
  // ---------------------------------------------------------------------------

  /// Collects extension counts from files.
  Map<String, int> _collectExtCounts() {
    final extCounts = <String, int>{};
    for (final f in widget.state.allFiles) {
      if (f.isDir) continue;
      final lastDot = f.path.lastIndexOf('.');
      if (lastDot < 0 || lastDot == f.path.length - 1) continue;
      final ext = f.path.substring(lastDot + 1).toLowerCase();
      extCounts[ext] = (extCounts[ext] ?? 0) + 1;
    }
    return extCounts;
  }

  Widget _buildQuickFilterBar(ThemeData theme, ColorScheme colorScheme) {
    final extCounts = _collectExtCounts();
    if (extCounts.isEmpty) return const SizedBox.shrink();

    final activeTypes = widget.useIncludeMode
        ? widget.includeTypes
        : widget.excludeTypes;

    // Build category chips showing only categories that have files present.
    final presentCategories = <String, _CategoryInfo>{};
    for (final entry in _extensionCategories.entries) {
      final matchingExts = entry.value.where((e) => extCounts.containsKey(e)).toList();
      if (matchingExts.isEmpty) continue;
      final totalFiles = matchingExts.fold<int>(0, (sum, e) => sum + extCounts[e]!);
      final activeCount = matchingExts.where((e) => activeTypes.contains(e)).length;
      presentCategories[entry.key] = _CategoryInfo(
        exts: matchingExts,
        totalFiles: totalFiles,
        activeCount: activeCount,
      );
    }

    // Collect uncategorized extensions.
    final allCategorized = _extensionCategories.values.expand((e) => e).toSet();
    final uncategorized = extCounts.keys.where((e) => !allCategorized.contains(e)).toList()
      ..sort((a, b) => extCounts[b]!.compareTo(extCounts[a]!));
    if (uncategorized.isNotEmpty) {
      final totalFiles = uncategorized.fold<int>(0, (sum, e) => sum + extCounts[e]!);
      final activeCount = uncategorized.where((e) => activeTypes.contains(e)).length;
      presentCategories['Other'] = _CategoryInfo(
        exts: uncategorized,
        totalFiles: totalFiles,
        activeCount: activeCount,
      );
    }

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
                'File types:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                widget.useIncludeMode ? 'Include mode' : 'Exclude mode',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: widget.useIncludeMode
                      ? const Color(0xFF4CAF50)
                      : colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              ...presentCategories.entries.map((entry) {
                final cat = entry.value;
                final allActive = cat.activeCount == cat.exts.length;
                final someActive = cat.activeCount > 0;
                return GestureDetector(
                  onLongPress: () => _showCategoryDetail(
                    context, entry.key, cat.exts, extCounts,
                  ),
                  child: FilterChip(
                    label: Text(
                      '${entry.key} (${cat.totalFiles})',
                      style: theme.textTheme.labelSmall,
                    ),
                    selected: allActive,
                    avatar: someActive && !allActive
                        ? Icon(Icons.indeterminate_check_box_outlined,
                            size: 14, color: colorScheme.primary)
                        : null,
                    onSelected: (_) => _toggleCategory(entry.key, cat),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    showCheckmark: allActive,
                    selectedColor: widget.useIncludeMode
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                        : colorScheme.errorContainer,
                  ),
                );
              }),
              // "Manage" button to open full extension picker
              ActionChip(
                avatar: const Icon(Icons.tune, size: 14),
                label: Text('Manage', style: theme.textTheme.labelSmall),
                onPressed: () => _showFullExtensionPicker(
                  context, extCounts, presentCategories,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
            ],
          ),
          // Show active filter summary if any
          if (activeTypes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 2,
              children: activeTypes.map((ext) {
                return Chip(
                  label: Text('.$ext',
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
                  onDeleted: () => _removeExtension(ext),
                  deleteIcon: const Icon(Icons.close, size: 12),
                  visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.only(left: 4),
                  backgroundColor: widget.useIncludeMode
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                      : colorScheme.errorContainer.withValues(alpha: 0.5),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _toggleCategory(String name, _CategoryInfo cat) {
    final activeTypes = widget.useIncludeMode
        ? widget.includeTypes
        : widget.excludeTypes;
    final allActive = cat.activeCount == cat.exts.length;

    List<String> updated;
    if (allActive) {
      // Remove all exts in this category.
      updated = activeTypes.where((e) => !cat.exts.contains(e)).toList();
    } else {
      // Add all exts in this category.
      updated = {...activeTypes, ...cat.exts}.toList();
    }

    if (widget.useIncludeMode) {
      widget.onIncludeTypesChanged(updated);
    } else {
      widget.onExcludeTypesChanged(updated);
    }
  }

  void _removeExtension(String ext) {
    final activeTypes = widget.useIncludeMode
        ? widget.includeTypes
        : widget.excludeTypes;
    final updated = activeTypes.where((e) => e != ext).toList();
    if (widget.useIncludeMode) {
      widget.onIncludeTypesChanged(updated);
    } else {
      widget.onExcludeTypesChanged(updated);
    }
  }

  void _toggleExtension(String ext) {
    final activeTypes = widget.useIncludeMode
        ? widget.includeTypes
        : widget.excludeTypes;
    List<String> updated;
    if (activeTypes.contains(ext)) {
      updated = activeTypes.where((e) => e != ext).toList();
    } else {
      updated = [...activeTypes, ext];
    }
    if (widget.useIncludeMode) {
      widget.onIncludeTypesChanged(updated);
    } else {
      widget.onExcludeTypesChanged(updated);
    }
  }

  void _showCategoryDetail(
    BuildContext context,
    String categoryName,
    List<String> exts,
    Map<String, int> extCounts,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final activeTypes = widget.useIncludeMode
                ? widget.includeTypes
                : widget.excludeTypes;
            final sorted = [...exts]
              ..sort((a, b) => (extCounts[b] ?? 0).compareTo(extCounts[a] ?? 0));

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: sorted.map((ext) {
                      final isActive = activeTypes.contains(ext);
                      return FilterChip(
                        label: Text(
                          '.$ext (${extCounts[ext] ?? 0})',
                          style: theme.textTheme.bodySmall,
                        ),
                        selected: isActive,
                        onSelected: (_) {
                          _toggleExtension(ext);
                          setSheetState(() {});
                        },
                        showCheckmark: true,
                        selectedColor: widget.useIncludeMode
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                            : colorScheme.errorContainer,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFullExtensionPicker(
    BuildContext context,
    Map<String, int> extCounts,
    Map<String, _CategoryInfo> presentCategories,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final activeTypes = widget.useIncludeMode
                ? widget.includeTypes
                : widget.excludeTypes;

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (ctx, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Manage File Types',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            '${activeTypes.length} selected',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Include/Exclude mode toggle
                      Row(
                        children: [
                          Text(
                            'Mode:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: false,
                                label: Text('Exclude'),
                                icon: Icon(Icons.cancel, size: 14),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text('Include'),
                                icon: Icon(Icons.check_circle, size: 14),
                              ),
                            ],
                            selected: {widget.useIncludeMode},
                            onSelectionChanged: (v) {
                              widget.onIncludeModeChanged(v.first);
                              setSheetState(() {});
                            },
                            showSelectedIcon: false,
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              textStyle: WidgetStatePropertyAll(
                                theme.textTheme.labelSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.useIncludeMode
                            ? 'Only selected types will be synced'
                            : 'Selected types will be excluded from sync',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: presentCategories.entries.map((entry) {
                            final cat = entry.value;
                            final sorted = [...cat.exts]..sort(
                                (a, b) => (extCounts[b] ?? 0)
                                    .compareTo(extCounts[a] ?? 0));
                            final allActive =
                                cat.exts.every((e) => activeTypes.contains(e));
                            final someActive =
                                cat.exts.any((e) => activeTypes.contains(e));

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _toggleCategory(entry.key, cat);
                                    setSheetState(() {});
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          allActive
                                              ? Icons.check_box
                                              : someActive
                                                  ? Icons
                                                      .indeterminate_check_box
                                                  : Icons
                                                      .check_box_outline_blank,
                                          size: 18,
                                          color: (allActive || someActive)
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          entry.key,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${cat.totalFiles} files',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 26, bottom: 8),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: sorted.map((ext) {
                                      final isActive =
                                          activeTypes.contains(ext);
                                      return FilterChip(
                                        label: Text(
                                          '.$ext (${extCounts[ext] ?? 0})',
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        selected: isActive,
                                        onSelected: (_) {
                                          _toggleExtension(ext);
                                          setSheetState(() {});
                                        },
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        showCheckmark: true,
                                        selectedColor: widget.useIncludeMode
                                            ? const Color(0xFF4CAF50)
                                                .withValues(alpha: 0.2)
                                            : colorScheme.errorContainer,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
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

class _CategoryInfo {
  final List<String> exts;
  final int totalFiles;
  final int activeCount;

  const _CategoryInfo({
    required this.exts,
    required this.totalFiles,
    required this.activeCount,
  });
}
