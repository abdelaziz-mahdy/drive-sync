import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rclone_service.dart';
import '../services/rclone_daemon_manager.dart';

/// RcloneService singleton - must be overridden with actual credentials.
final rcloneServiceProvider = Provider<RcloneService>((ref) {
  throw UnimplementedError('rcloneServiceProvider must be overridden');
});

/// RcloneDaemonManager singleton - must be overridden with actual path.
final daemonManagerProvider = Provider<RcloneDaemonManager>((ref) {
  throw UnimplementedError('daemonManagerProvider must be overridden');
});

/// Stream of rclone daemon health status, polls every 10 seconds.
final daemonHealthProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(rcloneServiceProvider);
  while (true) {
    yield await service.healthCheck();
    await Future.delayed(const Duration(seconds: 10));
  }
});

/// Lists available remotes from rclone.
final remotesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(rcloneServiceProvider);
  return service.listRemotes();
});
