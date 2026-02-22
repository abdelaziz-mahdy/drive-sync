import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/launch_at_login_service.dart';

/// Provides the [LaunchAtLoginService] singleton.
final launchAtLoginServiceProvider = Provider<LaunchAtLoginService>((ref) {
  return LaunchAtLoginService();
});
