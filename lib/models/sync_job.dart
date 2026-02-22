enum SyncJobStatus { running, finished, error }

class TransferringFile {
  final String name;
  final int size;
  final int bytesTransferred;
  final double speed;
  final double percentage;

  const TransferringFile({
    required this.name,
    required this.size,
    required this.bytesTransferred,
    required this.speed,
    required this.percentage,
  });

  factory TransferringFile.fromJson(Map<String, dynamic> data) {
    return TransferringFile(
      name: data['name'] as String? ?? '',
      size: (data['size'] as int?) ?? 0,
      bytesTransferred: (data['bytes'] as int?) ?? 0,
      speed: (data['speed'] as num?)?.toDouble() ?? 0,
      percentage: (data['percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SyncJob {
  final int jobId;
  final String profileId;
  final SyncJobStatus status;
  final int bytesTransferred;
  final int totalBytes;
  final int filesTransferred;
  final int totalFiles;
  final double speed;
  final double? eta;
  final String? error;
  final DateTime startTime;
  final DateTime? endTime;
  final List<TransferringFile> transferring;

  const SyncJob({
    required this.jobId,
    required this.profileId,
    required this.status,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.filesTransferred,
    this.totalFiles = 0,
    required this.speed,
    this.eta,
    this.error,
    required this.startTime,
    this.endTime,
    this.transferring = const [],
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
    int? totalFiles,
    double? speed,
    double? eta,
    String? error,
    DateTime? startTime,
    DateTime? endTime,
    List<TransferringFile>? transferring,
  }) {
    return SyncJob(
      jobId: jobId ?? this.jobId,
      profileId: profileId ?? this.profileId,
      status: status ?? this.status,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      totalBytes: totalBytes ?? this.totalBytes,
      filesTransferred: filesTransferred ?? this.filesTransferred,
      totalFiles: totalFiles ?? this.totalFiles,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
      error: error ?? this.error,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      transferring: transferring ?? this.transferring,
    );
  }
}
