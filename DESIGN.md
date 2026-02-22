# DriveSync — Technical Design Document

## 1. Overview

**DriveSync** is a native macOS Flutter desktop app that lets users selectively sync specific file types from Google Drive folders to local directories. It wraps `rclone` and communicates with it entirely over its HTTP RC API — no per-command CLI shelling.

### Problem

Google Drive for Desktop only supports folder-level selective sync. There is no way to sync only certain file types (e.g., only `.pdf` and `.docx`) from a folder. Users must sync everything or nothing. It also doesn't respect `.gitignore` files, causing `node_modules`, build artifacts, and other junk to pollute your cloud storage.

### Solution

A lightweight Flutter macOS GUI that:

- Runs `rclone rcd` as a daemon **while the app is open** — stops when the app quits
- Talks to it over `http://localhost:5572` via the RC REST API
- For **background scheduled syncs** (app closed), generates macOS `launchd` plists that invoke rclone CLI directly
- Lets users create "sync profiles" with flexible sync modes: backup (local→cloud, never deletes cloud), mirror (exact copy), and bidirectional
- Supports `.gitignore`-aware syncing — parses `.gitignore` files in source directories and converts them to rclone filter rules automatically
- Handles encrypted config and credentials via rclone's built-in config encryption + macOS Keychain

---

## 2. Architecture

```
                    ┌─── App Open ─────────────────────────────────┐
                    │                                              │
                    │  DriveSync (Flutter macOS)                   │
                    │                                              │
                    │  ┌────────────┐    ┌──────────────────┐      │
                    │  │  UI Layer  │    │ State (Riverpod) │      │
                    │  │  (Screens) │◄───┤  Providers       │      │
                    │  └─────┬──────┘    └───────┬──────────┘      │
                    │        │                   │                 │
                    │  ┌─────▼───────────────────▼──────────┐      │
                    │  │         RcloneService              │      │
                    │  │   (HTTP client → localhost:5572)   │──┐   │
                    │  └────────────────────────────────────┘  │   │
                    │                                          │   │
                    │  ┌────────────────────────────────────┐  │   │
                    │  │  RcloneDaemonManager               │  │   │
                    │  │  (start on open / stop on quit)    │  │   │
                    │  └──────────────┬─────────────────────┘  │   │
                    │                 │                         │   │
                    │  ┌──────────────┼─────────────────────┐  │   │
                    │  │  GitignoreService                  │  │   │
                    │  │  (parse .gitignore → rclone rules) │  │   │
                    │  └────────────────────────────────────┘  │   │
                    │                                          │   │
                    │  ┌────────────────────────────────────┐  │   │
                    │  │  LaunchdManager                    │  │   │
                    │  │  (write/remove plist for bg sync)  │  │   │
                    │  └────────────────────────────────────┘  │   │
                    │                 │                         │   │
                    │                 ▼                    HTTP │   │
                    │          ┌─────────────────┐    POST(JSON)   │
                    │          │   rclone rcd     │◄────────┘      │
                    │          │  localhost:5572  │                 │
                    │          └────────┬────────┘                 │
                    │                  ▼                            │
                    │            Google Drive                       │
                    │                                              │
                    └──────────────────────────────────────────────┘

                    ┌─── App Closed ───────────────────────────────┐
                    │                                              │
                    │  macOS launchd                               │
                    │  ~/Library/LaunchAgents/                     │
                    │  com.drivesync.profile.{id}.plist            │
                    │       │                                      │
                    │       ▼ (on schedule)                        │
                    │  rclone copy/sync (direct CLI, not rcd)      │
                    │       │                                      │
                    │       ▼                                      │
                    │  Google Drive                                │
                    │                                              │
                    └──────────────────────────────────────────────┘
```

### Key Principles

- **Two execution modes.** When the app is open, use `rclone rcd` (HTTP API, progress tracking, UI). When the app is closed, scheduled syncs run via macOS `launchd` calling rclone CLI directly.
- **No orphan daemons.** `rclone rcd` starts on app launch, stops on app quit. If the app crashes, next launch detects and kills stale processes via PID file.
- **No CLI shelling per operation while app is open.** The only `Process.start` call during runtime is to launch `rclone rcd` once. Everything else is HTTP.
- **rclone owns all cloud auth and sync logic.** The Flutter app is purely a config UI + HTTP client + gitignore parser.
- **Config encryption is rclone's job.** The app stores the rclone config password in macOS Keychain via `flutter_secure_storage` and passes it as `RCLONE_CONFIG_PASS` env var.
- **Direct distribution (DMG/notarized), NOT App Store.** macOS sandbox would block `Process.start`.

---

## 3. Tech Stack

