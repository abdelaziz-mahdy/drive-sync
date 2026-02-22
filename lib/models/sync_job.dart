enum SyncJobStatus { running, finished, error }

class SyncJob {
  final int jobId;
  final String profileId;
  final SyncJobStatus status;
  final int bytesTransferred;
  final int totalBytes;
  final int filesTransferred;
  final double speed;
  final String? error;
  final DateTime startTime;
  final DateTime? endTime;

  const SyncJob({
    required this.jobId,
    required this.profileId,
    required this.status,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.filesTransferred,
    required this.speed,
    this.error,
    required this.startTime,
    this.endTime,
  });

  bool get isRunning => status == SyncJobStatus.running;

  double get progress => totalBytes > 0 ? bytesTransferred / totalBytes : 0;

  factory SyncJob.fromRcResponse({
    required String profileId,
    required Map<String, dynamic> data,
  }) {
    final finished = data['finished'] as bool? ?? false;
    final success = data['success'] as bool? ?? false;
    final errorStr = data['error'] as String?;
    final hasError = finished && !success;

    SyncJobStatus status;
    if (hasError) {
      status = SyncJobStatus.error;
    } else if (finished) {
      status = SyncJobStatus.finished;
    } else {
      status = SyncJobStatus.running;
    }

    final progress = data['progress'] as Map<String, dynamic>?;

    return SyncJob(
      jobId: data['jobid'] as int,
      profileId: profileId,
      status: status,
      bytesTransferred: (progress?['bytes'] as int?) ?? 0,
      totalBytes: (progress?['totalBytes'] as int?) ?? 0,
      filesTransferred: (progress?['files'] as int?) ?? 0,
      speed: (progress?['speed'] as num?)?.toDouble() ?? 0.0,
      error: hasError ? (errorStr ?? '') : null,
      startTime: DateTime.parse(data['startTime'] as String),
      endTime: data['endTime'] != null
          ? DateTime.parse(data['endTime'] as String)
          : null,
    );
  }

  SyncJob copyWith({
    int? jobId,
    String? profileId,
    SyncJobStatus? status,
    int? bytesTransferred,
    int? totalBytes,
    int? filesTransferred,
    double? speed,
    String? error,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return SyncJob(
      jobId: jobId ?? this.jobId,
      profileId: profileId ?? this.profileId,
      status: status ?? this.status,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      totalBytes: totalBytes ?? this.totalBytes,
      filesTransferred: filesTransferred ?? this.filesTransferred,
      speed: speed ?? this.speed,
      error: error ?? this.error,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
