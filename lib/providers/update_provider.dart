import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_release.dart';
import '../services/update_checker.dart';
import 'app_config_provider.dart';

final updateCheckerProvider = Provider<UpdateChecker>((ref) {
  return UpdateChecker();
});

/// Checks for app updates. Returns null if no update or update is skipped.
final updateAvailableProvider = FutureProvider<AppRelease?>((ref) async {
  final checker = ref.read(updateCheckerProvider);
  final config = ref.watch(appConfigProvider).value;

  // Current version - will be read from package_info_plus in main.dart
  // For now, use a placeholder that can be overridden
  const currentVersion = '0.1.0';

  final release = await checker.checkForUpdate(currentVersion);
  if (release == null) return null;

  // Check if user skipped this version
  if (config?.skippedVersion == release.version) return null;

  return release;
});
