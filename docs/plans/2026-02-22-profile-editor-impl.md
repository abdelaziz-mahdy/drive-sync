# Profile Editor Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign the profile editor with NavigationRail layout, section tabs, and a live dry-run file preview panel that shows which files will sync vs be excluded.

**Architecture:** Replace the single-scroll form with a three-zone responsive layout: NavigationRail (left) + Config section (center) + Live preview (right). On narrow screens, collapse to bottom tabs with preview as a tab. The preview uses existing `RcloneService.listFiles()` for source listing and `SyncExecutor.executeSync(dryRun: true)` for filter preview. Existing section widgets (SyncModeSelector, FileTypeChips, GitExcludesSection, AdvancedOptions) are reused as-is.

**Tech Stack:** Flutter, Riverpod, Drift, rclone RC API

---

### Task 1: EditorSection Enum and Section Content Builder

**Files:**
- Create: `lib/screens/profile_editor/editor_section.dart`

**Step 1: Create the EditorSection enum**

This enum defines the 6 navigation sections and maps to icons/labels.

```dart
import 'package:flutter/material.dart';

enum EditorSection {
  basic(icon: Icons.person_outline, label: 'Basic'),
  mode(icon: Icons.sync, label: 'Mode'),
  paths(icon: Icons.folder, label: 'Paths'),
  filters(icon: Icons.filter_list, label: 'Filters'),
  excludes(icon: Icons.block, label: 'Excludes'),
  advanced(icon: Icons.tune, label: 'Advanced');

  const EditorSection({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
```

**Step 2: Commit**

```bash
git add lib/screens/profile_editor/editor_section.dart
git commit -m "feat(editor): add EditorSection enum for navigation sections"
```

---

### Task 2: File Preview Data Model

**Files:**
- Create: `lib/screens/profile_editor/preview_state.dart`

**Step 1: Create preview state classes**

These hold the state for the live preview panel.

```dart
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

  const PreviewState({
    this.allFiles = const [],
    this.includedPaths = const {},
    this.isLoadingFiles = false,
    this.isLoadingPreview = false,
    this.error,
  });

  bool get isReady => allFiles.isNotEmpty && !isLoadingFiles;

  int get includedCount =>
      allFiles.where((f) => !f.isDir && includedPaths.contains(f.path)).length;

  int get excludedCount =>
      allFiles.where((f) => !f.isDir && !includedPaths.contains(f.path)).length;

  int get includedSize => allFiles
      .where((f) => !f.isDir && includedPaths.contains(f.path))
      .fold(0, (sum, f) => sum + f.size);

  PreviewState copyWith({
    List<PreviewFileEntry>? allFiles,
    Set<String>? includedPaths,
    bool? isLoadingFiles,
    bool? isLoadingPreview,
    String? error,
    bool clearError = false,
  }) {
    return PreviewState(
      allFiles: allFiles ?? this.allFiles,
      includedPaths: includedPaths ?? this.includedPaths,
      isLoadingFiles: isLoadingFiles ?? this.isLoadingFiles,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/screens/profile_editor/preview_state.dart
git commit -m "feat(editor): add PreviewState model for live file preview"
```

---

### Task 3: File Tree View Widget

**Files:**
- Create: `lib/screens/profile_editor/file_tree_view.dart`

**Step 1: Create the file tree widget**

This renders a flat list of files with include/exclude indicators and directory grouping. It takes the `PreviewState` and renders it.

```dart
import 'package:flutter/material.dart';

import '../../utils/format_utils.dart';
import 'preview_state.dart';

/// Displays a flat list of source files with include/exclude indicators.
class FileTreeView extends StatelessWidget {
  const FileTreeView({
    super.key,
    required this.files,
    required this.includedPaths,
    required this.showExcluded,
  });

  final List<PreviewFileEntry> files;
  final Set<String> includedPaths;
  final bool showExcluded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter files (skip dirs, optionally hide excluded).
    final displayFiles = files.where((f) {
      if (f.isDir) return false;
      if (!showExcluded && !includedPaths.contains(f.path)) return false;
      return true;
    }).toList();

    // Sort: included first, then excluded, alphabetical within each group.
    displayFiles.sort((a, b) {
      final aIncluded = includedPaths.contains(a.path);
      final bIncluded = includedPaths.contains(b.path);
      if (aIncluded != bIncluded) return aIncluded ? -1 : 1;
      return a.path.compareTo(b.path);
    });

    if (displayFiles.isEmpty) {
      return Center(
        child: Text(
          showExcluded ? 'No files found' : 'No included files',
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
              decoration:
                  isIncluded ? null : TextDecoration.lineThrough,
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
```

**Step 2: Commit**

