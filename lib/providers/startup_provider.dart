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

  /// Startup log entries for diagnostics.
  final List<String> logs;

  const StartupState({
    required this.phase,
    required this.message,
    this.errorDetail,
    this.needsOnboarding = false,
    this.logs = const [],
  });

  const StartupState.initial()
      : phase = StartupPhase.cleaningUp,
        message = 'Initializing...',
        errorDetail = null,
        needsOnboarding = false,
        logs = const [];
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
    final logs = <String>[];

    void log(String message) {
      final timestamp = DateTime.now().toIso8601String().substring(11, 23);
      logs.add('[$timestamp] $message');
    }

    try {
      final daemonManager = ref.read(daemonManagerProvider);
      final rcloneService = ref.read(rcloneServiceProvider);

      // Phase 1 - Cleanup stale processes.
      log('Phase 1: Cleaning up stale processes');
      state = StartupState(
        phase: StartupPhase.cleaningUp,
        message: 'Cleaning up stale processes...',
        logs: List.unmodifiable(logs),
      );
      await daemonManager.cleanupStale();
      log('Stale process cleanup complete');

      // Phase 2 - Check rclone is installed.
      log('Phase 2: Checking rclone installation');
      state = StartupState(
        phase: StartupPhase.checkingRclone,
        message: 'Checking rclone installation...',
        logs: List.unmodifiable(logs),
      );
      final installed = await daemonManager.isRcloneInstalled();
      final rclonePath = await daemonManager.getRclonePath();
      log('rclone installed: $installed (path: ${rclonePath ?? 'not found'})');

      if (!installed) {
        log('ERROR: rclone not found on PATH');
        state = StartupState(
          phase: StartupPhase.rcloneNotFound,
          message: 'rclone not found',
          errorDetail:
              'rclone is not installed or not available on the system PATH.\n'
              'Please install rclone and restart DriveSync.',
          logs: List.unmodifiable(logs),
        );
        return;
      }

      // Phase 3 - Start the rclone daemon if not already running.
      if (!daemonManager.isRunning) {
        log('Phase 3: Starting rclone daemon');
        state = StartupState(
          phase: StartupPhase.startingDaemon,
          message: 'Starting rclone daemon...',
          logs: List.unmodifiable(logs),
        );
        await _startDaemon(daemonManager);
        log('Daemon start command issued');
      } else {
        log('Phase 3: Daemon already running, skipping start');
      }

      // Phase 4 - Wait for health check.
      log('Phase 4: Polling daemon health check');
      state = StartupState(
        phase: StartupPhase.waitingForDaemon,
        message: 'Connecting to rclone daemon...',
        logs: List.unmodifiable(logs),
      );
      final healthy = await _pollHealthCheck(rcloneService, log);
      if (!healthy) {
        log('ERROR: Daemon health check timed out after 10 seconds');
        // Include daemon process logs in the startup logs.
        for (final processLog in daemonManager.processLogs) {
          logs.add(processLog);
        }
        state = StartupState(
          phase: StartupPhase.error,
          message: 'Failed to connect to daemon',
          errorDetail:
              'The rclone daemon did not respond within 10 seconds.\n'
              'Please check that rclone is working correctly and retry.',
          logs: List.unmodifiable(logs),
        );
        return;
      }
      log('Daemon health check passed');

      // Phase 5 - Load profiles and check remotes.
      log('Phase 5: Loading profiles and checking remotes');
      state = StartupState(
        phase: StartupPhase.loadingProfiles,
        message: 'Loading profiles...',
        logs: List.unmodifiable(logs),
      );

      List<String> remotes = [];
      try {
        remotes = await rcloneService.listRemotes();
        log('Found ${remotes.length} remote(s): ${remotes.join(', ')}');
      } catch (e) {
        log('Warning: Could not list remotes: $e');
      }

      final configStore = ref.read(configStoreProvider);
      final profiles = await configStore.loadProfiles();
      log('Found ${profiles.length} profile(s)');

      final needsOnboarding = remotes.isEmpty && profiles.isEmpty;
      log('Needs onboarding: $needsOnboarding');

      // Phase 6 - Done!
      log('Phase 6: Startup complete');
      state = StartupState(
        phase: StartupPhase.ready,
        message: 'Ready',
        needsOnboarding: needsOnboarding,
        logs: List.unmodifiable(logs),
      );
    } catch (e, stack) {
      log('FATAL ERROR: $e');
      log('Stack trace: $stack');
      state = StartupState(
        phase: StartupPhase.error,
        message: 'Startup failed',
        errorDetail: e.toString(),
        logs: List.unmodifiable(logs),
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
  Future<bool> _pollHealthCheck(
    RcloneService service, [
    void Function(String)? log,
  ]) async {
    const pollInterval = Duration(milliseconds: 500);
    const timeout = Duration(seconds: 10);

    var attempt = 0;
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      attempt++;
      try {
        if (await service.healthCheck()) {
          log?.call('Health check passed on attempt $attempt');
          return true;
        }
      } catch (e) {
        log?.call('Health check attempt $attempt failed: $e');
      }
      await Future.delayed(pollInterval);
    }
    log?.call('Health check timed out after $attempt attempts');
    return false;
  }
}

final startupProvider = NotifierProvider<StartupNotifier, StartupState>(
  StartupNotifier.new,
);