| Layer | Choice | Rationale |
|---|---|---|
| Framework | Flutter 3.x macOS desktop | Cross-platform potential, strong desktop support |
| State management | Riverpod | Compile-safe, testable, async-native |
| HTTP client | `dio` | Interceptors for auth, error handling, logging |
| Secure storage | `flutter_secure_storage` | macOS Keychain integration for rclone config password |
| Local config | JSON file in `~/Library/Application Support/DriveSync/` | Simple, human-readable, no DB needed |
| File/folder picker | `file_picker` | Native macOS folder selection dialogs |
| System tray | `tray_manager` or `system_tray` | Keep app alive as menu bar icon |
| macOS styling | `macos_ui` | Native Cupertino-style widgets |
| Process management | `dart:io` Process | Launch rclone rcd daemon only |
| Backend | `rclone rcd` on localhost:5572 | Full REST API, async jobs, progress tracking |

### External Dependencies

- **rclone** — must be installed on the user's machine (`brew install rclone`)
- No other external dependencies

---

## 4. Data Models

### SyncMode Enum

```dart
/// Determines which rclone command to use and how deletions are handled.
enum SyncMode {
  /// Local → Cloud. Uses `rclone copy`. Only adds/updates files on cloud.
  /// Deleting a file locally does NOT delete it from cloud.
  /// This is the "Google Drive app" behavior.
  backup,

  /// Cloud → Local. Uses `rclone sync`. Local becomes exact mirror of cloud.
  /// Files deleted from cloud WILL be deleted locally.
  mirror,

  /// Cloud → Local. Uses `rclone copy`. Only downloads new/updated files.
  /// Files deleted from cloud are NOT deleted locally.
  download,

  /// Two-way. Uses `rclone bisync`. Changes propagate in both directions.
  /// EXPERIMENTAL — conflicts may require manual resolution.
  bisync,
}
```

### SyncProfile

```dart
class SyncProfile {
  final String id;              // UUID
  String name;                  // User-facing label, e.g. "Work Backup"
  String remoteName;            // rclone remote name, e.g. "gdrive"
  String cloudFolder;           // Path on remote, e.g. "Backups/Work"
  String localPath;             // Local path, e.g. "/Users/me/projects"
  List<String> includeTypes;    // File extensions to include, e.g. ["pdf", "docx"]
  List<String> excludeTypes;    // File extensions to exclude (alternative mode)
  bool useIncludeMode;          // true = whitelist these types, false = blacklist
  SyncMode syncMode;            // backup, mirror, download, bisync
  int scheduleMinutes;          // Sync interval in minutes (0 = manual only)
  bool enabled;                 // Whether this profile is active
  bool backgroundSync;          // Install launchd plist for when app is closed
  bool respectGitignore;        // Parse .gitignore files and exclude matched paths
  bool excludeGitDirs;          // Always exclude .git/ directories
  List<String> customExcludes;  // Additional rclone exclude patterns (advanced)
  DateTime? lastSyncTime;
  String? lastSyncStatus;       // "success", "error", "running"
  String? lastSyncError;
}
```

### AppConfig

```dart
class AppConfig {
  bool launchAtLogin;
  bool showInMenuBar;
  bool showNotifications;
  int rcPort;                   // Default 5572
  String? rcUser;               // Auto-generated on first launch
  String? rcPass;               // Auto-generated, stored in Keychain
}
```

### SyncJob (runtime only, not persisted)

```dart
class SyncJob {
  final int jobId;           // From rclone RC API
  final String profileId;    // Which SyncProfile this belongs to
  double progress;           // 0.0 - 1.0
  String status;             // "running", "finished", "error"
  int bytesTransferred;
  int filesTransferred;
  double speed;              // bytes/sec
  String? error;
  DateTime startTime;
  DateTime? endTime;
}
```

---

## 5. Daemon Lifecycle

### Critical: No Background Daemons

`rclone rcd` runs ONLY while the app is open. This is important because:

- Users don't expect hidden background processes after quitting an app
- Orphan daemons waste resources and hold OAuth tokens in memory
- macOS users are sensitive to "this app is still running" in Activity Monitor

### Lifecycle

```
App Opens:
  1. Check for stale rclone rcd (read PID file, check if process alive)
     → If stale: kill it, delete PID file
  2. Start rclone rcd with auth + config password
  3. Write PID to ~/Library/Application Support/DriveSync/rclone.pid
  4. Wait for health check (poll /rc/noop every 500ms, timeout 10s)
  5. Start in-app scheduled sync timers

App Quits (normal):
  1. Cancel all in-app timers
  2. If sync jobs running: show confirmation dialog
  3. Send POST to /core/quit to gracefully stop rclone rcd
  4. Wait up to 5s for process exit
  5. Delete PID file
  6. launchd plists remain installed — background syncs continue without daemon

App Crashes:
  1. Next launch detects stale PID file
  2. Checks if PID is still alive → If alive: SIGTERM, wait 5s, SIGKILL
  3. Delete PID file, continue with normal startup
```

### Background Scheduled Syncs (App Closed)

When a user enables "Run in background when app is closed" for a profile, the app generates a macOS `launchd` plist that runs rclone CLI directly (NOT rclone rcd). This is the standard macOS way to run scheduled tasks.

