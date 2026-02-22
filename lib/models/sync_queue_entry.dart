/// Represents a profile waiting in the sync queue.
///
/// Queue entries are in-memory only and not persisted across restarts.
class SyncQueueEntry {
  final String profileId;
  final DateTime enqueuedAt;

  const SyncQueueEntry({
    required this.profileId,
    required this.enqueuedAt,
  });
}
