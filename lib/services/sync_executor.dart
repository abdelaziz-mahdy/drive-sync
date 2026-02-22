import 'dart:async';

import 'package:dio/dio.dart';

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

  /// Poll interval for checking job status during sync.
  final Duration pollInterval;

  SyncExecutor({
    required this.rcloneService,
    required this.gitignoreService,
    this.errorClassifier = const ErrorClassifier(),
    this.pollInterval = const Duration(seconds: 2),
  });

  /// Execute a sync (or dry-run) for the given [profile].
  ///
  /// 1. Optionally generates gitignore filter rules.
  /// 2. Starts the rclone sync job.
  /// 3. Polls for progress, invoking [onProgress] with each update.
  /// 4. For dry runs, collects completed transfers and invokes [onDryRunComplete].
  /// 5. Returns the final [SyncJob].
  Future<SyncJob> executeSync(
    SyncProfile profile, {
    bool dryRun = false,
    void Function(SyncJob)? onProgress,
    void Function(SyncPreview)? onDryRunComplete,
  }) async {
    // Step 1: Generate gitignore filter rules if needed.
    List<String>? gitignoreRules;
    if (profile.respectGitignore) {
      gitignoreRules =
          await gitignoreService.generateRcloneFilters(profile.localPath);
    }

    // Step 2: Start the sync job.
    final jobId = await rcloneService.startSync(
      profile,
      gitignoreRules: gitignoreRules,
      dryRun: dryRun,
    );

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

    // Step 4: Poll loop.
    while (true) {
      await Future.delayed(pollInterval);

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

        job = job.copyWith(
          status: newStatus,
          bytesTransferred: (stats['bytes'] as int?) ?? job.bytesTransferred,
          totalBytes: (stats['totalBytes'] as int?) ?? job.totalBytes,
          filesTransferred:
              (stats['transfers'] as int?) ?? job.filesTransferred,
          speed: (stats['speed'] as num?)?.toDouble() ?? job.speed,
          error: userError,
          endTime: finished ? DateTime.now() : null,
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

    // Step 5: For dry runs, build and deliver the preview.
    if (dryRun && job.status != SyncJobStatus.error) {
      final transfers =
          await rcloneService.getCompletedTransfers(group: 'job/$jobId');
      final preview = _buildPreview(profile.id, transfers);
      onDryRunComplete?.call(preview);
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