```dart
class LaunchdManager {
  final String plistDir = '~/Library/LaunchAgents';

  /// Generate and install a launchd plist for a sync profile.
  Future<void> installProfile(SyncProfile profile, String configPass) async {
    final plistName = 'com.drivesync.profile.${profile.id}';
    final plistPath = '$plistDir/$plistName.plist';
    final rcloneCmd = _buildRcloneCommand(profile);

    final plist = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$plistName</string>
  <key>ProgramArguments</key>
  <array>
    ${rcloneCmd.map((a) => '    <string>$a</string>').join('\n')}
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>RCLONE_CONFIG_PASS</key>
    <string>$configPass</string>
  </dict>
  <key>StartInterval</key>
  <integer>${profile.scheduleMinutes * 60}</integer>
  <key>StandardOutPath</key>
  <string>$appSupportDir/logs/${profile.id}.log</string>
  <key>StandardErrorPath</key>
  <string>$appSupportDir/logs/${profile.id}.error.log</string>
  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
''';

    File(plistPath).writeAsStringSync(plist);
    await Process.run('launchctl', ['load', plistPath]);
  }

  /// Build rclone CLI args for a profile (used in launchd, not rcd).
  List<String> _buildRcloneCommand(SyncProfile profile) {
    final cmd = [_rclonePath];

    switch (profile.syncMode) {
      case SyncMode.backup:
        cmd.addAll(['copy', profile.localPath, '${profile.remoteName}:${profile.cloudFolder}']);
      case SyncMode.mirror:
        cmd.addAll(['sync', '${profile.remoteName}:${profile.cloudFolder}', profile.localPath]);
      case SyncMode.download:
        cmd.addAll(['copy', '${profile.remoteName}:${profile.cloudFolder}', profile.localPath]);
      case SyncMode.bisync:
        cmd.addAll(['bisync', '${profile.remoteName}:${profile.cloudFolder}', profile.localPath]);
    }

    // File type filters
    if (profile.useIncludeMode) {
      for (final ext in profile.includeTypes) cmd.addAll(['--include', '*.$ext']);
    } else {
      for (final ext in profile.excludeTypes) cmd.addAll(['--exclude', '*.$ext']);
    }

    // Gitignore filter file
    if (profile.respectGitignore) {
      cmd.addAll(['--filter-from', '$appSupportDir/filters/${profile.id}.rules']);
    }

    // .git directory exclusion
    if (profile.excludeGitDirs) cmd.addAll(['--exclude', '.git/**']);

    // Custom excludes
    for (final pattern in profile.customExcludes) cmd.addAll(['--exclude', pattern]);

    return cmd;
  }

  Future<void> uninstallProfile(String profileId) async {
    final plistName = 'com.drivesync.profile.$profileId';
    final plistPath = '$plistDir/$plistName.plist';
    await Process.run('launchctl', ['unload', plistPath]);
    File(plistPath).deleteSync();
  }
}
```

### When App Opens While launchd Sync Is Running

On startup, check if any launchd-triggered rclone processes are running:
1. Wait for them to finish (poll process list)
2. Read their log files for status
3. Update profile lastSyncTime/lastSyncStatus accordingly
4. Then start rclone rcd as normal

---

## 6. Sync Modes

### Mode Comparison

| Mode | rclone cmd | Direction | Deleting source file deletes on dest? | Use case |
|---|---|---|---|---|
| **Backup** | `copy` | Local → Cloud | **NO** — cloud keeps everything forever | "Back up my projects to Drive. If I delete a local file, keep it on Drive." |
| **Mirror** | `sync` | Cloud → Local | **YES** — local matches cloud exactly | "I want an exact local copy of my cloud folder." |
| **Download** | `copy` | Cloud → Local | **NO** — local keeps everything | "Download new files from cloud but keep local files even if deleted from cloud." |
| **Bisync** | `bisync` | Both ways | **YES** in both directions | "Changes on either side propagate to the other." (experimental) |

### How each mode maps to the RC API

```dart
Future<int> startSync(SyncProfile profile, {List<String>? gitignoreRules}) async {
  final filter = _buildFilterPayload(profile, gitignoreRules: gitignoreRules);
  late final String endpoint;
  late final Map<String, dynamic> data;

  switch (profile.syncMode) {
    case SyncMode.backup:
      endpoint = '/sync/copy';
      data = {
        'srcFs': profile.localPath,                                  // local → cloud
        'dstFs': '${profile.remoteName}:${profile.cloudFolder}',
        '_async': true,
        if (filter.isNotEmpty) '_filter': filter,
      };
    case SyncMode.mirror:
      endpoint = '/sync/sync';
      data = {
        'srcFs': '${profile.remoteName}:${profile.cloudFolder}',    // cloud → local (exact)
        'dstFs': profile.localPath,
        '_async': true,
        if (filter.isNotEmpty) '_filter': filter,
      };
    case SyncMode.download:
      endpoint = '/sync/copy';
      data = {
        'srcFs': '${profile.remoteName}:${profile.cloudFolder}',    // cloud → local (additive)
        'dstFs': profile.localPath,
        '_async': true,
        if (filter.isNotEmpty) '_filter': filter,
      };
    case SyncMode.bisync:
      endpoint = '/sync/bisync';
      data = {
        'path1': '${profile.remoteName}:${profile.cloudFolder}',
        'path2': profile.localPath,
        '_async': true,
        if (filter.isNotEmpty) '_filter': filter,
      };
  }

  final resp = await _dio.post(endpoint, data: data);
  return resp.data['jobid'] as int;
}
```

