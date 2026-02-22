import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  AppConfigs,
  SyncProfiles,
  ProfileLocalPaths,
  ProfileFilterTypes,
  ProfileCustomExcludes,
  SyncHistoryEntries,
  TransferredFiles,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String dbFolder)
      : super(
          NativeDatabase.createInBackground(
            File(p.join(dbFolder, 'drive_sync.db')),
          ),
        );

  /// For testing — accept a QueryExecutor directly.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
