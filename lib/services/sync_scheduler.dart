import 'dart:async';

import '../models/sync_profile.dart';

/// Manages periodic sync timers for scheduled profiles.
class SyncScheduler {
  final Map<String, Timer> _timers = {};
  final void Function(SyncProfile profile) onSyncDue;

  SyncScheduler({required this.onSyncDue});

  /// Schedules a periodic sync for the given profile. If the profile is
  /// already scheduled, it is first unscheduled. Profiles with
  /// [scheduleMinutes] <= 0 or [enabled] == false are skipped.
  void scheduleProfile(SyncProfile profile) {
    unscheduleProfile(profile.id);
    if (profile.scheduleMinutes <= 0 || !profile.enabled) return;

    _timers[profile.id] = Timer.periodic(
      Duration(minutes: profile.scheduleMinutes),
      (_) => onSyncDue(profile),
    );
  }

  /// Cancels the scheduled sync for the given profile ID.
  void unscheduleProfile(String profileId) {
    _timers[profileId]?.cancel();
    _timers.remove(profileId);
  }

  /// Reschedules all profiles, removing timers for profiles no longer in the
  /// list.
  void rescheduleAll(List<SyncProfile> profiles) {
    final activeIds = profiles.map((p) => p.id).toSet();
    _timers.keys
        .where((id) => !activeIds.contains(id))
        .toList()
        .forEach(unscheduleProfile);
    for (final profile in profiles) {
      scheduleProfile(profile);
    }
  }

  /// Returns true if the given profile ID has an active timer.
  bool isScheduled(String profileId) => _timers.containsKey(profileId);

  /// Cancels all timers and clears the internal state.
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
