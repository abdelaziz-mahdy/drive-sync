import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/rclone_provider.dart';
import '../../theme/color_schemes.dart';

/// Step 1: Verify that rclone is installed on the system.
class RcloneCheckStep extends ConsumerStatefulWidget {
  const RcloneCheckStep({
    super.key,
    required this.onStatusChanged,
  });

  final ValueChanged<bool> onStatusChanged;

  @override
  ConsumerState<RcloneCheckStep> createState() => _RcloneCheckStepState();
}

class _RcloneCheckStepState extends ConsumerState<RcloneCheckStep> {
  bool _isChecking = true;
  bool _isInstalled = false;

  @override
  void initState() {
    super.initState();
    _checkRclone();
  }

  Future<void> _checkRclone() async {
    setState(() => _isChecking = true);

    try {
      final manager = ref.read(daemonManagerProvider);
      final installed = await manager.isRcloneInstalled();
      if (mounted) {
        setState(() {
          _isInstalled = installed;
          _isChecking = false;
        });
        widget.onStatusChanged(installed);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInstalled = false;
          _isChecking = false;
        });
        widget.onStatusChanged(false);
      }
    }
  }

  String get _installInstructions {
    if (Platform.isMacOS) {
      return 'brew install rclone';
    } else if (Platform.isWindows) {
      return 'winget install rclone';
    } else {
      return 'sudo apt install rclone';
    }
  }

  String get _platformName {
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    return 'Linux';
  }

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
              Icons.terminal,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Rclone Installation',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'DriveSync requires rclone to sync your files.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_isChecking)
              const CircularProgressIndicator()
            else if (_isInstalled) ...[
              const Icon(Icons.check_circle, size: 48, color: AppColors.success),
              const SizedBox(height: 12),
              Text(
                'Rclone is installed!',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ] else ...[
              const Icon(Icons.cancel, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Rclone is not installed',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Install rclone on $_platformName:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _installInstructions,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _checkRclone,
                icon: const Icon(Icons.refresh),
                label: const Text('Check Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
