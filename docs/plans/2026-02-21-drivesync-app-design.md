# DriveSync App Design

## Summary

DriveSync is a cross-platform desktop app that wraps rclone to provide selective file-type syncing with Google Drive. It communicates with rclone via its RC HTTP API running on localhost:5572.

## Decisions

- **UI**: Custom Material 3 with heavy theming, neutral/adaptive color scheme, full light + dark mode
- **State**: Riverpod (compile-safe, async-native)
- **Layout**: Sidebar + content pane with responsive breakpoints
- **Background sync**: In-app service via system tray (no OS-level schedulers)
- **Remote setup**: Guide user to `rclone config` in terminal
- **Updates**: GitHub Releases API check on startup + manual, markdown-rendered changelog
- **Dry run**: Optional test/validation tool per profile, not mandatory
- **Testing**: TDD with `:local:` pseudo-remote for integration tests + mocked unit tests
- **Distribution**: Direct (DMG/exe/deb), not app stores
- **Repo**: https://github.com/abdelaziz-mahdy/drive-sync

---

## Architecture

```
DriveSync App
├── UI Layer (Material 3, custom theme)
├── Providers (Riverpod)
├── Service Layer
│   ├── RcloneService (HTTP client → RC API)
│   ├── RcloneDaemonManager (start/stop rclone rcd, PID management)
│   ├── GitignoreService (.gitignore → rclone filter rules)
│   ├── ConfigStore (JSON config + secure storage for secrets)
│   ├── SyncScheduler (in-app timers)
│   └── UpdateChecker (GitHub Releases API)
└── rclone rcd (localhost:5572)
    └── Google Drive
```

### Daemon Lifecycle

- `rclone rcd` starts on app launch, stops on app quit
- PID file at `~/Library/Application Support/DriveSync/rclone.pid` (platform-adapted)
- Stale process detection and cleanup on startup
- Health check polling via `rc/noop`
- Graceful shutdown via `core/quit`

---

## Data Models

### SyncMode

```
backup   → rclone copy  (local → cloud, no cloud deletes)
mirror   → rclone sync  (cloud → local, exact copy, DELETES local extras)
download → rclone copy  (cloud → local, no local deletes)
bisync   → rclone bisync (bidirectional, experimental)
```

### SyncProfile

```
id, name, remoteName, cloudFolder, localPath
includeTypes, excludeTypes, useIncludeMode
syncMode, scheduleMinutes, enabled
respectGitignore, excludeGitDirs, customExcludes
bandwidthLimit, maxTransfers, checkFirst
lastSyncTime, lastSyncStatus, lastSyncError
```

### SyncPreview (dry-run results)

```
profileId, timestamp
filesToAdd: List<FileChange>
filesToUpdate: List<FileChange>
filesToDelete: List<FileChange>
totalSize
```

### AppRelease (GitHub release)

```
version, tagName, publishedAt
changelog (markdown body)
downloadUrl (platform asset)
isPreRelease
```

### SyncHistoryEntry

```
profileId, timestamp, status
filesTransferred, bytesTransferred, duration
error (if any)
```

### AppConfig

```
themeMode (system/light/dark), launchAtLogin
showInMenuBar, showNotifications
rcPort (default 5572), rcUser, rcPass
skippedVersion (for update dismissal)
```

---

## RC API Integration

### Endpoints Used

| Feature | Endpoint | Notes |
|---|---|---|
| Health check | `rc/noop` | Poll on startup |
| List remotes | `config/listremotes` | Remote selector |
| Remote config | `config/get` | Show details |
| Browse folders | `operations/list` (dirsOnly) | Lazy-loaded tree |
| Backup sync | `sync/copy` + `_async: true` | Local → cloud |
| Mirror sync | `sync/sync` + `_async: true` | Cloud → local (exact) |
| Download sync | `sync/copy` + `_async: true` | Cloud → local (additive) |
| Bidirectional | `sync/bisync` + `_async: true` | Both ways |
| Dry run | Any sync + `_config: {DryRun: true}` | Preview without executing |
| Job status | `job/status` | Poll every 2s |
| Job list | `job/list` | Running/finished IDs |
| Stop job | `job/stop` | Cancel running sync |
| Transfer stats | `core/stats` (group: "job/{id}") | Live progress |
| Completed transfers | `core/transferred` | Dry-run results |
| Bandwidth limit | `core/bwlimit` | Runtime throttling |
| Version | `core/version` | Settings display |
| Shutdown | `core/quit` | App close |

### Filter System

Using `_filter` parameter on RC API calls:
```json
{
  "_filter": {
    "IncludeRule": ["*.pdf", "*.docx"],
    "ExcludeRule": ["*.tmp"],
    "FilterRule": ["- .git/**", "- node_modules/**"],
    "FilterFrom": ["/path/to/gitignore-rules.txt"]
  }
}
```

### Bisync Configuration

Exposed in profile editor advanced section (bisync mode only):
- `conflictResolve`: none/path1/path2/newer/older
- `maxDelete`: safety limit (default 50%)
- `checkAccess`: sentinel file verification
- `recover`: auto-recover from interruptions

---

## UI/UX Design

### Navigation

Sidebar layout:
- Dashboard (home)
- Profiles (listed individually in sidebar)
- Activity (sync history)
- Settings

### Theme

- Material 3 `ColorScheme.fromSeed()` with neutral slate seed
- Light: white surfaces, subtle borders, dark text
- Dark: #121212 base, muted surfaces
- Status colors consistent across themes: green/blue/amber/red
- System font, clean typography hierarchy

