import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_job.dart';
import '../../providers/profiles_provider.dart';
import '../../providers/sync_queue_provider.dart';
import '../../utils/format_utils.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/sync_mode_icon.dart';

/// Full-width banner showing active sync progress on the dashboard.
///
/// Slides in from the top when a sync is running and disappears when idle.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(syncQueueProvider);

    if (queueState.isIdle) return const SizedBox.shrink();

    final activeJob = queueState.activeJob;
    if (activeJob == null) return const SizedBox.shrink();

    final profiles = ref.watch(profilesProvider).value ?? [];
    final profile =
        profiles.where((p) => p.id == activeJob.profileId).firstOrNull;
    final profileName = profile?.name ?? 'Unknown';
    final theme = Theme.of(context);
    final queueCount = queueState.queue.length;

    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 350),
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: profile name + sync mode + cancel
                Row(
                  children: [
                    if (profile != null) ...[
                      SyncModeIcon(mode: profile.syncMode, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        activeJob.isQueued
                            ? 'Preparing: $profileName'
                            : 'Syncing: $profileName',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (queueCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(
                            '+$queueCount queued',
                            style: theme.textTheme.labelSmall,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: 'Cancel sync',
                      onPressed: () =>
                          ref.read(syncQueueProvider.notifier).cancelActive(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress bar
                SyncProgressBar(
                  progress: activeJob.progress,
                  label: _buildProgressLabel(activeJob),
                ),

                // Stats row
                if (activeJob.isRunning) ...[
                  const SizedBox(height: 8),
                  _StatsRow(job: activeJob),
                ],

                // Currently transferring files
                if (activeJob.transferring.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...activeJob.transferring.take(4).map(
                        (file) => _TransferringFileRow(file: file),
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildProgressLabel(SyncJob job) {
    if (job.isQueued) return 'Waiting to start...';

    final pct = '${(job.progress * 100).toStringAsFixed(0)}%';
    if (job.totalBytes > 0) {
      return '$pct - ${FormatUtils.formatSize(job.bytesTransferred)} / ${FormatUtils.formatSize(job.totalBytes)}';
    }
    return pct;
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.job});
  final SyncJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );

    return Row(
      children: [
        if (job.filesTransferred > 0 || job.totalFiles > 0) ...[
          Icon(Icons.insert_drive_file_outlined,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text(
            job.totalFiles > 0
                ? '${job.filesTransferred}/${job.totalFiles} files'
                : '${job.filesTransferred} files',
            style: statStyle,
          ),
          const SizedBox(width: 16),
        ],
        if (job.speed > 0) ...[
          Icon(Icons.speed,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text(FormatUtils.formatSpeed(job.speed), style: statStyle),
          const SizedBox(width: 16),
        ],
        if (job.eta != null && job.eta! > 0 && !job.eta!.isInfinite) ...[
          Icon(Icons.timer_outlined,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text('${FormatUtils.formatEta(job.eta!.toInt())} left',
              style: statStyle),
        ],
      ],
    );
  }
}

class _TransferringFileRow extends StatelessWidget {
  const _TransferringFileRow({required this.file});
  final TransferringFile file;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            Icons.sync_outlined,
            size: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              file.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            FormatUtils.formatSize(file.size),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${file.percentage.toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
