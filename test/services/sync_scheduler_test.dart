import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/services/sync_scheduler.dart';

void main() {
  SyncProfile testProfile({
    String? id,
    int scheduleMinutes = 30,
    bool enabled = true,
  }) =>
      SyncProfile(
        id: id ?? 'profile-1',
        name: 'Test Profile',
        remoteName: 'gdrive',
        cloudFolder: 'Documents',
        localPath: '/home/user/docs',
        includeTypes: const [],
        excludeTypes: const [],
        useIncludeMode: false,
        syncMode: SyncMode.backup,
        scheduleMinutes: scheduleMinutes,
        enabled: enabled,
        respectGitignore: false,
        excludeGitDirs: false,
        customExcludes: const [],
      );

  group('SyncScheduler', () {
    test('scheduleProfile creates a timer that fires on interval', () {
      fakeAsync((async) {
        final firedProfiles = <String>[];
        final scheduler = SyncScheduler(
          onSyncDue: (profile) => firedProfiles.add(profile.id),
        );

        scheduler.scheduleProfile(testProfile(scheduleMinutes: 10));

        expect(scheduler.isScheduled('profile-1'), true);
        expect(firedProfiles, isEmpty);

        // Advance 10 minutes - should fire once.
        async.elapse(const Duration(minutes: 10));
        expect(firedProfiles.length, 1);

        // Advance another 10 minutes - should fire again.
        async.elapse(const Duration(minutes: 10));
        expect(firedProfiles.length, 2);

        scheduler.dispose();
      });
    });

    test('unscheduleProfile cancels the timer', () {
      fakeAsync((async) {
        final firedProfiles = <String>[];
        final scheduler = SyncScheduler(
          onSyncDue: (profile) => firedProfiles.add(profile.id),
        );

        scheduler.scheduleProfile(testProfile(scheduleMinutes: 10));
        expect(scheduler.isScheduled('profile-1'), true);

        scheduler.unscheduleProfile('profile-1');
        expect(scheduler.isScheduled('profile-1'), false);

        // Advance time - should not fire.
        async.elapse(const Duration(minutes: 30));
        expect(firedProfiles, isEmpty);

        scheduler.dispose();
      });
    });

    test('scheduleProfile skips profiles with scheduleMinutes <= 0', () {
      fakeAsync((async) {
        final firedProfiles = <String>[];
        final scheduler = SyncScheduler(
          onSyncDue: (profile) => firedProfiles.add(profile.id),
        );

        scheduler.scheduleProfile(testProfile(scheduleMinutes: 0));
        expect(scheduler.isScheduled('profile-1'), false);

        async.elapse(const Duration(hours: 1));
        expect(firedProfiles, isEmpty);

        scheduler.dispose();
      });
    });

    test('scheduleProfile skips disabled profiles', () {
      fakeAsync((async) {
        final firedProfiles = <String>[];
        final scheduler = SyncScheduler(
          onSyncDue: (profile) => firedProfiles.add(profile.id),
        );

        scheduler.scheduleProfile(testProfile(enabled: false));
        expect(scheduler.isScheduled('profile-1'), false);

        async.elapse(const Duration(hours: 1));
        expect(firedProfiles, isEmpty);

        scheduler.dispose();
      });
    });

    test('scheduleProfile replaces existing timer for same profile', () {
      fakeAsync((async) {
        final firedProfiles = <String>[];
        final scheduler = SyncScheduler(
          onSyncDue: (profile) => firedProfiles.add(profile.id),
        );

        // Schedule with 10 minute interval.
        scheduler.scheduleProfile(testProfile(scheduleMinutes: 10));

        // Re-schedule with 20 minute interval.
        scheduler.scheduleProfile(testProfile(scheduleMinutes: 20));
        expect(scheduler.isScheduled('profile-1'), true);

        // After 10 minutes - should NOT fire (old timer cancelled).
        async.elapse(const Duration(minutes: 10));
        expect(firedProfiles, isEmpty);

        // After 20 minutes total - should fire (new timer).
        async.elapse(const Duration(minutes: 10));
        expect(firedProfiles.length, 1);

        scheduler.dispose();
      });
    });

    test('rescheduleAll adds new profiles and removes stale ones', () {
      fakeAsync((async) {
        final firedProfiles = <String>[];
        final scheduler = SyncScheduler(
          onSyncDue: (profile) => firedProfiles.add(profile.id),
        );

        // Start with profiles p1 and p2.
        scheduler.scheduleProfile(testProfile(id: 'p1', scheduleMinutes: 10));
        scheduler.scheduleProfile(testProfile(id: 'p2', scheduleMinutes: 10));

        // Reschedule with only p2 and p3.
        scheduler.rescheduleAll([
          testProfile(id: 'p2', scheduleMinutes: 15),
          testProfile(id: 'p3', scheduleMinutes: 5),
        ]);

        expect(scheduler.isScheduled('p1'), false);
        expect(scheduler.isScheduled('p2'), true);
        expect(scheduler.isScheduled('p3'), true);

        // p3 fires first at 5 minutes.
        async.elapse(const Duration(minutes: 5));
        expect(firedProfiles, ['p3']);

        scheduler.dispose();
      });
    });

    test('dispose cancels all timers', () {
      fakeAsync((async) {
        final firedProfiles = <String>[];
        final scheduler = SyncScheduler(
          onSyncDue: (profile) => firedProfiles.add(profile.id),
        );

        scheduler.scheduleProfile(testProfile(id: 'p1', scheduleMinutes: 10));
        scheduler.scheduleProfile(testProfile(id: 'p2', scheduleMinutes: 10));

        scheduler.dispose();

        expect(scheduler.isScheduled('p1'), false);
        expect(scheduler.isScheduled('p2'), false);

        async.elapse(const Duration(hours: 1));
        expect(firedProfiles, isEmpty);
      });
    });

    test('isScheduled returns false for unknown profile', () {
      final scheduler = SyncScheduler(onSyncDue: (_) {});
      expect(scheduler.isScheduled('unknown'), false);
      scheduler.dispose();
    });
  });
}
