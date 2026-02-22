import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/startup_provider.dart';

/// Splash screen shown while the app is performing its startup sequence.
///
/// Displays the DriveSync logo, a progress indicator, and status messages
/// for each phase of startup. Shows an error state with retry button if
/// the daemon fails to start. Uses AnimatedSwitcher for smooth phase
/// transitions.
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

              // Error detail with animated visibility.
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: startup.errorDetail != null
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

              // Retry button with animated visibility.
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: isError
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
