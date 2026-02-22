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