### UI Representation in Profile Editor

```
Sync Mode
──────────────────────────────────────────────────
○ 📤 Backup (local → cloud)
  Push local files to Drive. Deleting locally
  does NOT delete from Drive.

○ 📥 Download (cloud → local)
  Pull new files from Drive. Keeps local files
  even if deleted from Drive.

● 🔄 Mirror (cloud → local)
  Local folder becomes exact copy of Drive.
  ⚠️ Files not on Drive WILL be deleted locally.

○ ↔️ Bidirectional
  Changes sync both ways.
  ⚠️ Experimental — conflicts may need manual resolution.
──────────────────────────────────────────────────
```

---

## 7. Gitignore Support

### The Problem

rclone does NOT natively parse `.gitignore` files. It has `--exclude-if-present .gitignore` which excludes entire directories containing a `.gitignore`, but that's the opposite of what we want — we want to read the rules INSIDE `.gitignore` and apply them as rclone filters.

### Solution: GitignoreService

A custom Dart service that:
1. Recursively scans the source directory for `.gitignore` files
2. Parses each one following Git's spec (comments, negation, directory patterns, globbing)
3. Converts rules to rclone filter format
4. Writes a combined filter file passed to rclone via `_filter` (RC API) or `--filter-from` (CLI/launchd)

### Gitignore → Rclone Rule Conversion

| `.gitignore` pattern | Meaning | rclone equivalent |
|---|---|---|
| `node_modules/` | Exclude directory named node_modules | `- node_modules/**` |
| `*.pyc` | Exclude all .pyc files | `- *.pyc` |
| `build/` | Exclude directory named build | `- build/**` |
| `/dist` | Exclude dist only at repo root | `- /dist/**` |
| `!important.pyc` | Negate (re-include) | `+ important.pyc` |
| `*.log` | Exclude all log files | `- *.log` |
| `temp?.txt` | Single char wildcard | `- temp?.txt` |
| `doc/**/*.pdf` | Nested glob | `- doc/**/*.pdf` |
| `# comment` | Comment line | (skip) |
| (blank line) | Separator | (skip) |

### Scoping Rules to Their Directory

A `.gitignore` in a subdirectory only applies within that subdirectory. The converter must prefix rules with the relative path:

```
Source dir: /Users/me/projects
Found: /Users/me/projects/backend/.gitignore containing "*.pyc"

→ rclone rule: - /backend/*.pyc
→ NOT: - *.pyc (that would apply globally)
```

### Implementation

```dart
class GitignoreService {
  /// Scan a directory tree for .gitignore files and produce rclone filter rules.
  Future<List<String>> generateRcloneFilters(String rootPath) async {
    final rules = <String>[];
    final root = Directory(rootPath);

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.gitignore')) {
        final relativeDir = _relativePath(rootPath, entity.parent.path);
        final gitignoreRules = await _parseGitignore(entity);

        for (final rule in gitignoreRules) {
          final rcloneRule = _convertRule(rule, relativeDir);
          if (rcloneRule != null) rules.add(rcloneRule);
        }
      }
    }

    return rules;
  }

  Future<List<String>> _parseGitignore(File file) async {
    final lines = await file.readAsLines();
    return lines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();
  }

  String? _convertRule(String gitRule, String scopeDir) {
    var rule = gitRule;
    var prefix = '-'; // exclude by default

    // Handle negation
    if (rule.startsWith('!')) {
      prefix = '+';
      rule = rule.substring(1);
    }

    // Handle directory-only patterns (trailing slash)
    final dirOnly = rule.endsWith('/');
    if (dirOnly) rule = rule.substring(0, rule.length - 1);

    // Scope to the directory containing this .gitignore
    String scopedRule;
    if (rule.startsWith('/')) {
      scopedRule = scopeDir.isEmpty ? rule : '/$scopeDir${rule}';
    } else {
      scopedRule = rule;
    }

    if (dirOnly) scopedRule = '$scopedRule/**';

    return '$prefix $scopedRule';
  }

  /// Write filter rules to a file for rclone --filter-from.
  Future<String> writeFilterFile(String profileId, List<String> rules) async {
    final dir = await _getFilterDir();
    final file = File('$dir/$profileId.rules');
    await file.writeAsString(rules.join('\n'));
    return file.path;
  }
}
```

### Integration with Sync Flow

Before each sync, if `profile.respectGitignore` is true:

```
1. GitignoreService.generateRcloneFilters(source path)
2. Write rules to filter file (for launchd reference)
3. For RC API (app open): pass rules in _filter.FilterRule
4. For launchd CLI (app closed): pass --filter-from pointing to the saved filter file
```

