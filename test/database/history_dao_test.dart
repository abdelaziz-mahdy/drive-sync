import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/database/daos/history_dao.dart';
import 'package:drive_sync/database/daos/profiles_dao.dart';
import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_profile.dart';

import 'test_database.dart';

void main() {
  group('HistoryDao', () {
    late HistoryDao historyDao;
    late ProfilesDao profilesDao;

    setUp(() async {
      final db = createTestDatabase();
      historyDao = HistoryDao(db);
      profilesDao = ProfilesDao(db);

      // Insert a profile for FK constraint.
      await profilesDao.saveProfile(const SyncProfile(
        id: 'profile-1',
        name: 'Test Profile',
        remoteName: 'gdrive',
        cloudFolder: '/test',
        localPaths: ['/tmp/test'],
        includeTypes: [],
        excludeTypes: [],
        useIncludeMode: false,
        syncMode: SyncMode.backup,
        scheduleMinutes: 30,
        enabled: true,
        respectGitignore: false,
        excludeGitDirs: false,
        customExcludes: [],
      ));
    });

    test('loadAll returns empty list initially', () async {
      final entries = await historyDao.loadAll();
      expect(entries, isEmpty);
    });

    test('addEntry and loadAll round-trips', () async {
      final now = DateTime.now();
      await historyDao.addEntry(
        profileId: 'profile-1',
        timestamp: now,
        status: 'success',
        filesTransferred: 5,
        bytesTransferred: 1024,
        durationMs: 3000,
      );

      final entries = await historyDao.loadAll();
      expect(entries, hasLength(1));
      expect(entries.first.profileId, 'profile-1');
      expect(entries.first.status, 'success');
      expect(entries.first.filesTransferred, 5);
      expect(entries.first.bytesTransferred, 1024);
      expect(entries.first.durationMs, 3000);
    });

    test('addEntry with files and getWithFiles', () async {
      final now = DateTime.now();
      final historyId = await historyDao.addEntry(
        profileId: 'profile-1',
        timestamp: now,
        status: 'success',
        filesTransferred: 2,
        bytesTransferred: 2048,
        durationMs: 5000,
        files: [
          const TransferredFileRecord(
            fileName: 'document.pdf',
            fileSize: 1024,
            completedAt: '2026-01-01T00:00:00Z',
          ),
          const TransferredFileRecord(
            fileName: 'photo.jpg',
            fileSize: 1024,
          ),
        ],
      );

      final result = await historyDao.getWithFiles(historyId);
      expect(result, isNotNull);
      expect(result!.files, hasLength(2));
      // Sorted by file name.
      expect(result.files[0].fileName, 'document.pdf');
      expect(result.files[0].fileSize, 1024);
      expect(result.files[0].completedAt, '2026-01-01T00:00:00Z');
      expect(result.files[1].fileName, 'photo.jpg');
    });

    test('getWithFiles returns null for non-existent ID', () async {
      final result = await historyDao.getWithFiles(999);
      expect(result, isNull);
    });

    test('addEntry with error stores error message', () async {
      await historyDao.addEntry(
        profileId: 'profile-1',
        timestamp: DateTime.now(),
        status: 'error',
        filesTransferred: 0,
        bytesTransferred: 0,
        durationMs: 100,
        error: 'Connection timeout',
      );

      final entries = await historyDao.loadAll();
      expect(entries.first.error, 'Connection timeout');
    });

    test('entries ordered by timestamp descending', () async {
      final now = DateTime.now();
      await historyDao.addEntry(
        profileId: 'profile-1',
        timestamp: now.subtract(const Duration(hours: 2)),
        status: 'success',
        filesTransferred: 1,
        bytesTransferred: 100,
        durationMs: 1000,
      );
      await historyDao.addEntry(
        profileId: 'profile-1',
        timestamp: now,
        status: 'success',
        filesTransferred: 2,
        bytesTransferred: 200,
        durationMs: 2000,
      );

      final entries = await historyDao.loadAll();
      expect(entries, hasLength(2));
      expect(entries.first.filesTransferred, 2); // Most recent first.
    });
  });
}
