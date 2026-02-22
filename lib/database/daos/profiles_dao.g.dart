// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profiles_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfilesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncProfilesTable get syncProfiles => attachedDatabase.syncProfiles;
  $ProfileLocalPathsTable get profileLocalPaths =>
      attachedDatabase.profileLocalPaths;
  $ProfileFilterTypesTable get profileFilterTypes =>
      attachedDatabase.profileFilterTypes;
  $ProfileCustomExcludesTable get profileCustomExcludes =>
      attachedDatabase.profileCustomExcludes;
  ProfilesDaoManager get managers => ProfilesDaoManager(this);
}

class ProfilesDaoManager {
  final _$ProfilesDaoMixin _db;
  ProfilesDaoManager(this._db);
  $$SyncProfilesTableTableManager get syncProfiles =>
      $$SyncProfilesTableTableManager(_db.attachedDatabase, _db.syncProfiles);
  $$ProfileLocalPathsTableTableManager get profileLocalPaths =>
      $$ProfileLocalPathsTableTableManager(
        _db.attachedDatabase,
        _db.profileLocalPaths,
      );
  $$ProfileFilterTypesTableTableManager get profileFilterTypes =>
      $$ProfileFilterTypesTableTableManager(
        _db.attachedDatabase,
        _db.profileFilterTypes,
      );
  $$ProfileCustomExcludesTableTableManager get profileCustomExcludes =>
      $$ProfileCustomExcludesTableTableManager(
        _db.attachedDatabase,
        _db.profileCustomExcludes,
      );
}
