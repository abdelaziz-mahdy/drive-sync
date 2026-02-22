# Drift Migration & Dashboard Redesign — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace JSON file storage with Drift (SQLite), add file-level sync history, and add a prominent sync progress banner to the dashboard.

**Architecture:** Drift database with 3 DAOs (profiles, history, config) replaces `ConfigStore`. One-time migration reads existing `config.json` and imports into SQLite. New `SyncBanner` widget watches `syncQueueProvider` for live progress. History detail screen shows per-file transfer records.

**Tech Stack:** Drift 2.x, sqlite3_flutter_libs, path_provider, Flutter Riverpod

---

### Task 1: Add Drift dependencies

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Add drift packages to pubspec.yaml**

Add to `dependencies`:
```yaml
  drift: ^2.26.0
  sqlite3_flutter_libs: ^0.5.32
  path: ^1.9.0
```

Add to `dev_dependencies`:
```yaml
  drift_dev: ^2.26.0
```

**Step 2: Run pub get**

Run: `flutter pub get`
Expected: resolves without errors

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add drift and sqlite3_flutter_libs dependencies"
```

---

### Task 2: Define Drift table classes

**Files:**
- Create: `lib/database/tables.dart`

**Step 1: Create the table definitions file**

```dart
import 'package:drift/drift.dart';

class AppConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get launchAtLogin => boolean().withDefault(const Constant(false))();
  BoolColumn get showInMenuBar => boolean().withDefault(const Constant(true))();
  BoolColumn get showNotifications => boolean().withDefault(const Constant(true))();
  IntColumn get rcPort => integer().withDefault(const Constant(5572))();
  TextColumn get skippedVersion => text().nullable()();
  TextColumn get bandwidthLimit => text().nullable()();
}

class SyncProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get remoteName => text()();
  TextColumn get cloudFolder => text()();
  TextColumn get syncMode => text().withDefault(const Constant('backup'))();
  IntColumn get scheduleMinutes => integer().withDefault(const Constant(30))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  BoolColumn get respectGitignore => boolean().withDefault(const Constant(false))();
  BoolColumn get excludeGitDirs => boolean().withDefault(const Constant(false))();
  BoolColumn get preserveSourceDir => boolean().withDefault(const Constant(true))();
  BoolColumn get useIncludeMode => boolean().withDefault(const Constant(true))();
  TextColumn get bandwidthLimit => text().nullable()();
  IntColumn get maxTransfers => integer().withDefault(const Constant(4))();
  BoolColumn get checkFirst => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncTime => dateTime().nullable()();
  TextColumn get lastSyncStatus => text().nullable()();
  TextColumn get lastSyncError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

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

class SyncHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text().references(SyncProfiles, #id)();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get status => text()();
  IntColumn get filesTransferred => integer().withDefault(const Constant(0))();
  IntColumn get bytesTransferred => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();
}

class TransferredFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get historyId => integer().references(SyncHistoryEntries, #id)();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  TextColumn get completedAt => text().nullable()();
}
```

**Step 2: Commit**

```bash
git add lib/database/tables.dart
git commit -m "feat: define Drift table classes for all app data"
```

---

### Task 3: Create AppDatabase and generate code

**Files:**
- Create: `lib/database/app_database.dart`

**Step 1: Create the database class**

```dart
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
```

**Step 2: Run build_runner to generate code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: generates `lib/database/app_database.g.dart`

**Step 3: Verify generation succeeded**

Run: `dart analyze lib/database/`
Expected: no errors

**Step 4: Commit**

```bash
git add lib/database/
git commit -m "feat: create AppDatabase with Drift code generation"
```

---

### Task 4: Create ProfilesDao

**Files:**
- Create: `lib/database/daos/profiles_dao.dart`

**Step 1: Write the DAO**

The DAO needs to:
- Load a `SyncProfile` model by joining `sync_profiles` + `profile_local_paths` + `profile_filter_types` + `profile_custom_excludes`
- Save/update a `SyncProfile` (upsert profile row + delete+reinsert children)
- Delete a profile and its children
- Update profile status fields

```dart
import 'package:drift/drift.dart';
import '../../models/sync_mode.dart';
import '../../models/sync_profile.dart';
import '../app_database.dart';
import '../tables.dart';

