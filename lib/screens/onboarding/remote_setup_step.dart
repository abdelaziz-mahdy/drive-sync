import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/rclone_provider.dart';
import '../../widgets/command_card.dart';

/// Step 1: Check for configured rclone remotes.
class RemoteSetupStep extends ConsumerWidget {
  const RemoteSetupStep({
    super.key,
    required this.onRemotesFound,
  });

  final ValueChanged<bool> onRemotesFound;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remotesAsync = ref.watch(remotesProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Remote Configuration',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
            Text(
              'Configure at least one remote (e.g., Google Drive) using rclone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const CommandCard(
              command: 'rclone config',
              subtitle: 'Run this command to set up a remote:',
              runButtonLabel: 'Open in Terminal',
            ),
            const SizedBox(height: 20),
            remotesAsync.when(
              data: (remotes) {
                // Notify parent about status
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onRemotesFound(remotes.isNotEmpty);
                });

                if (remotes.isEmpty) {
                  return Column(
                    children: [
                      Text(
                        'No remotes found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => ref.invalidate(remotesProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${remotes.length} remote(s) found:',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...remotes.map(
                      (remote) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.cloud),
                          title: Text(remote),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(remotesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Column(
                children: [
                  Text(
                    'Error checking remotes: $error',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(remotesProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
