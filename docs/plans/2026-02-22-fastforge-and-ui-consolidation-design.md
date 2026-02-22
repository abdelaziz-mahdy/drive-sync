# Design: fastforge CI/CD + UI Consolidation

**Date:** 2026-02-22
**Status:** Approved

## Part 1: CI/CD - Switch to fastforge

Replace per-platform packaging tools with `fastforge` (global CLI, formerly flutter_distributor).

### Changes

- Add `distribute_options.yaml` at project root with 3 release names (one per platform)
- Add `macos/packaging/dmg/make_config.yaml` - DMG layout with Applications link
- Add `windows/packaging/exe/make_config.yaml` - Inno Setup config (app name, publisher, icon)
- Add `linux/packaging/deb/make_config.yaml` - DEB metadata (maintainer, categories, icon)
- Rewrite `.github/workflows/release.yml` to use `fastforge release --name <platform>` per runner
- macOS runner: `npm install -g appdmg` (fastforge DMG maker dependency)
- Windows runner: Inno Setup pre-installed on `windows-latest`
- No pubspec changes (fastforge is a global tool)

### Output Artifacts

- `DriveSync-macOS.dmg` (drag-to-Applications)
- `DriveSync-Windows-Setup.exe` (installer with Start Menu + desktop icon)
- `DriveSync-Linux-amd64.deb` (desktop entry + icon)

## Part 2: UI Consolidation - Eliminate Redundancy

### Problem

Sync status shown in 3 places simultaneously: SyncBanner (dashboard), ProfileCard progress section, RunningJobCard (Activity screen).

### Solution

**Dashboard SyncBanner (enhanced)** - single source of truth for active sync:
- Progress bar, speed/ETA/files stats, transferring file list, cancel button
- "+N queued" chip becomes expandable - tap reveals queue list with remove buttons

**ProfileCard (simplified)** - remove progress section entirely:
- When syncing: small "Syncing" or "Queued (#2)" status chip next to name
- No progress bar, no file list on the card

**Activity tab -> History tab:**
- Rename NavItem.activity to NavItem.history (icon: Icons.history, label: "History")
- Remove Active Syncs section (RunningJobCard) and Queued section
- Show only sync history list
- Delete running_job_card.dart

**Sidebar:** Profile status indicators stay as-is (lightweight).
