import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/daos/history_dao.dart';
import '../models/sync_history_entry.dart';
import 'database_provider.dart';

class SyncHistoryNotifier extends AsyncNotifier<List<SyncHistoryEntry>> {
  @override
  Future<List<SyncHistoryEntry>> build() async {
    final dao = HistoryDao(ref.read(appDatabaseProvider));
    // One-time cleanup of stale transferred file rows from before the fix.
    await dao.cleanOrphanedTransferredFiles();
    final rows = await dao.loadAll();
    return rows.map(_rowToEntry).toList();
  }

  Future<void> addEntry(
    SyncHistoryEntry entry, {
    List<TransferredFileRecord> files = const [],
  }) async {
    final dao = HistoryDao(ref.read(appDatabaseProvider));
    await dao.addEntry(
      profileId: entry.profileId,
      timestamp: entry.timestamp,
      status: entry.status,
      filesTransferred: entry.filesTransferred,
      bytesTransferred: entry.bytesTransferred,
      durationMs: entry.duration.inMilliseconds,
      error: entry.error,
      files: files,
    );
    final rows = await dao.loadAll();
    state = AsyncData(rows.map(_rowToEntry).toList());
  }

  static SyncHistoryEntry _rowToEntry(SyncHistoryEntryRow row) {
    return SyncHistoryEntry(
      id: row.id,
      profileId: row.profileId,
      timestamp: row.timestamp,
      status: row.status,
      filesTransferred: row.filesTransferred,
      bytesTransferred: row.bytesTransferred,
      duration: Duration(milliseconds: row.durationMs),
      error: row.error,
    );
  }
}

final syncHistoryProvider =
    AsyncNotifierProvider<SyncHistoryNotifier, List<SyncHistoryEntry>>(
  SyncHistoryNotifier.new,
);
