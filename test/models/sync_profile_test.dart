import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_profile.dart';

void main() {
  SyncProfile createProfile({SyncMode syncMode = SyncMode.backup}) {
    return SyncProfile(
      id: 'test-id',
      name: 'Test Profile',
      remoteName: 'gdrive',
      cloudFolder: 'Documents',
      localPaths: ['/home/user/docs'],
      includeTypes: ['*.dart', '*.md'],
      excludeTypes: [],
      useIncludeMode: true,
      syncMode: syncMode,
      scheduleMinutes: 30,
      enabled: true,
      respectGitignore: true,
      excludeGitDirs: true,
      customExcludes: ['node_modules', '.DS_Store'],
      bandwidthLimit: '10M',
      maxTransfers: 4,
      checkFirst: true,
    );
  }

  group('SyncProfile', () {
    test('remoteFs returns remoteName:cloudFolder', () {
      final p = createProfile();
      expect(p.remoteFs, 'gdrive:Documents');
    });

    group('sourceFs and destinationFs', () {
      test('backup: local → remote (preserveSourceDir appends basename)', () {
        final p = createProfile(syncMode: SyncMode.backup);
        expect(p.sourceFs, '/home/user/docs');
        expect(p.destinationFs, 'gdrive:Documents/docs');
      });

      test('mirror: remote → local (preserveSourceDir appends basename)', () {
        final p = createProfile(syncMode: SyncMode.mirror);
        expect(p.sourceFs, 'gdrive:Documents/docs');
        expect(p.destinationFs, '/home/user/docs');
      });

      test('download: remote → local (preserveSourceDir appends basename)',
          () {
        final p = createProfile(syncMode: SyncMode.download);
        expect(p.sourceFs, 'gdrive:Documents/docs');
        expect(p.destinationFs, '/home/user/docs');
      });

      test('bisync: remote → local (no preserveSourceDir effect)', () {
        final p = createProfile(syncMode: SyncMode.bisync);
        expect(p.sourceFs, 'gdrive:Documents');
        expect(p.destinationFs, '/home/user/docs');
      });
    });

    group('preserveSourceDir', () {
      test('backup: appends basename of local path to cloud folder', () {
        final p = SyncProfile(
          id: 'id',
          name: 'n',
          remoteName: 'remote',
          cloudFolder: '/',
          localPaths: ['/Users/me/test-drive'],
          includeTypes: [],
          excludeTypes: [],
          useIncludeMode: true,
          syncMode: SyncMode.backup,
          scheduleMinutes: 0,
          enabled: true,
          respectGitignore: false,
          excludeGitDirs: false,
          customExcludes: [],
          preserveSourceDir: true,
        );
        expect(
            p.destinationFsFor('/Users/me/test-drive'), 'remote:/test-drive');
      });

      test('backup: appends basename to non-root cloud folder', () {
        final p = SyncProfile(
          id: 'id',
          name: 'n',
          remoteName: 'remote',
          cloudFolder: '/backups',
          localPaths: ['/Users/me/test-drive'],
          includeTypes: [],
          excludeTypes: [],
          useIncludeMode: true,
          syncMode: SyncMode.backup,
          scheduleMinutes: 0,
          enabled: true,
          respectGitignore: false,
          excludeGitDirs: false,
          customExcludes: [],
          preserveSourceDir: true,
        );
        expect(p.destinationFsFor('/Users/me/test-drive'),
            'remote:/backups/test-drive');
      });

      test('backup: preserveSourceDir false uses remoteFs directly', () {
        final p = SyncProfile(
          id: 'id',
          name: 'n',
          remoteName: 'remote',
          cloudFolder: '/',
          localPaths: ['/Users/me/test-drive'],
          includeTypes: [],
          excludeTypes: [],
          useIncludeMode: true,
          syncMode: SyncMode.backup,
          scheduleMinutes: 0,
          enabled: true,
          respectGitignore: false,
          excludeGitDirs: false,
          customExcludes: [],
          preserveSourceDir: false,
        );
        expect(p.destinationFsFor('/Users/me/test-drive'), 'remote:/');
      });

      test('download: appends basename to source remote path', () {
        final p = SyncProfile(
          id: 'id',
          name: 'n',
          remoteName: 'remote',
          cloudFolder: '/backups',
          localPaths: ['/Users/me/test-drive'],
          includeTypes: [],
          excludeTypes: [],
          useIncludeMode: true,
          syncMode: SyncMode.download,
          scheduleMinutes: 0,
          enabled: true,
          respectGitignore: false,
          excludeGitDirs: false,
          customExcludes: [],
          preserveSourceDir: true,
        );
        expect(p.sourceFsFor('/Users/me/test-drive'),
            'remote:/backups/test-drive');
      });

      test('defaults to true', () {
        final p = createProfile();
        expect(p.preserveSourceDir, true);
      });

      test('JSON round-trip preserves preserveSourceDir', () {
        final p = createProfile();
        final json = p.toJson();
        expect(json['preserveSourceDir'], true);
        final p2 = SyncProfile.fromJson(json);
        expect(p2.preserveSourceDir, true);
      });

      test('JSON defaults to true when field missing', () {
        final json = {
          'id': 'id',
          'name': 'n',
          'remoteName': 'r',
          'cloudFolder': 'c',
          'localPaths': ['/l'],
          'includeTypes': <String>[],
          'excludeTypes': <String>[],
          'useIncludeMode': true,
          'syncMode': 'backup',
          'scheduleMinutes': 0,
          'enabled': true,
          'respectGitignore': false,
          'excludeGitDirs': false,
          'customExcludes': <String>[],
        };
        final p = SyncProfile.fromJson(json);
        expect(p.preserveSourceDir, true);
      });
    });

    group('toRcApiData', () {
      test('backup uses srcFs/dstFs', () {
        final p = createProfile(syncMode: SyncMode.backup);
        final data = p.toRcApiData();
        expect(data['srcFs'], '/home/user/docs');
        expect(data['dstFs'], 'gdrive:Documents/docs');
        expect(data['_async'], true);
        expect(data.containsKey('_filter'), true);
        expect(data.containsKey('_config'), true);
      });

      test('bisync uses path1/path2', () {
        final p = createProfile(syncMode: SyncMode.bisync);
        final data = p.toRcApiData();
        expect(data['path1'], p.sourceFs);
        expect(data['path2'], p.destinationFs);
        expect(data.containsKey('srcFs'), false);
        expect(data.containsKey('dstFs'), false);
      });

      test('dryRun passes through to config', () {
        final p = createProfile();
        final data = p.toRcApiData(dryRun: true);
        expect(data['_config']['DryRun'], true);
      });
    });

    group('buildFilterPayload', () {
      test('includes IncludeRule for includeTypes when useIncludeMode', () {
        final p = createProfile();
        final filter = p.buildFilterPayload();
        expect(filter['IncludeRule'], isNotEmpty);
      });

      test('includes ExcludeRule for excludeTypes when not useIncludeMode', () {
        final p = SyncProfile(
          id: 'id',
          name: 'n',
          remoteName: 'r',
          cloudFolder: 'c',
          localPaths: ['/l'],
          includeTypes: [],
          excludeTypes: ['*.log'],
          useIncludeMode: false,
          syncMode: SyncMode.backup,
          scheduleMinutes: 0,
          enabled: true,
          respectGitignore: false,
          excludeGitDirs: false,
          customExcludes: [],
        );
        final filter = p.buildFilterPayload();
        expect(filter['ExcludeRule'], isNotEmpty);
      });

      test('includes FilterRule for customExcludes', () {
        final p = createProfile();
        final filter = p.buildFilterPayload();
        expect(filter['FilterRule'], isNotEmpty);
      });

      test('includes gitignore rules when provided', () {
        final p = createProfile();
        final filter =
            p.buildFilterPayload(gitignoreRules: ['*.pyc', '__pycache__/']);
        expect(filter['FilterRule'], isNotEmpty);
      });

      test('includes .git exclusion when excludeGitDirs is true', () {
        final p = createProfile();
        final filter = p.buildFilterPayload();
        final filterRule = filter['FilterRule'] as List<String>;
        expect(filterRule.any((r) => r.contains('.git')), true);
      });
    });

    group('buildConfigPayload', () {
      test('contains correct fields', () {
        final p = createProfile();
        final config = p.buildConfigPayload();
        expect(config['DryRun'], false);
        expect(config['CheckFirst'], true);
        expect(config['Transfers'], 4);
        expect(config['BwLimit'], '10M');
      });

      test('dryRun override', () {
        final p = createProfile();
        final config = p.buildConfigPayload(dryRun: true);
        expect(config['DryRun'], true);
      });

      test('no BwLimit when null', () {
        final p = SyncProfile(
          id: 'id',
          name: 'n',
          remoteName: 'r',
          cloudFolder: 'c',
          localPaths: ['/l'],
          includeTypes: [],
          excludeTypes: [],
          useIncludeMode: true,
          syncMode: SyncMode.backup,
          scheduleMinutes: 0,
          enabled: true,
          respectGitignore: false,
          excludeGitDirs: false,
          customExcludes: [],
        );
        final config = p.buildConfigPayload();
        expect(config.containsKey('BwLimit'), false);
      });
    });

    group('copyWith', () {
      test('returns new instance with changed fields', () {
        final p = createProfile();
        final p2 = p.copyWith(name: 'New Name', enabled: false);
        expect(p2.name, 'New Name');
        expect(p2.enabled, false);
        expect(p2.id, p.id);
        expect(p2.syncMode, p.syncMode);
      });

      test('returns identical values when no args', () {
        final p = createProfile();
        final p2 = p.copyWith();
        expect(p2.id, p.id);
        expect(p2.name, p.name);
        expect(p2.syncMode, p.syncMode);
      });
    });

    group('JSON serialization', () {
      test('round-trip fromJson/toJson', () {
        final p = createProfile();
        final json = p.toJson();
        final p2 = SyncProfile.fromJson(json);
        expect(p2.id, p.id);
        expect(p2.name, p.name);
        expect(p2.remoteName, p.remoteName);
        expect(p2.cloudFolder, p.cloudFolder);
        expect(p2.localPath, p.localPath);
        expect(p2.syncMode, p.syncMode);
        expect(p2.includeTypes, p.includeTypes);
        expect(p2.customExcludes, p.customExcludes);
        expect(p2.bandwidthLimit, p.bandwidthLimit);
        expect(p2.maxTransfers, p.maxTransfers);
        expect(p2.checkFirst, p.checkFirst);
      });

      test('handles nullable fields', () {
        final p = createProfile();
        final json = p.toJson();
        expect(json['lastSyncTime'], isNull);
        expect(json['lastSyncStatus'], isNull);
        expect(json['lastSyncError'], isNull);
      });

      test('serializes DateTime correctly', () {
        final now = DateTime.now();
        final p = createProfile().copyWith(lastSyncTime: now);
        final json = p.toJson();
        final p2 = SyncProfile.fromJson(json);
        expect(p2.lastSyncTime?.millisecondsSinceEpoch,
            now.millisecondsSinceEpoch);
      });

      test('migrates legacy localPath string to localPaths list', () {
        final json = {
          'id': 'legacy-id',
          'name': 'Legacy',
          'remoteName': 'gdrive',
          'cloudFolder': 'docs',
          'localPaths': '/old/path',
          'includeTypes': <String>[],
          'excludeTypes': <String>[],
          'useIncludeMode': false,
          'syncMode': 'backup',
          'scheduleMinutes': 0,
          'enabled': true,
          'respectGitignore': false,
          'excludeGitDirs': false,
          'customExcludes': <String>[],
        };
        final p = SyncProfile.fromJson(json);
        expect(p.localPaths, ['/old/path']);
        expect(p.localPath, '/old/path');
      });

      test('serializes localPaths as list', () {
        final p = createProfile();
        final json = p.toJson();
        expect(json['localPaths'], isA<List>());
        expect(json['localPaths'], ['/home/user/docs']);
      });
    });
  });
}
