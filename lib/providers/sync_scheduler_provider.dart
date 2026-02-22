import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_scheduler.dart';
import 'profiles_provider.dart';
import 'sync_queue_provider.dart';

/// Provides a [SyncScheduler] that routes scheduled syncs through the queue.
///
/// The scheduler auto-reschedules when profiles change and disposes with
/// the provider scope.
final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final scheduler = SyncScheduler(
    onSyncDue: (profile) {
      ref.read(syncQueueProvider.notifier).enqueue(profile.id);
    },
  );

  // Reschedule when profiles change.
  ref.listen(profilesProvider, (_, next) {
    final profiles = next.value;
    if (profiles != null) scheduler.rescheduleAll(profiles);
  });

  ref.onDispose(scheduler.dispose);

  return scheduler;
});
