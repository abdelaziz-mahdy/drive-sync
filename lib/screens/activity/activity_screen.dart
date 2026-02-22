import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_history_entry.dart';
import '../../models/sync_profile.dart';
import '../../providers/profiles_provider.dart';
import '../../providers/sync_history_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';
import 'sync_history_tile.dart';

/// History screen showing past sync records that had actual file changes.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  SyncProfile? _findProfile(String profileId, List<SyncProfile> profiles) {
    final match = profiles.where((p) => p.id == profileId);
    return match.isNotEmpty ? match.first : null;
  }

  String _profileName(String profileId, List<SyncProfile> profiles) {
    return _findProfile(profileId, profiles)?.name ?? profileId;
  }

  /// An entry is "meaningful" if it transferred files or had an error.
  bool _isMeaningful(SyncHistoryEntry entry) {
    return entry.filesTransferred > 0 || entry.status == 'error';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final historyAsync = ref.watch(syncHistoryProvider);
    final profilesAsync = ref.watch(profilesProvider);
    final profiles = profilesAsync.value ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text('History', style: theme.textTheme.titleMedium),
            ),
          ),
          historyAsync.when(
            data: (allEntries) {
              final meaningful =
                  allEntries.where(_isMeaningful).toList();
              final noChangeCount = allEntries.length - meaningful.length;

              if (meaningful.isEmpty && noChangeCount == 0) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.history,
                    title: 'No sync history yet',
                    subtitle: 'Completed syncs will appear here.',
                    compact: true,
                  ),
                );
              }

              if (meaningful.isEmpty) {
                return SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.history,
                    title: 'No changes recorded',
                    subtitle:
                        '$noChangeCount sync${noChangeCount == 1 ? '' : 's'} completed with no file changes.',
                    compact: true,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList.builder(
                  itemCount: meaningful.length + (noChangeCount > 0 ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show no-change banner at the top
                    if (noChangeCount > 0 && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Card(
                          color: colorScheme.surfaceContainerHighest,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$noChangeCount sync${noChangeCount == 1 ? '' : 's'} completed with no changes',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final entryIndex =
                        noChangeCount > 0 ? index - 1 : index;
                    final entry = meaningful[entryIndex];
                    return SyncHistoryTile(
                      entry: entry,
                      profileName:
                          _profileName(entry.profileId, profiles),
                      profile:
                          _findProfile(entry.profileId, profiles),
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
