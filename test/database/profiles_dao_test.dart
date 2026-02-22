import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/database/daos/profiles_dao.dart';
import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_profile.dart';

import 'test_database.dart';

void main() {
  group('ProfilesDao', () {
    late ProfilesDao dao;

    setUp(() {
      final db = createTestDatabase();
      dao = ProfilesDao(db);
    });

    SyncProfile makeProfile({String id = 'p1', String name = 'Test'}) {
      return SyncProfile(
        id: id,
        name: name,
        remoteName: 'gdrive',
        cloudFolder: '/backup',
        localPaths: ['/home/user/docs', '/home/user/photos'],
        includeTypes: ['.jpg', '.png'],
        excludeTypes: ['.tmp'],
        useIncludeMode: true,
        syncMode: SyncMode.backup,
        scheduleMinutes: 30,
        enabled: true,
        respectGitignore: true,
        excludeGitDirs: true,
        customExcludes: ['*.log', 'node_modules/**'],
        bandwidthLimit: '10M',
        maxTransfers: 8,
        checkFirst: false,
        preserveSourceDir: true,
      );
    }

    test('loadAll returns empty list initially', () async {
      final profiles = await dao.loadAll();
      expect(profiles, isEmpty);
    });

    test('saveProfile and loadAll round-trips correctly', () async {
      final profile = makeProfile();
      await dao.saveProfile(profile);

      final profiles = await dao.loadAll();
      expect(profiles, hasLength(1));

      final loaded = profiles.first;
      expect(loaded.id, 'p1');
      expect(loaded.name, 'Test');
      expect(loaded.remoteName, 'gdrive');
      expect(loaded.cloudFolder, '/backup');
      expect(loaded.localPaths, ['/home/user/docs', '/home/user/photos']);
      expect(loaded.includeTypes, ['.jpg', '.png']);
      expect(loaded.excludeTypes, ['.tmp']);
      expect(loaded.useIncludeMode, true);
      expect(loaded.syncMode, SyncMode.backup);
      expect(loaded.scheduleMinutes, 30);
      expect(loaded.enabled, true);
      expect(loaded.respectGitignore, true);
      expect(loaded.excludeGitDirs, true);
      expect(loaded.customExcludes, ['*.log', 'node_modules/**']);
      expect(loaded.bandwidthLimit, '10M');
      expect(loaded.maxTransfers, 8);
      expect(loaded.checkFirst, false);
      expect(loaded.preserveSourceDir, true);
    });

    test('findById returns profile when exists', () async {
      await dao.saveProfile(makeProfile(id: 'find-me'));

      final found = await dao.findById('find-me');
      expect(found, isNotNull);
      expect(found!.id, 'find-me');
    });

    test('findById returns null when not exists', () async {
      final found = await dao.findById('nope');
      expect(found, isNull);
    });

    test('saveProfile updates existing profile', () async {
      await dao.saveProfile(makeProfile(name: 'Original'));
      await dao.saveProfile(makeProfile(name: 'Updated'));

      final profiles = await dao.loadAll();
      expect(profiles, hasLength(1));
      expect(profiles.first.name, 'Updated');
    });

    test('deleteProfile removes profile and children', () async {
      await dao.saveProfile(makeProfile());

      await dao.deleteProfile('p1');

      final profiles = await dao.loadAll();
      expect(profiles, isEmpty);
    });

    test('updateStatus updates status fields', () async {
      await dao.saveProfile(makeProfile());
      final now = DateTime.now();

      await dao.updateStatus(
        'p1',
        status: 'success',
        lastSyncTime: now,
      );

      final profile = await dao.findById('p1');
      expect(profile!.lastSyncStatus, 'success');
      expect(profile.lastSyncTime, isNotNull);
    });

    test('multiple profiles are independent', () async {
      await dao.saveProfile(makeProfile(id: 'a', name: 'Profile A'));
      await dao.saveProfile(makeProfile(id: 'b', name: 'Profile B'));

      final profiles = await dao.loadAll();
      expect(profiles, hasLength(2));

      await dao.deleteProfile('a');

      final remaining = await dao.loadAll();
      expect(remaining, hasLength(1));
      expect(remaining.first.id, 'b');
    });
  });
}
