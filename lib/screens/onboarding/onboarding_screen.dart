import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/startup_provider.dart';
import 'remote_setup_step.dart';

/// Onboarding wizard for initial app setup.
///
/// The single step checks for configured rclone remotes. Once at least one
/// remote is found the user can continue to the main dashboard where they
/// can create profiles using the full profile editor.
///
/// The rclone installation check happens on the splash screen before
/// onboarding is reached, so we skip directly to remote configuration.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _remotesConfigured = false;

  void _onRemotesFound(bool found) {
    setState(() {
      _remotesConfigured = found;
    });
  }

  void _onFinish() {
    // Re-run startup which will re-evaluate needsOnboarding.
    // Since remotes now exist, it will transition to the shell screen.
    ref.read(startupProvider.notifier).run();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to DriveSync'),
      ),
      body: Column(
        children: [
          // Step content
          Expanded(
            child: RemoteSetupStep(
              onRemotesFound: _onRemotesFound,
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: _remotesConfigured ? _onFinish : null,
                  child: const Text('Get Started'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
