import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/app_config.dart';
import '../models/sync_history_entry.dart';
import '../models/sync_profile.dart';

/// Manages JSON config file storage and secure storage for secrets.
class ConfigStore {
  final String appSupportDir;
  final FlutterSecureStorage _secureStorage;

  /// Maximum number of history entries to retain.
  static const int maxHistoryEntries = 500;

  ConfigStore({
    required this.appSupportDir,
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Path to the main configuration JSON file.
  String get configFilePath => '$appSupportDir/config.json';

  // ---------------------------------------------------------------------------
  // App Config
  // ---------------------------------------------------------------------------

  /// Loads the application configuration from disk, or returns defaults.
  Future<AppConfig> loadAppConfig() async {
    final data = await _readConfigFile();
    final appConfigJson = data['appConfig'] as Map<String, dynamic>?;
    if (appConfigJson == null) return AppConfig.defaults();
    return AppConfig.fromJson(appConfigJson);
  }

  /// Saves the application configuration to disk.
  Future<void> saveAppConfig(AppConfig config) async {
    final data = await _readConfigFile();
    data['appConfig'] = config.toJson();
    await _writeConfigFile(data);
  }

  // ---------------------------------------------------------------------------
  // Profiles
  // ---------------------------------------------------------------------------

  /// Loads all sync profiles from disk.
  Future<List<SyncProfile>> loadProfiles() async {
    final data = await _readConfigFile();
    final profilesJson = data['profiles'] as List<dynamic>? ?? [];
    return profilesJson
        .map((e) => SyncProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Saves or updates a sync profile. If a profile with the same ID exists,
  /// it is replaced; otherwise, the profile is appended.
  Future<void> saveProfile(SyncProfile profile) async {
    final data = await _readConfigFile();
    final profilesJson = data['profiles'] as List<dynamic>? ?? [];

    final index = profilesJson.indexWhere(
      (e) => (e as Map<String, dynamic>)['id'] == profile.id,
    );

    if (index >= 0) {
      profilesJson[index] = profile.toJson();
    } else {
      profilesJson.add(profile.toJson());
    }

    data['profiles'] = profilesJson;
    await _writeConfigFile(data);
  }

  /// Deletes a sync profile by its ID.
  Future<void> deleteProfile(String profileId) async {
    final data = await _readConfigFile();
    final profilesJson = data['profiles'] as List<dynamic>? ?? [];

    profilesJson.removeWhere(
      (e) => (e as Map<String, dynamic>)['id'] == profileId,
    );

    data['profiles'] = profilesJson;
    await _writeConfigFile(data);
  }

  // ---------------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------------

  /// Loads the sync history from disk.
  Future<List<SyncHistoryEntry>> loadHistory() async {
    final data = await _readConfigFile();
    final historyJson = data['syncHistory'] as List<dynamic>? ?? [];
    return historyJson
        .map((e) => SyncHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Appends a history entry, keeping only the last [maxHistoryEntries].
  Future<void> addHistoryEntry(SyncHistoryEntry entry) async {
    final data = await _readConfigFile();
    final historyJson = data['syncHistory'] as List<dynamic>? ?? [];

    historyJson.add(entry.toJson());

    // Trim to max entries.
    if (historyJson.length > maxHistoryEntries) {
      data['syncHistory'] =
          historyJson.sublist(historyJson.length - maxHistoryEntries);
    } else {
      data['syncHistory'] = historyJson;
    }

    await _writeConfigFile(data);
  }

  // ---------------------------------------------------------------------------
  // Secure Storage
  // ---------------------------------------------------------------------------

  /// Saves RC credentials to secure storage.
  Future<void> saveRcCredentials(String user, String pass) async {
    await _secureStorage.write(key: 'rc_user', value: user);
    await _secureStorage.write(key: 'rc_pass', value: pass);
  }

  /// Loads RC credentials from secure storage.
  Future<({String user, String pass})?> loadRcCredentials() async {
    final user = await _secureStorage.read(key: 'rc_user');
    final pass = await _secureStorage.read(key: 'rc_pass');
    if (user == null || pass == null) return null;
    return (user: user, pass: pass);
  }

  /// Saves the rclone config encryption password to secure storage.
  Future<void> saveConfigPass(String pass) async {
    await _secureStorage.write(key: 'config_pass', value: pass);
  }

  /// Loads the rclone config encryption password from secure storage.
  Future<String?> loadConfigPass() async {
    return await _secureStorage.read(key: 'config_pass');
  }

  /// Generates a random credential string for first-launch RC auth.
  static String generateCredential() => const Uuid().v4().substring(0, 16);

  // ---------------------------------------------------------------------------
  // Internal JSON file I/O
  // ---------------------------------------------------------------------------

  /// Reads the entire config file as a JSON map. Returns an empty map if the
  /// file does not exist or is invalid.
  Future<Map<String, dynamic>> _readConfigFile() async {
    final file = File(configFilePath);
    if (!await file.exists()) return {};

    try {
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) return {};
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Writes the given data map to the config file as formatted JSON.
  Future<void> _writeConfigFile(Map<String, dynamic> data) async {
    final file = File(configFilePath);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }
}
