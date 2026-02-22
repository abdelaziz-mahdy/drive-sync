import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_job.dart';

/// Manages active sync jobs state.
class SyncJobsNotifier extends Notifier<Map<String, SyncJob>> {
  @override
  Map<String, SyncJob> build() => {};

  void addJob(SyncJob job) {
    state = {...state, job.profileId: job};
  }

  void updateJob(String profileId, SyncJob job) {
    state = {...state, profileId: job};
  }

  void removeJob(String profileId) {
    state = Map.from(state)..remove(profileId);
  }

  SyncJob? getJob(String profileId) => state[profileId];

  bool hasRunningJob(String profileId) {
    final job = state[profileId];
    return job != null && job.isRunning;
  }

  bool get hasAnyRunningJobs => state.values.any((j) => j.isRunning);
}

final syncJobsProvider =
    NotifierProvider<SyncJobsNotifier, Map<String, SyncJob>>(
  SyncJobsNotifier.new,
);
