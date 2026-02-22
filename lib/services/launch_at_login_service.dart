import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service wrapping the `launch_at_startup` package to manage
/// whether the app starts automatically when the user logs in.
class LaunchAtLoginService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: _getAppPath(),
    );
    _initialized = true;
  }

  String _getAppPath() {
    // On macOS, the app path should be the .app bundle.
    // Platform.resolvedExecutable gives the binary path inside the bundle.
    // Go up from Contents/MacOS/<binary> to the .app bundle.
    final execPath = Platform.resolvedExecutable;
    final parts = execPath.split('/');
    final appIndex = parts.lastIndexWhere((p) => p.endsWith('.app'));
    if (appIndex >= 0) {
      return parts.sublist(0, appIndex + 1).join('/');
    }
    return execPath;
  }

  Future<void> setEnabled(bool enabled) async {
    await initialize();
    if (enabled) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }

  Future<bool> isEnabled() async {
    await initialize();
    return launchAtStartup.isEnabled();
  }
}
