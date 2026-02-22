import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/history_dao.dart';
import '../models/sync_history_entry.dart';
import '../models/sync_job.dart';
import '../models/sync_queue_entry.dart';
import 'profiles_provider.dart';
import 'rclone_provider.dart';
import 'sync_executor_provider.dart';
import 'sync_history_provider.dart';
import 'talker_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class SyncQueueState {
  final List<SyncQueueEntry> queue;
  final SyncJob? activeJob;

  const SyncQueueState({this.queue = const [], this.activeJob});

  bool get isIdle => activeJob == null && queue.isEmpty;

  bool get hasActiveJob =>
      activeJob != null && (activeJob!.isRunning || activeJob!.isQueued);

  bool isQueued(String profileId) =>
      queue.any((e) => e.profileId == profileId);

  bool isRunning(String profileId) =>
      activeJob != null &&
      activeJob!.profileId == profileId &&
      activeJob!.isRunning;

  bool isActiveOrQueued(String profileId) =>
      isRunning(profileId) || isQueued(profileId);

  /// 1-based queue position, or -1 if not queued.
  int queuePositionOf(String profileId) {
    final idx = queue.indexWhere((e) => e.profileId == profileId);
    return idx == -1 ? -1 : idx + 1;
  }

  SyncQueueState copyWith({
    List<SyncQueueEntry>? queue,
    SyncJob? activeJob,
    bool clearActiveJob = false,
  }) {
    return SyncQueueState(
      queue: queue ?? this.queue,
      activeJob: clearActiveJob ? null : (activeJob ?? this.activeJob),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SyncQueueNotifier extends Notifier<SyncQueueState> {
  @override
  SyncQueueState build() => const SyncQueueState();

  /// Add a profile to the sync queue. Silently skips duplicates.
  void enqueue(String profileId) {
    if (state.isActiveOrQueued(profileId)) return;
    state = state.copyWith(
      queue: [
        ...state.queue,
        SyncQueueEntry(
          profileId: profileId,
          enqueuedAt: DateTime.now(),
        ),
      ],
    );
    _processNext();
  }

  /// Enqueue all given profiles (skips duplicates).
  void enqueueAll(List<String> profileIds) {
    for (final id in profileIds) {
      enqueue(id);
    }
  }

  /// Remove a pending profile from the queue (does not cancel active sync).
  void dequeue(String profileId) {
    state = state.copyWith(
      queue: state.queue.where((e) => e.profileId != profileId).toList(),
    );
  }

  /// Cancel the currently running sync job.
  Future<void> cancelActive() async {
    final job = state.activeJob;
    if (job == null || !job.isRunning) return;
    final executor = ref.read(syncExecutorProvider);
    await executor.stopSync(job.jobId);
  }

  /// Clear the queue and cancel the active job.
  Future<void> cancelAll() async {
    state = state.copyWith(queue: [], clearActiveJob: true);
    await cancelActive();
  }

  // -------------------------------------------------------------------------
  // Internal
  // -------------------------------------------------------------------------

  void _processNext() {
    if (state.hasActiveJob) return;
    if (state.queue.isEmpty) return;

    final entry = state.queue.first;

    // Move from queue → active with a sentinel queued job.
    state = state.copyWith(
      queue: state.queue.sublist(1),
      activeJob: SyncJob(
        jobId: -1,
        profileId: entry.profileId,
        status: SyncJobStatus.queued,
        bytesTransferred: 0,
        totalBytes: 0,
        filesTransferred: 0,
        speed: 0,
        startTime: DateTime.now(),
      ),
    );

    // Defer async work to avoid re-entrancy during state mutation.
    Future.microtask(() => _executeProfile(entry.profileId));
  }

  Future<void> _executeProfile(String profileId) async {
    final talker = ref.read(talkerProvider);
    final executor = ref.read(syncExecutorProvider);
    final profilesNotifier = ref.read(profilesProvider.notifier);
    final historyNotifier = ref.read(syncHistoryProvider.notifier);
    final startTime = DateTime.now();

    final profiles = ref.read(profilesProvider).value ?? [];
    final profile = profiles.where((p) => p.id == profileId).firstOrNull;

    if (profile == null) {
      talker.warning('SyncQueue: profile $profileId not found, skipping');
      state = state.copyWith(clearActiveJob: true);
      _processNext();
      return;
    }

    try {
      // Reset transfer stats before starting so we only capture this sync's files.
      final rcloneService = ref.read(rcloneServiceProvider);
      try {
        await rcloneService.resetStats();
      } catch (_) {
        // Best-effort: stats reset may fail if daemon is not ready.
      }

      final job = await executor.executeSync(
        profile,
        onProgress: (job) {
          state = state.copyWith(activeJob: job);
        },
      );

      final isSuccess = job.status == SyncJobStatus.finished;

      // Collect transferred file records only when files actually moved.
      List<TransferredFileRecord> transferredFiles = [];
      if (job.filesTransferred > 0) {
        try {
          final transfers = await rcloneService.getCompletedTransfers(
            group: 'job/${job.jobId}',
          );
          transferredFiles = transfers
              .map((t) => TransferredFileRecord(
                    fileName: (t['name'] as String?) ?? '',
                    fileSize: (t['size'] as int?) ?? 0,
                    completedAt: t['completed_at'] as String?,
                  ))
              .toList();
        } catch (_) {
          // Best-effort: transfers may not be available.
        }
      }

      await profilesNotifier.updateProfileStatus(
        profileId,
        status: isSuccess ? 'success' : 'error',
        error: job.error,
        lastSyncTime: DateTime.now(),
      );

      await historyNotifier.addEntry(
        SyncHistoryEntry(
          profileId: profileId,
          timestamp: DateTime.now(),
          status: isSuccess ? 'success' : 'error',
          filesTransferred: job.filesTransferred,
          bytesTransferred: job.bytesTransferred,
          duration: DateTime.now().difference(startTime),
          error: job.error,
        ),
        files: transferredFiles,
      );
    } catch (e, stack) {
      talker.handle(e, stack, 'SyncQueue: error syncing profile $profileId');
    } finally {
      state = state.copyWith(clearActiveJob: true);
      _processNext();
    }
  }
}

final syncQueueProvider =
    NotifierProvider<SyncQueueNotifier, SyncQueueState>(
  SyncQueueNotifier.new,
);
