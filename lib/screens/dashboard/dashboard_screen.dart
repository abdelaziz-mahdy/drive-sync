import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profiles_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeleton_loader.dart';
import 'profile_card.dart';

/// Dashboard screen showing a responsive grid of sync profile cards.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Profile',
            onPressed: () {
              // Placeholder: will navigate to profile editor in Task 6.4
            },
          ),
        ],
      ),
      body: profilesAsync.when(
        data: (profiles) {
          if (profiles.isEmpty) {
            return EmptyState(
              icon: Icons.cloud_sync_outlined,
              title: 'No Sync Profiles',
              subtitle:
                  'Create your first sync profile to start backing up\nyour files to Google Drive.',
              actionLabel: 'Create your first sync profile',
              onAction: () {
                // Placeholder: will navigate to profile editor
              },
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 900
                  ? (constraints.maxWidth - 64) / 3
                  : constraints.maxWidth >= 600
                      ? (constraints.maxWidth - 48) / 2
                      : constraints.maxWidth - 32;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: profiles.map((profile) {
                    return SizedBox(
                      width: cardWidth,
                      child: ProfileCard(profile: profile),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
        loading: () => _LoadingState(),
        error: (error, _) => Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading profiles',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(profilesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: profilesAsync.whenOrNull(
        data: (profiles) => profiles.isNotEmpty
            ? FloatingActionButton(
                onPressed: () {
                  // Placeholder: will navigate to profile editor in Task 6.4
                },
                tooltip: 'Add Profile',
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 900
            ? (constraints.maxWidth - 64) / 3
            : constraints.maxWidth >= 600
                ? (constraints.maxWidth - 48) / 2
                : constraints.maxWidth - 32;

        return SkeletonLoader(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(3, (_) {
                return SizedBox(
                  width: cardWidth,
                  child: const SkeletonCard(),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
