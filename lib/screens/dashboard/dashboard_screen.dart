import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profiles_provider.dart';
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
            return _EmptyState(
              onCreateProfile: () {
                // Placeholder: will navigate to profile editor in Task 6.4
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateProfile});

  final VoidCallback onCreateProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_sync_outlined,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Sync Profiles',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first sync profile to start backing up\nyour files to Google Drive.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateProfile,
              icon: const Icon(Icons.add),
              label: const Text('Create your first sync profile'),
            ),
          ],
        ),
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
