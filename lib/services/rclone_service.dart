import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/sync_profile.dart';

/// HTTP client that talks to the rclone rcd daemon on localhost via POST
/// requests with JSON bodies. Uses Dio with Basic auth.
class RcloneService {
  final Dio _dio;

  RcloneService({
    required String user,
    required String pass,
    int port = 5572,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://localhost:$port',
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$user:$pass'))}',
              'Content-Type': 'application/json',
            },
          ),
        );

  /// For testing with a pre-configured Dio instance.
  RcloneService.withDio(this._dio);

  /// POST /rc/noop - returns true if the daemon is reachable.
  Future<bool> healthCheck() async {
    try {
      await _dio.post('/rc/noop', data: {});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// POST /core/version - returns version info from rclone.
  Future<Map<String, dynamic>> getVersion() async {
    final response = await _dio.post('/core/version', data: {});
    return response.data as Map<String, dynamic>;
  }

  /// POST /core/quit - tells rclone to shut down. May throw, that's OK.
  Future<void> quit() async {
    await _dio.post('/core/quit', data: {});
  }

  /// POST /config/listremotes - returns a list of configured remote names.
  Future<List<String>> listRemotes() async {
    final response = await _dio.post('/config/listremotes', data: {});
    final data = response.data as Map<String, dynamic>;
    final remotes = data['remotes'] as List<dynamic>? ?? [];
    return remotes.cast<String>();
  }

  /// POST /config/get - returns configuration for a specific remote.
  Future<Map<String, dynamic>> getRemoteConfig(String name) async {
    final response = await _dio.post(
      '/config/get',
      data: {'name': name},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /config/delete - deletes a remote configuration.
  Future<void> deleteRemote(String name) async {
    await _dio.post(
      '/config/delete',
      data: {'name': name},
    );
  }

  /// POST /operations/list - lists folders (directories only) at the given
  /// remote path.
  Future<List<Map<String, dynamic>>> listFolders(
    String remote,
    String path,
  ) async {
    final fs = remote.endsWith(':') ? remote : '$remote:';
    final response = await _dio.post(
      '/operations/list',
      data: {
        'fs': fs,
        'remote': path,
        'opt': {'dirsOnly': true},
      },
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['list'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  /// POST /operations/list - lists all files and folders at the given remote
  /// path.
  Future<List<Map<String, dynamic>>> listFiles(
    String remote,
    String path,
  ) async {
    final fs = remote.endsWith(':') ? remote : '$remote:';
    final response = await _dio.post(
      '/operations/list',
      data: {
        'fs': fs,
        'remote': path,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['list'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  /// Starts a sync operation using the profile's sync mode endpoint.
  /// Returns the job ID for tracking.
  Future<int> startSync(
    SyncProfile profile, {
    List<String>? gitignoreRules,
    bool dryRun = false,
  }) async {
    final response = await _dio.post(
      profile.syncMode.rcEndpoint,
      data: profile.toRcApiData(
        gitignoreRules: gitignoreRules,
        dryRun: dryRun,
      ),
    );
    final data = response.data as Map<String, dynamic>;
    return data['jobid'] as int;
  }

  /// POST /job/status - returns the status of a running or completed job.
  Future<Map<String, dynamic>> getJobStatus(int jobId) async {
    final response = await _dio.post(
      '/job/status',
      data: {'jobid': jobId},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /job/list - returns a list of all jobs.
  Future<Map<String, dynamic>> getJobList() async {
    final response = await _dio.post('/job/list', data: {});
    return response.data as Map<String, dynamic>;
  }

  /// POST /job/stop - stops a running job.
  Future<void> stopJob(int jobId) async {
    await _dio.post(
      '/job/stop',
      data: {'jobid': jobId},
    );
  }

  /// POST /core/stats - returns transfer statistics.
  Future<Map<String, dynamic>> getTransferStats({String? group}) async {
    final response = await _dio.post(
      '/core/stats',
      data: group != null ? {'group': group} : <String, dynamic>{},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /core/transferred - returns list of completed transfers.
  Future<List<Map<String, dynamic>>> getCompletedTransfers({
    String? group,
  }) async {
    final response = await _dio.post(
      '/core/transferred',
      data: group != null ? {'group': group} : <String, dynamic>{},
    );
    final data = response.data as Map<String, dynamic>;
    final transferred = data['transferred'] as List<dynamic>? ?? [];
    return transferred.cast<Map<String, dynamic>>();
  }

  /// POST /core/stats-reset - resets transfer statistics.
  Future<void> resetStats({String? group}) async {
    await _dio.post(
      '/core/stats-reset',
      data: group != null ? {'group': group} : <String, dynamic>{},
    );
  }

  /// POST /core/bwlimit - sets bandwidth limit (e.g. "1M", "off").
  Future<Map<String, dynamic>> setBandwidthLimit(String rate) async {
    final response = await _dio.post(
      '/core/bwlimit',
      data: {'rate': rate},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /core/bwlimit - gets current bandwidth limit.
  Future<Map<String, dynamic>> getBandwidthLimit() async {
    final response = await _dio.post('/core/bwlimit', data: {});
    return response.data as Map<String, dynamic>;
  }
}
