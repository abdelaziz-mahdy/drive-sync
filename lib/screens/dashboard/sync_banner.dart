import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_job.dart';
import '../../models/sync_profile.dart';
import '../../models/sync_queue_entry.dart';
import '../../providers/profiles_provider.dart';
import '../../providers/sync_queue_provider.dart';
import '../../utils/format_utils.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/sync_mode_icon.dart';

/// Full-width banner showing active sync progress on the dashboard.
///
/// Slides in from the top when a sync is running and disappears when idle.
/// The queued chip is tappable and expands to show the queue list.
class SyncBanner extends ConsumerStatefulWidget {
  const SyncBanner({super.key});

  @override
  ConsumerState<SyncBanner> createState() => _SyncBannerState();
}

class _SyncBannerState extends ConsumerState<SyncBanner> {
  bool _queueExpanded = false;

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(syncQueueProvider);

    if (queueState.isIdle) return const SizedBox.shrink();

    final activeJob = queueState.activeJob;
    if (activeJob == null) return const SizedBox.shrink();

    final profiles = ref.watch(profilesProvider).value ?? [];
    final profile =
        profiles.where((p) => p.id == activeJob.profileId).firstOrNull;
    final profileName = profile?.name ?? 'Unknown';
    final theme = Theme.of(context);
    final pendingQueue = queueState.queue;

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
                // Header: profile name + sync mode + queue chip + cancel
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
                    if (pendingQueue.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: Icon(
                            _queueExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 16,
                          ),
                          label: Text(
                            '+${pendingQueue.length} queued',
                            style: theme.textTheme.labelSmall,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onPressed: () => setState(
                              () => _queueExpanded = !_queueExpanded),
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

                // Expandable queue list
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: _queueExpanded && pendingQueue.isNotEmpty
                      ? _QueueList(
                          queue: pendingQueue,
                          profiles: profiles,
                        )
                      : const SizedBox.shrink(),
                ),
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

class _QueueList extends ConsumerWidget {
  const _QueueList({required this.queue, required this.profiles});

  final List<SyncQueueEntry> queue;
  final List<SyncProfile> profiles;

  String _profileName(String profileId) {
    final match = profiles.where((p) => p.id == profileId);
    return match.isNotEmpty ? match.first.name : profileId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          Text(
            'Up next',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          ...queue.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _profileName(item.profileId),
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    tooltip: 'Remove from queue',
                    onPressed: () => ref
                        .read(syncQueueProvider.notifier)
                        .dequeue(item.profileId),
                    visualDensity: VisualDensity.compact,
                    iconSize: 16,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
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
