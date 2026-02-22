import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_profile.dart';
import '../../providers/sync_executor_provider.dart';
import '../../providers/sync_queue_provider.dart';
import '../../widgets/status_indicator.dart';
import '../../widgets/sync_mode_icon.dart';
import '../dry_run/dry_run_results_screen.dart';
import '../../utils/format_utils.dart';
import '../profile_editor/profile_editor_screen.dart';

/// Material card displaying a sync profile's status and actions.
class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key, required this.profile});

  final SyncProfile profile;

  void _enqueueSync(WidgetRef ref) {
    ref.read(syncQueueProvider.notifier).enqueue(profile.id);
  }

  /// Dry runs bypass the queue — they are interactive previews.
  void _startDryRun(BuildContext context, WidgetRef ref) async {
    final executor = ref.read(syncExecutorProvider);

    await executor.executeSync(
      profile,
      dryRun: true,
      onDryRunComplete: (preview) {
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DryRunResultsScreen(
                preview: preview,
                onExecuteSync: () {
                  Navigator.of(context).pop();
                  _enqueueSync(ref);
                },
              ),
            ),
          );
        }
      },
    );
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
    final queueState = ref.watch(syncQueueProvider);
    final isRunning = queueState.isRunning(profile.id);
    final isQueued = queueState.isQueued(profile.id);
    final isActive = isRunning || isQueued;
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

            // Sync/queued status chip
            if (isRunning)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(
                  avatar: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  label: const Text('Syncing'),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            else if (isQueued)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(
                  avatar: Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.colorScheme.tertiary,
                  ),
                  label: Text('Queued (#${queueState.queuePositionOf(profile.id)})'),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
                    onPressed: isActive
                        ? null
                        : () => _enqueueSync(ref),
                    child: const Text('Sync Now'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: isActive
                      ? null
                      : () => _startDryRun(context, ref),
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
