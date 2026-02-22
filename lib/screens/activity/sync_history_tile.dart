import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/sync_history_entry.dart';
import '../../models/sync_profile.dart';
import '../../utils/format_utils.dart';

/// A tile displaying a completed sync history entry.
///
/// Tapping the tile opens a detail dialog with full sync information.
class SyncHistoryTile extends StatelessWidget {
  const SyncHistoryTile({
    super.key,
    required this.entry,
    required this.profileName,
    this.profile,
  });

  final SyncHistoryEntry entry;
  final String profileName;

  /// The matching [SyncProfile], used to display source/destination paths
  /// in the detail dialog. May be null if the profile was deleted.
  final SyncProfile? profile;

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

  void _showDetailDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = entry.status == 'error' && entry.error != null;
    final isSuccess = entry.status == 'success';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _statusIcon(),
              color: _statusColor(),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                profileName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: 'Status',
                value: isSuccess
                    ? 'Success'
                    : (entry.status == 'error' ? 'Error' : entry.status),
                valueColor: _statusColor(),
              ),
              _DetailRow(
                label: 'Timestamp',
                value: DateFormat.yMMMd().add_jm().format(entry.timestamp),
              ),
              _DetailRow(
                label: 'Duration',
                value: FormatUtils.formatDuration(entry.duration),
              ),
              _DetailRow(
                label: 'Files Transferred',
                value: '${entry.filesTransferred}',
              ),
              _DetailRow(
                label: 'Bytes Transferred',
                value: FormatUtils.formatSize(entry.bytesTransferred),
              ),
              if (profile != null) ...[
                _DetailRow(
                  label: 'Source',
                  value: profile!.localPath,
                ),
                _DetailRow(
                  label: 'Destination',
                  value: profile!.remoteFs,
                ),
              ],
              if (hasError) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = entry.status == 'error' && entry.error != null;

    final subtitleText =
        '${_formatTimestamp(entry.timestamp)} — ${FormatUtils.formatDuration(entry.duration)}'
        ' — ${entry.filesTransferred} files, ${FormatUtils.formatSize(entry.bytesTransferred)}';

    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.7),
    );

    if (!hasError) {
      return ListTile(
        leading: Icon(_statusIcon(), color: _statusColor()),
        title: Text(profileName),
        subtitle: Text(subtitleText, style: subtitleStyle),
        onTap: () => _showDetailDialog(context),
      );
    }

    return ExpansionTile(
      leading: Icon(_statusIcon(), color: _statusColor()),
      title: Text(profileName),
      subtitle: Text(subtitleText, style: subtitleStyle),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showDetailDialog(context),
              child: const Text('View Details'),
            ),
          ),
        ),
      ],
    );
  }
}

/// A simple label-value row used in the detail dialog.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
