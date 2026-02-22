import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/rclone_daemon_manager.dart';
import '../services/rclone_service.dart';
import 'app_config_provider.dart';
import 'rclone_provider.dart';

/// Represents the current phase of the app startup sequence.
enum StartupPhase {
  /// Cleaning up stale rclone processes from a previous run.
  cleaningUp,

  /// Checking whether rclone is installed on the system.
  checkingRclone,

  /// Starting the rclone rcd daemon process.
  startingDaemon,

  /// Polling the daemon's health endpoint until it responds.
  waitingForDaemon,

  /// Loading user profiles and checking for configured remotes.
  loadingProfiles,

  /// Startup completed successfully.
  ready,

  /// rclone is not installed on the system.
  rcloneNotFound,

  /// An error occurred during startup.
  error,
}

/// State emitted by [startupProvider] during the app bootstrap sequence.
class StartupState {
  final StartupPhase phase;

  /// Human-readable status message shown in the splash screen.
  final String message;

  /// Non-null when [phase] is [StartupPhase.error].
  final String? errorDetail;

  /// True when there are no remotes and no profiles (first launch).
  final bool needsOnboarding;

  const StartupState({
    required this.phase,
    required this.message,
    this.errorDetail,
    this.needsOnboarding = false,
  });

  const StartupState.initial()
      : phase = StartupPhase.cleaningUp,
        message = 'Initializing...',
        errorDetail = null,
        needsOnboarding = false;
}

/// Manages the startup state machine. Reads from rclone, daemon, and config
/// providers that are overridden in main.dart's ProviderScope.
class StartupNotifier extends Notifier<StartupState> {
  @override
  StartupState build() {
    return const StartupState.initial();
  }

  /// Executes the full startup sequence. Called once from the splash screen.
  Future<void> run() async {
    try {
      final daemonManager = ref.read(daemonManagerProvider);
      final rcloneService = ref.read(rcloneServiceProvider);

      // Phase 1 - Cleanup stale processes.
      state = const StartupState(
        phase: StartupPhase.cleaningUp,
        message: 'Cleaning up stale processes...',
      );
      await daemonManager.cleanupStale();

      // Phase 2 - Check rclone is installed.
      state = const StartupState(
        phase: StartupPhase.checkingRclone,
        message: 'Checking rclone installation...',
      );
      final installed = await daemonManager.isRcloneInstalled();
      if (!installed) {
        state = const StartupState(
          phase: StartupPhase.rcloneNotFound,
          message: 'rclone not found',
          errorDetail:
              'rclone is not installed or not available on the system PATH.\n'
              'Please install rclone and restart DriveSync.',
        );
        return;
      }

      // Phase 3 - Start the rclone daemon if not already running.
      if (!daemonManager.isRunning) {
        state = const StartupState(
          phase: StartupPhase.startingDaemon,
          message: 'Starting rclone daemon...',
        );
        await _startDaemon(daemonManager);
      }

      // Phase 4 - Wait for health check.
      state = const StartupState(
        phase: StartupPhase.waitingForDaemon,
        message: 'Connecting to rclone daemon...',
      );
      final healthy = await _pollHealthCheck(rcloneService);
      if (!healthy) {
        state = const StartupState(
          phase: StartupPhase.error,
          message: 'Failed to connect to daemon',
          errorDetail:
              'The rclone daemon did not respond within 10 seconds.\n'
              'Please check that rclone is working correctly and retry.',
        );
        return;
      }

      // Phase 5 - Load profiles and check remotes.
      state = const StartupState(
        phase: StartupPhase.loadingProfiles,
        message: 'Loading profiles...',
      );

      List<String> remotes = [];
      try {
        remotes = await rcloneService.listRemotes();
      } catch (_) {
        // Non-fatal: user may not have remotes configured yet.
      }

      final configStore = ref.read(configStoreProvider);
      final profiles = await configStore.loadProfiles();

      final needsOnboarding = remotes.isEmpty && profiles.isEmpty;

      // Phase 6 - Done!
      state = StartupState(
        phase: StartupPhase.ready,
        message: 'Ready',
        needsOnboarding: needsOnboarding,
      );
    } catch (e) {
      state = StartupState(
        phase: StartupPhase.error,
        message: 'Startup failed',
        errorDetail: e.toString(),
      );
    }
  }

  /// Starts the rclone daemon using stored credentials.
  Future<void> _startDaemon(RcloneDaemonManager daemonManager) async {
    final configStore = ref.read(configStoreProvider);
    final creds = await configStore.loadRcCredentials();
    if (creds == null) {
      throw Exception('RC credentials not found in secure storage.');
    }
    await daemonManager.start(user: creds.user, pass: creds.pass);
  }

  /// Polls the health check endpoint every 500ms for up to 10 seconds.
  Future<bool> _pollHealthCheck(RcloneService service) async {
    const pollInterval = Duration(milliseconds: 500);
    const timeout = Duration(seconds: 10);

    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (await service.healthCheck()) return true;
      await Future.delayed(pollInterval);
    }
    return false;
  }
}

final startupProvider = NotifierProvider<StartupNotifier, StartupState>(
  StartupNotifier.new,
);