```bash
git add lib/screens/profile_editor/file_tree_view.dart
git commit -m "feat(editor): add FileTreeView widget for preview panel"
```

---

### Task 4: File Preview Panel

**Files:**
- Create: `lib/screens/profile_editor/file_preview_panel.dart`

**Step 1: Create the preview panel widget**

This is the right-side panel that shows the summary bar, toggle, and file tree. It receives PreviewState and renders the full preview experience.

```dart
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
              Text('Set Remote, Cloud Folder, and Local Path to preview files',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
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
              Icon(Icons.error_outline, size: 48,
                  color: colorScheme.error),
              const SizedBox(height: 8),
              Text(ps.error!, textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  )),
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
        child: Text('No files found at this location',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            )),
      );
    }

    return Column(
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 14,
                  color: const Color(0xFF4CAF50)),
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
                  width: 16, height: 16,
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
              Text('Show excluded files',
                  style: theme.textTheme.bodySmall),
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
```

**Step 2: Commit**

```bash
git add lib/screens/profile_editor/file_preview_panel.dart
git commit -m "feat(editor): add FilePreviewPanel with summary bar and tree view"
```

---

### Task 5: Rewrite ProfileEditorScreen with NavigationRail Layout

**Files:**
- Modify: `lib/screens/profile_editor/profile_editor_screen.dart`

This is the biggest task. The screen becomes a ConsumerStatefulWidget with:
- NavigationRail on wide screens, bottom tabs on narrow
- Section content in the center
- FilePreviewPanel on the right (wide) or as a tab (narrow)
- All form state stays in-widget (same pattern as before)
- Debounced dry-run trigger on filter changes

**Step 1: Rewrite the profile editor screen**

The new screen layout uses `LayoutBuilder` to switch between wide (NavigationRail + 3 columns) and narrow (bottom TabBar) modes. All existing form state management stays the same. The key addition is preview state management with debounced dry-run.

Key structure:
- `_selectedSection` tracks the current EditorSection
- `_previewState` holds the PreviewState
- `_fetchSourceFiles()` calls `RcloneService.listFiles()` once when paths are set
- `_runDryRunPreview()` builds a temp SyncProfile from form state and runs dry-run
- `_debouncedPreview()` is called on every filter change with 1s debounce
- Each section's content is a method that returns a widget using existing sub-widgets (SyncModeSelector, FileTypeChips, GitExcludesSection, AdvancedOptions)
- The bottom action bar (Delete/Cancel/Save) is shared across both layouts

The `_SectionHeader` class is removed since sections now have their own nav labels. The `_SaveProfileIntent` stays for keyboard shortcuts.

Preserve all existing form state variables (`_nameController`, `_syncMode`, `_remoteName`, etc.) and the `_save()`, `_delete()`, `_browseCloudFolder()`, `_browseLocalFolder()` methods unchanged.

**Step 2: Run analyzer**

Run: `dart analyze lib/screens/profile_editor/profile_editor_screen.dart`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/screens/profile_editor/profile_editor_screen.dart
git commit -m "feat(editor): rewrite with NavigationRail layout and live preview"
```

---

### Task 6: Update Tests

**Files:**
- Modify: `test/screens/profile_editor_test.dart` (if exists)
- Create: `test/screens/profile_editor_test.dart` (if not)

**Step 1: Check for existing tests**

Run: `find test -name "*profile_editor*" -o -name "*profile*test*" | head`

**Step 2: Write widget tests**

Test the key behaviors:
- Editor renders NavigationRail destinations for all 6 sections
- Tapping a navigation destination switches the content
- Save button triggers validation
- On narrow layout (constrained width), bottom tabs appear instead of rail

**Step 3: Run all tests**

Run: `flutter test`
Expected: All tests pass (may need to mock rclone service for preview tests)

**Step 4: Commit**

```bash
git add test/screens/profile_editor_test.dart
git commit -m "test(editor): add widget tests for redesigned profile editor"
```

---

### Task 7: Run Full Analysis and Push

**Step 1: Run analyzer on full project**

Run: `flutter analyze`
Expected: 0 errors (infos OK)

**Step 2: Run all tests**

Run: `flutter test`
Expected: All pass (except pre-existing dio_error_handler failures)

**Step 3: Push**

```bash
git push
```

---

## Dependency Order

```
Task 1 (EditorSection enum) ─┐
Task 2 (PreviewState model) ─┤
                              ├── Task 5 (Main screen rewrite) ── Task 6 (Tests) ── Task 7 (Push)
Task 3 (FileTreeView) ───────┤
Task 4 (FilePreviewPanel) ───┘
```

Tasks 1-4 are independent and can be done in parallel. Task 5 depends on all of them. Tasks 6-7 are sequential.
