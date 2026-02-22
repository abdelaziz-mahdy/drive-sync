# DriveSync Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a complete, professional cross-platform desktop app for selective file-type syncing with Google Drive via rclone's RC API.

**Architecture:** Material 3 Flutter desktop app with Riverpod state management, communicating with rclone rcd daemon over HTTP. Custom light/dark theme, sidebar navigation, system tray background service.

**Tech Stack:** Flutter 3.x desktop, Riverpod 3.2.1, Dio 5.9.1, rclone RC API, GitHub Releases API

**Team Structure:** Tasks are organized into 7 workstreams. Workstreams 1 must complete first, then 2-4 can run in parallel, then 5 depends on 2-4, then 6 depends on 5, then 7 is final polish.

```
Workstream 1: Project Setup & Models (foundation)
    ↓
Workstream 2: Core Services ──┐
Workstream 3: Theme & Widgets ├── parallel
Workstream 4: Gitignore Svc ──┘
    ↓
Workstream 5: Providers & State (depends on 2,3,4)
    ↓
Workstream 6: Screens & UI (depends on 5)
    ↓
Workstream 7: Integration, System Tray & Polish (depends on 6)
```

---

## Workstream 1: Project Setup & Models

### Task 1.1: Create Flutter Project & Configure Dependencies

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Modify: `macos/Runner/DebugProfile.entitlements`
- Modify: `macos/Runner/Release.entitlements`

**Step 1: Create Flutter macOS desktop project**

Run:
```bash
cd /Users/AbdelazizMahdy/flutter_projects/sync
flutter create . --project-name drive_sync --org com.drivesync --platforms macos,windows,linux
```

**Step 2: Update pubspec.yaml with all dependencies**

Replace the dependencies section in `pubspec.yaml`:

```yaml
name: drive_sync
description: Selective file-type syncing with Google Drive via rclone
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.6.0

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.2.1
  riverpod_annotation: ^4.0.2
  dio: ^5.9.1
  flutter_secure_storage: ^10.0.0
  path_provider: ^2.1.5
  flutter_markdown: ^0.7.7+1
  file_picker: ^6.0.0
  system_tray: ^2.0.0
  launch_at_startup: ^0.3.0
  uuid: ^4.0.0
  intl: ^0.19.0
  json_annotation: ^4.0.0
  url_launcher: ^6.0.0
  package_info_plus: ^8.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.0.0
  json_serializable: ^6.0.0
  riverpod_generator: ^4.0.3
  flutter_lints: ^3.0.0
  mockito: ^5.0.0
  build_runner_core: ^8.0.0
  http_mock_adapter: ^0.6.0
```

**Step 3: Configure macOS entitlements**

Disable sandbox, enable network + filesystem + process execution in both `DebugProfile.entitlements` and `Release.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>com.apple.security.app-sandbox</key>
  <false/>
  <key>com.apple.security.network.client</key>
  <true/>
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
</dict>
</plist>
```

**Step 4: Run flutter pub get**

Run: `flutter pub get`
Expected: Dependencies resolve successfully.

**Step 5: Verify project builds**

Run: `flutter build macos --debug`
Expected: Build succeeds.

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: initialize Flutter project with all dependencies"
```

---

### Task 1.2: Create SyncMode Enum & SyncProfile Model

**Files:**
- Create: `lib/models/sync_mode.dart`
- Create: `lib/models/sync_profile.dart`
- Create: `test/models/sync_profile_test.dart`

**Step 1: Write the failing test**

```dart
// test/models/sync_profile_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_profile.dart';

