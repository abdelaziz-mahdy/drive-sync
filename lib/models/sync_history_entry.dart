import 'package:json_annotation/json_annotation.dart';

part 'sync_history_entry.g.dart';

@JsonSerializable()
class SyncHistoryEntry {
  /// Database row ID. Null for entries not yet persisted.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? id;
  final String profileId;
  final DateTime timestamp;
  final String status;
  final int filesTransferred;
  final int bytesTransferred;
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration duration;
  final String? error;

  const SyncHistoryEntry({
    this.id,
    required this.profileId,
    required this.timestamp,
    required this.status,
    required this.filesTransferred,
    required this.bytesTransferred,
    required this.duration,
    this.error,
  });

  static Duration _durationFromJson(int milliseconds) =>
      Duration(milliseconds: milliseconds);

  static int _durationToJson(Duration duration) => duration.inMilliseconds;

  factory SyncHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$SyncHistoryEntryFromJson(json);

  Map<String, dynamic> toJson() => _$SyncHistoryEntryToJson(this);
}
