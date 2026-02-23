import 'dart:async';
import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/sync_mode.dart';
import '../../models/sync_profile.dart';
import '../../providers/profiles_provider.dart';
import '../../providers/rclone_provider.dart';
import 'advanced_options.dart';
import 'cloud_folder_browser.dart';
import 'editor_section.dart';
import 'file_preview_panel.dart';
import 'file_type_chips.dart';
import 'git_excludes_section.dart';
import 'preview_state.dart';
import 'sync_mode_selector.dart';

/// Full-featured form for creating or editing a sync profile.
///
/// Pass [profile] as null to create a new profile, or provide an existing
/// profile to edit it.
///
/// Uses a three-zone responsive layout:
/// - Wide (>900px): NavigationRail + Config section + Live file preview panel
/// - Narrow (<=900px): Bottom navigation bar with section tabs + Preview tab
class ProfileEditorScreen extends ConsumerStatefulWidget {
  const ProfileEditorScreen({super.key, this.profile});

  final SyncProfile? profile;

  bool get isEditing => profile != null;

  @override
  ConsumerState<ProfileEditorScreen> createState() =>
      _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends ConsumerState<ProfileEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cloudFolderController = TextEditingController();
  late List<String> _localPaths;

  late SyncMode _syncMode;
  late String? _remoteName;
  late bool _useIncludeMode;
  late List<String> _includeTypes;
  late List<String> _excludeTypes;
  late bool _respectGitignore;
  late bool _excludeGitDirs;
  late List<String> _customExcludes;
  late String? _bandwidthLimit;
  late int _maxTransfers;
  late bool _checkFirst;
  late bool _preserveSourceDir;
  late int _scheduleMinutes;
  late bool _enabled;

  bool _saving = false;

  // Section navigation
  EditorSection _selectedSection = EditorSection.general;

  // For narrow layout: index 0-5 = sections, 6 = preview
  int _narrowSelectedIndex = 0;

  // Preview state
  PreviewState _previewState = const PreviewState();
  Timer? _previewDebounce;

  static const _scheduleOptions = <int, String>{
    0: 'Manual only',
    5: 'Every 5 minutes',
    15: 'Every 15 minutes',
    30: 'Every 30 minutes',
    60: 'Every hour',
  };

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController.text = p?.name ?? '';
    _cloudFolderController.text = p?.cloudFolder ?? '';
    _localPaths = List<String>.from(p?.localPaths ?? ['']);
    _syncMode = p?.syncMode ?? SyncMode.backup;
    _remoteName = p?.remoteName;
    _useIncludeMode = p?.useIncludeMode ?? true;
    _includeTypes = List<String>.from(p?.includeTypes ?? []);
    _excludeTypes = List<String>.from(p?.excludeTypes ?? []);
    _respectGitignore = p?.respectGitignore ?? false;
    _excludeGitDirs = p?.excludeGitDirs ?? true;
    _customExcludes = List<String>.from(p?.customExcludes ?? []);
    _bandwidthLimit = p?.bandwidthLimit;
    _maxTransfers = p?.maxTransfers ?? 4;
    _checkFirst = p?.checkFirst ?? true;
    _preserveSourceDir = p?.preserveSourceDir ?? true;
    _scheduleMinutes = p?.scheduleMinutes ?? 0;
    _enabled = p?.enabled ?? true;

    // Auto-fetch preview if config is already set (editing existing profile).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isPreviewConfigured) {
        _fetchSourceFiles();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cloudFolderController.dispose();
    _previewDebounce?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Preview helpers
  // ---------------------------------------------------------------------------

  bool get _isPreviewConfigured =>
      _remoteName != null &&
      _remoteName!.isNotEmpty &&
      _cloudFolderController.text.trim().isNotEmpty &&
      _localPaths.any((p) => p.trim().isNotEmpty);

