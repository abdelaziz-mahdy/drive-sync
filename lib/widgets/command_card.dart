import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/terminal_launcher.dart';

/// A card that displays a terminal command with copy and "Run in Terminal"
/// buttons.
///
/// Used on the splash screen (rclone install) and onboarding (rclone config).
class CommandCard extends StatelessWidget {
  const CommandCard({
    super.key,
    required this.command,
    this.title,
    this.subtitle,
    this.runButtonLabel = 'Run in Terminal',
  });

  /// The command to display and run.
  final String command;

  /// Optional title shown above the command (e.g. "Install rclone").
  final String? title;

  /// Optional subtitle shown below the title.
  final String? subtitle;

  /// Label for the "Run in Terminal" button.
  final String runButtonLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Command display with copy button.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    command,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy command',
                  onPressed: () => _copyCommand(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Run in terminal button.
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () => TerminalLauncher.runOrSnackbar(context, command),
              icon: const Icon(Icons.terminal, size: 18),
              label: Text(runButtonLabel),
            ),
          ),
        ],
      ),
    );
  }

  void _copyCommand(BuildContext context) {
    Clipboard.setData(ClipboardData(text: command));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Command copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
