import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../database/daos/history_dao.dart';
import '../../providers/database_provider.dart';
import '../../providers/profiles_provider.dart';
import '../../utils/format_utils.dart';

/// Full-screen detail view for a sync history entry, including transferred files.
class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({
    super.key,
    required this.historyId,
    required this.profileName,
  });

  final int historyId;
  final String profileName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(profileName)),
      body: FutureBuilder<HistoryEntryWithFiles?>(
        future: HistoryDao(ref.read(appDatabaseProvider))
            .getWithFiles(historyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Entry not found'));
          }

          final entry = data.entry;
          final files = data.files;
          final isSuccess = entry.status == 'success';
          final hasError = entry.status == 'error' && entry.error != null;
          final duration = Duration(milliseconds: entry.durationMs);

          final profiles = ref.watch(profilesProvider).value ?? [];
          final profile =
              profiles.where((p) => p.id == entry.profileId).firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary stat cards
              _StatCardsRow(
                filesTransferred: entry.filesTransferred,
                bytesTransferred: entry.bytesTransferred,
                duration: duration,
                status: entry.status,
              ),
              const SizedBox(height: 16),

              // Details card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Details',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Status',
                        value: isSuccess ? 'Success' : 'Error',
                        valueColor: isSuccess
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                      ),
                      _DetailRow(
                        label: 'Timestamp',
                        value: DateFormat.yMMMd()
                            .add_jm()
                            .format(entry.timestamp),
                      ),
                      _DetailRow(
                        label: 'Duration',
                        value: FormatUtils.formatDuration(duration),
                      ),
                      if (profile != null) ...[
                        _DetailRow(
                          label: 'Source',
                          value: profile.localPaths.length == 1
                              ? profile.localPath
                              : '${profile.localPath} (+${profile.localPaths.length - 1} more)',
                        ),
                        _DetailRow(
                          label: 'Destination',
                          value: profile.remoteFs,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Error section
              if (hasError) ...[
                const SizedBox(height: 12),
                Card(
                  color: colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline,
                                size: 20,
                                color: colorScheme.onErrorContainer),
                            const SizedBox(width: 8),
                            Text(
                              'Error',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Transferred files
              if (files.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Transferred Files (${files.length})',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: files.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.insert_drive_file_outlined,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          file.fileName,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          FormatUtils.formatSize(file.fileSize),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.filesTransferred,
    required this.bytesTransferred,
    required this.duration,
    required this.status,
  });

  final int filesTransferred;
  final int bytesTransferred;
  final Duration duration;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.insert_drive_file_outlined,
            label: 'Files',
            value: '$filesTransferred',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.data_usage,
            label: 'Transferred',
            value: FormatUtils.formatSize(bytesTransferred),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: FormatUtils.formatDuration(duration),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            width: 100,
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
              style: theme.textTheme.bodyMedium?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
