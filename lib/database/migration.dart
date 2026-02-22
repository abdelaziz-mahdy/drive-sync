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
