// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncHistoryEntry _$SyncHistoryEntryFromJson(Map<String, dynamic> json) =>
    SyncHistoryEntry(
      profileId: json['profileId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      filesTransferred: (json['filesTransferred'] as num).toInt(),
      bytesTransferred: (json['bytesTransferred'] as num).toInt(),
      duration: SyncHistoryEntry._durationFromJson(
        (json['duration'] as num).toInt(),
      ),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$SyncHistoryEntryToJson(SyncHistoryEntry instance) =>
    <String, dynamic>{
      'profileId': instance.profileId,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': instance.status,
      'filesTransferred': instance.filesTransferred,
      'bytesTransferred': instance.bytesTransferred,
      'duration': SyncHistoryEntry._durationToJson(instance.duration),
      'error': instance.error,
    };
