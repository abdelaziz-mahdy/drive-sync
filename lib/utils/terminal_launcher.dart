import 'dart:io';

import 'package:flutter/material.dart';

/// Utility for launching commands in the system terminal.
class TerminalLauncher {
  TerminalLauncher._();

  /// Opens the platform's terminal and runs the given [command].
  ///
  /// On macOS, uses osascript to open Terminal.app.
  /// On Linux, tries common terminal emulators in order.
  /// On Windows, uses cmd /k to keep the terminal open.
  ///
  /// Returns true if the terminal was launched, false otherwise.
  static Future<bool> run(String command) async {
    try {
      if (Platform.isMacOS) {
        await Process.start('osascript', [
          '-e',
          'tell application "Terminal" to do script "$command"',
          '-e',
          'tell application "Terminal" to activate',
        ]);
        return true;
      } else if (Platform.isLinux) {
        final terminals = [
          'gnome-terminal',
          'konsole',
          'xterm',
          'x-terminal-emulator',
        ];
        for (final terminal in terminals) {
          try {
            if (terminal == 'gnome-terminal') {
              await Process.start(terminal, [
                '--',
                'bash',
                '-c',
                '$command; echo "Press Enter to close..."; read',
              ]);
            } else if (terminal == 'konsole') {
              await Process.start(terminal, [
                '-e',
                'bash',
                '-c',
                '$command; echo "Press Enter to close..."; read',
              ]);
            } else {
              await Process.start(terminal, ['-e', command]);
            }
            return true;
          } catch (_) {
            continue;
          }
        }
        return false;
      } else if (Platform.isWindows) {
        await Process.start(
            'cmd', ['/c', 'start', 'cmd', '/k', command]);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Opens a terminal and runs the command, showing a snackbar on failure.
  static Future<void> runOrSnackbar(
    BuildContext context,
    String command,
  ) async {
    final success = await run(command);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open terminal. Please run manually:\n$command',
          ),
        ),
      );
    }
  }
}
