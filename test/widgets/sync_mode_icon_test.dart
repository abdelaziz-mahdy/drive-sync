import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/widgets/sync_mode_icon.dart';

void main() {
  group('SyncModeIcon', () {
    testWidgets('renders cloud_upload_outlined for backup', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncModeIcon(mode: SyncMode.backup),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.cloud_upload_outlined);
    });

    testWidgets('renders sync for mirror', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncModeIcon(mode: SyncMode.mirror),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.sync);
    });

    testWidgets('renders cloud_download_outlined for download', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncModeIcon(mode: SyncMode.download),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.cloud_download_outlined);
    });

    testWidgets('renders swap_horiz for bisync', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncModeIcon(mode: SyncMode.bisync),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.swap_horiz);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncModeIcon(mode: SyncMode.backup, size: 32),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 32);
    });

    testWidgets('respects custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncModeIcon(mode: SyncMode.backup, color: Colors.red),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.red);
    });
  });

  group('SyncModeIcon.iconForMode', () {
    test('returns correct icon for each mode', () {
      expect(SyncModeIcon.iconForMode(SyncMode.backup),
          Icons.cloud_upload_outlined);
      expect(SyncModeIcon.iconForMode(SyncMode.mirror), Icons.sync);
      expect(SyncModeIcon.iconForMode(SyncMode.download),
          Icons.cloud_download_outlined);
      expect(SyncModeIcon.iconForMode(SyncMode.bisync), Icons.swap_horiz);
    });
  });
}
