import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_history_entry.dart';
import 'app_config_provider.dart';

class SyncHistoryNotifier extends AsyncNotifier<List<SyncHistoryEntry>> {
  @override
  Future<List<SyncHistoryEntry>> build() async {
    final store = ref.read(configStoreProvider);
    return store.loadHistory();
  }

  Future<void> addEntry(SyncHistoryEntry entry) async {
    final store = ref.read(configStoreProvider);
    await store.addHistoryEntry(entry);
    state = AsyncData(await store.loadHistory());
  }
}

final syncHistoryProvider =
    AsyncNotifierProvider<SyncHistoryNotifier, List<SyncHistoryEntry>>(
  SyncHistoryNotifier.new,
);
