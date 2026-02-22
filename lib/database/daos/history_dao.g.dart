// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_dao.dart';

// ignore_for_file: type=lint
mixin _$HistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncProfilesTable get syncProfiles => attachedDatabase.syncProfiles;
  $SyncHistoryEntriesTable get syncHistoryEntries =>
      attachedDatabase.syncHistoryEntries;
  $TransferredFilesTable get transferredFiles =>
      attachedDatabase.transferredFiles;
  HistoryDaoManager get managers => HistoryDaoManager(this);
}

class HistoryDaoManager {
  final _$HistoryDaoMixin _db;
  HistoryDaoManager(this._db);
  $$SyncProfilesTableTableManager get syncProfiles =>
      $$SyncProfilesTableTableManager(_db.attachedDatabase, _db.syncProfiles);
  $$SyncHistoryEntriesTableTableManager get syncHistoryEntries =>
      $$SyncHistoryEntriesTableTableManager(
        _db.attachedDatabase,
        _db.syncHistoryEntries,
      );
  $$TransferredFilesTableTableManager get transferredFiles =>
      $$TransferredFilesTableTableManager(
        _db.attachedDatabase,
        _db.transferredFiles,
      );
}
