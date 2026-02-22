import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_profile.dart';
import '../../providers/sync_jobs_provider.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/status_indicator.dart';
import '../../widgets/sync_mode_icon.dart';

/// Material card displaying a sync profile's status and actions.
class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key, required this.profile});

  final SyncProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(syncJobsProvider);
    final job = jobs[profile.id];
    final isRunning = job != null && job.isRunning;
    final status = StatusIndicator.fromProfile(profile);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: name + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    profile.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusIndicator(status: status),
              ],
            ),
            const SizedBox(height: 8),

            // Sync mode
            Row(
              children: [
                SyncModeIcon(mode: profile.syncMode, size: 18),
                const SizedBox(width: 6),
                Text(
                  profile.syncMode.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Paths
            _PathRow(
              icon: Icons.folder_outlined,
              path: profile.localPath,
            ),
            const SizedBox(height: 4),
            _PathRow(
              icon: Icons.cloud_outlined,
              path: '${profile.remoteName}:${profile.cloudFolder}',
            ),
            const SizedBox(height: 12),

            // Progress bar when syncing
            if (isRunning) ...[
              SyncProgressBar(
                progress: job.progress,
                label:
                    '${(job.progress * 100).toStringAsFixed(0)}% - ${_formatSpeed(job.speed)}',
              ),
              const SizedBox(height: 8),
            ],

            // Last sync time
            Text(
              _formatLastSync(profile.lastSyncTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isRunning
                        ? null
                        : () {
                            // Placeholder: sync action
                          },
                    child: const Text('Sync Now'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: isRunning
                      ? null
                      : () {
                          // Placeholder: dry run action
                        },
                  child: const Text('Dry Run'),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit',
                  onPressed: () {
                    // Placeholder: edit action
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return 'Never synced';

    final now = DateTime.now();
    final diff = now.difference(lastSync);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${lastSync.day}/${lastSync.month}/${lastSync.year}';
  }

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({required this.icon, required this.path});

  final IconData icon;
  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            path,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
