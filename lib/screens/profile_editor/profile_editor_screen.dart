import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/sync_mode.dart';
import '../../models/sync_profile.dart';
import '../../providers/profiles_provider.dart';
import '../../providers/rclone_provider.dart';
import 'advanced_options.dart';
import 'cloud_folder_browser.dart';
import 'file_type_chips.dart';
import 'git_excludes_section.dart';
import 'sync_mode_selector.dart';

/// Full-featured form for creating or editing a sync profile.
///
/// Pass [profile] as null to create a new profile, or provide an existing
/// profile to edit it.
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
  final _localPathController = TextEditingController();

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
  late int _scheduleMinutes;
  late bool _enabled;

  bool _saving = false;

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
    _localPathController.text = p?.localPath ?? '';
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
    _scheduleMinutes = p?.scheduleMinutes ?? 0;
    _enabled = p?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cloudFolderController.dispose();
    _localPathController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final profile = SyncProfile(
        id: widget.profile?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        remoteName: _remoteName ?? '',
        cloudFolder: _cloudFolderController.text.trim(),
        localPath: _localPathController.text.trim(),
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
    }
  }

  Future<void> _browseLocalFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() => _localPathController.text = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remotesAsync = ref.watch(remotesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Profile' : 'New Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Section 1: Basic Info
            _SectionHeader(title: 'Basic Info'),
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
            const SizedBox(height: 24),

            // Section 2: Sync Mode
            _SectionHeader(title: 'Sync Mode'),
            const SizedBox(height: 8),
            SyncModeSelector(
              selected: _syncMode,
              onChanged: (mode) => setState(() => _syncMode = mode),
            ),
            const SizedBox(height: 24),

            // Section 3: Paths
            _SectionHeader(title: 'Paths'),
            const SizedBox(height: 8),

            // Remote dropdown
            remotesAsync.when(
              data: (remotes) => DropdownButtonFormField<String>(
                value: _remoteName != null && remotes.contains(_remoteName)
                    ? _remoteName
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Remote',
                ),
                items: remotes.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (v) => setState(() => _remoteName = v),
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

            // Local folder path
            TextFormField(
              controller: _localPathController,
              decoration: InputDecoration(
                labelText: 'Local Folder Path',
                hintText: 'e.g., /home/user/sync',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: _browseLocalFolder,
                  tooltip: 'Browse local folders',
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Local path is required'
                  : null,
            ),
            const SizedBox(height: 24),

            // Section 4: File Types
            _SectionHeader(title: 'File Types'),
            const SizedBox(height: 8),
            FileTypeChips(
              useIncludeMode: _useIncludeMode,
              onIncludeModeChanged: (v) =>
                  setState(() => _useIncludeMode = v),
              includeTypes: _includeTypes,
              excludeTypes: _excludeTypes,
              onIncludeTypesChanged: (v) =>
                  setState(() => _includeTypes = v),
              onExcludeTypesChanged: (v) =>
                  setState(() => _excludeTypes = v),
            ),
            const SizedBox(height: 24),

            // Section 5: Git Excludes
            _SectionHeader(title: 'Git Excludes'),
            const SizedBox(height: 8),
            GitExcludesSection(
              respectGitignore: _respectGitignore,
              excludeGitDirs: _excludeGitDirs,
              customExcludes: _customExcludes,
              onRespectGitignoreChanged: (v) =>
                  setState(() => _respectGitignore = v),
              onExcludeGitDirsChanged: (v) =>
                  setState(() => _excludeGitDirs = v),
              onCustomExcludesChanged: (v) =>
                  setState(() => _customExcludes = v),
            ),
            const SizedBox(height: 24),

            // Section 6: Advanced
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

            // Section 7: Schedule
            _SectionHeader(title: 'Schedule'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _scheduleOptions.containsKey(_scheduleMinutes)
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
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Enabled'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),

            // Bottom actions
            Row(
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
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
