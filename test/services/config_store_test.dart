import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/app_config.dart';
import 'package:drive_sync/models/sync_history_entry.dart';
import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/services/config_store.dart';

void main() {
  late Directory tempDir;
  late ConfigStore store;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('config_store_test_');
    // Pass a secureStorage that won't be used in these tests (JSON-only tests).
    store = ConfigStore(appSupportDir: tempDir.path);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  SyncProfile testProfile({String? id, String? name, bool enabled = true}) =>
      SyncProfile(
        id: id ?? 'profile-1',
        name: name ?? 'Test Profile',
        remoteName: 'gdrive',
        cloudFolder: 'Documents',
        localPaths: ['/home/user/docs'],
        includeTypes: const [],
        excludeTypes: const [],
        useIncludeMode: false,
        syncMode: SyncMode.backup,
        scheduleMinutes: 30,
        enabled: enabled,
        respectGitignore: false,
        excludeGitDirs: false,
        customExcludes: const [],
      );

  SyncHistoryEntry testHistoryEntry({String? profileId}) => SyncHistoryEntry(
        profileId: profileId ?? 'profile-1',
        timestamp: DateTime(2024, 1, 15, 10, 30),
        status: 'success',
        filesTransferred: 10,
        bytesTransferred: 5000,
        duration: const Duration(seconds: 45),
      );

  group('ConfigStore', () {
    group('configFilePath', () {
      test('returns correct path', () {
        expect(store.configFilePath, '${tempDir.path}/config.json');
      });
    });

    group('AppConfig', () {
      test('loadAppConfig returns defaults when file does not exist', () async {
        final config = await store.loadAppConfig();
        expect(config.themeMode, ThemeMode.system);
        expect(config.launchAtLogin, false);
        expect(config.showInMenuBar, true);
        expect(config.showNotifications, true);
        expect(config.rcPort, 5572);
      });

      test('saveAppConfig and loadAppConfig roundtrip', () async {
        final config = const AppConfig(
          themeMode: ThemeMode.dark,
          launchAtLogin: true,
          showInMenuBar: false,
          showNotifications: false,
          rcPort: 9999,
        );

        await store.saveAppConfig(config);
        final loaded = await store.loadAppConfig();

        expect(loaded.themeMode, ThemeMode.dark);
        expect(loaded.launchAtLogin, true);
        expect(loaded.showInMenuBar, false);
        expect(loaded.showNotifications, false);
        expect(loaded.rcPort, 9999);
      });

      test('loadAppConfig returns defaults for empty file', () async {
        File(store.configFilePath).writeAsStringSync('');
        final config = await store.loadAppConfig();
        expect(config.themeMode, ThemeMode.system);
      });

      test('loadAppConfig returns defaults for invalid JSON', () async {
        File(store.configFilePath).writeAsStringSync('not json');
        final config = await store.loadAppConfig();
        expect(config.themeMode, ThemeMode.system);
      });
    });

    group('Profiles', () {
      test('loadProfiles returns empty list when file does not exist',
          () async {
        final profiles = await store.loadProfiles();
        expect(profiles, isEmpty);
      });

      test('saveProfile adds new profile', () async {
        final profile = testProfile();
        await store.saveProfile(profile);

        final profiles = await store.loadProfiles();
        expect(profiles.length, 1);
        expect(profiles[0].id, 'profile-1');
        expect(profiles[0].name, 'Test Profile');
      });

      test('saveProfile updates existing profile', () async {
        await store.saveProfile(testProfile());
        await store.saveProfile(testProfile(name: 'Updated Name'));

        final profiles = await store.loadProfiles();
        expect(profiles.length, 1);
        expect(profiles[0].name, 'Updated Name');
      });

      test('saveProfile adds multiple profiles', () async {
        await store.saveProfile(testProfile(id: 'p1', name: 'Profile 1'));
        await store.saveProfile(testProfile(id: 'p2', name: 'Profile 2'));

        final profiles = await store.loadProfiles();
        expect(profiles.length, 2);
      });

      test('deleteProfile removes existing profile', () async {
        await store.saveProfile(testProfile(id: 'p1'));
        await store.saveProfile(testProfile(id: 'p2'));

        await store.deleteProfile('p1');

        final profiles = await store.loadProfiles();
        expect(profiles.length, 1);
        expect(profiles[0].id, 'p2');
      });

      test('deleteProfile does nothing for non-existent profile', () async {
        await store.saveProfile(testProfile());

        await store.deleteProfile('non-existent');

        final profiles = await store.loadProfiles();
        expect(profiles.length, 1);
      });
    });

    group('History', () {
      test('loadHistory returns empty list when file does not exist', () async {
        final history = await store.loadHistory();
        expect(history, isEmpty);
      });

      test('addHistoryEntry appends entry', () async {
        await store.addHistoryEntry(testHistoryEntry());

        final history = await store.loadHistory();
        expect(history.length, 1);
        expect(history[0].profileId, 'profile-1');
        expect(history[0].status, 'success');
        expect(history[0].filesTransferred, 10);
      });

      test('addHistoryEntry keeps multiple entries', () async {
        await store.addHistoryEntry(testHistoryEntry(profileId: 'p1'));
        await store.addHistoryEntry(testHistoryEntry(profileId: 'p2'));
        await store.addHistoryEntry(testHistoryEntry(profileId: 'p3'));

        final history = await store.loadHistory();
        expect(history.length, 3);
      });

      test('addHistoryEntry trims to max 500 entries', () async {
        // Write 500 entries directly.
        final entries = List.generate(
          500,
          (i) => testHistoryEntry(profileId: 'p$i').toJson(),
        );
        final file = File(store.configFilePath);
        await file.writeAsString(
          jsonEncode({'syncHistory': entries}),
        );

        // Add one more - should trim oldest.
        await store.addHistoryEntry(testHistoryEntry(profileId: 'new'));

        final history = await store.loadHistory();
        expect(history.length, 500);
        // The first entry should now be p1 (p0 was trimmed).
        expect(history.first.profileId, 'p1');
        expect(history.last.profileId, 'new');
      });
    });

    group('coexistence', () {
      test('config, profiles, and history coexist in same file', () async {
        final config = const AppConfig(
          themeMode: ThemeMode.light,
          launchAtLogin: false,
          showInMenuBar: true,
          showNotifications: true,
        );
        await store.saveAppConfig(config);
        await store.saveProfile(testProfile());
        await store.addHistoryEntry(testHistoryEntry());

        // Verify all data is present.
        final loadedConfig = await store.loadAppConfig();
        expect(loadedConfig.themeMode, ThemeMode.light);

        final profiles = await store.loadProfiles();
        expect(profiles.length, 1);

        final history = await store.loadHistory();
        expect(history.length, 1);
      });
    });

    group('generateCredential', () {
      test('returns 16-character string', () {
        final cred = ConfigStore.generateCredential();
        expect(cred.length, 16);
      });

      test('generates different values each time', () {
        final cred1 = ConfigStore.generateCredential();
        final cred2 = ConfigStore.generateCredential();
        expect(cred1, isNot(equals(cred2)));
      });
    });
  });
}
