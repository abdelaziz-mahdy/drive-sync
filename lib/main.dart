import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'database/app_database.dart';
import 'database/migration.dart';
import 'providers/database_provider.dart';
import 'providers/rclone_provider.dart';
import 'providers/talker_provider.dart';
import 'services/rclone_daemon_manager.dart';
import 'services/rclone_service.dart';
import 'services/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Get app support directory.
  final appSupportDir = await getApplicationSupportDirectory();
  final dirPath = appSupportDir.path;

  // 2. Create the Drift database.
  final db = AppDatabase(dirPath);

  // 3. Run one-time migration from config.json if it exists.
  final migration = JsonToDriftMigration(appSupportDir: dirPath, db: db);
  await migration.migrateIfNeeded();

  // 4. Load or generate RC credentials for daemon auth.
  final secureStorage = SecureStorageService();
  var creds = await secureStorage.loadRcCredentials();
  if (creds == null) {
    final user = SecureStorageService.generateCredential();
    final pass = SecureStorageService.generateCredential();
    await secureStorage.saveRcCredentials(user, pass);
    creds = (user: user, pass: pass);
  }

  // 5. Create the daemon manager and rclone service.
  final daemonManager = RcloneDaemonManager(
    appSupportDir: dirPath,
    talker: talker,
  );
  final rcloneService = RcloneService(
    user: creds.user,
    pass: creds.pass,
    talker: talker,
  );

  // 6. Run the app with provider overrides.
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        rcloneServiceProvider.overrideWithValue(rcloneService),
        daemonManagerProvider.overrideWithValue(daemonManager),
      ],
      child: const DriveSyncApp(),
    ),
  );
}
