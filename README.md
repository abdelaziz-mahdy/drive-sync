# DriveSync

A desktop application for selectively syncing files with Google Drive using [rclone](https://rclone.org/). Create profiles with custom file-type filters, schedule automatic syncs, and monitor progress in real time.

**Platforms:** macOS, Windows, Linux

## Features

- **4 Sync Modes** - Backup (local to cloud), Mirror (cloud to local), Download (cloud to local, non-destructive), and Bidirectional sync
- **File-Type Filtering** - Include or exclude specific file types per profile (e.g., sync only `.pdf` and `.docx`)
- **Multiple Local Paths** - Sync several folders to the same cloud destination
- **Scheduled Syncs** - Automatic syncing at 5-minute, 15-minute, 30-minute, or hourly intervals
- **Dry Run Preview** - See exactly what will change before committing to a sync
- **Real-Time Progress** - Live transfer speed, ETA, and per-file progress
- **Sync History** - Full history of past syncs with transferred file details
- **Sync Queue** - Queue multiple profiles and sync them sequentially, or sync all at once
- **Git-Aware** - Respects `.gitignore` files and excludes `.git` directories automatically
- **Custom Excludes** - Add your own exclude patterns per profile
- **Bandwidth Limiting** - Throttle transfer speeds when needed
- **System Integration** - Menu bar icon, launch at login, system tray support
- **Theme Support** - Light, Dark, and System theme modes

## Prerequisites

### 1. Install rclone

DriveSync uses rclone under the hood. Install it for your platform:

**macOS:**
```bash
brew install rclone
```

**Windows:**
```bash
winget install Rclone.Rclone
```

**Linux:**
```bash
curl https://rclone.org/install.sh | sudo bash
```

Or download from [rclone.org/downloads](https://rclone.org/downloads/).

### 2. Configure a Google Drive remote

Set up a Google Drive remote in rclone:

```bash
rclone config
```

Follow the interactive prompts:
1. Choose `n` for new remote
2. Name it (e.g., `gdrive`)
3. Choose `Google Drive` as the storage type
4. Follow the OAuth flow to authorize access
5. Confirm and quit

You can verify it works:
```bash
rclone lsd gdrive:
```

## Installation

### From GitHub Releases

Download the latest release for your platform from the [Releases](https://github.com/abdelaziz-mahdy/drive-sync/releases) page.

### Build from Source

Requires [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.11.0+).

```bash
# Clone the repository
git clone https://github.com/abdelaziz-mahdy/drive-sync.git
cd drive-sync

# Install dependencies
flutter pub get

# Generate code (database, JSON serialization, providers)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run -d macos    # or -d windows, -d linux
```

To build a release binary:

```bash
flutter build macos     # or windows, linux
```

## Usage

### First Launch

On first launch, DriveSync checks that rclone is installed and that you have at least one remote configured. If not, it guides you through the setup.

### Creating a Sync Profile

1. Click the **+** button on the Dashboard
2. Give your profile a name
3. Choose a **sync mode** (Backup, Mirror, Download, or Bidirectional)
4. Select one or more **local folders** to sync
5. Browse and select the **cloud folder** destination
6. Optionally configure file-type filters, excludes, and scheduling
7. Save the profile

### Running a Sync

- Click the **sync button** on any profile card to start syncing
- Use **Sync All** to queue every profile at once
- Use **Dry Run** (preview icon) to see what would change without making changes

### Monitoring

- The **Dashboard** shows a progress banner during active syncs
- The **Activity** screen shows running jobs, the queue, and sync history
- Click any history entry to see the full list of transferred files

## Architecture

```
lib/
├── main.dart              # Entry point
├── app.dart               # Root MaterialApp widget
├── database/              # Drift SQLite schema, DAOs, migrations
├── models/                # Data models (SyncProfile, SyncJob, etc.)
├── providers/             # Riverpod state management
├── services/              # Business logic (rclone, sync, tray, etc.)
├── screens/               # UI screens
│   ├── dashboard/         # Profile cards, sync banner
│   ├── activity/          # Running jobs, history, queue
│   ├── settings/          # App preferences
│   ├── profile_editor/    # Create/edit sync profiles
│   ├── onboarding/        # First-launch setup
│   └── dry_run/           # Sync preview results
├── widgets/               # Reusable UI components
├── theme/                 # Material 3 theming
└── utils/                 # Utilities
```

**Key technologies:**
- **Flutter** - Cross-platform desktop UI
- **Riverpod** - Reactive state management
- **Drift** - Type-safe SQLite database
- **rclone** - File synchronization engine (runs as a local daemon)

## Development

```bash
# Run tests
flutter test

# Run code generation (after modifying models/database/providers)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Analyze code
flutter analyze
```

## License

MIT License. See [LICENSE](LICENSE) for details.
