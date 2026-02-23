# Profile Editor Redesign: NavigationRail + Live Preview

## Problem

The current profile editor is a long scrollable form with 7 sections and no feedback. Users configure include/exclude filters, gitignore settings, and custom patterns blind - they can't see which files will actually sync until they run a real sync. The dry-run infrastructure exists but isn't integrated into the creation flow.

## Design

### Layout: Three-Zone Responsive

**Wide screens (>900px):**
- Left: `NavigationRail` with 6 section destinations
- Center: Config form for the selected section
- Right: Live file tree preview panel (~35% width)

**Narrow screens (<900px):**
- Bottom `TabBar` with section tabs + a Preview tab
- Full-width content area showing selected tab's content
- Preview becomes its own tab

Breakpoint: 900px. Bottom action bar (Delete/Cancel/Save) persists across all views. `Cmd+S`/`Ctrl+S` shortcut preserved.

### Navigation Sections

| Section | Icon | Content |
|---------|------|---------|
| Basic | `person_outline` | Profile name, Enabled toggle |
| Mode | `sync` | SyncModeSelector radio cards |
| Paths | `folder` | Remote dropdown, Cloud folder + browser, Local paths, Preserve source dir |
| Filters | `filter_list` | Include/Exclude toggle, File type chips, presets |
| Excludes | `block` | Gitignore, .git dirs, Quick excludes, Custom patterns |
| Advanced | `tune` | Bandwidth, Max transfers, Check first, Schedule |

Each section validates independently (red indicator on nav icon if invalid). Non-linear navigation - user can jump between sections freely.

### Live Preview Mechanics

**Trigger:** Preview activates once Remote + Cloud Folder + Local Path are all set.

**Data flow:**
1. Fetch full source file listing via `RcloneService.listFiles(remote, cloudFolder)`
2. Build temporary `SyncProfile` from current form state
3. Run `SyncExecutor.executeSync(profile, dryRun: true)` to get which files would transfer
4. Cross-reference: files in dry-run result = included (green), files not in result = excluded (dimmed)

**Re-run:** When filters change (include/exclude types, gitignore, custom excludes), debounce 1s then re-run dry-run only. No need to re-fetch the full file list.

**Preview panel UI:**
- Summary bar: "42 files (128 MB) will sync | 15 excluded" + refresh button
- File tree with directory grouping, each entry shows icon, name, size, include/exclude indicator
- Excluded files toggleable via "Show excluded" switch
- Loading shimmer during dry-run execution

**Edge cases:**
- Missing required paths: placeholder message ("Select a remote to preview")
- Dry-run failure: error message + retry button
- Empty source: "No files found at this location"
- Large directories (1000+): show first 200 + "and N more..."

### Onboarding

Keep `FirstProfileStep` simple (Name + Remote + Local Path). Link to full editor for advanced config.

## Files to Create/Modify

- `lib/screens/profile_editor/profile_editor_screen.dart` - Major rewrite with NavigationRail layout
- `lib/screens/profile_editor/file_preview_panel.dart` - New: live file tree preview widget
- `lib/screens/profile_editor/file_tree_view.dart` - New: file tree with include/exclude indicators
- `lib/screens/profile_editor/editor_section.dart` - New: enum + section content builder
- Existing section widgets (file_type_chips, git_excludes_section, advanced_options, sync_mode_selector) remain mostly unchanged - just extracted into section views
