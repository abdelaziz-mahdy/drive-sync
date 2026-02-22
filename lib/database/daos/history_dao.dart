import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'history_dao.g.dart';

/// Lightweight record for a transferred file.
class TransferredFileRecord {
  final String fileName;
  final int fileSize;
  final String? completedAt;

  const TransferredFileRecord({
    required this.fileName,
    required this.fileSize,
    this.completedAt,
  });
}

/// Full history entry with optional file records.
class HistoryEntryWithFiles {
  final SyncHistoryEntryRow entry;
  final List<TransferredFileRecord> files;

  const HistoryEntryWithFiles({required this.entry, required this.files});
}

@DriftAccessor(tables: [SyncHistoryEntries, TransferredFiles])
class HistoryDao extends DatabaseAccessor<AppDatabase>
    with _$HistoryDaoMixin {
  HistoryDao(super.db);

  static const int maxEntries = 500;

  /// Load all history entries (most recent first), without file records.
  Future<List<SyncHistoryEntryRow>> loadAll() async {
    return (select(syncHistoryEntries)
          ..orderBy([
            (t) => OrderingTerm.desc(t.timestamp),
          ]))
        .get();
  }

  /// Load a single history entry with its transferred files.
  Future<HistoryEntryWithFiles?> getWithFiles(int historyId) async {
    final entry = await (select(syncHistoryEntries)
          ..where((t) => t.id.equals(historyId)))
        .getSingleOrNull();
    if (entry == null) return null;

    final files = await (select(transferredFiles)
          ..where((t) => t.historyId.equals(historyId))
          ..orderBy([(t) => OrderingTerm.asc(t.fileName)]))
        .get();

    return HistoryEntryWithFiles(
      entry: entry,
      files: files
          .map((f) => TransferredFileRecord(
                fileName: f.fileName,
                fileSize: f.fileSize,
                completedAt: f.completedAt,
              ))
          .toList(),
    );
  }

  /// Add a history entry with transferred file records. Returns the history ID.
  Future<int> addEntry({
    required String profileId,
    required DateTime timestamp,
    required String status,
    required int filesTransferred,
    required int bytesTransferred,
    required int durationMs,
    String? error,
    List<TransferredFileRecord> files = const [],
  }) async {
    return transaction(() async {
      final historyId = await into(syncHistoryEntries).insert(
        SyncHistoryEntriesCompanion.insert(
          profileId: profileId,
          timestamp: timestamp,
          status: status,
          filesTransferred: Value(filesTransferred),
          bytesTransferred: Value(bytesTransferred),
          durationMs: Value(durationMs),
          error: Value(error),
        ),
      );

      for (final file in files) {
        await into(transferredFiles).insert(
          TransferredFilesCompanion.insert(
            historyId: historyId,
            fileName: file.fileName,
            fileSize: Value(file.fileSize),
            completedAt: Value(file.completedAt),
          ),
        );
      }

      await _trimHistory();

      return historyId;
    });
  }

  /// Remove orphaned transferred file rows for history entries that report
  /// zero files transferred (stale data from before the stats-reset fix).
  Future<void> cleanOrphanedTransferredFiles() async {
    final zeroFileEntries = selectOnly(syncHistoryEntries)
      ..addColumns([syncHistoryEntries.id])
      ..where(syncHistoryEntries.filesTransferred.equals(0));
    await (delete(transferredFiles)
          ..where((t) => t.historyId.isInQuery(zeroFileEntries)))
        .go();
  }

  Future<void> _trimHistory() async {
    final count = await syncHistoryEntries.count().getSingle();
    if (count <= maxEntries) return;

    final oldest = await (select(syncHistoryEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1, offset: maxEntries))
        .getSingleOrNull();
    if (oldest == null) return;

    // Delete transferred files for old entries.
    final oldIds = selectOnly(syncHistoryEntries)
      ..addColumns([syncHistoryEntries.id])
      ..where(
          syncHistoryEntries.timestamp.isSmallerOrEqualValue(oldest.timestamp));
    await (delete(transferredFiles)
          ..where((t) => t.historyId.isInQuery(oldIds)))
        .go();

    // Delete old history entries.
    await (delete(syncHistoryEntries)
          ..where(
              (t) => t.timestamp.isSmallerOrEqualValue(oldest.timestamp)))
        .go();
  }
}
