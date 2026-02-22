import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_history_entry.dart';
import '../../models/sync_job.dart';
import '../../models/sync_profile.dart';
import '../../providers/profiles_provider.dart';
import '../../providers/sync_executor_provider.dart';
import '../../providers/sync_history_provider.dart';
import '../../providers/sync_jobs_provider.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/status_indicator.dart';
import '../../widgets/sync_mode_icon.dart';
import '../dry_run/dry_run_results_screen.dart';
import '../../utils/format_utils.dart';
import '../profile_editor/profile_editor_screen.dart';

/// Material card displaying a sync profile's status and actions.
class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key, required this.profile});

  final SyncProfile profile;

  void _startSync(BuildContext context, WidgetRef ref, {bool dryRun = false}) async {
    // Capture all notifier references before the async gap so they stay valid.
    final executor = ref.read(syncExecutorProvider);
    final jobsNotifier = ref.read(syncJobsProvider.notifier);
    final profilesNotifier = ref.read(profilesProvider.notifier);
    final historyNotifier = ref.read(syncHistoryProvider.notifier);
    final profileId = profile.id;
    final startTime = DateTime.now();

    final job = await executor.executeSync(
      profile,
      dryRun: dryRun,
      onProgress: (job) => jobsNotifier.updateJob(profileId, job),
      onDryRunComplete: (preview) {
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DryRunResultsScreen(
                preview: preview,
                onExecuteSync: () {
                  Navigator.of(context).pop();
                  _startSync(context, ref);
                },
              ),
            ),
          );
        }
      },
    );

    // After sync completes (skip for dry runs), update profile and history.
    if (!dryRun) {
      final isSuccess = job.status == SyncJobStatus.finished;

      // Update profile's last sync status (await to avoid config file race).
      await profilesNotifier.updateProfileStatus(
        profileId,
        status: isSuccess ? 'success' : 'error',
        error: job.error,
        lastSyncTime: DateTime.now(),
      );

      // Add history entry.
      await historyNotifier.addEntry(
        SyncHistoryEntry(
          profileId: profileId,
          timestamp: DateTime.now(),
          status: isSuccess ? 'success' : 'error',
          filesTransferred: job.filesTransferred,
          bytesTransferred: job.bytesTransferred,
          duration: DateTime.now().difference(startTime),
          error: job.error,
        ),
      );

      // Clear the active job.
      jobsNotifier.removeJob(profileId);
    }
  }

  void _editProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileEditorScreen(profile: profile),
      ),
    );
  }

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
            // Header: name + status (animated)
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: StatusIndicator(
                    key: ValueKey(status),
                    status: status,
                  ),
                ),
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
              path: profile.localPaths.length == 1
                  ? profile.localPath
                  : '${profile.localPath} (+${profile.localPaths.length - 1} more)',
            ),
            const SizedBox(height: 4),
            _PathRow(
              icon: Icons.cloud_outlined,
              path: '${profile.remoteName}:${profile.cloudFolder}',
            ),
            const SizedBox(height: 12),

            // Progress bar when syncing (animated visibility)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isRunning
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SyncProgressBar(
                            progress: job.progress,
                            label: _buildProgressLabel(job),
                          ),
                          if (job.transferring.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            ...job.transferring.take(3).map(
                              (file) => Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sync_outlined,
                                      size: 12,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        file.name,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      FormatUtils.formatSize(file.size),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${file.percentage.toStringAsFixed(0)}%',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Last sync time
            Text(
              FormatUtils.formatRelativeTime(profile.lastSyncTime),
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
                        : () => _startSync(context, ref),
                    child: const Text('Sync Now'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: isRunning
                      ? null
                      : () => _startSync(context, ref, dryRun: true),
                  child: const Text('Dry Run'),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit',
                  onPressed: () => _editProfile(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildProgressLabel(SyncJob job) {
    final parts = <String>[];

    // Percentage
    parts.add('${(job.progress * 100).toStringAsFixed(0)}%');

    // File count
    if (job.totalFiles > 0) {
      parts.add('${job.filesTransferred}/${job.totalFiles} files');
    } else if (job.filesTransferred > 0) {
      parts.add('${job.filesTransferred} files');
    }

    // Speed
    if (job.speed > 0) {
      parts.add(FormatUtils.formatSpeed(job.speed));
    }

    // ETA
    if (job.eta != null && job.eta! > 0 && !job.eta!.isInfinite) {
      parts.add('${FormatUtils.formatEta(job.eta!.toInt())} left');
    }

    return parts.join(' - ');
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
