# Changelog

All notable changes to DriveSync will be documented in this file.

## 0.1.0

Initial release.

### Features

- **Sync Profiles** - Create named profiles with custom configuration
- **4 Sync Modes** - Backup, Mirror, Download, and Bidirectional sync via rclone
- **File-Type Filtering** - Include or exclude specific file extensions per profile
- **Multiple Local Paths** - Sync multiple folders within a single profile
- **Scheduled Syncs** - Automatic syncing at configurable intervals (5min, 15min, 30min, hourly)
- **Dry Run Preview** - Preview all file changes before executing a sync
- **Real-Time Progress** - Live transfer speed, ETA, and per-file tracking
- **Sync Queue** - Queue multiple syncs and execute them sequentially
- **Sync All** - Start syncing every profile with one click
- **Sync History** - View past sync results with transferred file details
- **Git Integration** - Automatically respects `.gitignore` and excludes `.git` directories
- **Custom Exclude Patterns** - Define additional exclusion rules per profile
- **Bandwidth Limiting** - Throttle upload/download speeds
- **Cloud Folder Browser** - Browse and select cloud destinations interactively
- **System Tray** - Minimize to system tray for background operation
- **Launch at Login** - Start DriveSync automatically on system boot
- **Theme Support** - Light, Dark, and System theme modes
- **In-App Updates** - Check for new versions from GitHub releases
- **Onboarding** - Guided setup for first-time users
- **Drift Database** - SQLite-backed persistence for profiles, history, and configuration
- **Desktop Support** - macOS, Windows, and Linux
