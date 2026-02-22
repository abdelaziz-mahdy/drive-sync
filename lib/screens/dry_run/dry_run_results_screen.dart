import 'package:flutter/material.dart';

import '../../models/file_change.dart';
import '../../models/sync_preview.dart';
import '../../theme/color_schemes.dart';
import '../../utils/format_utils.dart';
import '../../widgets/empty_state.dart';

/// Displays the results of a dry-run sync preview, showing files to add,
/// update, and delete with expandable sections.
class DryRunResultsScreen extends StatelessWidget {
  const DryRunResultsScreen({
    super.key,
    required this.preview,
    this.onExecuteSync,
  });

  final SyncPreview preview;
  final VoidCallback? onExecuteSync;

  int _sectionSize(List<FileChange> files) =>
      files.fold(0, (sum, f) => sum + f.size);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dry Run Results'),
      ),
      body: Column(
        children: [
          // Summary bar
          _SummaryBar(preview: preview),

          // Expandable sections or empty state
          Expanded(
            child: preview.hasChanges
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _FileChangeSection(
                        title:
                            'Files to Add (${preview.filesToAdd.length}) - ${FormatUtils.formatSize(_sectionSize(preview.filesToAdd))}',
                        icon: Icons.add_circle_outline,
                        color: AppColors.success,
                        files: preview.filesToAdd,
                      ),
                      const SizedBox(height: 8),
                      _FileChangeSection(
                        title:
                            'Files to Update (${preview.filesToUpdate.length}) - ${FormatUtils.formatSize(_sectionSize(preview.filesToUpdate))}',
                        icon: Icons.update,
                        color: AppColors.syncing,
                        files: preview.filesToUpdate,
                      ),
                      const SizedBox(height: 8),
                      _FileChangeSection(
                        title:
                            'Files to Delete (${preview.filesToDelete.length}) - ${FormatUtils.formatSize(_sectionSize(preview.filesToDelete))}',
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        files: preview.filesToDelete,
                      ),
                    ],
                  )
                : const EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'No changes detected',
                    subtitle:
                        'Everything is already in sync. There are no files to add, update, or delete.',
                  ),
          ),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: preview.hasChanges ? onExecuteSync : null,
                  child: const Text('Execute Sync'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.preview});

  final SyncPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final addSize = preview.filesToAdd.fold(0, (s, f) => s + f.size);
    final parts = <String>[];

    if (preview.filesToAdd.isNotEmpty) {
      parts.add(
          '${preview.filesToAdd.length} to add (${FormatUtils.formatSize(addSize)})');
    }
    if (preview.filesToUpdate.isNotEmpty) {
      parts.add('${preview.filesToUpdate.length} to update');
    }
    if (preview.filesToDelete.isNotEmpty) {
      parts.add('${preview.filesToDelete.length} to delete');
    }

    final summary = parts.isEmpty ? 'Everything is in sync' : parts.join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        summary,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FileChangeSection extends StatelessWidget {
  const _FileChangeSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.files,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<FileChange> files;

  IconData _fileIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'svg':
      case 'webp':
        return Icons.image_outlined;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file_outlined;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file_outlined;
      case 'zip':
      case 'tar':
      case 'gz':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(color: color),
      ),
      initiallyExpanded: files.isNotEmpty && files.length <= 20,
      children: files.isEmpty
          ? [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'No files',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ]
          : files.map((file) {
              return ListTile(
                leading: Icon(_fileIcon(file.path), size: 20),
                title: Text(
                  file.path,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  FormatUtils.formatSize(file.size),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                dense: true,
              );
            }).toList(),
    );
  }
}
