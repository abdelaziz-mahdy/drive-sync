import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'providers/app_config_provider.dart';
import 'providers/rclone_provider.dart';
import 'providers/talker_provider.dart';
import 'services/config_store.dart';
import 'services/rclone_daemon_manager.dart';
import 'services/rclone_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Get app support directory.
  final appSupportDir = await getApplicationSupportDirectory();
  final dirPath = appSupportDir.path;

  // 2. Create ConfigStore with the directory path.
  final configStore = ConfigStore(appSupportDir: dirPath);

  // 3. Load or generate RC credentials for daemon auth.
  var creds = await configStore.loadRcCredentials();
  if (creds == null) {
    final user = ConfigStore.generateCredential();
    final pass = ConfigStore.generateCredential();
    await configStore.saveRcCredentials(user, pass);
    creds = (user: user, pass: pass);
  }

  // 4. Create the daemon manager and rclone service.
  final daemonManager = RcloneDaemonManager(
    appSupportDir: dirPath,
    talker: talker,
  );
  final rcloneService = RcloneService(
    user: creds.user,
    pass: creds.pass,
    talker: talker,
  );

  // 5. Run the app with provider overrides so the previously-throwing
  //    providers are now backed by real instances.
  runApp(
    ProviderScope(
      overrides: [
        configStoreProvider.overrideWithValue(configStore),
        rcloneServiceProvider.overrideWithValue(rcloneService),
        daemonManagerProvider.overrideWithValue(daemonManager),
      ],
      child: const DriveSyncApp(),
    ),
  );
}
