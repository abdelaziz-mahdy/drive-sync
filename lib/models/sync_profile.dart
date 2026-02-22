import 'package:json_annotation/json_annotation.dart';
import 'sync_mode.dart';

part 'sync_profile.g.dart';

@JsonSerializable()
class SyncProfile {
  final String id;
  final String name;
  final String remoteName;
  final String cloudFolder;
  @JsonKey(fromJson: _localPathsFromJson, toJson: _localPathsToJson)
  final List<String> localPaths;
  final List<String> includeTypes;
  final List<String> excludeTypes;
  final bool useIncludeMode;
  @JsonKey(fromJson: SyncMode.fromJson, toJson: _syncModeToJson)
  final SyncMode syncMode;
  final int scheduleMinutes;
  final bool enabled;
  final bool respectGitignore;
  final bool excludeGitDirs;
  final List<String> customExcludes;
  final String? bandwidthLimit;
  final int maxTransfers;
  final bool checkFirst;
  final DateTime? lastSyncTime;
  final String? lastSyncStatus;
  final String? lastSyncError;

  const SyncProfile({
    required this.id,
    required this.name,
    required this.remoteName,
    required this.cloudFolder,
    required this.localPaths,
    required this.includeTypes,
    required this.excludeTypes,
    required this.useIncludeMode,
    required this.syncMode,
    required this.scheduleMinutes,
    required this.enabled,
    required this.respectGitignore,
    required this.excludeGitDirs,
    required this.customExcludes,
    this.bandwidthLimit,
    this.maxTransfers = 4,
    this.checkFirst = true,
    this.lastSyncTime,
    this.lastSyncStatus,
    this.lastSyncError,
  });

  static String _syncModeToJson(SyncMode mode) => mode.toJson();

  /// Reads localPaths from JSON, supporting both legacy `localPath` (String)
  /// and current `localPaths` (List<String>) formats.
  static List<String> _localPathsFromJson(dynamic json) {
    if (json is List) {
      return json.cast<String>();
    }
    if (json is String) {
      return [json];
    }
    return [];
  }

  static List<String> _localPathsToJson(List<String> paths) => paths;

  /// Convenience getter for the primary local path.
  String get localPath => localPaths.isNotEmpty ? localPaths.first : '';

  String get remoteFs => '$remoteName:$cloudFolder';

  String sourceFsFor(String path) {
    switch (syncMode) {
      case SyncMode.backup:
        return path;
      case SyncMode.mirror:
      case SyncMode.download:
      case SyncMode.bisync:
        return remoteFs;
    }
  }

  String destinationFsFor(String path) {
    switch (syncMode) {
      case SyncMode.backup:
        return remoteFs;
      case SyncMode.mirror:
      case SyncMode.download:
      case SyncMode.bisync:
        return path;
    }
  }

  String get sourceFs => sourceFsFor(localPath);
  String get destinationFs => destinationFsFor(localPath);

  Map<String, dynamic> toRcApiData({
    List<String>? gitignoreRules,
    bool dryRun = false,
    String? localPathOverride,
  }) {
    final path = localPathOverride ?? localPath;
    final data = <String, dynamic>{
      '_async': true,
      '_filter': buildFilterPayload(gitignoreRules: gitignoreRules),
      '_config': buildConfigPayload(dryRun: dryRun),
    };

    if (syncMode == SyncMode.bisync) {
      data['path1'] = sourceFsFor(path);
      data['path2'] = destinationFsFor(path);
    } else {
      data['srcFs'] = sourceFsFor(path);
      data['dstFs'] = destinationFsFor(path);
    }

    return data;
  }

  Map<String, dynamic> buildFilterPayload({List<String>? gitignoreRules}) {
    final filter = <String, dynamic>{};

    if (useIncludeMode && includeTypes.isNotEmpty) {
      filter['IncludeRule'] = includeTypes;
    }

    if (!useIncludeMode && excludeTypes.isNotEmpty) {
      filter['ExcludeRule'] = excludeTypes;
    }

    final filterRules = <String>[];

    if (excludeGitDirs) {
      filterRules.add('- .git/**');
    }

    for (final exclude in customExcludes) {
      filterRules.add('- $exclude');
    }

    if (gitignoreRules != null) {
      for (final rule in gitignoreRules) {
        filterRules.add('- $rule');
      }
    }

    if (filterRules.isNotEmpty) {
      filter['FilterRule'] = filterRules;
    }

    return filter;
  }

  Map<String, dynamic> buildConfigPayload({bool dryRun = false}) {
    final config = <String, dynamic>{
      'DryRun': dryRun,
      'CheckFirst': checkFirst,
      'Transfers': maxTransfers,
    };

    if (bandwidthLimit != null) {
      config['BwLimit'] = bandwidthLimit;
    }

    return config;
  }

  SyncProfile copyWith({
    String? id,
    String? name,
    String? remoteName,
    String? cloudFolder,
    List<String>? localPaths,
    List<String>? includeTypes,
    List<String>? excludeTypes,
    bool? useIncludeMode,
    SyncMode? syncMode,
    int? scheduleMinutes,
    bool? enabled,
    bool? respectGitignore,
    bool? excludeGitDirs,
    List<String>? customExcludes,
    String? bandwidthLimit,
    int? maxTransfers,
    bool? checkFirst,
    DateTime? lastSyncTime,
    String? lastSyncStatus,
    String? lastSyncError,
  }) {
    return SyncProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      remoteName: remoteName ?? this.remoteName,
      cloudFolder: cloudFolder ?? this.cloudFolder,
      localPaths: localPaths ?? this.localPaths,
      includeTypes: includeTypes ?? this.includeTypes,
      excludeTypes: excludeTypes ?? this.excludeTypes,
      useIncludeMode: useIncludeMode ?? this.useIncludeMode,
      syncMode: syncMode ?? this.syncMode,
      scheduleMinutes: scheduleMinutes ?? this.scheduleMinutes,
      enabled: enabled ?? this.enabled,
      respectGitignore: respectGitignore ?? this.respectGitignore,
      excludeGitDirs: excludeGitDirs ?? this.excludeGitDirs,
      customExcludes: customExcludes ?? this.customExcludes,
      bandwidthLimit: bandwidthLimit ?? this.bandwidthLimit,
      maxTransfers: maxTransfers ?? this.maxTransfers,
      checkFirst: checkFirst ?? this.checkFirst,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncError: lastSyncError ?? this.lastSyncError,
    );
  }

  factory SyncProfile.fromJson(Map<String, dynamic> json) =>
      _$SyncProfileFromJson(json);

  Map<String, dynamic> toJson() => _$SyncProfileToJson(this);
}
