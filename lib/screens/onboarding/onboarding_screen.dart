import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_profile.dart';
import 'first_profile_step.dart';
import 'remote_setup_step.dart';

/// Two-step onboarding wizard for initial app setup.
///
/// Step 1: Configure cloud remotes via `rclone config`.
/// Step 2: Create the first sync profile.
///
/// The rclone installation check happens on the splash screen before
/// onboarding is reached, so we skip directly to remote configuration.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;

  bool _remotesConfigured = false;

  void _onRemotesFound(bool found) {
    setState(() {
      _remotesConfigured = found;
    });
  }

  void _onProfileCreated(SyncProfile profile) {
    Navigator.of(context).pop(profile);
  }

  void _onContinue() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to DriveSync'),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _StepDot(
                  index: 0,
                  label: 'Remotes',
                  isActive: _currentStep == 0,
                  isCompleted: _remotesConfigured,
                ),
                Expanded(
                    child: _StepConnector(completed: _remotesConfigured)),
                _StepDot(
                  index: 1,
                  label: 'Profile',
                  isActive: _currentStep == 1,
                  isCompleted: false,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Step content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStepContent(),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: _onBack,
                    child: const Text('Back'),
                  )
                else
                  const SizedBox.shrink(),
                if (_currentStep < 1)
                  FilledButton(
                    onPressed: _canContinue ? _onContinue : null,
                    child: const Text('Continue'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _remotesConfigured;
      default:
        return false;
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return RemoteSetupStep(
          key: const ValueKey('remote_setup'),
          onRemotesFound: _onRemotesFound,
        );
      case 1:
        return FirstProfileStep(
          key: const ValueKey('first_profile'),
          onProfileCreated: _onProfileCreated,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  final int index;
  final String label;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;

    if (isCompleted) {
      backgroundColor = colorScheme.primary;
      foregroundColor = colorScheme.onPrimary;
    } else if (isActive) {
      backgroundColor = colorScheme.primary;
      foregroundColor = colorScheme.onPrimary;
    } else {
      backgroundColor = colorScheme.surfaceContainerHighest;
      foregroundColor = colorScheme.onSurface;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 20, color: foregroundColor)
                : Text(
                    '${index + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isActive || isCompleted
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: completed
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest,
    );
  }
}
