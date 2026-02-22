import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/startup_provider.dart';

/// Splash screen shown while the app is performing its startup sequence.
///
/// Displays the DriveSync logo, a progress indicator, and status messages
/// for each phase of startup. Shows an error state with retry button if
/// the daemon fails to start. When rclone is not found, shows platform-
/// specific install commands and an "Install in Terminal" button.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off startup on the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(startupProvider.notifier).run();
    });
  }

  void _retry() {
    ref.read(startupProvider.notifier).run();
  }

  /// Returns the platform-specific install command for rclone.
  static String get _installCommand {
    if (Platform.isMacOS) return 'brew install rclone';
    if (Platform.isLinux) return 'sudo apt install rclone';
    if (Platform.isWindows) return 'winget install Rclone.Rclone';
    return 'curl https://rclone.org/install.sh | sudo bash';
  }

  /// Opens a terminal and runs the rclone install command.
  Future<void> _installInTerminal() async {
    try {
      if (Platform.isMacOS) {
        // Use osascript to open Terminal.app and run the command.
        await Process.start('osascript', [
          '-e',
          'tell application "Terminal" to do script "$_installCommand"',
          '-e',
          'tell application "Terminal" to activate',
        ]);
      } else if (Platform.isLinux) {
        // Try common terminal emulators in order.
        final terminals = ['gnome-terminal', 'konsole', 'xterm', 'x-terminal-emulator'];
        for (final terminal in terminals) {
          try {
            if (terminal == 'gnome-terminal') {
              await Process.start(terminal, ['--', 'bash', '-c', '$_installCommand; echo "Press Enter to close..."; read']);
            } else if (terminal == 'konsole') {
              await Process.start(terminal, ['-e', 'bash', '-c', '$_installCommand; echo "Press Enter to close..."; read']);
            } else {
              await Process.start(terminal, ['-e', _installCommand]);
            }
            break;
          } catch (_) {
            continue;
          }
        }
      } else if (Platform.isWindows) {
        await Process.start('cmd', ['/c', 'start', 'cmd', '/k', _installCommand]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open terminal. Please run manually:\n$_installCommand'),
          ),
        );
      }
    }
  }

  /// Copies the install command to the clipboard.
  void _copyCommand() {
    Clipboard.setData(ClipboardData(text: _installCommand));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Command copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startup = ref.watch(startupProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isError = startup.phase == StartupPhase.error ||
        startup.phase == StartupPhase.rcloneNotFound;
    final isRcloneNotFound = startup.phase == StartupPhase.rcloneNotFound;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo / app icon area.
              Icon(
                Icons.cloud_sync,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'DriveSync',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Animated indicator: cross-fades between progress and error.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isError
                    ? Icon(
                        Icons.error_outline,
                        key: const ValueKey('error-icon'),
                        size: 48,
                        color: colorScheme.error,
                      )
                    : const Padding(
                        key: ValueKey('progress-bar'),
                        padding: EdgeInsets.only(bottom: 0),
                        child: LinearProgressIndicator(),
                      ),
              ),
              const SizedBox(height: 16),

              // Animated status message -- cross-fades on phase change.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: Text(
                  startup.message,
                  key: ValueKey(startup.phase),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color:
                        isError ? colorScheme.error : colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Rclone install help section.
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: isRcloneNotFound
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Install command card.
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Install rclone',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Run this command in your terminal:',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Command display with copy button.
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: colorScheme.outline.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.terminal,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: SelectableText(
                                            _installCommand,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.copy, size: 18),
                                          tooltip: 'Copy command',
                                          onPressed: _copyCommand,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Action buttons.
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton.icon(
                                  onPressed: _installInTerminal,
                                  icon: const Icon(Icons.terminal, size: 18),
                                  label: const Text('Install in Terminal'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton.tonalIcon(
                                  onPressed: _retry,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Generic error detail (non-rclone errors).
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: !isRcloneNotFound && startup.errorDetail != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            startup.errorDetail!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Generic retry button (non-rclone errors only).
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: !isRcloneNotFound && isError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: FilledButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
