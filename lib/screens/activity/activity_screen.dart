import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_mode.dart';
import '../../models/sync_profile.dart';
import '../../providers/profiles_provider.dart';
import '../../providers/sync_history_provider.dart';
import '../../providers/sync_queue_provider.dart';
import '../../utils/format_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';
import 'running_job_card.dart';
import 'sync_history_tile.dart';

/// Two-section screen: active syncs (top), queued (middle), and history (bottom).
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  SyncProfile? _findProfile(String profileId, List<SyncProfile> profiles) {
    final match = profiles.where((p) => p.id == profileId);
    return match.isNotEmpty ? match.first : null;
  }

  String _profileName(String profileId, List<SyncProfile> profiles) {
    return _findProfile(profileId, profiles)?.name ?? profileId;
  }

  SyncMode _profileSyncMode(String profileId, List<SyncProfile> profiles) {
    final match = profiles.where((p) => p.id == profileId);
    return match.isNotEmpty ? match.first.syncMode : SyncMode.backup;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final queueState = ref.watch(syncQueueProvider);
    final historyAsync = ref.watch(syncHistoryProvider);
    final profilesAsync = ref.watch(profilesProvider);

    final profiles = profilesAsync.value ?? [];
    final activeJob = queueState.activeJob;
    final hasActiveJob = activeJob != null && activeJob.isRunning;
    final pendingQueue = queueState.queue;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- Active Syncs Section ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Text('Active Syncs', style: theme.textTheme.titleMedium),
                  const SizedBox(width: 8),
                  if (hasActiveJob)
                    Badge(
                      label: const Text('1'),
                      backgroundColor: colorScheme.primary,
                      textColor: colorScheme.onPrimary,
                    ),
                ],
              ),
            ),
          ),
          if (!hasActiveJob)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_done_outlined,
                        size: 48,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No active syncs',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList.list(
                children: [
                  RunningJobCard(
                    job: activeJob,
                    profileName:
                        _profileName(activeJob.profileId, profiles),
                    syncMode:
                        _profileSyncMode(activeJob.profileId, profiles),
                    onCancel: () =>
                        ref.read(syncQueueProvider.notifier).cancelActive(),
                  ),
                ],
              ),
            ),

          // --- Queued Section ---
          if (pendingQueue.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Row(
                  children: [
                    Text('Queued', style: theme.textTheme.titleMedium),
                    const SizedBox(width: 8),
                    Badge(
                      label: Text('${pendingQueue.length}'),
                      backgroundColor: colorScheme.tertiary,
                      textColor: colorScheme.onTertiary,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverList.builder(
                itemCount: pendingQueue.length,
                itemBuilder: (context, index) {
                  final entry = pendingQueue[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                    title: Text(
                        _profileName(entry.profileId, profiles)),
                    subtitle: Text(
                      'Queued ${FormatUtils.formatRelativeTime(entry.enqueuedAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Remove from queue',
                      onPressed: () => ref
                          .read(syncQueueProvider.notifier)
                          .dequeue(entry.profileId),
                    ),
                  );
                },
              ),
            ),
          ],

          // --- Divider ---
          const SliverToBoxAdapter(
            child: Divider(height: 32, indent: 24, endIndent: 24),
          ),

          // --- History Section ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('History', style: theme.textTheme.titleMedium),
            ),
          ),
          historyAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.history,
                    title: 'No sync history yet',
                    subtitle: 'Completed syncs will appear here.',
                    compact: true,
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return SyncHistoryTile(
                      entry: entry,
                      profileName: _profileName(entry.profileId, profiles),
                      profile: _findProfile(entry.profileId, profiles),
                    );
                  },
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: SkeletonLoader(
                child: Column(
                  children: List.generate(
                    5,
                    (_) => const SkeletonListTile(),
                  ),
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error loading history: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
