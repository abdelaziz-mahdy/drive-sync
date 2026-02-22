import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_config_provider.dart';
import '../../providers/launch_at_login_provider.dart';
import '../../providers/rclone_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/update_provider.dart';
import '../../widgets/status_indicator.dart';
import '../update/update_dialog.dart';

/// App settings screen with General, Rclone, and About sections.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final configAsync = ref.watch(appConfigProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (config) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ---- General Section ----
            Text('General', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                // Theme toggle
                ListTile(
                  title: const Text('Theme'),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {currentThemeMode},
                    onSelectionChanged: (modes) {
                      ref
                          .read(appConfigProvider.notifier)
                          .setThemeMode(modes.first);
                    },
                  ),
                ),
                const Divider(height: 1),
                // Launch at login
                SwitchListTile(
                  title: const Text('Launch at login'),
                  value: config.launchAtLogin,
                  onChanged: (value) async {
                    await ref
                        .read(launchAtLoginServiceProvider)
                        .setEnabled(value);
                    await ref.read(appConfigProvider.notifier).updateConfig(
                          (c) => c.copyWith(launchAtLogin: value),
                        );
                  },
                ),
                const Divider(height: 1),
                // Show in menu bar
                SwitchListTile(
                  title: const Text('Show in menu bar'),
                  value: config.showInMenuBar,
                  onChanged: (value) {
                    ref.read(appConfigProvider.notifier).updateConfig(
                          (c) => c.copyWith(showInMenuBar: value),
                        );
                  },
                ),
                const Divider(height: 1),
                // Show notifications
                SwitchListTile(
                  title: const Text('Show notifications'),
                  value: config.showNotifications,
                  onChanged: (value) {
                    ref.read(appConfigProvider.notifier).updateConfig(
                          (c) => c.copyWith(showNotifications: value),
                        );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ---- Rclone Section ----
            Text('Rclone', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                // Connection status
                Consumer(
                  builder: (context, ref, _) {
                    final healthAsync = ref.watch(daemonHealthProvider);
                    final isConnected = healthAsync.value ?? false;
                    return ListTile(
                      title: const Text('Status'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusIndicator(
                            status: isConnected
                                ? SyncStatus.success
                                : SyncStatus.error,
                            size: 10,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isConnected ? 'Connected' : 'Disconnected',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                // Manage remotes
                ListTile(
                  title: const Text('Manage Remotes'),
                  subtitle: const Text(
                    'Open a terminal and run: rclone config',
                  ),
                  trailing: const Icon(Icons.terminal),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Open a terminal and run "rclone config" to manage remotes.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ---- About Section ----
            Text('About', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                ListTile(
                  title: const Text('Version'),
                  subtitle: const Text('0.1.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Check for Updates'),
                  trailing: FilledButton.tonal(
                    onPressed: () async {
                      final release =
                          await ref.read(updateAvailableProvider.future);
                      if (!context.mounted) return;
                      if (release != null) {
                        showDialog(
                          context: context,
                          builder: (_) => UpdateDialog(
                            release: release,
                            currentVersion: '0.1.0',
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You are up to date!'),
                          ),
                        );
                      }
                    },
                    child: const Text('Check'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    'DriveSync v0.1.0 — Selective sync powered by rclone',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience card wrapper for grouped settings.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }
}
