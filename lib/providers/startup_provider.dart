import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/profiles_dao.dart';
import '../services/rclone_daemon_manager.dart';
import '../services/rclone_service.dart';
import '../services/secure_storage.dart';
import 'database_provider.dart';
import 'rclone_provider.dart';
import 'talker_provider.dart';

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
      talker.info('[Startup] Phase 1: Cleaning up stale processes');
      state = const StartupState(
        phase: StartupPhase.cleaningUp,
        message: 'Cleaning up stale processes...',
      );
      await daemonManager.cleanupStale();
      talker.debug('[Startup] Stale process cleanup complete');

      // Phase 2 - Check rclone is installed.
      talker.info('[Startup] Phase 2: Checking rclone installation');
      state = const StartupState(
        phase: StartupPhase.checkingRclone,
        message: 'Checking rclone installation...',
      );
      final installed = await daemonManager.isRcloneInstalled();
      final rclonePath = await daemonManager.getRclonePath();
      talker.info('[Startup] rclone installed: $installed (path: ${rclonePath ?? 'not found'})');

      if (!installed) {
        talker.error('[Startup] rclone not found on PATH');
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
        talker.info('[Startup] Phase 3: Starting rclone daemon');
        state = const StartupState(
          phase: StartupPhase.startingDaemon,
          message: 'Starting rclone daemon...',
        );
        await _startDaemon(daemonManager);
        talker.debug('[Startup] Daemon start command issued');
      } else {
        talker.info('[Startup] Phase 3: Daemon already running, skipping start');
      }

      // Phase 4 - Wait for health check.
      talker.info('[Startup] Phase 4: Polling daemon health check');
      state = const StartupState(
        phase: StartupPhase.waitingForDaemon,
        message: 'Connecting to rclone daemon...',
      );
      final healthy = await _pollHealthCheck(rcloneService);
      if (!healthy) {
        talker.error('[Startup] Daemon health check timed out after 10 seconds');
        // Log daemon process output for diagnostics.
        for (final processLog in daemonManager.processLogs) {
          talker.debug('[rclone] $processLog');
        }
        state = const StartupState(
          phase: StartupPhase.error,
          message: 'Failed to connect to daemon',
          errorDetail:
              'The rclone daemon did not respond within 10 seconds.\n'
              'Please check that rclone is working correctly and retry.',
        );
        return;
      }
      talker.info('[Startup] Daemon health check passed');

      // Phase 5 - Load profiles and check remotes.
      talker.info('[Startup] Phase 5: Loading profiles and checking remotes');
      state = const StartupState(
        phase: StartupPhase.loadingProfiles,
        message: 'Loading profiles...',
      );

      List<String> remotes = [];
      try {
        remotes = await rcloneService.listRemotes();
        talker.info('[Startup] Found ${remotes.length} remote(s): ${remotes.join(', ')}');
      } catch (e) {
        talker.warning('[Startup] Could not list remotes: $e');
      }

      final profilesDao = ProfilesDao(ref.read(appDatabaseProvider));
      final profiles = await profilesDao.loadAll();
      talker.info('[Startup] Found ${profiles.length} profile(s)');

      final needsOnboarding = remotes.isEmpty && profiles.isEmpty;
      talker.debug('[Startup] Needs onboarding: $needsOnboarding');

      // Phase 6 - Done!
      talker.info('[Startup] Phase 6: Startup complete');
      state = StartupState(
        phase: StartupPhase.ready,
        message: 'Ready',
        needsOnboarding: needsOnboarding,
      );
    } catch (e, stack) {
      talker.handle(e, stack, '[Startup] Fatal error');
      state = StartupState(
        phase: StartupPhase.error,
        message: 'Startup failed',
        errorDetail: e.toString(),
      );
    }
  }

  /// Starts the rclone daemon using stored credentials.
  Future<void> _startDaemon(RcloneDaemonManager daemonManager) async {
    final secureStorage = SecureStorageService();
    final creds = await secureStorage.loadRcCredentials();
    if (creds == null) {
      throw Exception('RC credentials not found in secure storage.');
    }
    await daemonManager.start(user: creds.user, pass: creds.pass);
  }

  /// Polls the health check endpoint every 500ms for up to 10 seconds.
  Future<bool> _pollHealthCheck(RcloneService service) async {
    const pollInterval = Duration(milliseconds: 500);
    const timeout = Duration(seconds: 10);

    var attempt = 0;
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      attempt++;
      try {
        if (await service.healthCheck()) {
          talker.debug('[Startup] Health check passed on attempt $attempt');
          return true;
        }
      } catch (e) {
        talker.debug('[Startup] Health check attempt $attempt failed: $e');
      }
      await Future.delayed(pollInterval);
    }
    talker.warning('[Startup] Health check timed out after $attempt attempts');
    return false;
  }
}

final startupProvider = NotifierProvider<StartupNotifier, StartupState>(
  StartupNotifier.new,
);
