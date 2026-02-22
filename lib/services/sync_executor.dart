import 'dart:async';

import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

import '../models/file_change.dart';
import '../models/sync_job.dart';
import '../models/sync_preview.dart';
import '../models/sync_profile.dart';
import '../utils/dio_error_handler.dart';
import 'error_classifier.dart';
import 'gitignore_service.dart';
import 'rclone_service.dart';

/// Orchestrates full sync and dry-run operations by coordinating
/// [RcloneService] calls, polling for progress, and building previews.
class SyncExecutor {
  final RcloneService rcloneService;
  final GitignoreService gitignoreService;
  final ErrorClassifier errorClassifier;
  final Talker talker;

  /// Poll interval for checking job status during sync.
  final Duration pollInterval;

  SyncExecutor({
    required this.rcloneService,
    required this.gitignoreService,
    required this.talker,
    this.errorClassifier = const ErrorClassifier(),
    this.pollInterval = const Duration(milliseconds: 500),
  });

  /// Execute a sync (or dry-run) for the given [profile].
  ///
  /// When the profile has multiple local paths, runs a sync for each path
  /// sequentially. Progress callbacks aggregate across all paths.
  Future<SyncJob> executeSync(
    SyncProfile profile, {
    bool dryRun = false,
    void Function(SyncJob)? onProgress,
    void Function(SyncPreview)? onDryRunComplete,
  }) async {
    talker.info(
      'Starting ${dryRun ? "dry run" : "sync"} for profile "${profile.name}" '
      '(${profile.localPaths.length} path(s))',
    );

    SyncJob? lastJob;
    final allDryRunTransfers = <Map<String, dynamic>>[];

    for (final localPath in profile.localPaths) {
      talker.info('Syncing path: $localPath');
      lastJob = await _executeSyncForPath(
        profile,
        localPath: localPath,
        dryRun: dryRun,
        onProgress: onProgress,
        onDryRunTransfers: dryRun
            ? (transfers) => allDryRunTransfers.addAll(transfers)
            : null,
      );

      // Stop processing remaining paths if this one errored.
      if (lastJob.status == SyncJobStatus.error) break;
    }

    // Deliver aggregated dry-run preview.
    if (dryRun && lastJob != null && lastJob.status != SyncJobStatus.error) {
      talker.debug(
        'Dry run completed with ${allDryRunTransfers.length} total transfers',
      );
      if (allDryRunTransfers.isNotEmpty) {
        talker.debug('Sample transfer data: ${allDryRunTransfers.first}');
      }
      final preview = _buildPreview(profile.id, allDryRunTransfers);
      onDryRunComplete?.call(preview);
    }
    talker.info(
      'Sync finished with status: ${lastJob?.status.name ?? "unknown"}',
    );

    return lastJob!;
  }

  /// Runs a single sync operation for one local path.
  Future<SyncJob> _executeSyncForPath(
    SyncProfile profile, {
    required String localPath,
    required bool dryRun,
    void Function(SyncJob)? onProgress,
    void Function(List<Map<String, dynamic>>)? onDryRunTransfers,
  }) async {
    // Step 1: Generate gitignore filter rules if needed.
    List<String>? gitignoreRules;
    if (profile.respectGitignore) {
      gitignoreRules =
          await gitignoreService.generateRcloneFilters(localPath);
      talker.debug('Generated ${gitignoreRules.length} gitignore filter rules');
    }

    // Step 2: Start the sync job.
    final jobId = await rcloneService.startSync(
      profile,
      gitignoreRules: gitignoreRules,
      dryRun: dryRun,
      localPathOverride: localPath,
    );
    talker.info('Job $jobId started');

    // Step 3: Create initial SyncJob and notify.
    var job = SyncJob(
      jobId: jobId,
      profileId: profile.id,
      status: SyncJobStatus.running,
      bytesTransferred: 0,
      totalBytes: 0,
      filesTransferred: 0,
      speed: 0.0,
      startTime: DateTime.now(),
    );
    onProgress?.call(job);

    // Step 4: Poll loop — first poll fires immediately, then waits between polls.
    var isFirstPoll = true;
    while (true) {
      if (!isFirstPoll) {
        await Future.delayed(pollInterval);
      }
      isFirstPoll = false;

      try {
        final statusData = await rcloneService.getJobStatus(jobId);
        final finished = statusData['finished'] as bool? ?? false;
        final success = statusData['success'] as bool? ?? false;
        final errorStr = statusData['error'] as String?;

        // Get transfer stats.
        final stats =
            await rcloneService.getTransferStats(group: 'job/$jobId');

        final SyncJobStatus newStatus;
        if (finished && !success) {
          newStatus = SyncJobStatus.error;
        } else if (finished) {
          newStatus = SyncJobStatus.finished;
        } else {
          newStatus = SyncJobStatus.running;
        }

        // Classify rclone-reported errors into user-friendly messages.
        String? userError;
        if (finished && !success) {
          final raw = errorStr ?? '';
          final classified = errorClassifier.classify(raw);
          userError = '${classified.userMessage}\n${classified.suggestion}';
        }

        final transferringList = (stats['transferring'] as List<dynamic>?)
            ?.map((t) => TransferringFile.fromJson(t as Map<String, dynamic>))
            .toList() ?? const [];

        job = job.copyWith(
          status: newStatus,
          bytesTransferred: (stats['bytes'] as int?) ?? job.bytesTransferred,
          totalBytes: (stats['totalBytes'] as int?) ?? job.totalBytes,
          filesTransferred:
              (stats['transfers'] as int?) ?? job.filesTransferred,
          totalFiles:
              (stats['totalTransfers'] as int?) ?? job.totalFiles,
          speed: (stats['speed'] as num?)?.toDouble() ?? job.speed,
          eta: (stats['eta'] as num?)?.toDouble(),
          error: userError,
          endTime: finished ? DateTime.now() : null,
          transferring: transferringList,
        );
        onProgress?.call(job);

        if (finished) break;
      } catch (e) {
        // If polling fails, produce a user-friendly error message.
        final String friendlyError;
        if (e is DioException) {
          friendlyError = DioErrorHandler.userMessage(e);
        } else {
          friendlyError = e.toString();
        }
        job = job.copyWith(
          status: SyncJobStatus.error,
          error: friendlyError,
          endTime: DateTime.now(),
        );
        onProgress?.call(job);
        break;
      }
    }

    // Collect dry run transfers.
    if (dryRun && job.status != SyncJobStatus.error) {
      final transfers =
          await rcloneService.getCompletedTransfers(group: 'job/$jobId');
      onDryRunTransfers?.call(transfers);
    }

    return job;
  }

  /// Stop a running sync job.
  Future<void> stopSync(int jobId) async {
    await rcloneService.stopJob(jobId);
  }

  /// Build a [SyncPreview] from completed rclone transfers.
  ///
  /// In dry-run mode all transfers represent "would be" changes and are
  /// classified as additions for simplicity.
  SyncPreview _buildPreview(
    String profileId,
    List<Map<String, dynamic>> transfers,
  ) {
    final changes = transfers
        .map((t) => FileChange.fromRcloneTransfer(t, FileChangeAction.add))
        .toList();

    return SyncPreview(
      profileId: profileId,
      timestamp: DateTime.now(),
      filesToAdd: changes,
      filesToUpdate: [],
      filesToDelete: [],
    );
  }
}
