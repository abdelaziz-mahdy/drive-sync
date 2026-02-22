# Drift Migration & Dashboard Redesign

**Date:** 2026-02-22
**Status:** Approved

## Overview

Migrate all data storage from a single `config.json` file to Drift (SQLite), add file-level transfer records to sync history, and redesign the dashboard with a prominent full-width sync banner.

## 1. Drift Database Schema

### Tables

**app_config** (singleton row)
- `id` INT (always 1)
- `theme_mode` TEXT ('system'|'light'|'dark')
- `launch_at_login` BOOL
- `show_in_menu_bar` BOOL
- `show_notifications` BOOL
- `check_updates` BOOL
- `bandwidth_limit` TEXT (nullable)

**sync_profiles**
- `id` TEXT (PK, UUID)
- `name` TEXT
- `remote_name` TEXT
- `cloud_folder` TEXT
- `sync_mode` TEXT ('backup'|'sync'|'bisync'|'copy')
- `schedule_minutes` INT
- `enabled` BOOL
- `respect_gitignore` BOOL
- `exclude_git_dirs` BOOL
- `preserve_source_dir` BOOL
- `use_include_mode` BOOL
- `last_sync_time` DATETIME (nullable)
- `last_sync_status` TEXT (nullable)
- `last_sync_error` TEXT (nullable)
- `created_at` DATETIME
- `updated_at` DATETIME

**profile_local_paths** (one-to-many → sync_profiles)
- `id` INT (auto PK)
- `profile_id` TEXT (FK)
- `path` TEXT

**profile_filter_types** (one-to-many → sync_profiles)
- `id` INT (auto PK)
- `profile_id` TEXT (FK)
- `type_value` TEXT (e.g. '.jpg')
- `is_include` BOOL

**profile_custom_excludes** (one-to-many → sync_profiles)
- `id` INT (auto PK)
- `profile_id` TEXT (FK)
- `pattern` TEXT

**sync_history**
- `id` INT (auto PK)
- `profile_id` TEXT (FK)
- `timestamp` DATETIME
- `status` TEXT ('success'|'error')
- `files_transferred` INT
- `bytes_transferred` INT
- `duration_ms` INT
- `error` TEXT (nullable)

**transferred_files** (one-to-many → sync_history)
- `id` INT (auto PK)
- `history_id` INT (FK)
- `file_name` TEXT
- `file_size` INT
- `completed_at` TEXT (nullable)

### Notes
- Secure storage (RC credentials, config pass) stays in `FlutterSecureStorage`
- `profile_local_paths` replaces the JSON array for proper relational modeling
- `profile_filter_types` unifies include/exclude types with a boolean flag

## 2. Dashboard Sync Banner

When the sync queue has an active job, a full-width animated banner appears at the top of the dashboard, above profile cards.

### Banner Contents
- Profile name + sync mode icon
- Full-width progress bar with percentage
- Stats row: file count, speed, ETA (e.g., "4/12 files - 2.3 MB/s - ~2m left")
- Currently transferring files (up to 3-4 with individual % and size)
- Cancel button
- Queued indicator chip if items are waiting ("+2 queued")

### Behavior
- Animated slide-down when sync starts, slide-up when done
- Completely absent when no sync is running (not an empty state)
- Watches `syncQueueProvider` for data
- Profile cards retain subtle syncing/queued indicators but banner is primary
- Queue preview: expandable section showing "Up next: Profile B, Profile C"

## 3. History Detail Screen

Tapping a history entry navigates to a full detail screen (not a dialog).

### Layout
- **Summary cards** at top: file count, total bytes, duration
- **Profile info**: name, sync mode, timestamp, source → destination paths
- **File list**: scrollable list of transferred files with names and sizes, sorted by name
- **Error section** (conditional): displayed if the sync had errors

### Data Source
- Drift query joining `sync_history` + `transferred_files`
- Files collected from `rclone.getCompletedTransfers()` after each sync

## 4. Data Collection

In `SyncQueueNotifier._executeProfile()`, after sync completion:
1. Call `rcloneService.getCompletedTransfers(group: 'job/$jobId')`
2. Map each transfer to a `TransferredFileRecord`
3. Insert into `transferred_files` table linked to the history entry ID

The API already exists and is used for dry runs. This extends it to real syncs.

## 5. Migration Strategy (Big Bang)

### New Service
`AppDatabase extends GeneratedDatabase` with Drift-generated code.

### DAO Classes
- `ProfilesDao` — CRUD for profiles with joined local paths, filters, excludes
- `HistoryDao` — query history with file records, pagination, stats
- `AppConfigDao` — singleton config row read/write

### Migration Path
1. On first launch, check if `config.json` exists
2. If yes: read JSON, insert all data into Drift tables, rename to `config.json.bak`
3. All Riverpod providers switch from `ConfigStore` → DAO classes
4. Delete `ConfigStore` class and `json_annotation`/`json_serializable` deps for migrated models

### Provider Changes
- `configStoreProvider` → replaced by `appDatabaseProvider`
- `profilesProvider` reads from `ProfilesDao`
- `syncHistoryProvider` reads from `HistoryDao`
- `appConfigProvider` reads from `AppConfigDao`

## 6. Files Affected

### New Files
- `lib/database/app_database.dart` — Drift database class + tables
- `lib/database/daos/profiles_dao.dart`
- `lib/database/daos/history_dao.dart`
- `lib/database/daos/app_config_dao.dart`
- `lib/database/migration.dart` — JSON → Drift migration logic
- `lib/screens/dashboard/sync_banner.dart` — dashboard sync progress banner
- `lib/screens/activity/history_detail_screen.dart` — full history detail view

### Modified Files
- `lib/screens/dashboard/dashboard_screen.dart` — integrate sync banner
- `lib/screens/activity/sync_history_tile.dart` — navigate to detail screen instead of dialog
- `lib/providers/sync_queue_provider.dart` — collect transferred files after sync
- `lib/providers/profiles_provider.dart` — use ProfilesDao
- `lib/providers/sync_history_provider.dart` — use HistoryDao
- `lib/providers/app_config_provider.dart` — use AppConfigDao
- `pubspec.yaml` — add drift, drift_dev, sqlite3_flutter_libs deps

### Deleted Files
- `lib/services/config_store.dart` (after migration is verified)
- `lib/models/sync_history_entry.g.dart` (json_serializable generated code)
- `lib/models/sync_profile.g.dart`
