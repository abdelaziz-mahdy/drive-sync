import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/daos/profiles_dao.dart';
import '../models/sync_profile.dart';
import 'database_provider.dart';

/// Manages the list of sync profiles.
class ProfilesNotifier extends AsyncNotifier<List<SyncProfile>> {
  @override
  Future<List<SyncProfile>> build() async {
    final dao = ProfilesDao(ref.read(appDatabaseProvider));
    return dao.loadAll();
  }

  Future<void> addProfile(SyncProfile profile) async {
    final dao = ProfilesDao(ref.read(appDatabaseProvider));
    await dao.saveProfile(profile);
    final profiles = await dao.loadAll();
    state = AsyncData(profiles);
  }

  Future<void> updateProfile(SyncProfile profile) async {
    final dao = ProfilesDao(ref.read(appDatabaseProvider));
    await dao.saveProfile(profile);
    final profiles = await dao.loadAll();
    state = AsyncData(profiles);
  }

  Future<void> deleteProfile(String profileId) async {
    final dao = ProfilesDao(ref.read(appDatabaseProvider));
    await dao.deleteProfile(profileId);
    final profiles = await dao.loadAll();
    state = AsyncData(profiles);
  }

  Future<void> updateProfileStatus(
    String profileId, {
    String? status,
    String? error,
    DateTime? lastSyncTime,
  }) async {
    final current = state.value ?? [];
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
