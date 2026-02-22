import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/sync_history_entry.dart';

/// A tile displaying a completed sync history entry.
class SyncHistoryTile extends StatelessWidget {
  const SyncHistoryTile({
    super.key,
    required this.entry,
    required this.profileName,
  });

  final SyncHistoryEntry entry;
  final String profileName;

  IconData _statusIcon() {
    switch (entry.status) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.cancel;
      default:
        return Icons.warning;
    }
  }

  Color _statusColor() {
    switch (entry.status) {
      case 'success':
        return const Color(0xFF4CAF50);
      case 'error':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFFA726);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (date == today) {
      return 'Today ${DateFormat.jm().format(timestamp)}';
    }
    return DateFormat.MMMd().add_jm().format(timestamp);
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes >= 1) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      if (seconds == 0) return '${minutes}m';
      return '${minutes}m ${seconds}s';
    }
    return '${duration.inSeconds}s';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = entry.status == 'error' && entry.error != null;

    final tile = ListTile(
      leading: Icon(_statusIcon(), color: _statusColor()),
      title: Text(profileName),
      subtitle: Text(
        '${_formatTimestamp(entry.timestamp)} — ${_formatDuration(entry.duration)}'
        ' — ${entry.filesTransferred} files, ${_formatBytes(entry.bytesTransferred)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );

    if (!hasError) return tile;

    return ExpansionTile(
      leading: Icon(_statusIcon(), color: _statusColor()),
      title: Text(profileName),
      subtitle: Text(
        '${_formatTimestamp(entry.timestamp)} — ${_formatDuration(entry.duration)}'
        ' — ${entry.filesTransferred} files, ${_formatBytes(entry.bytesTransferred)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
