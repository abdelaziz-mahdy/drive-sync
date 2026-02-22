import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/app_release.dart';
import '../../providers/app_config_provider.dart';

/// Dialog showing update information with markdown changelog.
class UpdateDialog extends ConsumerWidget {
  const UpdateDialog({
    super.key,
    required this.release,
    required this.currentVersion,
  });

  final AppRelease release;
  final String currentVersion;

  String? _platformDownloadUrl() {
    String extension;
    if (Platform.isMacOS) {
      extension = '.dmg';
    } else if (Platform.isWindows) {
      extension = '.exe';
    } else {
      extension = '.deb';
    }

    for (final entry in release.downloadUrls.entries) {
      if (entry.key.endsWith(extension)) {
        return entry.value;
      }
    }
    // Fallback: return first URL if available
    return release.downloadUrls.values.isNotEmpty
        ? release.downloadUrls.values.first
        : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final downloadUrl = _platformDownloadUrl();

    return AlertDialog(
      title: const Text('Update Available'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version comparison
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'v$currentVersion',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  'v${release.version}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Changelog
            if (release.changelog.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No changelog available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: MarkdownBody(data: release.changelog),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Remind Me Later'),
        ),
        OutlinedButton(
          onPressed: () {
            ref
                .read(appConfigProvider.notifier)
                .skipVersion(release.version);
            Navigator.of(context).pop();
          },
          child: const Text('Skip This Version'),
        ),
        if (downloadUrl != null)
          FilledButton(
            onPressed: () {
              launchUrl(Uri.parse(downloadUrl));
            },
            child: const Text('Download'),
          ),
      ],
    );
  }
}
