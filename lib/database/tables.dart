import 'package:drift/drift.dart';

@DataClassName('AppConfigRow')
class AppConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get launchAtLogin =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get showInMenuBar =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get showNotifications =>
      boolean().withDefault(const Constant(true))();
  IntColumn get rcPort => integer().withDefault(const Constant(5572))();
  TextColumn get skippedVersion => text().nullable()();
  TextColumn get bandwidthLimit => text().nullable()();
}

@DataClassName('SyncProfileRow')
class SyncProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get remoteName => text()();
  TextColumn get cloudFolder => text()();
  TextColumn get syncMode =>
      text().withDefault(const Constant('backup'))();
  IntColumn get scheduleMinutes =>
      integer().withDefault(const Constant(30))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  BoolColumn get respectGitignore =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get excludeGitDirs =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get preserveSourceDir =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get useIncludeMode =>
      boolean().withDefault(const Constant(true))();
  TextColumn get bandwidthLimit => text().nullable()();
  IntColumn get maxTransfers =>
      integer().withDefault(const Constant(4))();
  BoolColumn get checkFirst =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncTime => dateTime().nullable()();
  TextColumn get lastSyncStatus => text().nullable()();
  TextColumn get lastSyncError => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ProfileLocalPaths extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text().references(SyncProfiles, #id)();
  TextColumn get path => text()();
}

class ProfileFilterTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text().references(SyncProfiles, #id)();
  TextColumn get typeValue => text()();
  BoolColumn get isInclude => boolean()();
}

class ProfileCustomExcludes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text().references(SyncProfiles, #id)();
  TextColumn get pattern => text()();
}

@DataClassName('SyncHistoryEntryRow')
class SyncHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text().references(SyncProfiles, #id)();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get status => text()();
  IntColumn get filesTransferred =>
      integer().withDefault(const Constant(0))();
  IntColumn get bytesTransferred =>
      integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();
}

@DataClassName('TransferredFileRow')
class TransferredFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get historyId =>
      integer().references(SyncHistoryEntries, #id)();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  TextColumn get completedAt => text().nullable()();
}