### Pre-built Quick Excludes

In addition to full `.gitignore` parsing, offer one-click common excludes in the profile editor:

```
Quick Excludes (checkboxes):
  [✓] .git directories          → .git/**
  [✓] node_modules              → node_modules/**
  [ ] Python virtualenvs        → .venv/**  venv/**
  [ ] Build artifacts           → build/**  dist/**
  [ ] macOS system files        → .DS_Store  ._*
  [ ] IDE configs               → .idea/**  .vscode/**
```

These are stored as `customExcludes` on the profile. Simpler and more predictable than full gitignore parsing.

---

## 8. Rclone RC API Integration

### Starting the Daemon

```dart
class RcloneDaemonManager {
  Process? _process;
  final String _pidFile; // ~/Library/Application Support/DriveSync/rclone.pid

  Future<void> start({required String user, required String pass, int port = 5572}) async {
    await _cleanupStale();

    if (await isRunning(port)) {
      throw Exception('Port $port already in use.');
    }

    _process = await Process.start('rclone', [
      'rcd',
      '--rc-user', user,
      '--rc-pass', pass,
      '--rc-addr', 'localhost:$port',
    ], environment: {
      'RCLONE_CONFIG_PASS': configPassword,
    });

    File(_pidFile).writeAsStringSync(_process!.pid.toString());
  }

  Future<bool> isRunning([int port = 5572]) async {
    try {
      final resp = await http.post(Uri.parse('http://localhost:$port/rc/noop'));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await http.post(Uri.parse('http://localhost:$port/core/quit'));
    } catch (_) {
      _process?.kill();
    }
    final f = File(_pidFile);
    if (f.existsSync()) f.deleteSync();
  }

  Future<void> _cleanupStale() async {
    final pidFile = File(_pidFile);
    if (!pidFile.existsSync()) return;
    final pid = int.tryParse(pidFile.readAsStringSync().trim());
    if (pid != null) {
      final result = await Process.run('kill', ['-0', '$pid']);
      if (result.exitCode == 0) {
        Process.killPid(pid, ProcessSignal.sigterm);
        await Future.delayed(Duration(seconds: 3));
        Process.killPid(pid, ProcessSignal.sigkill);
      }
    }
    pidFile.deleteSync();
  }
}
```

### RcloneService — Core API Client

```dart
class RcloneService {
  final Dio _dio;

  RcloneService({required String user, required String pass, int port = 5572}) {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:$port',
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode("$user:$pass"))}',
        'Content-Type': 'application/json',
      },
    ));
  }

  // ─── Remote Management ───
  Future<List<String>> listRemotes() async {
    final resp = await _dio.post('/config/listremotes');
    return List<String>.from(resp.data['remotes']);
  }

  Future<Map> getRemoteConfig(String name) async =>
      (await _dio.post('/config/get', data: {'name': name})).data;

  Future<void> deleteRemote(String name) async =>
      await _dio.post('/config/delete', data: {'name': name});

  // ─── Folder Browsing ───
  Future<List<Map>> listFolder(String remote, String path) async {
    final resp = await _dio.post('/operations/list', data: {
      'fs': '$remote:', 'remote': path,
      'opt': {'dirsOnly': false, 'recurse': false},
    });
    return List<Map>.from(resp.data['list'] ?? []);
  }

  Future<List<Map>> listFolders(String remote, String path) async {
    final resp = await _dio.post('/operations/list', data: {
      'fs': '$remote:', 'remote': path,
      'opt': {'dirsOnly': true, 'recurse': false},
    });
    return List<Map>.from(resp.data['list'] ?? []);
  }

  // ─── Filter Building ───
  Map<String, dynamic> _buildFilterPayload(SyncProfile profile, {List<String>? gitignoreRules}) {
    final filter = <String, dynamic>{};

    if (profile.useIncludeMode && profile.includeTypes.isNotEmpty) {
      filter['IncludeRule'] = profile.includeTypes.map((ext) => '*.$ext').toList();
    }
    if (!profile.useIncludeMode && profile.excludeTypes.isNotEmpty) {
      filter['ExcludeRule'] = profile.excludeTypes.map((ext) => '*.$ext').toList();
    }

    final filterRules = <String>[];
    if (gitignoreRules != null) filterRules.addAll(gitignoreRules);
    if (profile.excludeGitDirs) filterRules.add('- .git/**');
    for (final p in profile.customExcludes) filterRules.add('- $p');
    if (filterRules.isNotEmpty) filter['FilterRule'] = filterRules;

    return filter;
  }

  // ─── Sync Operations (see Section 6 for mode details) ───
  Future<int> startSync(SyncProfile profile, {List<String>? gitignoreRules}) async {
    final filter = _buildFilterPayload(profile, gitignoreRules: gitignoreRules);
    late final String endpoint;
    late final Map<String, dynamic> data;

    switch (profile.syncMode) {
      case SyncMode.backup:
        endpoint = '/sync/copy';
        data = {'srcFs': profile.localPath, 'dstFs': '${profile.remoteName}:${profile.cloudFolder}',
                '_async': true, if (filter.isNotEmpty) '_filter': filter};
      case SyncMode.mirror:
        endpoint = '/sync/sync';
        data = {'srcFs': '${profile.remoteName}:${profile.cloudFolder}', 'dstFs': profile.localPath,
                '_async': true, if (filter.isNotEmpty) '_filter': filter};
      case SyncMode.download:
        endpoint = '/sync/copy';
        data = {'srcFs': '${profile.remoteName}:${profile.cloudFolder}', 'dstFs': profile.localPath,
                '_async': true, if (filter.isNotEmpty) '_filter': filter};
      case SyncMode.bisync:
        endpoint = '/sync/bisync';
        data = {'path1': '${profile.remoteName}:${profile.cloudFolder}', 'path2': profile.localPath,
                '_async': true, if (filter.isNotEmpty) '_filter': filter};
    }

    final resp = await _dio.post(endpoint, data: data);
    return resp.data['jobid'] as int;
  }

  // ─── Job Monitoring ───
  Future<Map> getJobStatus(int jobId) async =>
      (await _dio.post('/job/status', data: {'jobid': jobId})).data;

  Future<Map> getJobList() async => (await _dio.post('/job/list')).data;

  Future<Map> getTransferStats({String? group}) async =>
      (await _dio.post('/core/stats', data: group != null ? {'group': group} : {})).data;

  // ─── Config & Health ───
  Future<Map> getConfigDump() async => (await _dio.post('/config/dump')).data;

  Future<bool> healthCheck() async {
    try { await _dio.post('/rc/noop'); return true; } catch (_) { return false; }
  }
}
```

