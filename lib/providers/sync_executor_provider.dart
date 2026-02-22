import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/gitignore_service.dart';
import '../services/sync_executor.dart';
import 'rclone_provider.dart';

final gitignoreServiceProvider = Provider<GitignoreService>((ref) {
  return GitignoreService();
});

final syncExecutorProvider = Provider<SyncExecutor>((ref) {
  final rcloneService = ref.watch(rcloneServiceProvider);
  return SyncExecutor(
    rcloneService: rcloneService,
    gitignoreService: ref.watch(gitignoreServiceProvider),
  );
});
