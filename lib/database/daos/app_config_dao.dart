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

  AppConfig _rowToConfig(AppConfigRow row) {
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
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}
