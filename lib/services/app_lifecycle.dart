import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rclone_provider.dart';
import '../providers/sync_jobs_provider.dart';
import 'tray_service.dart';

/// Manages the app shutdown sequence and system lifecycle events.
///
/// The shutdown flow:
/// 1. Check if sync jobs are running; prompt user for confirmation.
/// 2. Send POST /core/quit to stop rclone rcd.
/// 3. Wait up to 5s for daemon process exit.
/// 4. Cleanup (stop daemon manager, delete PID file).
/// 5. Dispose tray service.
/// 6. Exit the process.
class AppLifecycleManager extends WidgetsBindingObserver {
  final WidgetRef _ref;
  final TrayService? _trayService;
  final SyncSchedulerDisposer? _schedulerDisposer;

  AppLifecycleManager({
    required WidgetRef ref,
    TrayService? trayService,
    SyncSchedulerDisposer? schedulerDisposer,
  })  : _ref = ref,
        _trayService = trayService,
        _schedulerDisposer = schedulerDisposer;

  /// Registers this manager as a lifecycle observer.
  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Unregisters this manager as a lifecycle observer.
  void unregister() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Initiates the shutdown sequence. Returns true if the app should exit.
  ///
  /// If [context] is provided and sync jobs are running, a confirmation dialog
  /// is shown before proceeding. Pass [force] = true to skip the dialog.
  Future<bool> shutdown({
    BuildContext? context,
    bool force = false,
  }) async {
    // 1. Check for running sync jobs.
    final syncJobs = _ref.read(syncJobsProvider.notifier);
    if (!force && syncJobs.hasAnyRunningJobs && context != null) {
      final confirmed = await _showQuitConfirmation(context);
      if (!confirmed) return false;
    }

    // 2. Cancel all sync schedulers.
    _schedulerDisposer?.call();

    // 3. Stop the rclone daemon gracefully via the RC API.
    try {
      final rcloneService = _ref.read(rcloneServiceProvider);
      await rcloneService.quit();
    } catch (_) {
      // The daemon may already be gone; that is acceptable.
    }

    // 4. Wait briefly, then cleanup daemon manager state.
    try {
      final daemonManager = _ref.read(daemonManagerProvider);
      await daemonManager.stop();
    } catch (_) {
      // Best-effort cleanup.
    }

    // 5. Dispose tray service.
    try {
      await _trayService?.dispose();
    } catch (_) {
      // Best-effort cleanup.
    }

    // 6. Exit the process.
    exit(0);
  }

  /// Shows a confirmation dialog when the user attempts to quit while syncs
  /// are running.
  Future<bool> _showQuitConfirmation(BuildContext context) async {
    final runningCount = _ref
        .read(syncJobsProvider)
        .values
        .where((j) => j.isRunning)
        .length;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit DriveSync?'),
        content: Text(
          '$runningCount sync${runningCount == 1 ? ' is' : 's are'} '
          'currently running. Quitting now will interrupt '
          '${runningCount == 1 ? 'it' : 'them'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Quit Anyway'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

/// A callback type that disposes all sync scheduler timers.
typedef SyncSchedulerDisposer = void Function();
