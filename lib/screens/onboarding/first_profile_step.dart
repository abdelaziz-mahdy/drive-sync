import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/sync_mode.dart';
import '../../models/sync_profile.dart';
import '../../providers/profiles_provider.dart';
import '../../providers/rclone_provider.dart';

/// Step 3: Create the first sync profile.
class FirstProfileStep extends ConsumerStatefulWidget {
  const FirstProfileStep({
    super.key,
    required this.onProfileCreated,
  });

  final ValueChanged<SyncProfile> onProfileCreated;

  @override
  ConsumerState<FirstProfileStep> createState() => _FirstProfileStepState();
}

class _FirstProfileStepState extends ConsumerState<FirstProfileStep> {
  final _nameController = TextEditingController();
  final _cloudFolderController = TextEditingController(text: '/');
  final _localPathController = TextEditingController();

  String? _selectedRemote;
  SyncMode _selectedMode = SyncMode.backup;
  bool _isCreating = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _cloudFolderController.dispose();
    _localPathController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select local folder',
    );
    if (result != null) {
      setState(() {
        _localPathController.text = result;
      });
    }
  }

  bool get _isValid {
    return _nameController.text.trim().isNotEmpty &&
        _selectedRemote != null &&
        _cloudFolderController.text.trim().isNotEmpty &&
        _localPathController.text.trim().isNotEmpty;
  }

  Future<void> _createProfile() async {
    if (!_isValid) return;

    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      final profile = SyncProfile(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        remoteName: _selectedRemote!,
        cloudFolder: _cloudFolderController.text.trim(),
        localPaths: [_localPathController.text.trim()],
        includeTypes: const [],
        excludeTypes: const [],
        useIncludeMode: false,
        syncMode: _selectedMode,
        scheduleMinutes: 0,
        enabled: true,
        respectGitignore: false,
        excludeGitDirs: true,
        customExcludes: const [],
      );

      await ref.read(profilesProvider.notifier).addProfile(profile);
      widget.onProfileCreated(profile);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remotesAsync = ref.watch(remotesProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.folder_copy_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Create Your First Profile',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 32),

              // Profile name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Profile Name',
                  hintText: 'e.g., Work Documents',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Remote dropdown
              remotesAsync.when(
                data: (remotes) => DropdownButtonFormField<String>(
                  initialValue: _selectedRemote,
                  decoration: const InputDecoration(
                    labelText: 'Remote',
                  ),
                  items: remotes
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedRemote = value);
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Error loading remotes'),
              ),
              const SizedBox(height: 16),

              // Cloud folder path
              TextField(
                controller: _cloudFolderController,
                decoration: const InputDecoration(
                  labelText: 'Cloud Folder Path',
                  hintText: '/',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Local folder path with picker
              TextField(
                controller: _localPathController,
                decoration: InputDecoration(
                  labelText: 'Local Folder Path',
                  hintText: '/Users/you/Documents/sync',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _pickLocalFolder,
                    tooltip: 'Browse',
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Sync mode selection
              Text(
                'Sync Mode',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              RadioGroup<SyncMode>(
                groupValue: _selectedMode,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMode = value);
                  }
                },
                child: Column(
                  children: SyncMode.values.map(
                    (mode) => RadioListTile<SyncMode>(
                      value: mode,
                      title: Text(mode.label),
                      subtitle: Text(
                        mode.description,
                        style: theme.textTheme.bodySmall,
                      ),
                      secondary: Icon(_iconForMode(mode)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ).toList(),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isValid && !_isCreating ? _createProfile : null,
                  icon: _isCreating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                      _isCreating ? 'Creating...' : 'Create Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForMode(SyncMode mode) {
    switch (mode) {
      case SyncMode.backup:
        return Icons.cloud_upload_outlined;
      case SyncMode.mirror:
        return Icons.sync;
      case SyncMode.download:
        return Icons.cloud_download_outlined;
      case SyncMode.bisync:
        return Icons.swap_horiz;
    }
  }
}
