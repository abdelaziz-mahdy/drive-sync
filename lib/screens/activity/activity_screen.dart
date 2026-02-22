import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_profile.dart';
import '../../providers/profiles_provider.dart';
import '../../providers/sync_history_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';
import 'sync_history_tile.dart';

/// History screen showing past sync records.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  SyncProfile? _findProfile(String profileId, List<SyncProfile> profiles) {
    final match = profiles.where((p) => p.id == profileId);
    return match.isNotEmpty ? match.first : null;
  }

  String _profileName(String profileId, List<SyncProfile> profiles) {
    return _findProfile(profileId, profiles)?.name ?? profileId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
