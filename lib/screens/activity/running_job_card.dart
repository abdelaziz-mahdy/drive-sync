import 'package:flutter/material.dart';

import '../../models/sync_job.dart';
import '../../models/sync_mode.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/sync_mode_icon.dart';

/// Card showing a currently running sync job with progress details.
class RunningJobCard extends StatelessWidget {
  const RunningJobCard({
    super.key,
    required this.job,
    required this.profileName,
    required this.syncMode,
    this.onCancel,
  });

  final SyncJob job;
  final String profileName;
  final SyncMode syncMode;
  final VoidCallback? onCancel;

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond <= 0) return '0 B/s';
    if (bytesPerSecond < 1024) return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB/s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SyncModeIcon(mode: syncMode, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    profileName,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  syncMode.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  tooltip: 'Cancel',
                  onPressed: onCancel,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SyncProgressBar(
              progress: job.progress,
              label:
                  '${(job.progress * 100).toStringAsFixed(0)}% — ${_formatSpeed(job.speed)}',
            ),
            const SizedBox(height: 8),
            Text(
              '${job.filesTransferred} files transferred',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
