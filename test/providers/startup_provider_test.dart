import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/providers/startup_provider.dart';

void main() {
  group('StartupState', () {
    test('initial state has cleaningUp phase', () {
      const state = StartupState.initial();
      expect(state.phase, StartupPhase.cleaningUp);
      expect(state.message, 'Initializing...');
      expect(state.errorDetail, isNull);
      expect(state.needsOnboarding, isFalse);
    });

    test('rcloneNotFound state provides install instructions', () {
      const state = StartupState(
        phase: StartupPhase.rcloneNotFound,
        message: 'rclone not found',
        errorDetail:
            'rclone is not installed or not available on the system PATH.\n'
            'Please install rclone and restart DriveSync.',
      );
      expect(state.phase, StartupPhase.rcloneNotFound);
      expect(state.errorDetail, contains('install'));
      expect(state.errorDetail, contains('PATH'));
    });

    test('error state includes detail', () {
      const state = StartupState(
        phase: StartupPhase.error,
        message: 'Startup failed',
        errorDetail: 'The rclone daemon did not respond within 10 seconds.',
      );
      expect(state.phase, StartupPhase.error);
      expect(state.errorDetail, isNotNull);
    });

    test('ready state with needsOnboarding indicates no remotes', () {
      const state = StartupState(
        phase: StartupPhase.ready,
        message: 'Ready',
        needsOnboarding: true,
      );
      expect(state.phase, StartupPhase.ready);
      expect(state.needsOnboarding, isTrue);
    });

    test('ready state without onboarding indicates remotes exist', () {
      const state = StartupState(
        phase: StartupPhase.ready,
        message: 'Ready',
        needsOnboarding: false,
      );
      expect(state.needsOnboarding, isFalse);
    });
  });

  group('StartupPhase', () {
    test('has all expected phases', () {
      expect(StartupPhase.values, containsAll([
        StartupPhase.cleaningUp,
        StartupPhase.checkingRclone,
        StartupPhase.startingDaemon,
        StartupPhase.waitingForDaemon,
        StartupPhase.loadingProfiles,
        StartupPhase.ready,
        StartupPhase.rcloneNotFound,
        StartupPhase.error,
      ]));
    });

    test('rcloneNotFound is distinct from generic error', () {
      expect(StartupPhase.rcloneNotFound, isNot(StartupPhase.error));
    });
  });
}