part 'profiles_dao.g.dart';

@DriftAccessor(tables: [
  SyncProfiles,
  ProfileLocalPaths,
  ProfileFilterTypes,
  ProfileCustomExcludes,
])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin {
  ProfilesDao(super.db);

  Future<List<SyncProfile>> loadAll() async {
    final rows = await select(syncProfiles).get();
    final result = <SyncProfile>[];
    for (final row in rows) {
      result.add(await _rowToProfile(row));
    }
    return result;
  }

  Future<SyncProfile?> findById(String id) async {
    final row = await (select(syncProfiles)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _rowToProfile(row);
  }

  Future<void> saveProfile(SyncProfile profile) async {
    await transaction(() async {
      // Upsert the profile row.
      await into(syncProfiles).insertOnConflictUpdate(
        SyncProfilesCompanion.insert(
          id: profile.id,
          name: profile.name,
          remoteName: profile.remoteName,
          cloudFolder: profile.cloudFolder,
          syncMode: Value(profile.syncMode.toJson()),
          scheduleMinutes: Value(profile.scheduleMinutes),
          enabled: Value(profile.enabled),
          respectGitignore: Value(profile.respectGitignore),
          excludeGitDirs: Value(profile.excludeGitDirs),
          preserveSourceDir: Value(profile.preserveSourceDir),
          useIncludeMode: Value(profile.useIncludeMode),
          bandwidthLimit: Value(profile.bandwidthLimit),
          maxTransfers: Value(profile.maxTransfers),
          checkFirst: Value(profile.checkFirst),
          lastSyncTime: Value(profile.lastSyncTime),
          lastSyncStatus: Value(profile.lastSyncStatus),
          lastSyncError: Value(profile.lastSyncError),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Replace local paths.
      await (delete(profileLocalPaths)
            ..where((t) => t.profileId.equals(profile.id)))
          .go();
      for (final path in profile.localPaths) {
        await into(profileLocalPaths).insert(
          ProfileLocalPathsCompanion.insert(
            profileId: profile.id,
            path: path,
          ),
        );
      }

      // Replace filter types.
      await (delete(profileFilterTypes)
            ..where((t) => t.profileId.equals(profile.id)))
          .go();
      for (final t in profile.includeTypes) {
        await into(profileFilterTypes).insert(
          ProfileFilterTypesCompanion.insert(
            profileId: profile.id,
            typeValue: t,
            isInclude: true,
          ),
        );
      }
      for (final t in profile.excludeTypes) {
        await into(profileFilterTypes).insert(
          ProfileFilterTypesCompanion.insert(
            profileId: profile.id,
            typeValue: t,
            isInclude: false,
          ),
        );
      }

      // Replace custom excludes.
      await (delete(profileCustomExcludes)
            ..where((t) => t.profileId.equals(profile.id)))
          .go();
      for (final pattern in profile.customExcludes) {
        await into(profileCustomExcludes).insert(
          ProfileCustomExcludesCompanion.insert(
            profileId: profile.id,
            pattern: pattern,
          ),
        );
      }
    });
  }

  Future<void> deleteProfile(String id) async {
    await transaction(() async {
      await (delete(profileLocalPaths)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (delete(profileFilterTypes)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (delete(profileCustomExcludes)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (delete(syncProfiles)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> updateStatus(
    String id, {
    String? status,
    String? error,
    DateTime? lastSyncTime,
  }) async {
    await (update(syncProfiles)..where((t) => t.id.equals(id))).write(
      SyncProfilesCompanion(
        lastSyncStatus: Value(status),
        lastSyncError: Value(error),
        lastSyncTime: Value(lastSyncTime),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<SyncProfile> _rowToProfile(SyncProfileData row) async {
    final paths = await (select(profileLocalPaths)
          ..where((t) => t.profileId.equals(row.id)))
        .get();
    final filters = await (select(profileFilterTypes)
          ..where((t) => t.profileId.equals(row.id)))
        .get();
    final excludes = await (select(profileCustomExcludes)
          ..where((t) => t.profileId.equals(row.id)))
        .get();

    return SyncProfile(
      id: row.id,
      name: row.name,
      remoteName: row.remoteName,
      cloudFolder: row.cloudFolder,
      localPaths: paths.map((p) => p.path).toList(),
      includeTypes:
          filters.where((f) => f.isInclude).map((f) => f.typeValue).toList(),
      excludeTypes:
          filters.where((f) => !f.isInclude).map((f) => f.typeValue).toList(),
      useIncludeMode: row.useIncludeMode,
      syncMode: SyncMode.fromJson(row.syncMode),
      scheduleMinutes: row.scheduleMinutes,
      enabled: row.enabled,
      respectGitignore: row.respectGitignore,
      excludeGitDirs: row.excludeGitDirs,
      customExcludes: excludes.map((e) => e.pattern).toList(),
      bandwidthLimit: row.bandwidthLimit,
      maxTransfers: row.maxTransfers,
      checkFirst: row.checkFirst,
      preserveSourceDir: row.preserveSourceDir,
      lastSyncTime: row.lastSyncTime,
      lastSyncStatus: row.lastSyncStatus,
      lastSyncError: row.lastSyncError,
    );
  }
}
```

**Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 3: Commit**

```bash
git add lib/database/daos/
git commit -m "feat: create ProfilesDao for Drift profile CRUD"
```

---

### Task 5: Create HistoryDao

**Files:**
- Create: `lib/database/daos/history_dao.dart`

**Step 1: Write the DAO**

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'history_dao.g.dart';

/// Lightweight record for transferred file display.
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
  final SyncHistoryEntryData entry;
  final List<TransferredFileRecord> files;

  const HistoryEntryWithFiles({required this.entry, required this.files});
}

@DriftAccessor(tables: [SyncHistoryEntries, TransferredFiles])
class HistoryDao extends DatabaseAccessor<AppDatabase>
    with _$HistoryDaoMixin {
  HistoryDao(super.db);

  static const int maxEntries = 500;

  /// Load all history entries (most recent first), without file records.
  Future<List<SyncHistoryEntryData>> loadAll() async {
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

      // Trim old entries.
      await _trimHistory();

      return historyId;
    });
  }

  Future<void> _trimHistory() async {
    final count = await syncHistoryEntries.count().getSingle();
    if (count <= maxEntries) return;

    // Find the ID cutoff — keep only the most recent maxEntries.
    final oldest = await (select(syncHistoryEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1, offset: maxEntries))
        .getSingleOrNull();
    if (oldest == null) return;

    // Delete transferred files for old entries.
    final oldIds = selectOnly(syncHistoryEntries)
      ..addColumns([syncHistoryEntries.id])
      ..where(syncHistoryEntries.timestamp.isSmallerOrEqualValue(oldest.timestamp));
    await (delete(transferredFiles)
          ..where((t) => t.historyId.isInQuery(oldIds)))
        .go();

    // Delete old history entries.
    await (delete(syncHistoryEntries)
          ..where((t) => t.timestamp.isSmallerOrEqualValue(oldest.timestamp)))
        .go();
  }
}
```

**Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 3: Commit**

```bash
git add lib/database/daos/
git commit -m "feat: create HistoryDao with file records and trimming"
```

---

### Task 6: Create AppConfigDao

**Files:**
- Create: `lib/database/daos/app_config_dao.dart`

**Step 1: Write the DAO**

```dart
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../models/app_config.dart';
import '../app_database.dart';
import '../tables.dart';

part 'app_config_dao.g.dart';

@DriftAccessor(tables: [AppConfigs])
class AppConfigDao extends DatabaseAccessor<AppDatabase>
    with _$AppConfigDaoMixin {
  AppConfigDao(super.db);

  Future<AppConfig> load() async {
    final row = await select(appConfigs).getSingleOrNull();
    if (row == null) {
      // Insert defaults and return them.
      final defaults = AppConfig.defaults();
      await _upsert(defaults);
      return defaults;
    }
    return _rowToConfig(row);
  }

  Future<void> save(AppConfig config) async {
    await _upsert(config);
  }

  Future<void> _upsert(AppConfig config) async {
    await into(appConfigs).insertOnConflictUpdate(
      AppConfigsCompanion.insert(
        id: const Value(1),
        themeMode: Value(config.themeMode.name),
        launchAtLogin: Value(config.launchAtLogin),
        showInMenuBar: Value(config.showInMenuBar),
        showNotifications: Value(config.showNotifications),
        rcPort: Value(config.rcPort),
        skippedVersion: Value(config.skippedVersion),
      ),
    );
  }

  AppConfig _rowToConfig(AppConfigData row) {
    return AppConfig(
      themeMode: _parseThemeMode(row.themeMode),
      launchAtLogin: row.launchAtLogin,
      showInMenuBar: row.showInMenuBar,
      showNotifications: row.showNotifications,
      rcPort: row.rcPort,
      skippedVersion: row.skippedVersion,
    );
  }

  static ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'dark': return ThemeMode.dark;
      case 'light': return ThemeMode.light;
      default: return ThemeMode.system;
    }
  }
}
```

**Step 2: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 3: Commit**

```bash
git add lib/database/daos/
git commit -m "feat: create AppConfigDao for singleton config row"
```

---

### Task 7: JSON → Drift migration logic

**Files:**
- Create: `lib/database/migration.dart`

**Step 1: Write migration service**

This reads the existing `config.json`, inserts data into Drift, and renames the file to `.bak`.

```dart
import 'dart:convert';
import 'dart:io';

import '../models/app_config.dart';
import '../models/sync_profile.dart';
import '../models/sync_history_entry.dart';
import 'app_database.dart';
import 'daos/app_config_dao.dart';
import 'daos/history_dao.dart';
import 'daos/profiles_dao.dart';

/// Migrates data from the legacy config.json to Drift.
///
/// Call [migrateIfNeeded] once at startup. It checks for the JSON file,
/// imports all data, and renames the file to .bak.
class JsonToDriftMigration {
  final String appSupportDir;
  final AppDatabase db;

  JsonToDriftMigration({
    required this.appSupportDir,
    required this.db,
  });

  String get _configPath => '$appSupportDir/config.json';
  String get _backupPath => '$appSupportDir/config.json.bak';

  /// Returns true if migration was performed.
  Future<bool> migrateIfNeeded() async {
    final configFile = File(_configPath);
    if (!await configFile.exists()) return false;

    try {
      final contents = await configFile.readAsString();
      if (contents.trim().isEmpty) {
        await configFile.rename(_backupPath);
        return false;
      }

      final data = jsonDecode(contents) as Map<String, dynamic>;

      // Migrate app config.
      final appConfigJson = data['appConfig'] as Map<String, dynamic>?;
      if (appConfigJson != null) {
        final config = AppConfig.fromJson(appConfigJson);
        await AppConfigDao(db).save(config);
      }

      // Migrate profiles.
      final profilesJson = data['profiles'] as List<dynamic>? ?? [];
      final profilesDao = ProfilesDao(db);
      for (final pJson in profilesJson) {
        final profile = SyncProfile.fromJson(pJson as Map<String, dynamic>);
        await profilesDao.saveProfile(profile);
      }

      // Migrate history (without file records — old entries don't have them).
      final historyJson = data['syncHistory'] as List<dynamic>? ?? [];
      final historyDao = HistoryDao(db);
      for (final hJson in historyJson) {
        final entry =
            SyncHistoryEntry.fromJson(hJson as Map<String, dynamic>);
        await historyDao.addEntry(
          profileId: entry.profileId,
          timestamp: entry.timestamp,
          status: entry.status,
          filesTransferred: entry.filesTransferred,
          bytesTransferred: entry.bytesTransferred,
          durationMs: entry.duration.inMilliseconds,
          error: entry.error,
        );
      }

      // Rename the old file.
      await configFile.rename(_backupPath);
      return true;
    } catch (e) {
      // If migration fails, leave the file in place for retry.
      rethrow;
    }
  }
}
```

**Step 2: Commit**

```bash
git add lib/database/migration.dart
git commit -m "feat: add JSON to Drift migration service"
```

---

### Task 8: Wire database into providers and main.dart

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/providers/app_config_provider.dart`
- Modify: `lib/providers/profiles_provider.dart`
- Modify: `lib/providers/sync_history_provider.dart`
- Modify: `lib/providers/startup_provider.dart`

**Step 1: Create database provider**

Add to `lib/providers/app_config_provider.dart` (or a new file `lib/providers/database_provider.dart`):

Create `lib/providers/database_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

/// The app-wide Drift database instance.
/// Overridden in main.dart with the real database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden');
});
```

**Step 2: Update main.dart**

Replace `ConfigStore` creation with `AppDatabase` creation. Run migration. Override `appDatabaseProvider` instead of `configStoreProvider`.

Key changes:
- Create `AppDatabase(dirPath)` instead of `ConfigStore(appSupportDir: dirPath)`
- Run `JsonToDriftMigration(appSupportDir: dirPath, db: db).migrateIfNeeded()`
- RC credentials stay in `FlutterSecureStorage` (move secure storage calls out of ConfigStore to a small helper or keep them inline)
- Override `appDatabaseProvider` in `ProviderScope`

**Step 3: Update ProfilesNotifier**

Replace `ref.read(configStoreProvider)` with `ProfilesDao(ref.read(appDatabaseProvider))`.

**Step 4: Update SyncHistoryNotifier**

Replace `ref.read(configStoreProvider)` with `HistoryDao(ref.read(appDatabaseProvider))`.

**Step 5: Update AppConfigNotifier**

Replace `ref.read(configStoreProvider)` with `AppConfigDao(ref.read(appDatabaseProvider))`.

**Step 6: Update StartupNotifier**

Replace `ref.read(configStoreProvider).loadProfiles()` with `ProfilesDao(ref.read(appDatabaseProvider)).loadAll()`.

**Step 7: Run tests**

Run: `flutter test`
Expected: existing tests may need `appDatabaseProvider` override instead of `configStoreProvider`

**Step 8: Commit**

```bash
git add lib/providers/ lib/main.dart
git commit -m "refactor: wire Drift database into all providers, replace ConfigStore"
```

---

### Task 9: Update tests for Drift

**Files:**
- Modify: `test/services/config_store_test.dart` → convert or delete
- Modify: `test/screens/dashboard_test.dart`
- Modify: `test/screens/shell_test.dart`
- Create: `test/database/profiles_dao_test.dart`
- Create: `test/database/history_dao_test.dart`

**Step 1: Create in-memory database helper for tests**

```dart
// test/database/test_database.dart
import 'package:drift/native.dart';
import 'package:drive_sync/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
```

**Step 2: Write ProfilesDao tests**

Test: save profile, load all, find by id, delete, update status.

**Step 3: Write HistoryDao tests**

Test: add entry with files, load all, get with files, trim history.

**Step 4: Update widget tests**

Replace `configStoreProvider` overrides with `appDatabaseProvider` overrides using in-memory database.

**Step 5: Run all tests**

Run: `flutter test`
Expected: all pass

**Step 6: Commit**

```bash
git add test/
git commit -m "test: add Drift DAO tests and update widget tests for database"
```

---

### Task 10: Collect transferred files during sync

**Files:**
- Modify: `lib/providers/sync_queue_provider.dart`

**Step 1: Update _executeProfile to collect completed transfers**

After `executor.executeSync()` completes, call `rcloneService.getCompletedTransfers(group: 'job/${job.jobId}')` and pass the file records when adding the history entry.

Key changes to `_executeProfile`:
```dart
// After the job finishes, collect completed transfers.
List<TransferredFileRecord> transferredFiles = [];
try {
  final rcloneService = ref.read(rcloneServiceProvider);
  final transfers = await rcloneService.getCompletedTransfers(
    group: 'job/${job.jobId}',
  );
  transferredFiles = transfers
      .map((t) => TransferredFileRecord(
            fileName: (t['name'] as String?) ?? '',
            fileSize: (t['size'] as int?) ?? 0,
            completedAt: t['completed_at'] as String?,
          ))
      .toList();
} catch (_) {
  // Best-effort: transfers may not be available.
}

// Then pass files to historyDao.addEntry(..., files: transferredFiles)
```

**Step 2: Commit**

```bash
git add lib/providers/sync_queue_provider.dart
git commit -m "feat: collect transferred file records after sync for history"
```

---

### Task 11: Dashboard sync banner widget

**Files:**
- Create: `lib/screens/dashboard/sync_banner.dart`
- Modify: `lib/screens/dashboard/dashboard_screen.dart`

**Step 1: Create SyncBanner widget**

A full-width animated card that appears when `syncQueueProvider` has an active job. Shows:
- Profile name + sync mode icon
- Full-width progress bar with percentage
- Stats row (files, speed, ETA)
- Currently transferring files (up to 4)
- Cancel button
- Queue count chip if items are queued

The banner uses `AnimatedSlide` + `AnimatedOpacity` to slide in from top.

**Step 2: Integrate into DashboardScreen**

Insert the banner above the profile cards grid in the `SingleChildScrollView`. Wrap in `Consumer` watching `syncQueueProvider`.

When `queueState.isIdle`, the banner is completely absent (not rendered at all).

**Step 3: Visually test**

Run: `flutter run -d macos`
Trigger a sync and verify the banner appears with progress.

**Step 4: Commit**

```bash
git add lib/screens/dashboard/
git commit -m "feat: add full-width sync progress banner to dashboard"
```

---

### Task 12: History detail screen

**Files:**
- Create: `lib/screens/activity/history_detail_screen.dart`
- Modify: `lib/screens/activity/sync_history_tile.dart`

**Step 1: Create HistoryDetailScreen**

A full Scaffold screen showing:
- Summary stat cards (file count, bytes, duration) in a Row at top
- Profile name, sync mode, timestamp, source → destination
- Scrollable ListView of transferred files (name + size)
- Error section if applicable

The screen accepts a `historyId` and loads via `HistoryDao.getWithFiles()`.

**Step 2: Update SyncHistoryTile**

Replace `_showDetailDialog` with navigation push to `HistoryDetailScreen(historyId: entry.id)`.

Note: The tile now needs the history entry's database ID. Update the activity screen to pass it through.

**Step 3: Commit**

```bash
git add lib/screens/activity/
git commit -m "feat: add history detail screen with file transfer list"
```

---

### Task 13: Clean up old ConfigStore

**Files:**
- Delete: `lib/services/config_store.dart`
- Delete: `test/services/config_store_test.dart`
- Modify: `lib/models/sync_history_entry.dart` — remove json_serializable annotations (keep class for migration compatibility, or use Drift types directly)
- Modify: `pubspec.yaml` — remove `json_annotation` and `json_serializable` if no longer used

**Step 1: Check if json_serializable is still used**

Check if `SyncProfile`, `AppConfig`, or any model still uses `@JsonSerializable`. If they do (for the migration path reading config.json), keep the deps. If migration is self-contained with manual JSON parsing, remove them.

Decision: Keep `@JsonSerializable` on `SyncProfile`, `AppConfig`, and `SyncHistoryEntry` for the migration path only. These models are still used as domain objects — the JSON serialization is needed for the one-time migration from `config.json`.

**Step 2: Delete ConfigStore**

```bash
rm lib/services/config_store.dart test/services/config_store_test.dart
```

**Step 3: Remove configStoreProvider references**

Search for remaining `configStoreProvider` references and remove/replace them.

**Step 4: Run tests**

Run: `flutter test`
Expected: all pass

**Step 5: Run analyze**

Run: `dart analyze`
Expected: no errors

**Step 6: Commit**

```bash
git add -A
git commit -m "refactor: remove ConfigStore, all data now through Drift"
```

---

### Task 14: Final verification

**Step 1: Run full analysis**

Run: `dart analyze`
Expected: 0 errors

**Step 2: Run all tests**

Run: `flutter test`
Expected: all pass

**Step 3: Manual smoke test**

Run: `flutter run -d macos`
- Verify app starts (migration runs if config.json exists)
- Create a profile, verify it persists after restart
- Trigger a sync, verify dashboard banner shows progress
- After sync completes, check history — click entry, verify file list shows
- Check settings still work (theme, launch at login, etc.)

**Step 4: Final commit**

```bash
git add -A
git commit -m "feat: complete Drift migration with sync banner and history detail"
```
