import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync_profile.dart';
import 'app_config_provider.dart';

/// Manages the list of sync profiles.
class ProfilesNotifier extends AsyncNotifier<List<SyncProfile>> {
  @override
  Future<List<SyncProfile>> build() async {
    final store = ref.read(configStoreProvider);
    return store.loadProfiles();
  }

  Future<void> addProfile(SyncProfile profile) async {
    final store = ref.read(configStoreProvider);
    await store.saveProfile(profile);
    final profiles = await store.loadProfiles();
    state = AsyncData(profiles);
  }

  Future<void> updateProfile(SyncProfile profile) async {
    final store = ref.read(configStoreProvider);
    await store.saveProfile(profile);
    final profiles = await store.loadProfiles();
    state = AsyncData(profiles);
  }

  Future<void> deleteProfile(String profileId) async {
    final store = ref.read(configStoreProvider);
    await store.deleteProfile(profileId);
    final profiles = await store.loadProfiles();
    state = AsyncData(profiles);
  }

  Future<void> updateProfileStatus(
    String profileId, {
    String? status,
    String? error,
    DateTime? lastSyncTime,
  }) async {
    final current = state.valueOrNull ?? [];
    final index = current.indexWhere((p) => p.id == profileId);
    if (index < 0) return;
    final updated = current[index].copyWith(
      lastSyncStatus: status,
      lastSyncError: error,
      lastSyncTime: lastSyncTime,
    );
    await updateProfile(updated);
  }
}

final profilesProvider =
    AsyncNotifierProvider<ProfilesNotifier, List<SyncProfile>>(
  ProfilesNotifier.new,
);
