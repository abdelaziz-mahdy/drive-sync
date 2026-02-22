// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_dao.dart';

// ignore_for_file: type=lint
mixin _$AppConfigDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppConfigsTable get appConfigs => attachedDatabase.appConfigs;
  AppConfigDaoManager get managers => AppConfigDaoManager(this);
}

class AppConfigDaoManager {
  final _$AppConfigDaoMixin _db;
  AppConfigDaoManager(this._db);
  $$AppConfigsTableTableManager get appConfigs =>
      $$AppConfigsTableTableManager(_db.attachedDatabase, _db.appConfigs);
}