void main() {
  group('SyncMode', () {
    test('has correct rclone command mapping', () {
      expect(SyncMode.backup.rcloneCommand, 'copy');
      expect(SyncMode.mirror.rcloneCommand, 'sync');
      expect(SyncMode.download.rcloneCommand, 'copy');
      expect(SyncMode.bisync.rcloneCommand, 'bisync');
    });

    test('has correct RC API endpoint mapping', () {
      expect(SyncMode.backup.rcEndpoint, '/sync/copy');
      expect(SyncMode.mirror.rcEndpoint, '/sync/sync');
      expect(SyncMode.download.rcEndpoint, '/sync/copy');
      expect(SyncMode.bisync.rcEndpoint, '/sync/bisync');
    });

    test('has correct direction description', () {
      expect(SyncMode.backup.direction, 'Local → Cloud');
      expect(SyncMode.mirror.direction, 'Cloud → Local');
      expect(SyncMode.download.direction, 'Cloud → Local');
      expect(SyncMode.bisync.direction, 'Bidirectional');
    });

    test('serializes to and from JSON string', () {
      for (final mode in SyncMode.values) {
        expect(SyncMode.fromJson(mode.toJson()), mode);
      }
    });
  });

  group('SyncProfile', () {
    late SyncProfile profile;

    setUp(() {
      profile = SyncProfile(
        id: 'test-uuid-123',
        name: 'Work Backup',
        remoteName: 'gdrive',
        cloudFolder: 'Backups/Work',
        localPath: '/Users/me/projects/work',
        includeTypes: ['py', 'js', 'md'],
        excludeTypes: [],
        useIncludeMode: true,
        syncMode: SyncMode.backup,
        scheduleMinutes: 15,
        enabled: true,
        respectGitignore: true,
        excludeGitDirs: true,
        customExcludes: ['*.log', 'node_modules/**'],
        bandwidthLimit: null,
        maxTransfers: 4,
        checkFirst: true,
      );
    });

    test('serializes to JSON and back', () {
      final json = profile.toJson();
      final restored = SyncProfile.fromJson(json);
      expect(restored.id, profile.id);
      expect(restored.name, profile.name);
      expect(restored.syncMode, profile.syncMode);
      expect(restored.includeTypes, profile.includeTypes);
      expect(restored.respectGitignore, true);
      expect(restored.checkFirst, true);
    });

    test('source and destination are correct for backup mode', () {
      expect(profile.sourceFs, '/Users/me/projects/work');
      expect(profile.destinationFs, 'gdrive:Backups/Work');
    });

    test('source and destination are correct for mirror mode', () {
      final mirror = profile.copyWith(syncMode: SyncMode.mirror);
      expect(mirror.sourceFs, 'gdrive:Backups/Work');
      expect(mirror.destinationFs, '/Users/me/projects/work');
    });

    test('source and destination are correct for download mode', () {
      final download = profile.copyWith(syncMode: SyncMode.download);
      expect(download.sourceFs, 'gdrive:Backups/Work');
      expect(download.destinationFs, '/Users/me/projects/work');
    });

    test('builds correct RC API data payload for backup', () {
      final data = profile.toRcApiData();
      expect(data['srcFs'], '/Users/me/projects/work');
      expect(data['dstFs'], 'gdrive:Backups/Work');
      expect(data['_async'], true);
    });

    test('builds correct RC API data payload for bisync', () {
      final bisync = profile.copyWith(syncMode: SyncMode.bisync);
      final data = bisync.toRcApiData();
      expect(data['path1'], 'gdrive:Backups/Work');
      expect(data['path2'], '/Users/me/projects/work');
      expect(data['_async'], true);
      expect(data.containsKey('srcFs'), false);
    });

    test('builds filter payload with include rules', () {
      final filter = profile.buildFilterPayload();
      expect(filter['IncludeRule'], ['*.py', '*.js', '*.md']);
      expect(filter['FilterRule'], contains('- .git/**'));
      expect(filter['FilterRule'], contains('- *.log'));
      expect(filter['FilterRule'], contains('- node_modules/**'));
    });

    test('builds filter payload with exclude rules', () {
      final excludeProfile = profile.copyWith(
        useIncludeMode: false,
        includeTypes: [],
        excludeTypes: ['tmp', 'bak'],
      );
      final filter = excludeProfile.buildFilterPayload();
      expect(filter['ExcludeRule'], ['*.tmp', '*.bak']);
      expect(filter.containsKey('IncludeRule'), false);
    });

    test('builds config payload with dry run', () {
      final config = profile.buildConfigPayload(dryRun: true);
      expect(config['DryRun'], true);
      expect(config['CheckFirst'], true);
      expect(config['Transfers'], 4);
    });

    test('builds config payload with bandwidth limit', () {
      final limited = profile.copyWith(bandwidthLimit: '1M');
      final config = limited.buildConfigPayload();
      expect(config['BwLimit'], '1M');
    });

    test('copyWith preserves unchanged fields', () {
      final copy = profile.copyWith(name: 'New Name');
      expect(copy.name, 'New Name');
      expect(copy.id, profile.id);
      expect(copy.syncMode, profile.syncMode);
      expect(copy.includeTypes, profile.includeTypes);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/sync_profile_test.dart`
Expected: FAIL — imports not found.

**Step 3: Implement SyncMode**

```dart
// lib/models/sync_mode.dart

enum SyncMode {
  backup(
    rcloneCommand: 'copy',
    rcEndpoint: '/sync/copy',
    direction: 'Local → Cloud',
    label: 'Backup',
    description: 'Push local files to cloud. Deleting locally does NOT delete from cloud.',
    deletesOnDest: false,
  ),
  mirror(
    rcloneCommand: 'sync',
    rcEndpoint: '/sync/sync',
    direction: 'Cloud → Local',
    label: 'Mirror',
    description: 'Local folder becomes exact copy of cloud. Files not on cloud WILL be deleted locally.',
    deletesOnDest: true,
  ),
  download(
    rcloneCommand: 'copy',
    rcEndpoint: '/sync/copy',
    direction: 'Cloud → Local',
    label: 'Download',
    description: 'Pull new files from cloud. Keeps local files even if deleted from cloud.',
    deletesOnDest: false,
  ),
  bisync(
    rcloneCommand: 'bisync',
    rcEndpoint: '/sync/bisync',
    direction: 'Bidirectional',
    label: 'Bidirectional',
    description: 'Changes sync both ways. Experimental — conflicts may need manual resolution.',
    deletesOnDest: true,
  );

  const SyncMode({
    required this.rcloneCommand,
    required this.rcEndpoint,
    required this.direction,
    required this.label,
    required this.description,
    required this.deletesOnDest,
  });

  final String rcloneCommand;
  final String rcEndpoint;
  final String direction;
  final String label;
  final String description;
  final bool deletesOnDest;

  String toJson() => name;

  static SyncMode fromJson(String value) =>
      SyncMode.values.firstWhere((e) => e.name == value);
}
```

**Step 4: Implement SyncProfile**

```dart
// lib/models/sync_profile.dart
import 'package:json_annotation/json_annotation.dart';
import 'sync_mode.dart';

part 'sync_profile.g.dart';

@JsonSerializable()
class SyncProfile {
  final String id;
  final String name;
  final String remoteName;
  final String cloudFolder;
  final String localPath;
  final List<String> includeTypes;
  final List<String> excludeTypes;
  final bool useIncludeMode;
  @JsonKey(fromJson: SyncMode.fromJson, toJson: _syncModeToJson)
  final SyncMode syncMode;
  final int scheduleMinutes;
  final bool enabled;
  final bool respectGitignore;
  final bool excludeGitDirs;
  final List<String> customExcludes;
  final String? bandwidthLimit;
  final int maxTransfers;
  final bool checkFirst;
  final DateTime? lastSyncTime;
  final String? lastSyncStatus;
  final String? lastSyncError;

  const SyncProfile({
    required this.id,
    required this.name,
    required this.remoteName,
    required this.cloudFolder,
    required this.localPath,
    this.includeTypes = const [],
    this.excludeTypes = const [],
    this.useIncludeMode = true,
    this.syncMode = SyncMode.backup,
    this.scheduleMinutes = 0,
    this.enabled = true,
    this.respectGitignore = false,
    this.excludeGitDirs = true,
    this.customExcludes = const [],
    this.bandwidthLimit,
    this.maxTransfers = 4,
    this.checkFirst = true,
    this.lastSyncTime,
    this.lastSyncStatus,
    this.lastSyncError,
  });

  factory SyncProfile.fromJson(Map<String, dynamic> json) =>
      _$SyncProfileFromJson(json);

  Map<String, dynamic> toJson() => _$SyncProfileToJson(this);

  static String _syncModeToJson(SyncMode mode) => mode.toJson();

  /// Returns the remote filesystem string for rclone.
  String get remoteFs => '$remoteName:$cloudFolder';

  /// Source filesystem based on sync mode direction.
  String get sourceFs {
    switch (syncMode) {
      case SyncMode.backup:
        return localPath;
      case SyncMode.mirror:
      case SyncMode.download:
      case SyncMode.bisync:
        return remoteFs;
    }
  }

  /// Destination filesystem based on sync mode direction.
  String get destinationFs {
    switch (syncMode) {
      case SyncMode.backup:
        return remoteFs;
      case SyncMode.mirror:
      case SyncMode.download:
      case SyncMode.bisync:
        return localPath;
    }
  }

  /// Build the RC API request data for this profile's sync operation.
  Map<String, dynamic> toRcApiData({
    List<String>? gitignoreRules,
    bool dryRun = false,
  }) {
    final filter = buildFilterPayload(gitignoreRules: gitignoreRules);
    final config = buildConfigPayload(dryRun: dryRun);
    final data = <String, dynamic>{
      '_async': true,
      if (filter.isNotEmpty) '_filter': filter,
      if (config.isNotEmpty) '_config': config,
    };

    if (syncMode == SyncMode.bisync) {
      data['path1'] = remoteFs;
      data['path2'] = localPath;
    } else {
      data['srcFs'] = sourceFs;
      data['dstFs'] = destinationFs;
    }

    return data;
  }

  /// Build the _filter payload for the RC API.
  Map<String, dynamic> buildFilterPayload({List<String>? gitignoreRules}) {
    final filter = <String, dynamic>{};

    if (useIncludeMode && includeTypes.isNotEmpty) {
      filter['IncludeRule'] = includeTypes.map((ext) => '*.$ext').toList();
    }
    if (!useIncludeMode && excludeTypes.isNotEmpty) {
      filter['ExcludeRule'] = excludeTypes.map((ext) => '*.$ext').toList();
    }

    final filterRules = <String>[];
    if (gitignoreRules != null) filterRules.addAll(gitignoreRules);
    if (excludeGitDirs) filterRules.add('- .git/**');
    for (final p in customExcludes) filterRules.add('- $p');
    if (filterRules.isNotEmpty) filter['FilterRule'] = filterRules;

    return filter;
  }

  /// Build the _config payload for the RC API.
  Map<String, dynamic> buildConfigPayload({bool dryRun = false}) {
    final config = <String, dynamic>{};
    if (dryRun) config['DryRun'] = true;
    if (checkFirst) config['CheckFirst'] = true;
    if (maxTransfers != 4) config['Transfers'] = maxTransfers;
    if (bandwidthLimit != null) config['BwLimit'] = bandwidthLimit;
    return config;
  }

  SyncProfile copyWith({
    String? id,
    String? name,
    String? remoteName,
    String? cloudFolder,
    String? localPath,
    List<String>? includeTypes,
    List<String>? excludeTypes,
    bool? useIncludeMode,
    SyncMode? syncMode,
    int? scheduleMinutes,
    bool? enabled,
    bool? respectGitignore,
    bool? excludeGitDirs,
    List<String>? customExcludes,
    String? bandwidthLimit,
    int? maxTransfers,
    bool? checkFirst,
    DateTime? lastSyncTime,
    String? lastSyncStatus,
    String? lastSyncError,
  }) {
    return SyncProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      remoteName: remoteName ?? this.remoteName,
      cloudFolder: cloudFolder ?? this.cloudFolder,
      localPath: localPath ?? this.localPath,
      includeTypes: includeTypes ?? this.includeTypes,
      excludeTypes: excludeTypes ?? this.excludeTypes,
      useIncludeMode: useIncludeMode ?? this.useIncludeMode,
      syncMode: syncMode ?? this.syncMode,
      scheduleMinutes: scheduleMinutes ?? this.scheduleMinutes,
      enabled: enabled ?? this.enabled,
      respectGitignore: respectGitignore ?? this.respectGitignore,
      excludeGitDirs: excludeGitDirs ?? this.excludeGitDirs,
      customExcludes: customExcludes ?? this.customExcludes,
      bandwidthLimit: bandwidthLimit ?? this.bandwidthLimit,
      maxTransfers: maxTransfers ?? this.maxTransfers,
      checkFirst: checkFirst ?? this.checkFirst,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncError: lastSyncError ?? this.lastSyncError,
    );
  }
}
```

**Step 5: Generate JSON serialization code**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 6: Run tests to verify they pass**

Run: `flutter test test/models/sync_profile_test.dart`
Expected: All tests PASS.

**Step 7: Commit**

```bash
git add lib/models/sync_mode.dart lib/models/sync_profile.dart lib/models/sync_profile.g.dart test/models/sync_profile_test.dart
git commit -m "feat: add SyncMode enum and SyncProfile model with full RC API payload support"
```

---

### Task 1.3: Create AppConfig Model

**Files:**
- Create: `lib/models/app_config.dart`
- Create: `test/models/app_config_test.dart`

**Step 1: Write the failing test**

```dart
// test/models/app_config_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/app_config.dart';

void main() {
  group('AppConfig', () {
    test('has sensible defaults', () {
      final config = AppConfig.defaults();
      expect(config.themeMode, ThemeMode.system);
      expect(config.launchAtLogin, false);
      expect(config.showInMenuBar, true);
      expect(config.showNotifications, true);
      expect(config.rcPort, 5572);
      expect(config.skippedVersion, isNull);
    });

    test('serializes to JSON and back', () {
      final config = AppConfig(
        themeMode: ThemeMode.dark,
        launchAtLogin: true,
        showInMenuBar: true,
        showNotifications: false,
        rcPort: 5573,
        skippedVersion: '1.2.0',
      );
      final json = config.toJson();
      final restored = AppConfig.fromJson(json);
      expect(restored.themeMode, ThemeMode.dark);
      expect(restored.launchAtLogin, true);
      expect(restored.rcPort, 5573);
      expect(restored.skippedVersion, '1.2.0');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/app_config_test.dart`
Expected: FAIL.

**Step 3: Implement AppConfig**

```dart
// lib/models/app_config.dart
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfig {
  @JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
  final ThemeMode themeMode;
  final bool launchAtLogin;
  final bool showInMenuBar;
  final bool showNotifications;
  final int rcPort;
  final String? skippedVersion;

  const AppConfig({
    required this.themeMode,
    required this.launchAtLogin,
    required this.showInMenuBar,
    required this.showNotifications,
    required this.rcPort,
    this.skippedVersion,
  });

  factory AppConfig.defaults() => const AppConfig(
        themeMode: ThemeMode.system,
        launchAtLogin: false,
        showInMenuBar: true,
        showNotifications: true,
        rcPort: 5572,
      );

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  static ThemeMode _themeModeFromJson(String value) =>
      ThemeMode.values.firstWhere((e) => e.name == value);

  static String _themeModeToJson(ThemeMode mode) => mode.name;

  AppConfig copyWith({
    ThemeMode? themeMode,
    bool? launchAtLogin,
    bool? showInMenuBar,
    bool? showNotifications,
    int? rcPort,
    String? skippedVersion,
  }) {
    return AppConfig(
      themeMode: themeMode ?? this.themeMode,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      showInMenuBar: showInMenuBar ?? this.showInMenuBar,
      showNotifications: showNotifications ?? this.showNotifications,
      rcPort: rcPort ?? this.rcPort,
      skippedVersion: skippedVersion ?? this.skippedVersion,
    );
  }
}
```

**Step 4: Generate JSON serialization, run tests, commit**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/models/app_config_test.dart`
Expected: All PASS.

```bash
git add lib/models/app_config.dart lib/models/app_config.g.dart test/models/app_config_test.dart
git commit -m "feat: add AppConfig model with defaults and serialization"
```

---

### Task 1.4: Create SyncJob, SyncPreview, SyncHistoryEntry, AppRelease, FileChange Models

**Files:**
- Create: `lib/models/sync_job.dart`
- Create: `lib/models/sync_preview.dart`
- Create: `lib/models/sync_history_entry.dart`
- Create: `lib/models/app_release.dart`
- Create: `lib/models/file_change.dart`
- Create: `test/models/remaining_models_test.dart`

**Step 1: Write the failing test**

```dart
// test/models/remaining_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/sync_job.dart';
import 'package:drive_sync/models/sync_preview.dart';
import 'package:drive_sync/models/sync_history_entry.dart';
import 'package:drive_sync/models/app_release.dart';
import 'package:drive_sync/models/file_change.dart';

void main() {
  group('FileChange', () {
    test('creates from rclone transferred entry', () {
      final change = FileChange.fromRcloneTransfer({
        'name': 'docs/readme.md',
        'size': 1024,
        'checked': true,
        'error': '',
      }, FileChangeAction.add);
      expect(change.path, 'docs/readme.md');
      expect(change.size, 1024);
      expect(change.action, FileChangeAction.add);
    });
  });

  group('SyncJob', () {
    test('creates from rclone job status response', () {
      final job = SyncJob.fromRcResponse(
        profileId: 'profile-1',
        data: {
          'id': 42,
          'finished': false,
          'duration': 5.2,
          'error': '',
          'success': false,
          'startTime': '2026-02-21T10:00:00Z',
        },
      );
      expect(job.jobId, 42);
      expect(job.profileId, 'profile-1');
      expect(job.isRunning, true);
    });

    test('calculates progress from stats', () {
      final job = SyncJob(
        jobId: 1,
        profileId: 'p1',
        status: SyncJobStatus.running,
        bytesTransferred: 500,
        totalBytes: 1000,
        filesTransferred: 5,
        speed: 100.0,
        startTime: DateTime.now(),
      );
      expect(job.progress, 0.5);
    });
  });

  group('SyncPreview', () {
    test('calculates summary correctly', () {
      final preview = SyncPreview(
        profileId: 'p1',
        timestamp: DateTime.now(),
        filesToAdd: [
          FileChange(path: 'a.txt', size: 100, action: FileChangeAction.add),
          FileChange(path: 'b.txt', size: 200, action: FileChangeAction.add),
        ],
        filesToUpdate: [
          FileChange(path: 'c.txt', size: 50, action: FileChangeAction.update),
        ],
        filesToDelete: [],
      );
      expect(preview.totalFiles, 3);
      expect(preview.totalSize, 350);
      expect(preview.hasChanges, true);
    });

    test('empty preview has no changes', () {
      final preview = SyncPreview(
        profileId: 'p1',
        timestamp: DateTime.now(),
        filesToAdd: [],
        filesToUpdate: [],
        filesToDelete: [],
      );
      expect(preview.hasChanges, false);
      expect(preview.totalFiles, 0);
    });
  });

  group('SyncHistoryEntry', () {
    test('serializes to JSON and back', () {
      final entry = SyncHistoryEntry(
        profileId: 'p1',
        timestamp: DateTime.utc(2026, 2, 21, 10, 0),
        status: 'success',
        filesTransferred: 10,
        bytesTransferred: 5000,
        duration: const Duration(seconds: 30),
      );
      final json = entry.toJson();
      final restored = SyncHistoryEntry.fromJson(json);
      expect(restored.profileId, 'p1');
      expect(restored.status, 'success');
      expect(restored.filesTransferred, 10);
    });
  });

  group('AppRelease', () {
    test('parses from GitHub API response', () {
      final release = AppRelease.fromGitHubJson({
        'tag_name': 'v1.2.0',
        'name': 'Release 1.2.0',
        'body': '## Changes\n- Added feature X',
        'published_at': '2026-02-21T10:00:00Z',
        'prerelease': false,
        'assets': [
          {
            'name': 'DriveSync-1.2.0.dmg',
            'browser_download_url': 'https://example.com/DriveSync-1.2.0.dmg',
          },
        ],
      });
      expect(release.version, '1.2.0');
      expect(release.tagName, 'v1.2.0');
      expect(release.isPreRelease, false);
      expect(release.changelog, contains('Added feature X'));
    });

    test('isNewerThan compares semver correctly', () {
      final release = AppRelease(
        version: '1.2.0',
        tagName: 'v1.2.0',
        publishedAt: DateTime.now(),
        changelog: '',
        downloadUrls: {},
        isPreRelease: false,
      );
      expect(release.isNewerThan('1.1.0'), true);
      expect(release.isNewerThan('1.2.0'), false);
      expect(release.isNewerThan('1.3.0'), false);
      expect(release.isNewerThan('0.9.0'), true);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/remaining_models_test.dart`
Expected: FAIL.

**Step 3: Implement all models**

Create `lib/models/file_change.dart`:

```dart
enum FileChangeAction { add, update, delete }

class FileChange {
  final String path;
  final int size;
  final DateTime? modTime;
  final FileChangeAction action;

  const FileChange({
    required this.path,
    required this.size,
    this.modTime,
    required this.action,
  });

  factory FileChange.fromRcloneTransfer(
    Map<String, dynamic> data,
    FileChangeAction action,
  ) {
    return FileChange(
      path: data['name'] as String,
      size: (data['size'] as num?)?.toInt() ?? 0,
      action: action,
    );
  }
}
```

Create `lib/models/sync_job.dart`:

```dart
enum SyncJobStatus { running, finished, error }

class SyncJob {
  final int jobId;
  final String profileId;
  final SyncJobStatus status;
  final int bytesTransferred;
  final int totalBytes;
  final int filesTransferred;
  final double speed;
  final String? error;
  final DateTime startTime;
  final DateTime? endTime;

  const SyncJob({
    required this.jobId,
    required this.profileId,
    required this.status,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.filesTransferred = 0,
    this.speed = 0,
    this.error,
    required this.startTime,
    this.endTime,
  });

  bool get isRunning => status == SyncJobStatus.running;
  double get progress => totalBytes > 0 ? bytesTransferred / totalBytes : 0;

  factory SyncJob.fromRcResponse({
    required String profileId,
    required Map<String, dynamic> data,
  }) {
    final finished = data['finished'] as bool? ?? false;
    final errorStr = data['error'] as String? ?? '';
    return SyncJob(
      jobId: data['id'] as int,
      profileId: profileId,
      status: finished
          ? (errorStr.isNotEmpty ? SyncJobStatus.error : SyncJobStatus.finished)
          : SyncJobStatus.running,
      error: errorStr.isNotEmpty ? errorStr : null,
      startTime: DateTime.parse(data['startTime'] as String),
      endTime: data['endTime'] != null
          ? DateTime.tryParse(data['endTime'] as String)
          : null,
    );
  }

  SyncJob copyWith({
    SyncJobStatus? status,
    int? bytesTransferred,
    int? totalBytes,
    int? filesTransferred,
    double? speed,
    String? error,
    DateTime? endTime,
  }) {
    return SyncJob(
      jobId: jobId,
      profileId: profileId,
      status: status ?? this.status,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      totalBytes: totalBytes ?? this.totalBytes,
      filesTransferred: filesTransferred ?? this.filesTransferred,
      speed: speed ?? this.speed,
      error: error ?? this.error,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
```

Create `lib/models/sync_preview.dart`:

```dart
import 'file_change.dart';

class SyncPreview {
  final String profileId;
  final DateTime timestamp;
  final List<FileChange> filesToAdd;
  final List<FileChange> filesToUpdate;
  final List<FileChange> filesToDelete;

  const SyncPreview({
    required this.profileId,
    required this.timestamp,
    required this.filesToAdd,
    required this.filesToUpdate,
    required this.filesToDelete,
  });

  int get totalFiles =>
      filesToAdd.length + filesToUpdate.length + filesToDelete.length;

  int get totalSize =>
      filesToAdd.fold(0, (s, f) => s + f.size) +
      filesToUpdate.fold(0, (s, f) => s + f.size) +
      filesToDelete.fold(0, (s, f) => s + f.size);

  bool get hasChanges => totalFiles > 0;
}
```

Create `lib/models/sync_history_entry.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'sync_history_entry.g.dart';

@JsonSerializable()
class SyncHistoryEntry {
  final String profileId;
  final DateTime timestamp;
  final String status;
  final int filesTransferred;
  final int bytesTransferred;
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration duration;
  final String? error;

  const SyncHistoryEntry({
    required this.profileId,
    required this.timestamp,
    required this.status,
    required this.filesTransferred,
    required this.bytesTransferred,
    required this.duration,
    this.error,
  });

  factory SyncHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$SyncHistoryEntryFromJson(json);

  Map<String, dynamic> toJson() => _$SyncHistoryEntryToJson(this);

  static Duration _durationFromJson(int ms) => Duration(milliseconds: ms);
  static int _durationToJson(Duration d) => d.inMilliseconds;
}
```

Create `lib/models/app_release.dart`:

```dart
class AppRelease {
  final String version;
  final String tagName;
  final DateTime publishedAt;
  final String changelog;
  final Map<String, String> downloadUrls;
  final bool isPreRelease;

  const AppRelease({
    required this.version,
    required this.tagName,
    required this.publishedAt,
    required this.changelog,
    required this.downloadUrls,
    required this.isPreRelease,
  });

  factory AppRelease.fromGitHubJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String;
    final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;
    final assets = (json['assets'] as List?) ?? [];
    final urls = <String, String>{};
    for (final asset in assets) {
      final name = asset['name'] as String;
      urls[name] = asset['browser_download_url'] as String;
    }

    return AppRelease(
      version: version,
      tagName: tagName,
      publishedAt: DateTime.parse(json['published_at'] as String),
      changelog: json['body'] as String? ?? '',
      downloadUrls: urls,
      isPreRelease: json['prerelease'] as bool? ?? false,
    );
  }

  bool isNewerThan(String currentVersion) {
    final current = _parseVersion(currentVersion);
    final this_ = _parseVersion(version);
    for (var i = 0; i < 3; i++) {
      if (this_[i] > current[i]) return true;
      if (this_[i] < current[i]) return false;
    }
    return false;
  }

  static List<int> _parseVersion(String v) {
    final cleaned = v.startsWith('v') ? v.substring(1) : v;
    final parts = cleaned.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    while (parts.length < 3) parts.add(0);
    return parts;
  }
}
```

**Step 4: Generate JSON serialization, run tests, commit**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/models/remaining_models_test.dart`
Expected: All PASS.

```bash
git add lib/models/ test/models/
git commit -m "feat: add SyncJob, SyncPreview, SyncHistoryEntry, AppRelease, FileChange models"
```

---

## Workstream 2: Core Services (can parallel with 3, 4 after Workstream 1)

### Task 2.1: RcloneService — RC API HTTP Client

**Files:**
- Create: `lib/services/rclone_service.dart`
- Create: `test/services/rclone_service_test.dart`

**Step 1: Write the failing test**

```dart
// test/services/rclone_service_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:drive_sync/services/rclone_service.dart';
import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/models/sync_mode.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late RcloneService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:5572'));
    dioAdapter = DioAdapter(dio: dio);
    service = RcloneService.withDio(dio);
  });

  group('healthCheck', () {
    test('returns true when rclone is responsive', () async {
      dioAdapter.onPost('/rc/noop', (server) => server.reply(200, {}));
      expect(await service.healthCheck(), true);
    });

    test('returns false when rclone is down', () async {
      dioAdapter.onPost(
        '/rc/noop',
        (server) => server.throws(
          500,
          DioException(requestOptions: RequestOptions(), type: DioExceptionType.connectionError),
        ),
      );
      expect(await service.healthCheck(), false);
    });
  });

  group('listRemotes', () {
    test('returns list of remote names', () async {
      dioAdapter.onPost(
        '/config/listremotes',
        (server) => server.reply(200, {
          'remotes': ['gdrive', 'onedrive']
        }),
      );
      final remotes = await service.listRemotes();
      expect(remotes, ['gdrive', 'onedrive']);
    });

    test('returns empty list when no remotes', () async {
      dioAdapter.onPost(
        '/config/listremotes',
        (server) => server.reply(200, {'remotes': <String>[]}),
      );
      final remotes = await service.listRemotes();
      expect(remotes, isEmpty);
    });
  });

  group('listFolders', () {
    test('returns folder entries', () async {
      dioAdapter.onPost(
        '/operations/list',
        (server) => server.reply(200, {
          'list': [
            {'Path': 'Documents', 'Name': 'Documents', 'IsDir': true},
            {'Path': 'Photos', 'Name': 'Photos', 'IsDir': true},
          ]
        }),
        data: {
          'fs': 'gdrive:',
          'remote': '',
          'opt': {'dirsOnly': true, 'recurse': false},
        },
      );
      final folders = await service.listFolders('gdrive', '');
      expect(folders.length, 2);
    });
  });

  group('startSync', () {
    test('starts backup sync and returns job ID', () async {
      final profile = SyncProfile(
        id: 'test-1',
        name: 'Test',
        remoteName: 'gdrive',
        cloudFolder: 'Backup',
        localPath: '/tmp/test',
        syncMode: SyncMode.backup,
      );

      dioAdapter.onPost(
        '/sync/copy',
        (server) => server.reply(200, {'jobid': 42}),
        data: Matchers.any,
      );

      final jobId = await service.startSync(profile);
      expect(jobId, 42);
    });
  });

  group('getJobStatus', () {
    test('returns job status map', () async {
      dioAdapter.onPost(
        '/job/status',
        (server) => server.reply(200, {
          'id': 42,
          'finished': false,
          'duration': 5.0,
          'error': '',
          'success': false,
          'startTime': '2026-02-21T10:00:00Z',
        }),
        data: {'jobid': 42},
      );
      final status = await service.getJobStatus(42);
      expect(status['finished'], false);
      expect(status['id'], 42);
    });
  });

  group('getTransferStats', () {
    test('returns stats for a job group', () async {
      dioAdapter.onPost(
        '/core/stats',
        (server) => server.reply(200, {
          'bytes': 5000,
          'transfers': 3,
          'speed': 1000.0,
          'totalBytes': 10000,
          'eta': 5.0,
        }),
        data: {'group': 'job/42'},
      );
      final stats = await service.getTransferStats(group: 'job/42');
      expect(stats['bytes'], 5000);
      expect(stats['totalBytes'], 10000);
    });
  });

  group('stopJob', () {
    test('stops a running job', () async {
      dioAdapter.onPost(
        '/job/stop',
        (server) => server.reply(200, {}),
        data: {'jobid': 42},
      );
      await service.stopJob(42);
      // No exception means success
    });
  });

  group('getVersion', () {
    test('returns rclone version info', () async {
      dioAdapter.onPost(
        '/core/version',
        (server) => server.reply(200, {
          'version': 'rclone v1.65.0',
          'os': 'darwin',
          'arch': 'arm64',
        }),
      );
      final version = await service.getVersion();
      expect(version['version'], contains('rclone'));
    });
  });

  group('setBandwidthLimit', () {
    test('sets bandwidth and returns current rate', () async {
      dioAdapter.onPost(
        '/core/bwlimit',
        (server) => server.reply(200, {
          'bytesPerSecond': 1048576,
          'rate': '1M',
        }),
        data: {'rate': '1M'},
      );
      final result = await service.setBandwidthLimit('1M');
      expect(result['rate'], '1M');
    });
  });

  group('quit', () {
    test('sends quit command', () async {
      dioAdapter.onPost('/core/quit', (server) => server.reply(200, {}));
      await service.quit();
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/services/rclone_service_test.dart`
Expected: FAIL.

**Step 3: Implement RcloneService**

```dart
// lib/services/rclone_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/sync_profile.dart';

class RcloneService {
  final Dio _dio;

  RcloneService({
    required String user,
    required String pass,
    int port = 5572,
  }) : _dio = Dio(BaseOptions(
          baseUrl: 'http://localhost:$port',
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$user:$pass'))}',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ));

  /// For testing with a pre-configured Dio instance.
  RcloneService.withDio(this._dio);

  // ─── Health & Info ───

  Future<bool> healthCheck() async {
    try {
      await _dio.post('/rc/noop');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getVersion() async {
    final resp = await _dio.post('/core/version');
    return Map<String, dynamic>.from(resp.data);
  }

  Future<void> quit() async {
    try {
      await _dio.post('/core/quit');
    } catch (_) {
      // Connection may close before response
    }
  }

  // ─── Remote Management ───

  Future<List<String>> listRemotes() async {
    final resp = await _dio.post('/config/listremotes');
    return List<String>.from(resp.data['remotes'] ?? []);
  }

  Future<Map<String, dynamic>> getRemoteConfig(String name) async {
    final resp = await _dio.post('/config/get', data: {'name': name});
    return Map<String, dynamic>.from(resp.data);
  }

  Future<void> deleteRemote(String name) async {
    await _dio.post('/config/delete', data: {'name': name});
  }

  // ─── Folder Browsing ───

  Future<List<Map<String, dynamic>>> listFolders(
      String remote, String path) async {
    final resp = await _dio.post('/operations/list', data: {
      'fs': '$remote:',
      'remote': path,
      'opt': {'dirsOnly': true, 'recurse': false},
    });
    return List<Map<String, dynamic>>.from(resp.data['list'] ?? []);
  }

  Future<List<Map<String, dynamic>>> listFiles(
      String remote, String path) async {
    final resp = await _dio.post('/operations/list', data: {
      'fs': '$remote:',
      'remote': path,
      'opt': {'dirsOnly': false, 'recurse': false},
    });
    return List<Map<String, dynamic>>.from(resp.data['list'] ?? []);
  }

  // ─── Sync Operations ───

  Future<int> startSync(
    SyncProfile profile, {
    List<String>? gitignoreRules,
    bool dryRun = false,
  }) async {
    final data = profile.toRcApiData(
      gitignoreRules: gitignoreRules,
      dryRun: dryRun,
    );
    final resp = await _dio.post(profile.syncMode.rcEndpoint, data: data);
    return resp.data['jobid'] as int;
  }

  // ─── Job Monitoring ───

  Future<Map<String, dynamic>> getJobStatus(int jobId) async {
    final resp = await _dio.post('/job/status', data: {'jobid': jobId});
    return Map<String, dynamic>.from(resp.data);
  }

  Future<Map<String, dynamic>> getJobList() async {
    final resp = await _dio.post('/job/list');
    return Map<String, dynamic>.from(resp.data);
  }

  Future<void> stopJob(int jobId) async {
    await _dio.post('/job/stop', data: {'jobid': jobId});
  }

  // ─── Transfer Stats ───

  Future<Map<String, dynamic>> getTransferStats({String? group}) async {
    final resp = await _dio.post(
      '/core/stats',
      data: group != null ? {'group': group} : {},
    );
    return Map<String, dynamic>.from(resp.data);
  }

  Future<List<Map<String, dynamic>>> getCompletedTransfers(
      {String? group}) async {
    final resp = await _dio.post(
      '/core/transferred',
      data: group != null ? {'group': group} : {},
    );
    return List<Map<String, dynamic>>.from(resp.data['transferred'] ?? []);
  }

  Future<void> resetStats({String? group}) async {
    await _dio.post(
      '/core/stats-reset',
      data: group != null ? {'group': group} : {},
    );
  }

  // ─── Bandwidth ───

  Future<Map<String, dynamic>> setBandwidthLimit(String rate) async {
    final resp = await _dio.post('/core/bwlimit', data: {'rate': rate});
    return Map<String, dynamic>.from(resp.data);
  }

  Future<Map<String, dynamic>> getBandwidthLimit() async {
    final resp = await _dio.post('/core/bwlimit');
    return Map<String, dynamic>.from(resp.data);
  }
}
```

**Step 4: Run tests, commit**

Run: `flutter test test/services/rclone_service_test.dart`
Expected: All PASS.

```bash
git add lib/services/rclone_service.dart test/services/rclone_service_test.dart
git commit -m "feat: add RcloneService with full RC API client"
```

---

### Task 2.2: RcloneDaemonManager — Process Lifecycle

**Files:**
- Create: `lib/services/rclone_daemon_manager.dart`
- Create: `test/services/rclone_daemon_manager_test.dart`

This task implements the daemon manager that starts/stops rclone rcd, manages the PID file, detects stale processes, and handles crash recovery.

**Step 1: Write the failing test**

Tests should cover: `isRcloneInstalled()`, `start()`, `stop()`, `_cleanupStale()`, PID file management. Mock `Process.start` and `Process.run` using an abstract `ProcessRunner` interface for testability.

```dart
// test/services/rclone_daemon_manager_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/services/rclone_daemon_manager.dart';

void main() {
  late Directory tempDir;
  late String pidFilePath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('daemon_test_');
    pidFilePath = '${tempDir.path}/rclone.pid';
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('RcloneDaemonManager', () {
    test('isRcloneInstalled returns true when rclone exists', () async {
      // This test depends on rclone being installed on the test machine
      final result = await Process.run('which', ['rclone']);
      final installed = result.exitCode == 0;
      final manager = RcloneDaemonManager(
        appSupportDir: tempDir.path,
      );
      expect(await manager.isRcloneInstalled(), installed);
    });

    test('getRclonePath returns path when installed', () async {
      final manager = RcloneDaemonManager(
        appSupportDir: tempDir.path,
      );
      final path = await manager.getRclonePath();
      if (path != null) {
        expect(File(path).existsSync(), true);
      }
    });

    test('cleanupStale removes stale PID file', () async {
      // Write a PID file with a definitely-dead PID
      File(pidFilePath).writeAsStringSync('999999999');
      final manager = RcloneDaemonManager(
        appSupportDir: tempDir.path,
      );
      await manager.cleanupStale();
      expect(File(pidFilePath).existsSync(), false);
    });

    test('isRunning returns false when no PID file', () {
      final manager = RcloneDaemonManager(
        appSupportDir: tempDir.path,
      );
      expect(manager.isRunning, false);
    });
  });
}
```

**Step 2: Run test to verify it fails, implement, run tests, commit**

Implementation should include:
- `isRcloneInstalled()` — runs `which rclone`
- `getRclonePath()` — returns path from which
- `start({user, pass, port, configPass})` — starts `rclone rcd`, writes PID file
- `stop()` — POST to `/core/quit`, fallback to SIGTERM, delete PID file
- `cleanupStale()` — check PID file, kill if stale
- `isRunning` getter — checks PID file and process

```bash
git add lib/services/rclone_daemon_manager.dart test/services/rclone_daemon_manager_test.dart
git commit -m "feat: add RcloneDaemonManager for rclone rcd lifecycle"
```

---

### Task 2.3: ConfigStore — JSON Config + Secure Storage

**Files:**
- Create: `lib/services/config_store.dart`
- Create: `test/services/config_store_test.dart`

Manages reading/writing the config JSON file at `~/Library/Application Support/DriveSync/config.json` and storing secrets in the platform's secure storage (Keychain on macOS).

**Step 1: Write tests covering:**
- `loadConfig()` / `saveConfig()` with JSON file
- `loadProfiles()` / `saveProfile()` / `deleteProfile()`
- `loadHistory()` / `addHistoryEntry()`
- Secure storage for RC credentials (`rcUser`, `rcPass`, `rcloneConfigPass`)
- Config file creation on first run (defaults)

**Step 2: Implement with:**
- `path_provider` for app support directory
- `flutter_secure_storage` for secrets
- JSON file I/O for config and profiles
- Auto-generate RC user/pass on first launch using `uuid`

```bash
git commit -m "feat: add ConfigStore for JSON config and secure credential storage"
```

---

### Task 2.4: UpdateChecker — GitHub Releases API

**Files:**
- Create: `lib/services/update_checker.dart`
- Create: `test/services/update_checker_test.dart`

**Step 1: Write tests covering:**
- `checkForUpdate(currentVersion)` → returns `AppRelease?`
- Version comparison logic
- Parsing GitHub API response
- Handling network errors gracefully (returns null)
- Respecting `skippedVersion` config
- Platform-specific asset URL selection (`.dmg` for macOS, `.exe` for Windows, `.deb` for Linux)

**Step 2: Implement with Dio calling:**
`GET https://api.github.com/repos/abdelaziz-mahdy/drive-sync/releases/latest`

```bash
git commit -m "feat: add UpdateChecker for GitHub release checking"
```

---

### Task 2.5: SyncScheduler — In-App Timer Service

**Files:**
- Create: `lib/services/sync_scheduler.dart`
- Create: `test/services/sync_scheduler_test.dart`

**Step 1: Write tests covering:**
- `scheduleProfile(profile)` — creates periodic timer
- `unscheduleProfile(profileId)` — cancels timer
- `rescheduleAll(profiles)` — updates all timers
- Timer fires callback with correct profile
- `dispose()` cancels all timers
- Profiles with `scheduleMinutes == 0` are skipped (manual only)

**Step 2: Implement using `dart:async` Timer.periodic**

```bash
git commit -m "feat: add SyncScheduler for in-app periodic sync timers"
```

---

## Workstream 3: Theme & Widgets (parallel with 2, 4)

### Task 3.1: Theme System — Light & Dark Mode

**Files:**
- Create: `lib/theme/app_theme.dart`
- Create: `lib/theme/color_schemes.dart`
- Create: `test/theme/app_theme_test.dart`

**Step 1: Write tests**

```dart
// test/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme has light brightness', () {
      expect(AppTheme.light.brightness, Brightness.light);
    });

    test('dark theme has dark brightness', () {
      expect(AppTheme.dark.brightness, Brightness.dark);
    });

    test('both themes use Material 3', () {
      expect(AppTheme.light.useMaterial3, true);
      expect(AppTheme.dark.useMaterial3, true);
    });

    test('status colors are consistent across themes', () {
      expect(AppTheme.successColor, isNotNull);
      expect(AppTheme.errorColor, isNotNull);
      expect(AppTheme.syncingColor, isNotNull);
      expect(AppTheme.warningColor, isNotNull);
    });
  });
}
```

**Step 2: Implement**

```dart
// lib/theme/color_schemes.dart
import 'package:flutter/material.dart';

class AppColors {
  // Neutral seed for adaptive feel
  static const seedColor = Color(0xFF607D8B); // Blue Grey

  static final lightScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  static final darkScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );

  // Status colors — consistent across themes
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const syncing = Color(0xFF2196F3);
  static const warning = Color(0xFFFFA726);
  static const idle = Color(0xFF9E9E9E);
}
```

```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppTheme {
  static const successColor = AppColors.success;
  static const errorColor = AppColors.error;
  static const syncingColor = AppColors.syncing;
  static const warningColor = AppColors.warning;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.lightScheme,
        brightness: Brightness.light,
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.darkScheme,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade800),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      );
}
```

```bash
git commit -m "feat: add Material 3 theme system with light/dark mode"
```

---

### Task 3.2: Core Widgets — StatusIndicator, ProgressBar, SyncModeIcon

**Files:**
- Create: `lib/widgets/status_indicator.dart`
- Create: `lib/widgets/progress_bar.dart`
- Create: `lib/widgets/sync_mode_icon.dart`
- Create: `test/widgets/core_widgets_test.dart`

**Step 1: Write widget tests for each**
- StatusIndicator: renders correct color/icon for each status (idle, syncing, success, error)
- ProgressBar: shows correct fill percentage, animates
- SyncModeIcon: shows correct icon for each SyncMode

**Step 2: Implement each widget**

```bash
git commit -m "feat: add StatusIndicator, ProgressBar, SyncModeIcon widgets"
```

---

### Task 3.3: SidebarLayout Widget

**Files:**
- Create: `lib/widgets/sidebar_layout.dart`
- Create: `test/widgets/sidebar_layout_test.dart`

Responsive sidebar + content layout. Sidebar collapses to drawer below breakpoint (800px).

**Step 1: Write widget tests**
- Shows sidebar and content side by side on wide screens
- Collapses sidebar to drawer on narrow screens
- Sidebar items are selectable
- Selected item is highlighted

**Step 2: Implement**

```bash
git commit -m "feat: add responsive SidebarLayout widget"
```

---

## Workstream 4: GitignoreService (parallel with 2, 3)

### Task 4.1: GitignoreService — Parse & Convert

**Files:**
- Create: `lib/services/gitignore_service.dart`
- Create: `test/services/gitignore_service_test.dart`

**Step 1: Write comprehensive tests**

```dart
// test/services/gitignore_service_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/services/gitignore_service.dart';

void main() {
  late Directory tempDir;
  late GitignoreService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('gitignore_test_');
    service = GitignoreService();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('Rule conversion', () {
    test('converts simple glob pattern', () {
      expect(service.convertRule('*.pyc', ''), '- *.pyc');
    });

    test('converts directory pattern (trailing slash)', () {
      expect(service.convertRule('node_modules/', ''), '- node_modules/**');
    });

    test('converts negation pattern', () {
      expect(service.convertRule('!important.log', ''), '+ important.log');
    });

    test('converts root-anchored pattern', () {
      expect(service.convertRule('/dist', ''), '- /dist/**');
    });

    test('converts root-anchored pattern in subdirectory', () {
      expect(service.convertRule('/dist', 'backend'), '- /backend/dist/**');
    });

    test('preserves nested glob', () {
      expect(service.convertRule('doc/**/*.pdf', ''), '- doc/**/*.pdf');
    });

    test('preserves wildcard', () {
      expect(service.convertRule('temp?.txt', ''), '- temp?.txt');
    });

    test('skips comments', () {
      expect(service.convertRule('# this is a comment', ''), isNull);
    });

    test('skips empty lines', () {
      expect(service.convertRule('', ''), isNull);
      expect(service.convertRule('   ', ''), isNull);
    });
  });

  group('File scanning', () {
    test('finds and parses root .gitignore', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('*.pyc\nnode_modules/\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- *.pyc'));
      expect(rules, contains('- node_modules/**'));
    });

    test('scopes subdirectory .gitignore rules', () async {
      final subDir = Directory('${tempDir.path}/backend');
      subDir.createSync();
      File('${subDir.path}/.gitignore').writeAsStringSync('/dist\n*.log\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- /backend/dist/**'));
      expect(rules, contains('- *.log'));
    });

    test('handles nested .gitignore files', () async {
      File('${tempDir.path}/.gitignore').writeAsStringSync('*.tmp\n');
      final sub = Directory('${tempDir.path}/src');
      sub.createSync();
      File('${sub.path}/.gitignore').writeAsStringSync('*.o\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- *.tmp'));
      expect(rules, contains('- *.o'));
    });

    test('handles negation', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('*.log\n!important.log\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- *.log'));
      expect(rules, contains('+ important.log'));
    });

    test('returns empty list when no .gitignore files', () async {
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, isEmpty);
    });
  });

  group('Filter file writing', () {
    test('writes rules to file', () async {
      final path = await service.writeFilterFile(
        'test-profile',
        ['- *.pyc', '- node_modules/**'],
        tempDir.path,
      );
      final content = File(path).readAsStringSync();
      expect(content, contains('- *.pyc'));
      expect(content, contains('- node_modules/**'));
    });
  });
}
```

**Step 2: Run test, implement, run test, commit**

```bash
git commit -m "feat: add GitignoreService for .gitignore to rclone filter conversion"
```

---

## Workstream 5: Providers & State (depends on 2, 3, 4)

### Task 5.1: Riverpod Providers — All Core Providers

**Files:**
- Create: `lib/providers/rclone_provider.dart`
- Create: `lib/providers/profiles_provider.dart`
- Create: `lib/providers/sync_jobs_provider.dart`
- Create: `lib/providers/app_config_provider.dart`
- Create: `lib/providers/theme_provider.dart`
- Create: `lib/providers/update_provider.dart`
- Create: `test/providers/providers_test.dart`

Implement all Riverpod providers:
- `rcloneServiceProvider` — singleton RcloneService
- `daemonManagerProvider` — singleton RcloneDaemonManager
- `configStoreProvider` — singleton ConfigStore
- `appConfigProvider` — AsyncNotifier for app config
- `profilesProvider` — AsyncNotifier for profile list
- `syncJobsProvider` — StateNotifier for active sync jobs
- `themeProvider` — reads from appConfigProvider, exposes ThemeMode
- `updateProvider` — AsyncNotifier for update checking

```bash
git commit -m "feat: add all Riverpod providers for state management"
```

---

## Workstream 6: Screens & UI (depends on 5)

### Task 6.1: App Shell — Main App with Router & Sidebar

**Files:**
- Create: `lib/app.dart`
- Modify: `lib/main.dart`
- Create: `lib/screens/shell_screen.dart`

Set up the main app with:
- `ProviderScope` wrapping the app
- Theme switching based on `themeProvider`
- Sidebar navigation shell with Dashboard, Activity, Settings sections
- Profile list in sidebar

```bash
git commit -m "feat: add app shell with sidebar navigation and theme switching"
```

---

### Task 6.2: Onboarding Screen

**Files:**
- Create: `lib/screens/onboarding/onboarding_screen.dart`
- Create: `lib/screens/onboarding/rclone_check_step.dart`
- Create: `lib/screens/onboarding/remote_setup_step.dart`
- Create: `lib/screens/onboarding/first_profile_step.dart`
- Create: `test/screens/onboarding_test.dart`

Three-step onboarding:
1. Check rclone installed — show install instructions per platform if missing
2. Check remotes exist — guide to `rclone config` in terminal, poll for new remotes
3. Create first profile — simplified profile editor

```bash
git commit -m "feat: add onboarding flow for first-launch setup"
```

---

### Task 6.3: Dashboard Screen

**Files:**
- Create: `lib/screens/dashboard/dashboard_screen.dart`
- Create: `lib/screens/dashboard/profile_card.dart`
- Create: `test/screens/dashboard_test.dart`

Profile cards showing:
- Name, sync mode icon, status indicator
- Source → destination paths
- Last sync time
- Progress bar when syncing
- Quick actions: Sync Now, Dry Run, Edit

Use `@frontend-design` skill principles for polished card design.

```bash
git commit -m "feat: add dashboard screen with profile cards"
```

---

### Task 6.4: Profile Editor Screen

**Files:**
- Create: `lib/screens/profile_editor/profile_editor_screen.dart`
- Create: `lib/screens/profile_editor/sync_mode_selector.dart`
- Create: `lib/screens/profile_editor/cloud_folder_browser.dart`
- Create: `lib/screens/profile_editor/file_type_chips.dart`
- Create: `lib/screens/profile_editor/git_excludes_section.dart`
- Create: `lib/screens/profile_editor/advanced_options.dart`
- Create: `test/screens/profile_editor_test.dart`

Sectioned form:
1. Basic info — name, sync mode (radio cards with descriptions and warning badges)
2. Paths — remote dropdown, cloud folder browser (lazy-loaded modal), local folder picker
3. File types — include/exclude mode toggle, extension chip input, preset buttons (PDF, Code, Images)
4. Git excludes — respect .gitignore toggle, exclude .git toggle, quick exclude checkboxes, custom pattern input
5. Advanced — bandwidth limit, max transfers slider, check-first toggle
6. Schedule — interval dropdown (manual/5min/15min/30min/1hr), enabled toggle

```bash
git commit -m "feat: add profile editor with all configuration sections"
```

---

### Task 6.5: Cloud Folder Browser Modal

**Files:**
- Already created in Task 6.4 `cloud_folder_browser.dart`

Modal dialog that:
- Lists folders from the selected remote via `operations/list` with `dirsOnly: true`
- Lazy-loads subfolders on expand
- Shows breadcrumb navigation
- Caches results within session
- Returns selected path

```bash
git commit -m "feat: add cloud folder browser modal with lazy loading"
```

---

### Task 6.6: Dry Run Results Screen

**Files:**
- Create: `lib/screens/dry_run/dry_run_results_screen.dart`
- Create: `test/screens/dry_run_test.dart`

Shows SyncPreview data:
- Summary bar: "X files to add (Y MB), X to update, X to delete"
- Three expandable sections with file lists
- Color-coded: green for add, blue for update, red for delete
- "Execute Sync" button to run the real sync
- "Close" to cancel

```bash
git commit -m "feat: add dry run results screen with file change preview"
```

---

### Task 6.7: Activity Screen

**Files:**
- Create: `lib/screens/activity/activity_screen.dart`
- Create: `lib/screens/activity/sync_history_tile.dart`
- Create: `test/screens/activity_test.dart`

Two sections:
1. **Running Jobs** — live progress cards with speed, ETA, progress bar, cancel button
2. **History** — scrollable list of past syncs with status, file count, duration, expandable error details

```bash
git commit -m "feat: add activity screen with job monitoring and sync history"
```

---

### Task 6.8: Settings Screen

**Files:**
- Create: `lib/screens/settings/settings_screen.dart`
- Create: `lib/screens/settings/general_settings.dart`
- Create: `lib/screens/settings/rclone_settings.dart`
- Create: `lib/screens/settings/update_settings.dart`
- Create: `test/screens/settings_test.dart`

Three sections:
1. **General** — theme toggle (System/Light/Dark), launch at login, system tray, notifications
2. **Rclone** — status indicator (connected/disconnected), version, path, "Manage Remotes" button (opens terminal)
3. **Updates** — current version, "Check for Updates" button, changelog viewer

```bash
git commit -m "feat: add settings screen with theme, rclone, and update sections"
```

---

### Task 6.9: Update Dialog with Markdown Changelog

**Files:**
- Create: `lib/screens/update/update_dialog.dart`
- Create: `test/screens/update_dialog_test.dart`

Dialog showing:
- "Update Available" header
- Version comparison: "v0.1.0 → v1.2.0"
- Scrollable markdown-rendered changelog using `flutter_markdown`
- "Download" button (opens URL via `url_launcher`)
- "Skip This Version" button (stores in config)
- "Remind Me Later" button (dismisses)

```bash
git commit -m "feat: add update dialog with markdown changelog rendering"
```

---

## Workstream 7: Integration, System Tray & Polish (depends on 6)

### Task 7.1: System Tray Integration

**Files:**
- Create: `lib/services/tray_service.dart`
- Modify: `lib/main.dart`

System tray menu showing:
- App name
- Profile list with status icons and "Sync Now" actions
- "Sync All Now" action
- "Open DriveSync" action
- "Quit" action

```bash
git commit -m "feat: add system tray with profile status and quick actions"
```

---

### Task 7.2: App Startup Flow — Daemon Init & Onboarding Logic

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/app.dart`

Startup sequence:
1. Load config from ConfigStore
2. Check if first launch → show onboarding
3. Cleanup stale rclone rcd processes
4. Generate RC credentials if first launch
5. Start rclone rcd daemon
6. Wait for health check (poll `/rc/noop` every 500ms, timeout 10s)
7. Verify remotes exist
8. Load profiles
9. Start sync schedulers for enabled profiles
10. Check for updates
11. Show dashboard

```bash
git commit -m "feat: add full app startup flow with daemon init and onboarding"
```

---

### Task 7.3: App Shutdown Flow

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/services/tray_service.dart`

Shutdown sequence:
1. Cancel all sync schedulers
2. If sync jobs running → show confirmation dialog
3. Send `POST /core/quit` to stop rclone rcd
4. Wait up to 5s for process exit
5. Delete PID file
6. Exit app

```bash
git commit -m "feat: add graceful app shutdown with sync confirmation"
```

---

### Task 7.4: Sync Flow — Full Sync & Dry Run Execution

**Files:**
- Modify: `lib/providers/sync_jobs_provider.dart`
- Create: `lib/services/sync_executor.dart`

Full sync flow:
1. If `respectGitignore` → run GitignoreService, get filter rules
2. Call `startSync()` on RcloneService (with or without dryRun)
3. Poll `job/status` every 2 seconds
4. Poll `core/stats` with `group: "job/{id}"` for live progress
5. Update SyncJob in providers
6. On finish → update profile `lastSyncTime`/`lastSyncStatus`, add history entry
7. If dry run → collect `core/transferred` results, build SyncPreview, show results screen
8. If error → update profile `lastSyncError`, show notification

```bash
git commit -m "feat: add complete sync execution flow with job monitoring"
```

---

### Task 7.5: Integration Tests with :local: Remote

**Files:**
- Create: `integration_test/sync_integration_test.dart`

Tests using real rclone with `:local:` pseudo-remote:
1. Start rclone rcd
2. Create temp source/dest directories with test files
3. Test backup mode: copy local→local, verify files copied
4. Test mirror mode: sync with extra dest files, verify extras deleted
5. Test download mode: copy, verify no deletions
6. Test dry run: verify no files actually change
7. Test filters: include only .txt, verify .py excluded
8. Test gitignore: create .gitignore with `*.log`, verify excluded
9. Test job monitoring: start async, poll status, verify completion
10. Stop rclone rcd
11. Cleanup temp directories

```bash
git commit -m "test: add integration tests with :local: pseudo-remote"
```

---

### Task 7.6: Error Handling & Edge Cases

**Files:**
- Modify: multiple service and screen files

Implement all error handling from the design doc:
- rclone not installed → onboarding
- rclone rcd won't start → error dialog
- No remotes → onboarding
- Auth expired → re-auth prompt
- Network offline → offline banner
- Bisync conflict → show affected files
- Local folder missing → offer to create/re-select
- Disk full → warning
- .gitignore parse error → skip bad rules, continue

```bash
git commit -m "feat: add comprehensive error handling for all edge cases"
```

---

### Task 7.7: Polish — Animations, Empty States, Loading States

**Files:**
- Modify: screen files

- Add loading skeletons for dashboard cards while loading
- Empty state illustrations for no profiles, no history
- Smooth transitions between screens
- Progress bar animations
- Status indicator pulse animation when syncing
- Keyboard shortcuts (Cmd+N for new profile, Cmd+S to sync)

```bash
git commit -m "feat: add polish — loading states, empty states, animations"
```

---

### Task 7.8: Launch at Login Integration

**Files:**
- Modify: `lib/screens/settings/general_settings.dart`
- Modify: `lib/providers/app_config_provider.dart`

Use `launch_at_startup` package to toggle auto-launch.

```bash
git commit -m "feat: add launch at login support"
```

---

### Task 7.9: Final Integration Test & Build Verification

**Files:**
- Create: `integration_test/full_app_test.dart`

End-to-end test:
1. App launches successfully
2. If rclone available → daemon starts
3. Can create a profile
4. Can trigger dry run
5. Can trigger sync
6. Can view activity
7. Can change settings (theme toggle works)
8. Can check for updates
9. App quits gracefully

Run: `flutter build macos --release`
Expected: Release build succeeds.

```bash
git commit -m "test: add full end-to-end integration test"
```

---

## Dependency Graph Summary

```
Task 1.1 (project setup)
  → Task 1.2 (SyncMode + SyncProfile)
  → Task 1.3 (AppConfig)
  → Task 1.4 (remaining models)
    → Task 2.1 (RcloneService)         ─┐
    → Task 2.2 (DaemonManager)          │
    → Task 2.3 (ConfigStore)            ├─ parallel
    → Task 2.4 (UpdateChecker)          │
    → Task 2.5 (SyncScheduler)          │
    → Task 3.1 (Theme)                  │
    → Task 3.2 (Core Widgets)           │
    → Task 3.3 (SidebarLayout)          │
    → Task 4.1 (GitignoreService)      ─┘
      → Task 5.1 (All Providers)
        → Task 6.1 (App Shell)
        → Task 6.2 (Onboarding)         ─┐
        → Task 6.3 (Dashboard)           │
        → Task 6.4 (Profile Editor)      ├─ parallel
        → Task 6.5 (Folder Browser)      │
        → Task 6.6 (Dry Run Results)     │
        → Task 6.7 (Activity)            │
        → Task 6.8 (Settings)            │
        → Task 6.9 (Update Dialog)      ─┘
          → Task 7.1 (System Tray)
          → Task 7.2 (Startup Flow)
          → Task 7.3 (Shutdown Flow)
          → Task 7.4 (Sync Execution)
          → Task 7.5 (Integration Tests)
          → Task 7.6 (Error Handling)
          → Task 7.7 (Polish)
          → Task 7.8 (Launch at Login)
          → Task 7.9 (Final Test & Build)
```

## Team Assignment Recommendation

For a team of developers:

| Developer | Workstream | Tasks |
|---|---|---|
| **Dev 1 (Lead)** | Setup + Integration | 1.1-1.4, 7.1-7.9 |
| **Dev 2** | Services | 2.1-2.5 |
| **Dev 3** | Theme + Widgets + Gitignore | 3.1-3.3, 4.1 |
| **Dev 4** | Providers + Screens (1) | 5.1, 6.1-6.3 |
| **Dev 5** | Screens (2) | 6.4-6.9 |

After Workstream 1 completes, Dev 2, 3, and 4 can start in parallel. Dev 5 starts when providers are ready.