### Screens

**Dashboard**: Card grid of profiles with status, progress, quick actions (Sync Now, Dry Run, Edit)

**Profile Editor**: Sectioned form - basic info, sync mode (radio cards), paths, file filters (extension chips), git excludes (checkboxes + custom), advanced (bandwidth, transfers), schedule

**Dry Run Results**: Three expandable sections (add/update/delete), summary bar, "Execute Sync" button

**Activity**: Timeline of past syncs with expandable details, running jobs with live progress

**Settings**: Theme toggle, launch at login, system tray, rclone status/version, update checker with changelog

**Onboarding**: Check rclone installed → check remotes → create first profile

**Update Dialog**: Version comparison, markdown-rendered changelog, download button, skip/remind options

---

## GitHub Update System

- Check `GET https://api.github.com/repos/abdelaziz-mahdy/drive-sync/releases/latest` on startup
- Compare semver with `package_info_plus` current version
- Show badge in sidebar if update available
- Dialog renders full changelog via `flutter_markdown`
- Download link from release assets (platform-specific)
- "Skip this version" persisted in config

---

## Gitignore Support

GitignoreService:
1. Recursively scan source directory for `.gitignore` files
2. Parse each following Git spec (comments, negation, directory patterns, globbing)
3. Convert to rclone filter format with directory scoping
4. Write combined filter file for reference
5. Pass via `_filter.FilterRule` (RC API)

Quick excludes (one-click): .git, node_modules, .venv, build/dist, .DS_Store, .idea/.vscode

---

## Testing Strategy

### Unit Tests (mocked)
- GitignoreService: rule parsing, conversion, scoping, negation, wildcards
- ConfigStore: JSON serialization, validation
- UpdateChecker: version comparison, release parsing
- SyncProfile: filter building, serialization

### Service Tests (mocked HTTP)
- RcloneService: all endpoints, error handling, auth, filters
- RcloneDaemonManager: lifecycle, PID management
- SyncScheduler: timer behavior

### Integration Tests (real rclone, `:local:` remote)
- Each sync mode with temp directories
- Dry-run verification (no actual changes)
- Filter application
- Job lifecycle: start → monitor → complete
- Error scenarios

### Widget Tests
- Profile editor form validation
- Sync mode selector
- Dry-run results display
- Theme switching
- Dashboard card states

---

## Packages

```yaml
dependencies:
  flutter: { sdk: flutter }
  flutter_riverpod: ^2.0.0
  riverpod_annotation: ^2.0.0
  dio: ^5.0.0
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.0.0
  flutter_markdown: ^0.7.0
  file_picker: ^6.0.0
  system_tray: ^2.0.0
  launch_at_startup: ^0.3.0
  uuid: ^4.0.0
  intl: ^0.19.0
  json_annotation: ^4.0.0
  url_launcher: ^6.0.0
  package_info_plus: ^8.0.0

dev_dependencies:
  flutter_test: { sdk: flutter }
  build_runner: ^2.0.0
  json_serializable: ^6.0.0
  riverpod_generator: ^2.0.0
  flutter_lints: ^3.0.0
  mockito: ^5.0.0
  http_mock_adapter: ^0.6.0
```

---

## File Structure

```
lib/
├── main.dart
├── app.dart
├── theme/
│   ├── app_theme.dart
│   ├── color_schemes.dart
│   └── text_styles.dart
├── models/
│   ├── sync_profile.dart
│   ├── app_config.dart
│   ├── sync_job.dart
│   ├── sync_preview.dart
│   ├── sync_history_entry.dart
│   ├── app_release.dart
│   └── file_change.dart
├── services/
│   ├── rclone_service.dart
│   ├── rclone_daemon_manager.dart
│   ├── config_store.dart
│   ├── sync_scheduler.dart
│   ├── gitignore_service.dart
│   └── update_checker.dart
├── providers/
│   ├── rclone_provider.dart
│   ├── profiles_provider.dart
│   ├── sync_jobs_provider.dart
│   ├── app_config_provider.dart
│   ├── theme_provider.dart
│   └── update_provider.dart
├── screens/
│   ├── onboarding/
│   ├── dashboard/
│   ├── profile_editor/
│   ├── dry_run/
│   ├── activity/
│   ├── settings/
│   └── update/
└── widgets/
    ├── sidebar_layout.dart
    ├── status_indicator.dart
    ├── progress_bar.dart
    ├── sync_mode_icon.dart
    └── responsive_scaffold.dart
```

---

## Error Handling

| Error | Detection | Action |
|---|---|---|
| rclone not installed | `which rclone` fails | Onboarding with install instructions |
| rclone rcd won't start | Health check timeout 10s | Error dialog, check port conflict |
| Stale rclone rcd | PID file exists on startup | Auto-kill, restart |
| No remotes configured | `config/listremotes` empty | Onboarding flow |
| Auth expired | 401/403 from Google | "Re-authenticate" → terminal |
| Rate limited | Job error | Suggest longer interval |
| Network offline | HTTP timeout | Offline banner, pause syncs |
| Bisync conflict | Job error with conflict info | Show affected files, suggest resolution |
| Local folder missing | Pre-sync path check | Offer to create or re-select |
| Disk full | Job error | Warning with space info |
| .gitignore parse error | GitignoreService exception | Log warning, skip bad rules |
| Update check fails | Network error | Silent failure, retry next launch |
