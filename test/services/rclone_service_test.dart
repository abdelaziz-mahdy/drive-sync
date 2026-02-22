import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/services/rclone_service.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late RcloneService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:5572'));
    dioAdapter = DioAdapter(dio: dio);
    service = RcloneService.withDio(dio);
  });

  SyncProfile testProfile() => const SyncProfile(
        id: 'test-id',
        name: 'Test Profile',
        remoteName: 'gdrive',
        cloudFolder: 'Documents',
        localPath: '/home/user/docs',
        includeTypes: [],
        excludeTypes: [],
        useIncludeMode: false,
        syncMode: SyncMode.backup,
        scheduleMinutes: 30,
        enabled: true,
        respectGitignore: false,
        excludeGitDirs: false,
        customExcludes: [],
      );

  group('RcloneService', () {
    group('healthCheck', () {
      test('returns true when daemon is reachable', () async {
        dioAdapter.onPost('/rc/noop', (server) {
          server.reply(200, {});
        }, data: {});

        expect(await service.healthCheck(), true);
      });

      test('returns false when daemon is unreachable', () async {
        dioAdapter.onPost('/rc/noop', (server) {
          server.throws(
            500,
            DioException(
              requestOptions: RequestOptions(path: '/rc/noop'),
            ),
          );
        }, data: {});

        expect(await service.healthCheck(), false);
      });
    });

    group('getVersion', () {
      test('returns version info', () async {
        final versionData = {
          'version': 'rclone v1.64.0',
          'decomposed': [1, 64, 0],
          'isGit': false,
          'os': 'darwin',
          'arch': 'arm64',
        };

        dioAdapter.onPost('/core/version', (server) {
          server.reply(200, versionData);
        }, data: {});

        final result = await service.getVersion();
        expect(result['version'], 'rclone v1.64.0');
        expect(result['os'], 'darwin');
      });
    });

    group('quit', () {
      test('sends quit command', () async {
        dioAdapter.onPost('/core/quit', (server) {
          server.reply(200, {});
        }, data: {});

        // Should not throw.
        await service.quit();
      });
    });

    group('listRemotes', () {
      test('returns list of remote names', () async {
        dioAdapter.onPost('/config/listremotes', (server) {
          server.reply(200, {
            'remotes': ['gdrive', 'onedrive'],
          });
        }, data: {});

        final remotes = await service.listRemotes();
        expect(remotes, ['gdrive', 'onedrive']);
      });

      test('returns empty list when no remotes configured', () async {
        dioAdapter.onPost('/config/listremotes', (server) {
          server.reply(200, {'remotes': []});
        }, data: {});

        final remotes = await service.listRemotes();
        expect(remotes, isEmpty);
      });
    });

    group('getRemoteConfig', () {
      test('returns config for named remote', () async {
        dioAdapter.onPost(
          '/config/get',
          (server) {
            server.reply(200, {
              'type': 'drive',
              'scope': 'drive',
            });
          },
          data: {'name': 'gdrive'},
        );

        final config = await service.getRemoteConfig('gdrive');
        expect(config['type'], 'drive');
      });
    });

    group('deleteRemote', () {
      test('sends delete command', () async {
        dioAdapter.onPost(
          '/config/delete',
          (server) {
            server.reply(200, {});
          },
          data: {'name': 'gdrive'},
        );

        await service.deleteRemote('gdrive');
      });
    });

    group('listFolders', () {
      test('returns directories only', () async {
        dioAdapter.onPost(
          '/operations/list',
          (server) {
            server.reply(200, {
              'list': [
                {'Path': 'folder1', 'Name': 'folder1', 'IsDir': true},
                {'Path': 'folder2', 'Name': 'folder2', 'IsDir': true},
              ],
            });
          },
          data: {
            'fs': 'gdrive:',
            'remote': '/',
            'opt': {'dirsOnly': true},
          },
        );

        final folders = await service.listFolders('gdrive:', '/');
        expect(folders.length, 2);
        expect(folders[0]['Name'], 'folder1');
      });
    });

    group('listFiles', () {
      test('returns files and folders', () async {
        dioAdapter.onPost(
          '/operations/list',
          (server) {
            server.reply(200, {
              'list': [
                {'Path': 'file.txt', 'Name': 'file.txt', 'IsDir': false},
                {'Path': 'folder', 'Name': 'folder', 'IsDir': true},
              ],
            });
          },
          data: {
            'fs': 'gdrive:',
            'remote': '/',
          },
        );

        final items = await service.listFiles('gdrive:', '/');
        expect(items.length, 2);
      });
    });

    group('startSync', () {
      test('starts sync and returns job ID', () async {
        final profile = testProfile();

        dioAdapter.onPost(
          profile.syncMode.rcEndpoint,
          (server) {
            server.reply(200, {'jobid': 42});
          },
          data: Matchers.any,
        );

        final jobId = await service.startSync(profile);
        expect(jobId, 42);
      });

      test('passes dry run parameter', () async {
        final profile = testProfile();

        dioAdapter.onPost(
          profile.syncMode.rcEndpoint,
          (server) {
            server.reply(200, {'jobid': 99});
          },
          data: Matchers.any,
        );

        final jobId = await service.startSync(profile, dryRun: true);
        expect(jobId, 99);
      });
    });

    group('getJobStatus', () {
      test('returns job status data', () async {
        dioAdapter.onPost(
          '/job/status',
          (server) {
            server.reply(200, {
              'jobid': 42,
              'finished': false,
              'success': false,
            });
          },
          data: {'jobid': 42},
        );

        final status = await service.getJobStatus(42);
        expect(status['jobid'], 42);
        expect(status['finished'], false);
      });
    });

    group('getJobList', () {
      test('returns list of jobs', () async {
        dioAdapter.onPost('/job/list', (server) {
          server.reply(200, {
            'jobids': [1, 2, 3],
          });
        }, data: {});

        final jobs = await service.getJobList();
        expect(jobs['jobids'], [1, 2, 3]);
      });
    });

    group('stopJob', () {
      test('sends stop command', () async {
        dioAdapter.onPost(
          '/job/stop',
          (server) {
            server.reply(200, {});
          },
          data: {'jobid': 42},
        );

        await service.stopJob(42);
      });
    });

    group('getTransferStats', () {
      test('returns stats without group', () async {
        dioAdapter.onPost('/core/stats', (server) {
          server.reply(200, {
            'bytes': 1024,
            'speed': 512.0,
            'transfers': 5,
          });
        }, data: {});

        final stats = await service.getTransferStats();
        expect(stats['bytes'], 1024);
      });

      test('passes group parameter', () async {
        dioAdapter.onPost(
          '/core/stats',
          (server) {
            server.reply(200, {'bytes': 2048});
          },
          data: {'group': 'job/42'},
        );

        final stats = await service.getTransferStats(group: 'job/42');
        expect(stats['bytes'], 2048);
      });
    });

    group('getCompletedTransfers', () {
      test('returns completed transfers list', () async {
        dioAdapter.onPost('/core/transferred', (server) {
          server.reply(200, {
            'transferred': [
              {'Name': 'file1.txt', 'Size': 100},
              {'Name': 'file2.txt', 'Size': 200},
            ],
          });
        }, data: {});

        final transfers = await service.getCompletedTransfers();
        expect(transfers.length, 2);
        expect(transfers[0]['Name'], 'file1.txt');
      });

      test('returns empty list when no transfers', () async {
        dioAdapter.onPost('/core/transferred', (server) {
          server.reply(200, {'transferred': []});
        }, data: {});

        final transfers = await service.getCompletedTransfers();
        expect(transfers, isEmpty);
      });
    });

    group('resetStats', () {
      test('sends reset command', () async {
        dioAdapter.onPost('/core/stats-reset', (server) {
          server.reply(200, {});
        }, data: {});

        await service.resetStats();
      });
    });

    group('setBandwidthLimit', () {
      test('sets bandwidth limit and returns result', () async {
        dioAdapter.onPost(
          '/core/bwlimit',
          (server) {
            server.reply(200, {
              'bytesPerSecond': 1048576,
              'rate': '1M',
            });
          },
          data: {'rate': '1M'},
        );

        final result = await service.setBandwidthLimit('1M');
        expect(result['rate'], '1M');
      });
    });

    group('getBandwidthLimit', () {
      test('returns current bandwidth limit', () async {
        dioAdapter.onPost('/core/bwlimit', (server) {
          server.reply(200, {
            'bytesPerSecond': -1,
            'rate': 'off',
          });
        }, data: {});

        final result = await service.getBandwidthLimit();
        expect(result['rate'], 'off');
      });
    });
  });
}
