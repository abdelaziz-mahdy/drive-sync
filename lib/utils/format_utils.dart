/// Shared formatting utilities for human-readable sizes, speeds, durations,
/// and relative timestamps.
class FormatUtils {
  FormatUtils._();

  /// Format [bytes] into a human-readable string (B, KB, MB, GB).
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Format [bytesPerSecond] into a human-readable speed string with /s suffix.
  static String formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond <= 0) return '0 B/s';
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    }
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB/s';
  }

  /// Format a [Duration] into a compact string like "1s", "2m 15s", "1h 30m".
  static String formatDuration(Duration duration) {
    if (duration.inHours >= 1) {
      final h = duration.inHours;
      final m = (duration.inSeconds % 3600) ~/ 60;
      return '${h}h ${m}m';
    }
    if (duration.inMinutes >= 1) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      if (seconds == 0) return '${minutes}m';
      return '${minutes}m ${seconds}s';
    }
    return '${duration.inSeconds}s';
  }

  /// Format raw [seconds] into a compact string like "1s", "2m 15s", "1h 30m".
  static String formatEta(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m ${seconds % 60}s';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}h ${m}m';
  }

  /// Format a [DateTime] as a relative time string.
  ///
  /// Returns "Never synced" when [time] is null, "Just now" for less than a
  /// minute, "X min ago", "X hours ago", "X days ago", or a date string for
  /// older timestamps.
  static String formatRelativeTime(DateTime? time) {
    if (time == null) return 'Never synced';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${time.day}/${time.month}/${time.year}';
  }
}
