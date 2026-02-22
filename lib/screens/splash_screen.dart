import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../providers/startup_provider.dart';
import '../providers/talker_provider.dart';
import '../widgets/command_card.dart';

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
                            CommandCard(
                              command: _installCommand,
                              title: 'Install rclone',
                              subtitle:
                                  'Run this command in your terminal:',
                              runButtonLabel: 'Install in Terminal',
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Retry'),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.tonalIcon(
                              onPressed: () => _showLogs(context),
                              icon: const Icon(Icons.article_outlined, size: 18),
                              label: const Text('Show Logs'),
                            ),
                          ],
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

  /// Opens the Talker log viewer screen.
  void _showLogs(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TalkerScreen(talker: talker),
      ),
    );
  }
}