---

## 9. Screen Designs

The app uses `macos_ui` for native macOS look and feel. Sidebar navigation layout.

### 9.1 — Onboarding / First Launch

**Flow:**
1. Check rclone installed → if not, show `brew install rclone` instructions
2. Check remotes exist → if empty, show "Set up Google Drive"
3. Google Drive setup → open Terminal.app with `rclone config`, poll until remote appears
4. Optional config encryption → prompt, store password in Keychain
5. Done → navigate to main app

### 9.2 — Main Dashboard

```
┌─────────────────────────────────────────────────┐
│  DriveSync                          [+ New]     │
│─────────────────────────────────────────────────│
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ 📤 Work Backup            ✅ Backed up  │    │
│  │    ~/projects/work → gdrive:Backups     │    │
│  │    .py, .js, .md · Respects .gitignore  │    │
│  │    Last: 5 min ago · ⏰ Background: ON  │    │
│  │    [Sync Now]                            │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ 📥 School Notes           🔄 Syncing... │    │
│  │    gdrive:School → ~/sync/school        │    │
│  │    .pdf, .pptx · Download mode          │    │
│  │    [████████░░░░░░] 65%   2.3 MB/s      │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │ ↔️ Shared Project         ❌ Error      │    │
│  │    gdrive:Shared ↔ ~/projects/shared    │    │
│  │    Error: conflict on report.docx       │    │
│  │    [View Details] [Retry]                │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 9.3 — Profile Editor

```
┌─────────────────────────────────────────────────┐
│  ← Back                    New Sync Profile     │
│─────────────────────────────────────────────────│
│                                                 │
│  Profile Name: [Work Backup              ]      │
│                                                 │
│  ── Sync Mode ──                                │
│  ○ 📤 Backup (local → cloud, no cloud deletes) │
│  ○ 📥 Download (cloud → local, no local deletes│
│  ● 🔄 Mirror (cloud → local, exact copy)       │
│  ○ ↔️ Bidirectional (experimental)              │
│                                                 │
│  Remote: [gdrive           ▼] [Manage Remotes]  │
│  Cloud Folder: [📁 Work/Projects          [📁]] │
│  Local Folder: [/Users/me/projects/work   [📁]] │
│                                                 │
│  ── File Types ──                               │
│  ● Include only: [pdf ×][docx ×][xlsx ×][+Add] │
│  ○ Exclude these types  ○ All files             │
│  Common: [PDF][Word][Excel][Images][Code]       │
│                                                 │
│  ── Git & Dev Excludes ──                       │
│  [✓] Respect .gitignore files                   │
│  [✓] Exclude .git directories                   │
│  Quick excludes:                                │
│  [✓] node_modules   [ ] .venv/venv              │
│  [ ] build/dist      [ ] .DS_Store/._*           │
│  [ ] .idea/.vscode                               │
│  Custom patterns:                               │
│  [*.tmp                                    ]    │
│  [*.log                                    ]    │
│                                                 │
│  ── Schedule ──                                 │
│  [Every 15 min ▼]  ○ Manual only                │
│  [✓] Run in background when app is closed       │
│                                                 │
│              [Cancel]  [Save Profile]            │
└─────────────────────────────────────────────────┘
```

### 9.4 — Cloud Folder Browser (Modal)

Lazy-loads subfolders via `operations/list` with `dirsOnly: true`. Caches within session.

### 9.5 — Activity / Logs

Shows running jobs with progress, history of completed syncs, background (launchd) sync results read from log files on app open.

### 9.6 — Settings

General preferences, rclone status, active launchd jobs list, remote management, data import/export.

---

## 10. Navigation Structure

```
┌──────────┬──────────────────────────────┐
│ Sidebar  │  Content Area                │
│ 🏠 Home  │  (selected screen)           │
│ ➕ New   │                              │
│ 📋 Activity                             │
│ ⚙️ Settings                             │
│──────────│                              │
│ PROFILES │                              │
│ 📤 Work  │                              │
│ 📥 School│                              │
│ ↔️ Shared│                              │
└──────────┴──────────────────────────────┘
```

---

## 11. System Tray / Menu Bar

```
  [☁️▼]
  ┌──────────────────────────┐
  │ DriveSync                │
  │──────────────────────────│
  │ ✅ 📤 Work Backup [Sync] │
  │ 🔄 📥 School       65%  │
  │ ❌ ↔️ Shared     [Retry] │
  │──────────────────────────│
  │ Sync All Now             │
  │ Open DriveSync           │
  │ Quit                     │
  └──────────────────────────┘
```

---

## 12. Key Flows

### 12.1 — App Startup
1. Read AppConfig → retrieve credentials from Keychain → cleanup stale PID → check launchd log files → start rclone rcd → health check → verify remotes → load profiles → start timers → show dashboard

### 12.2 — Creating a Profile
Select mode → select remote → browse cloud folder → pick local folder → configure file types → configure git excludes → set schedule + background toggle → save → generate filter file if gitignore → install launchd plist if background sync

### 12.3 — Sync (App Open)
Generate gitignore filters if enabled → call RC API startSync → poll job/status every 2s → update UI → on finish: update profile, notify, stop polling

### 12.4 — Sync (App Closed)
launchd fires on schedule → runs rclone CLI directly with filters → logs to file → next app open reads logs and updates profile status

### 12.5 — App Quit
Cancel timers → confirm if syncs running → POST /core/quit → delete PID file → launchd plists stay installed

---

## 13. Config Storage

Location: `~/Library/Application Support/DriveSync/config.json`

```json
{
  "appConfig": {
    "launchAtLogin": true,
    "showInMenuBar": true,
    "showNotifications": true,
    "rcPort": 5572
  },
  "profiles": [
    {
      "id": "uuid-1234",
      "name": "Work Backup",
      "remoteName": "gdrive",
      "cloudFolder": "Backups/Work",
      "localPath": "/Users/me/projects/work",
      "includeTypes": ["py", "js", "ts", "md", "json"],
      "excludeTypes": [],
      "useIncludeMode": true,
      "syncMode": "backup",
      "scheduleMinutes": 15,
      "enabled": true,
      "backgroundSync": true,
      "respectGitignore": true,
      "excludeGitDirs": true,
      "customExcludes": ["*.log", "__pycache__/**", ".DS_Store", "node_modules/**"],
      "lastSyncTime": "2025-02-21T10:30:00Z",
      "lastSyncStatus": "success",
      "lastSyncError": null
    }
  ],
  "syncHistory": []
}
```

### Generated Files

| Path | Purpose |
|---|---|
| `~/Library/Application Support/DriveSync/rclone.pid` | PID of running rclone rcd (deleted on quit) |
| `~/Library/Application Support/DriveSync/filters/{id}.rules` | Rclone filter rules generated from .gitignore |
| `~/Library/Application Support/DriveSync/logs/{id}.log` | stdout from launchd background syncs |
| `~/Library/Application Support/DriveSync/logs/{id}.error.log` | stderr from launchd background syncs |
| `~/Library/LaunchAgents/com.drivesync.profile.{id}.plist` | launchd plists for background syncs |

### Secrets (macOS Keychain)

| Key | Value |
|---|---|
| `drivesync.rc_user` | RC API username |
| `drivesync.rc_pass` | RC API password |
| `drivesync.rclone_config_pass` | Rclone config encryption password |

---

## 14. Encryption Strategy

The app implements NO crypto itself.

- **Credentials:** rclone config encryption + macOS Keychain for the password
- **Data on Drive (optional):** rclone `crypt` remote — user selects it in profile editor
- **Local disk:** macOS FileVault

---

## 15. Error Handling

| Error | Detection | Action |
|---|---|---|
| rclone not installed | `which rclone` fails | Show install instructions |
| rclone rcd won't start | Health check timeout 10s | Show error, check port conflict |
| Stale rclone rcd | PID file exists on startup | Auto-kill, restart |
| No remotes | `config/listremotes` empty | Onboarding |
| Auth expired | 401/403 from Google | "Re-authenticate" → Terminal |
| Rate limit | Job error | Suggest longer schedule interval |
| Network offline | HTTP to localhost fails | Offline banner, pause syncs |
| Bisync conflict | Job error | Show files, suggest resolution |
| Local folder missing | Pre-sync check | Offer to create or re-pick |
| Disk full | Job error | Warning with space info |
| launchd install fails | `launchctl load` error | Show manual instructions |
| .gitignore parse error | GitignoreService throws | Log warning, skip bad rules, continue |
| Background sync error | Read error log on app open | Badge in Activity screen |

---

## 16. Platform Config (macos/)

Disable sandbox, enable network client + filesystem + process execution in entitlements. Distribute as notarized DMG, NOT App Store.

---

## 17. Packages (pubspec.yaml)

```yaml
dependencies:
  flutter: { sdk: flutter }
  macos_ui: ^2.0.0
  flutter_riverpod: ^2.0.0
  dio: ^5.0.0
  flutter_secure_storage: ^9.0.0
  file_picker: ^6.0.0
  uuid: ^4.0.0
  path_provider: ^2.0.0
  system_tray: ^2.0.0
  launch_at_startup: ^0.3.0
  intl: ^0.19.0
  json_annotation: ^4.0.0

dev_dependencies:
  flutter_test: { sdk: flutter }
  build_runner: ^2.0.0
  json_serializable: ^6.0.0
  flutter_lints: ^3.0.0
```

---

## 18. File Structure

```
lib/
├── main.dart
├── app.dart
├── models/
│   ├── sync_profile.dart          # SyncProfile + SyncMode enum
│   ├── app_config.dart
│   └── sync_job.dart
├── services/
│   ├── rclone_service.dart        # RC API HTTP client
│   ├── rclone_daemon_manager.dart # Start/stop/PID management
│   ├── config_store.dart          # JSON config + Keychain
│   ├── sync_scheduler.dart        # In-app timers
│   ├── launchd_manager.dart       # Background sync plist management
│   └── gitignore_service.dart     # .gitignore → rclone filter rules
├── providers/
│   ├── rclone_provider.dart
│   ├── profiles_provider.dart
│   ├── sync_jobs_provider.dart
│   └── app_config_provider.dart
├── screens/
│   ├── onboarding/
│   ├── dashboard/
│   ├── profile_editor/
│   │   ├── profile_editor_screen.dart
│   │   ├── sync_mode_selector.dart
│   │   ├── folder_browser_modal.dart
│   │   ├── file_type_chips.dart
│   │   └── git_excludes_section.dart
│   ├── activity/
│   └── settings/
└── widgets/
    ├── status_dot.dart
    ├── sync_mode_icon.dart
    ├── progress_bar.dart
    └── sidebar_layout.dart
```

---

## 19. Implementation Order

### Phase 1: Foundation
1. Flutter macOS project + macos_ui shell
2. RcloneDaemonManager (start/stop/PID/crash recovery)
3. RcloneService (all RC API methods, all sync modes)
4. ConfigStore (JSON + Keychain)
5. SyncProfile + SyncMode models
6. **Test:** Start rcd, list remotes, run copy/sync/bisync via HTTP

### Phase 2: Core UI
7. Onboarding
8. Dashboard with sync mode icons and status
9. Profile Editor with sync mode radio cards
10. Cloud Folder Browser modal
11. **Test:** Create profiles with different modes, trigger syncs

### Phase 3: Gitignore & Filtering
12. GitignoreService — parse → convert → write filter files
13. Git/dev excludes UI (checkboxes + custom patterns)
14. Integrate into sync flow (RC API and CLI)
15. **Test:** Syncs correctly exclude gitignored files

### Phase 4: Background Sync
16. LaunchdManager — generate/install/remove plists
17. "Background sync" toggle in editor
18. On app open: read launchd logs, update status
19. Settings: active launchd jobs management
20. **Test:** Close app, launchd fires sync, reopen and verify

### Phase 5: Activity & Notifications
21. SyncScheduler (in-app timers)
22. Job polling + progress UI
23. Sync history + Activity screen
24. macOS notifications
25. **Test:** Full scheduled + manual sync lifecycle

### Phase 6: Polish
26. System tray / menu bar
27. Launch at login
28. Error handling (all cases)
29. Profile import/export
30. **Test:** Full end-to-end

---

## 20. Testing Notes

- **Unit test** `GitignoreService` thoroughly — nested scoping, negation, directory patterns, wildcards
- **Unit test** `LaunchdManager` — verify plist XML, correct rclone args per sync mode
- **Unit test** `RcloneService` with mock HTTP server
- **Integration test** with real rclone rcd against `:local:` remote (no Google account needed)
- Test daemon lifecycle: start → crash → restart → PID cleanup
- Test that `SyncMode.backup` (copy) does NOT delete cloud files when local files are deleted

---

## 21. Out of Scope (Future)

- Windows/Linux (launchd → systemd/Task Scheduler)
- Embedded OAuth flow
- Conflict resolution UI for bisync
- Bandwidth throttling
- Auto-update for the app
- Full Git-spec .gitignore inheritance (v1 treats each file independently)
- .gitignore hot-reload via fswatch (v1 re-parses on each sync)
- Selective per-file sync (v1 is folder-level profiles only)
