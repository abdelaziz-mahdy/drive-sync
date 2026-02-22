// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncProfile _$SyncProfileFromJson(Map<String, dynamic> json) => SyncProfile(
  id: json['id'] as String,
  name: json['name'] as String,
  remoteName: json['remoteName'] as String,
  cloudFolder: json['cloudFolder'] as String,
  localPaths: SyncProfile._localPathsFromJson(json['localPaths'] ?? json['localPath']),
  includeTypes: (json['includeTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  excludeTypes: (json['excludeTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  useIncludeMode: json['useIncludeMode'] as bool,
  syncMode: SyncMode.fromJson(json['syncMode'] as String),
  scheduleMinutes: (json['scheduleMinutes'] as num).toInt(),
  enabled: json['enabled'] as bool,
  respectGitignore: json['respectGitignore'] as bool,
  excludeGitDirs: json['excludeGitDirs'] as bool,
  customExcludes: (json['customExcludes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bandwidthLimit: json['bandwidthLimit'] as String?,
  maxTransfers: (json['maxTransfers'] as num?)?.toInt() ?? 4,
  checkFirst: json['checkFirst'] as bool? ?? true,
  preserveSourceDir: json['preserveSourceDir'] as bool? ?? true,
  lastSyncTime: json['lastSyncTime'] == null
      ? null
      : DateTime.parse(json['lastSyncTime'] as String),
  lastSyncStatus: json['lastSyncStatus'] as String?,
  lastSyncError: json['lastSyncError'] as String?,
);

Map<String, dynamic> _$SyncProfileToJson(SyncProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'remoteName': instance.remoteName,
      'cloudFolder': instance.cloudFolder,
      'localPaths': SyncProfile._localPathsToJson(instance.localPaths),
      'includeTypes': instance.includeTypes,
      'excludeTypes': instance.excludeTypes,
      'useIncludeMode': instance.useIncludeMode,
      'syncMode': SyncProfile._syncModeToJson(instance.syncMode),
      'scheduleMinutes': instance.scheduleMinutes,
      'enabled': instance.enabled,
      'respectGitignore': instance.respectGitignore,
      'excludeGitDirs': instance.excludeGitDirs,
      'customExcludes': instance.customExcludes,
      'bandwidthLimit': instance.bandwidthLimit,
      'maxTransfers': instance.maxTransfers,
      'checkFirst': instance.checkFirst,
      'preserveSourceDir': instance.preserveSourceDir,
      'lastSyncTime': instance.lastSyncTime?.toIso8601String(),
      'lastSyncStatus': instance.lastSyncStatus,
      'lastSyncError': instance.lastSyncError,
    };