  Future<void> _fetchSourceFiles() async {
    if (!_isPreviewConfigured) return;

    setState(() {
      _previewState = _previewState.copyWith(
        isLoadingFiles: true,
        clearError: true,
      );
    });

    try {
      final rclone = ref.read(rcloneServiceProvider);
      final allEntries = <PreviewFileEntry>[];

      // List files from all configured local paths.
      final validPaths =
          _localPaths.where((p) => p.trim().isNotEmpty).toList();

      for (final localPath in validPaths) {
        final rawFiles = await rclone.listLocalFiles(localPath.trim());
        final prefix = validPaths.length > 1
            ? localPath.trim().split('/').last
            : null;

        for (final f in rawFiles) {
          final path = (f['Path'] as String?) ?? '';
          allEntries.add(PreviewFileEntry(
            path: prefix != null ? '$prefix/$path' : path,
            name: (f['Name'] as String?) ?? '',
            size: (f['Size'] as int?) ?? 0,
            isDir: (f['IsDir'] as bool?) ?? false,
          ));
        }
      }

      if (!mounted) return;
      setState(() {
        _previewState = _previewState.copyWith(
          allFiles: allEntries,
          isLoadingFiles: false,
        );
      });

      // Apply filter rules to determine which files are included/excluded.
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _previewState = _previewState.copyWith(
          isLoadingFiles: false,
          error: 'Failed to list files: $e',
        );
      });
    }
  }

  /// Apply filter rules client-side to determine which files are included.
  ///
  /// This mirrors the logic in SyncProfile.buildFilterPayload() but runs
  /// locally against the file list instead of needing a dry-run sync.
  void _applyFilters() {
    if (_previewState.allFiles.isEmpty) return;

    setState(() {
      _previewState = _previewState.copyWith(isLoadingPreview: true);
    });

    final included = <String>{};

    for (final file in _previewState.allFiles) {
      if (file.isDir) continue;

      final path = file.path;
      final ext = _extensionOf(path);

      // Check include/exclude type filters.
      if (_useIncludeMode && _includeTypes.isNotEmpty) {
        if (!_includeTypes.contains(ext)) continue;
      }
      if (!_useIncludeMode && _excludeTypes.isNotEmpty) {
        if (_excludeTypes.contains(ext)) continue;
      }

      // Check .git exclusion.
      if (_excludeGitDirs && _matchesGitDir(path)) continue;

      // Check custom excludes.
      if (_matchesCustomExclude(path)) continue;

      included.add(path);
    }

    setState(() {
      _previewState = _previewState.copyWith(
        includedPaths: included,
        isLoadingPreview: false,
      );
    });
  }

  /// Extract file extension without dot, lowercased.
  String _extensionOf(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot < 0 || lastDot == path.length - 1) return '';
    return path.substring(lastDot + 1).toLowerCase();
  }

  /// Check if a path is under a .git directory.
  bool _matchesGitDir(String path) {
    return path == '.git' ||
        path.startsWith('.git/') ||
        path.contains('/.git/') ||
        path.contains('/.git');
  }

  /// Check if a path matches any custom exclude pattern.
  bool _matchesCustomExclude(String path) {
    for (final pattern in _customExcludes) {
      if (pattern.isEmpty) continue;
      // Simple glob matching: support * and ** patterns.
      final trimmed = pattern.trim();
      if (trimmed.contains('*')) {
        final regex = _globToRegex(trimmed);
        if (regex.hasMatch(path)) return true;
      } else {
        // Plain string match: check if path contains the pattern.
        if (path.contains(trimmed)) return true;
      }
    }
    return false;
  }

  /// Convert a simple glob pattern to a regex.
  RegExp _globToRegex(String glob) {
    final buffer = StringBuffer('^');
    for (var i = 0; i < glob.length; i++) {
      final c = glob[i];
      if (c == '*') {
        if (i + 1 < glob.length && glob[i + 1] == '*') {
          buffer.write('.*');
          i++; // skip next *
          if (i + 1 < glob.length && glob[i + 1] == '/') {
            i++; // skip /
          }
        } else {
          buffer.write('[^/]*');
        }
      } else if (c == '?') {
        buffer.write('[^/]');
      } else if (RegExp(r'[.+^${}()|[\]\\]').hasMatch(c)) {
        buffer.write('\\$c');
      } else {
        buffer.write(c);
      }
    }
    buffer.write(r'$');
    return RegExp(buffer.toString());
  }

  void _debouncedPreview() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(const Duration(seconds: 1), () {
      _applyFilters();
    });
  }

  void _onFilterChanged() {
    if (_isPreviewConfigured) {
      _debouncedPreview();
    }
  }

  // ---------------------------------------------------------------------------
  // Existing actions
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final profile = SyncProfile(
        id: widget.profile?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        remoteName: _remoteName ?? '',
        cloudFolder: _cloudFolderController.text.trim(),
        localPaths: _localPaths
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList(),
        includeTypes: _includeTypes,
        excludeTypes: _excludeTypes,
        useIncludeMode: _useIncludeMode,
        syncMode: _syncMode,
        scheduleMinutes: _scheduleMinutes,
        enabled: _enabled,
        respectGitignore: _respectGitignore,
        excludeGitDirs: _excludeGitDirs,
        customExcludes: _customExcludes,
        bandwidthLimit: _bandwidthLimit,
        maxTransfers: _maxTransfers,
        checkFirst: _checkFirst,
        preserveSourceDir: _preserveSourceDir,
      );

      final notifier = ref.read(profilesProvider.notifier);
      if (widget.isEditing) {
        await notifier.updateProfile(profile);
      } else {
        await notifier.addProfile(profile);
      }

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
            'Are you sure you want to delete "${widget.profile!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(profilesProvider.notifier)
          .deleteProfile(widget.profile!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _browseCloudFolder() async {
    if (_remoteName == null || _remoteName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a remote first')),
      );
      return;
    }
    final result = await showCloudFolderBrowser(
      context,
      remoteName: _remoteName!,
    );
    if (result != null) {
      setState(() => _cloudFolderController.text = result);
      _fetchSourceFiles();
    }
  }

  Future<void> _browseLocalFolder(int index) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() => _localPaths[index] = result);
      _fetchSourceFiles();
    }
  }

  List<Widget> _buildLocalPathFields() {
    return List.generate(_localPaths.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          key: ValueKey('local_path_${i}_${_localPaths[i].hashCode}'),
          initialValue: _localPaths[i],
          decoration: InputDecoration(
            labelText: _localPaths.length == 1
                ? 'Local Folder Path'
                : 'Local Folder Path ${i + 1}',
            hintText: 'e.g., /home/user/sync',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () => _browseLocalFolder(i),
                  tooltip: 'Browse local folders',
                ),
                if (_localPaths.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => _removeLocalPath(i),
                    tooltip: 'Remove this path',
                  ),
              ],
            ),
          ),
          onChanged: (v) => _localPaths[i] = v,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Local path is required'
              : null,
        ),
      );
    });
  }

  void _addLocalPath() {
    setState(() => _localPaths.add(''));
  }

  void _removeLocalPath(int index) {
    if (_localPaths.length > 1) {
      setState(() => _localPaths.removeAt(index));
    }
  }

  // ---------------------------------------------------------------------------
  // Section content builders
  // ---------------------------------------------------------------------------

  Widget _buildGeneralSection() {
    final theme = Theme.of(context);
    final remotesAsync = ref.watch(remotesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Profile'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Profile Name',
            hintText: 'e.g., Work Documents',
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Enabled'),
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Paths'),
        const SizedBox(height: 8),
        // Remote dropdown
        remotesAsync.when(
          data: (remotes) => DropdownButtonFormField<String>(
            initialValue: _remoteName != null && remotes.contains(_remoteName)
                ? _remoteName
                : null,
            decoration: const InputDecoration(
              labelText: 'Remote',
            ),
            items: remotes.map((r) {
              return DropdownMenuItem(value: r, child: Text(r));
            }).toList(),
            onChanged: (v) {
              setState(() => _remoteName = v);
              _fetchSourceFiles();
            },
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Remote is required' : null,
          ),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(
            'Failed to load remotes: $e',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        const SizedBox(height: 12),
        // Cloud folder path
        TextFormField(
          controller: _cloudFolderController,
          decoration: InputDecoration(
            labelText: 'Cloud Folder Path',
            hintText: 'e.g., Documents/Work',
            suffixIcon: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _browseCloudFolder,
              tooltip: 'Browse cloud folders',
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Local folder paths
        ..._buildLocalPathFields(),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addLocalPath,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add another local path'),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Preserve source folder'),
          subtitle: const Text('Keep directory structure at destination'),
          value: _preserveSourceDir,
          onChanged: (v) => setState(() => _preserveSourceDir = v),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Sync Mode'),
        const SizedBox(height: 8),
        SyncModeSelector(
          selected: _syncMode,
          onChanged: (mode) => setState(() => _syncMode = mode),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'File Types'),
        const SizedBox(height: 8),
        FileTypeChips(
          useIncludeMode: _useIncludeMode,
          onIncludeModeChanged: (v) {
            setState(() => _useIncludeMode = v);
            _onFilterChanged();
          },
          includeTypes: _includeTypes,
          excludeTypes: _excludeTypes,
          onIncludeTypesChanged: (v) {
            setState(() => _includeTypes = v);
            _onFilterChanged();
          },
          onExcludeTypesChanged: (v) {
            setState(() => _excludeTypes = v);
            _onFilterChanged();
          },
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Excludes'),
        const SizedBox(height: 8),
        GitExcludesSection(
          respectGitignore: _respectGitignore,
          excludeGitDirs: _excludeGitDirs,
          customExcludes: _customExcludes,
          onRespectGitignoreChanged: (v) {
            setState(() => _respectGitignore = v);
            _onFilterChanged();
          },
          onExcludeGitDirsChanged: (v) {
            setState(() => _excludeGitDirs = v);
            _onFilterChanged();
          },
          onCustomExcludesChanged: (v) {
            setState(() => _customExcludes = v);
            _onFilterChanged();
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Advanced'),
        const SizedBox(height: 8),
        AdvancedOptions(
          bandwidthLimit: _bandwidthLimit,
          maxTransfers: _maxTransfers,
          checkFirst: _checkFirst,
          onBandwidthLimitChanged: (v) =>
              setState(() => _bandwidthLimit = v),
          onMaxTransfersChanged: (v) =>
              setState(() => _maxTransfers = v),
          onCheckFirstChanged: (v) =>
              setState(() => _checkFirst = v),
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Schedule'),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _scheduleOptions.containsKey(_scheduleMinutes)
              ? _scheduleMinutes
              : 0,
          decoration: const InputDecoration(
            labelText: 'Schedule',
          ),
          items: _scheduleOptions.entries.map((e) {
            return DropdownMenuItem(value: e.key, child: Text(e.value));
          }).toList(),
          onChanged: (v) => setState(() => _scheduleMinutes = v ?? 0),
        ),
      ],
    );
  }

  Widget _buildSectionContent() {
    final Widget content;
    switch (_selectedSection) {
      case EditorSection.general:
        content = _buildGeneralSection();
      case EditorSection.mode:
        content = _buildModeSection();
      case EditorSection.filters:
        content = _buildFiltersSection();
      case EditorSection.advanced:
        content = _buildAdvancedSection();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: content,
    );
  }

  Widget _buildActionBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.isEditing)
            TextButton(
              onPressed: _delete,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return FilePreviewPanel(
      state: _previewState,
      isConfigured: _isPreviewConfigured,
      onRefresh: _fetchSourceFiles,
    );
  }

  // ---------------------------------------------------------------------------
  // Wide layout (>= 900px)
  // ---------------------------------------------------------------------------

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Navigation rail
        NavigationRail(
          selectedIndex: _selectedSection.index,
          onDestinationSelected: (index) {
            setState(() {
              _selectedSection = EditorSection.values[index];
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: EditorSection.values.map((section) {
            return NavigationRailDestination(
              icon: Icon(section.icon),
              label: Text(section.label),
            );
          }).toList(),
        ),
        const VerticalDivider(width: 1),

        // Center config section
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildSectionContent()),
              _buildActionBar(),
            ],
          ),
        ),

        // Preview panel divider + panel
        const VerticalDivider(width: 1),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: _buildPreviewPanel(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Narrow layout (< 900px)
  // ---------------------------------------------------------------------------

  Widget _buildNarrowLayout() {
    final bool showingPreview =
        _narrowSelectedIndex == EditorSection.values.length;

    // Sync narrow index to _selectedSection when not on preview
    if (!showingPreview && _narrowSelectedIndex < EditorSection.values.length) {
      _selectedSection = EditorSection.values[_narrowSelectedIndex];
    }

    return Column(
      children: [
        Expanded(
          child: showingPreview
              ? _buildPreviewPanel()
              : _buildSectionContent(),
        ),
        if (!showingPreview) _buildActionBar(),
      ],
    );
  }

  BottomNavigationBar _buildNarrowBottomNav() {
    return BottomNavigationBar(
      currentIndex: _narrowSelectedIndex,
      onTap: (index) {
        setState(() {
          _narrowSelectedIndex = index;
          if (index < EditorSection.values.length) {
            _selectedSection = EditorSection.values[index];
          }
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 10,
      items: [
        ...EditorSection.values.map((section) {
          return BottomNavigationBarItem(
            icon: Icon(section.icon),
            label: section.label,
          );
        }),
        const BottomNavigationBarItem(
          icon: Icon(Icons.preview),
          label: 'Preview',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        SingleActivator(
          LogicalKeyboardKey.keyS,
          meta: Platform.isMacOS,
          control: !Platform.isMacOS,
        ): const _SaveProfileIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SaveProfileIntent: CallbackAction<_SaveProfileIntent>(
            onInvoke: (_) {
              if (!_saving) _save();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title:
                  Text(widget.isEditing ? 'Edit Profile' : 'New Profile'),
            ),
            body: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  if (isWide) {
                    return _buildWideLayout();
                  }
                  return _buildNarrowLayout();
                },
              ),
            ),
            bottomNavigationBar: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return const SizedBox.shrink();
                }
                return _buildNarrowBottomNav();
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Intent for the Cmd+S / Ctrl+S save shortcut.
class _SaveProfileIntent extends Intent {
  const _SaveProfileIntent();
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
