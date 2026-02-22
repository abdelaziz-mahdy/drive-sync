import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/startup_provider.dart';

/// Splash screen shown while the app is performing its startup sequence.
///
/// Displays the DriveSync logo, a progress indicator, and status messages
/// for each phase of startup. Shows an error state with retry button if
/// the daemon fails to start.
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

  @override
  Widget build(BuildContext context) {
    final startup = ref.watch(startupProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isError = startup.phase == StartupPhase.error ||
        startup.phase == StartupPhase.rcloneNotFound;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
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

              // Loading indicator or error icon.
              if (!isError) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ] else ...[
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
              ],

              // Status message.
              Text(
                startup.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isError ? colorScheme.error : colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              // Error detail.
              if (startup.errorDetail != null) ...[
                const SizedBox(height: 12),
                Container(
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
              ],

              // Retry button for error states.
              if (isError) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
