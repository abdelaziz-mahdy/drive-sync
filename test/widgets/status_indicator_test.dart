import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/models/sync_profile.dart';
import 'package:drive_sync/theme/color_schemes.dart';
import 'package:drive_sync/widgets/status_indicator.dart';

SyncProfile _makeProfile({String? lastSyncStatus}) {
  return SyncProfile(
    id: 'test-id',
    name: 'Test Profile',
    remoteName: 'gdrive',
    cloudFolder: '/backup',
    localPaths: ['/home/user/docs'],
    includeTypes: const [],
    excludeTypes: const [],
    useIncludeMode: false,
    syncMode: SyncMode.backup,
    scheduleMinutes: 30,
    enabled: true,
    respectGitignore: false,
    excludeGitDirs: false,
    customExcludes: const [],
    lastSyncStatus: lastSyncStatus,
  );
}

void main() {
  group('StatusIndicator', () {
    testWidgets('renders idle status with grey color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicator(status: SyncStatus.idle),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.idle);
    });

    testWidgets('renders success status with green color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicator(status: SyncStatus.success),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.success);
    });

    testWidgets('renders error status with red color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicator(status: SyncStatus.error),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.error);
    });

    testWidgets('renders warning status with amber color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicator(status: SyncStatus.warning),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.warning);
    });

    testWidgets('renders syncing status with animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicator(status: SyncStatus.syncing),
          ),
        ),
      );

      // Should find AnimatedBuilder widgets (including the pulse animation)
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusIndicator(status: SyncStatus.idle, size: 20),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 20);
      expect(container.constraints?.maxHeight, 20);
    });
  });

  group('StatusIndicator.colorForStatus', () {
    test('returns correct color for each status', () {
      expect(StatusIndicator.colorForStatus(SyncStatus.idle), AppColors.idle);
      expect(
          StatusIndicator.colorForStatus(SyncStatus.syncing), AppColors.syncing);
      expect(
          StatusIndicator.colorForStatus(SyncStatus.success), AppColors.success);
      expect(StatusIndicator.colorForStatus(SyncStatus.error), AppColors.error);
      expect(
          StatusIndicator.colorForStatus(SyncStatus.warning), AppColors.warning);
    });
  });

  group('StatusIndicator.fromProfile', () {
    test('returns syncing for running status', () {
      final profile = _makeProfile(lastSyncStatus: 'running');
      expect(StatusIndicator.fromProfile(profile), SyncStatus.syncing);
    });

    test('returns error for error status', () {
      final profile = _makeProfile(lastSyncStatus: 'error');
      expect(StatusIndicator.fromProfile(profile), SyncStatus.error);
    });

    test('returns success for success status', () {
      final profile = _makeProfile(lastSyncStatus: 'success');
      expect(StatusIndicator.fromProfile(profile), SyncStatus.success);
    });

    test('returns idle for null status', () {
      final profile = _makeProfile();
      expect(StatusIndicator.fromProfile(profile), SyncStatus.idle);
    });

    test('returns idle for unknown status', () {
      final profile = _makeProfile(lastSyncStatus: 'unknown');
      expect(StatusIndicator.fromProfile(profile), SyncStatus.idle);
    });
  });
}
