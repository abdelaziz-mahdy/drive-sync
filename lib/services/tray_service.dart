import 'package:system_tray/system_tray.dart';

import '../models/sync_profile.dart';

/// Manages the system tray icon and context menu for the DriveSync app.
///
/// Displays profiles with their sync status and provides quick actions
/// for syncing, opening the main window, and quitting the app.
class TrayService {
  final SystemTray _systemTray = SystemTray();

  /// Called when the user clicks "Sync Now" for a specific profile.
  void Function(SyncProfile profile)? onSyncProfile;

  /// Called when the user clicks "Sync All Now".
  void Function()? onSyncAll;

  /// Called when the user clicks "Open DriveSync" to bring the window to front.
  void Function()? onOpen;

  /// Called when the user clicks "Quit".
  void Function()? onQuit;

  /// Initializes the system tray icon and sets up the default menu.
  Future<void> init() async {
    await _systemTray.initSystemTray(
      title: 'DriveSync',
      iconPath: '',
    );

    // Set up the initial menu with no profiles.
    await _buildMenu([]);

    // Register handler for left-click on tray icon to open the app.
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        onOpen?.call();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

  /// Updates the tray context menu with the current list of profiles.
  Future<void> updateProfiles(List<SyncProfile> profiles) async {
    await _buildMenu(profiles);
  }

  /// Builds and sets the context menu from the given profiles.
  Future<void> _buildMenu(List<SyncProfile> profiles) async {
    final menuItems = <MenuItemBase>[];

    // App title (disabled label).
    menuItems.add(MenuItemLabel(label: 'DriveSync', enabled: false));
    menuItems.add(MenuSeparator());

    // Profile items with status and sync action.
    if (profiles.isNotEmpty) {
      for (final profile in profiles) {
        final status = _profileStatusLabel(profile);
        menuItems.add(
          MenuItemLabel(
            label: '${profile.name} - $status',
            onClicked: (_) => onSyncProfile?.call(profile),
          ),
        );
      }

      menuItems.add(MenuSeparator());

      // Sync All action.
      menuItems.add(
        MenuItemLabel(
          label: 'Sync All Now',
          onClicked: (_) => onSyncAll?.call(),
        ),
      );

      menuItems.add(MenuSeparator());
    }

    // Open action.
    menuItems.add(
      MenuItemLabel(
        label: 'Open DriveSync',
        onClicked: (_) => onOpen?.call(),
      ),
    );

    // Quit action.
    menuItems.add(
      MenuItemLabel(
        label: 'Quit',
        onClicked: (_) => onQuit?.call(),
      ),
    );

    final menu = Menu();
    await menu.buildFrom(menuItems);
    await _systemTray.setContextMenu(menu);
  }

  /// Returns a human-readable status label for a profile.
  String _profileStatusLabel(SyncProfile profile) {
    if (!profile.enabled) return 'Disabled';
    final status = profile.lastSyncStatus;
    if (status == null) return 'Idle';
    switch (status) {
      case 'syncing':
        return 'Syncing...';
      case 'success':
        return 'Synced';
      case 'error':
        return 'Error';
      default:
        return 'Idle';
    }
  }

  /// Cleans up the system tray icon and menu.
  Future<void> dispose() async {
    await _systemTray.destroy();
  }
}
