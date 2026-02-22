import 'dart:convert';
import 'dart:io';

/// Manages the rclone rcd process lifecycle - starting, stopping, and
/// cleaning up stale daemon processes.
class RcloneDaemonManager {
  final String appSupportDir;
  Process? _process;

  RcloneDaemonManager({required this.appSupportDir});

  /// Path to the PID file used to track the daemon process.
  String get pidFilePath => '$appSupportDir/rclone.pid';

  /// Checks whether rclone is installed and available on the system PATH.
  Future<bool> isRcloneInstalled() async {
    try {
      final result = await Process.run('which', ['rclone']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Returns the full path to the rclone binary, or null if not found.
  Future<String?> getRclonePath() async {
    try {
      final result = await Process.run('which', ['rclone']);
      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns true if the daemon process is currently running.
  bool get isRunning {
    if (_process != null) return true;

    final pidFile = File(pidFilePath);
    if (!pidFile.existsSync()) return false;

    try {
      final pid = int.parse(pidFile.readAsStringSync().trim());
      // kill -0 checks if process exists without actually sending a signal
      final result = Process.runSync('kill', ['-0', '$pid']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Starts the rclone rcd daemon process.
  Future<void> start({
    required String user,
    required String pass,
    String? configPass,
    int port = 5572,
  }) async {
    await cleanupStale();

    final environment = <String, String>{};
    if (configPass != null) {
      environment['RCLONE_CONFIG_PASS'] = configPass;
    }

    _process = await Process.start(
      'rclone',
      [
        'rcd',
        '--rc-user',
        user,
        '--rc-pass',
        pass,
        '--rc-addr',
        'localhost:$port',
      ],
      environment: environment.isNotEmpty ? environment : null,
    );

    // Write PID to file for tracking.
    final pidFile = File(pidFilePath);
    await pidFile.writeAsString('${_process!.pid}');
  }

  /// Stops the rclone daemon process gracefully.
  Future<void> stop({
    int port = 5572,
    String? user,
    String? pass,
  }) async {
    // First, try to stop via the RC API.
    try {
      final client = HttpClient();
      final request = await client.postUrl(
        Uri.parse('http://localhost:$port/core/quit'),
      );
      if (user != null && pass != null) {
        request.headers.set(
          'Authorization',
          'Basic ${base64Encode(utf8.encode('$user:$pass'))}',
        );
      }
      request.headers.contentType = ContentType.json;
      await request.close();
      client.close();
    } catch (_) {
      // If the API call fails, kill the process directly.
      _process?.kill();
    }

    // Wait up to 5 seconds for the process to exit.
    if (_process != null) {
      try {
        await _process!.exitCode.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _process?.kill(ProcessSignal.sigkill);
            return -1;
          },
        );
      } catch (_) {
        // Ignore errors during cleanup.
      }
      _process = null;
    }

    // Delete PID file.
    final pidFile = File(pidFilePath);
    if (pidFile.existsSync()) {
      pidFile.deleteSync();
    }
  }

  /// Cleans up a stale daemon process from a previous run.
  Future<void> cleanupStale() async {
    final pidFile = File(pidFilePath);
    if (!pidFile.existsSync()) return;

    try {
      final pid = int.parse(pidFile.readAsStringSync().trim());

      // Check if process is alive.
      final checkResult = Process.runSync('kill', ['-0', '$pid']);
      if (checkResult.exitCode == 0) {
        // Process is alive - send SIGTERM.
        Process.runSync('kill', ['-TERM', '$pid']);

        // Wait up to 3 seconds for graceful shutdown.
        var terminated = false;
        for (var i = 0; i < 30; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          final alive = Process.runSync('kill', ['-0', '$pid']);
          if (alive.exitCode != 0) {
            terminated = true;
            break;
          }
        }

        // If still alive, force kill.
        if (!terminated) {
          Process.runSync('kill', ['-KILL', '$pid']);
        }
      }
    } catch (_) {
      // Ignore errors - PID file might have invalid content.
    }

    // Always clean up the PID file.
    if (pidFile.existsSync()) {
      pidFile.deleteSync();
    }
  }

  /// Disposes of the daemon manager, killing the process if running.
  void dispose() {
    if (_process != null) {
      _process!.kill();
      _process = null;
    }
  }
}
