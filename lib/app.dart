import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/startup_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

/// Root widget for the DriveSync application.
///
/// Manages theme switching and routes between the splash screen (startup),
/// the onboarding wizard (first launch), and the main shell screen.
class DriveSyncApp extends ConsumerWidget {
  const DriveSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final startup = ref.watch(startupProvider);

    return MaterialApp(
      title: 'DriveSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: _buildHome(startup),
    );
  }

  Widget _buildHome(StartupState startup) {
    switch (startup.phase) {
      case StartupPhase.ready:
        if (startup.needsOnboarding) {
          return const OnboardingScreen();
        }
        return const ShellScreen();
      case StartupPhase.error:
      case StartupPhase.rcloneNotFound:
        // SplashScreen renders the error state with a retry button.
        return const SplashScreen();
      default:
        // All intermediate startup phases show the splash screen.
        return const SplashScreen();
    }
  }
}
