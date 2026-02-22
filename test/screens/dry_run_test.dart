import 'package:drive_sync/models/file_change.dart';
import 'package:drive_sync/models/sync_preview.dart';
import 'package:drive_sync/screens/dry_run/dry_run_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testPreview = SyncPreview(
    profileId: 'test-id',
    timestamp: DateTime(2024, 1, 15),
    filesToAdd: [
      const FileChange(
        path: 'documents/report.pdf',
        size: 1048576, // 1 MB
        action: FileChangeAction.add,
      ),
      const FileChange(
        path: 'images/photo.jpg',
        size: 2097152, // 2 MB
        action: FileChangeAction.add,
      ),
    ],
    filesToUpdate: [
      const FileChange(
        path: 'notes/readme.txt',
        size: 512,
        action: FileChangeAction.update,
      ),
    ],
    filesToDelete: [
      const FileChange(
        path: 'old/backup.zip',
        size: 5242880, // 5 MB
        action: FileChangeAction.delete,
      ),
    ],
  );

  group('DryRunResultsScreen', () {
    testWidgets('shows summary bar with file counts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DryRunResultsScreen(preview: testPreview),
        ),
      );

      // Summary should mention counts
      expect(find.textContaining('2 to add'), findsOneWidget);
      expect(find.textContaining('1 to update'), findsOneWidget);
      expect(find.textContaining('1 to delete'), findsOneWidget);
    });

    testWidgets('shows expandable sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DryRunResultsScreen(preview: testPreview),
        ),
      );

      // Section headers should be visible
      expect(find.textContaining('Files to Add'), findsOneWidget);
      expect(find.textContaining('Files to Update'), findsOneWidget);
      expect(find.textContaining('Files to Delete'), findsOneWidget);
    });

    testWidgets('shows file paths in expanded sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DryRunResultsScreen(preview: testPreview),
        ),
      );

      // Since files <= 20, sections should be initially expanded
      expect(find.text('documents/report.pdf'), findsOneWidget);
      expect(find.text('images/photo.jpg'), findsOneWidget);
      expect(find.text('notes/readme.txt'), findsOneWidget);
      expect(find.text('old/backup.zip'), findsOneWidget);
    });

    testWidgets('shows file sizes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DryRunResultsScreen(preview: testPreview),
        ),
      );

      // Should show formatted sizes
      expect(find.text('1.0 MB'), findsOneWidget);
      expect(find.text('2.0 MB'), findsOneWidget);
      expect(find.text('512 B'), findsOneWidget);
      expect(find.text('5.0 MB'), findsOneWidget);
    });

    testWidgets('Execute Sync button is enabled when there are changes',
        (tester) async {
      bool synced = false;

      await tester.pumpWidget(
        MaterialApp(
          home: DryRunResultsScreen(
            preview: testPreview,
            onExecuteSync: () => synced = true,
          ),
        ),
      );

      expect(find.text('Execute Sync'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Execute Sync'));
      await tester.pump();
      expect(synced, true);
    });

    testWidgets('shows "No changes" when preview is empty', (tester) async {
      final emptyPreview = SyncPreview(
        profileId: 'test-id',
        timestamp: DateTime(2024, 1, 15),
        filesToAdd: const [],
        filesToUpdate: const [],
        filesToDelete: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DryRunResultsScreen(preview: emptyPreview),
        ),
      );

      expect(find.text('No changes detected'), findsOneWidget);
    });

    testWidgets('shows "No files" text in empty sections', (tester) async {
      final partialPreview = SyncPreview(
        profileId: 'test-id',
        timestamp: DateTime(2024, 1, 15),
        filesToAdd: [
          const FileChange(
            path: 'test.txt',
            size: 100,
            action: FileChangeAction.add,
          ),
        ],
        filesToUpdate: const [],
        filesToDelete: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DryRunResultsScreen(preview: partialPreview),
        ),
      );

      // Expand the empty sections to see "No files"
      // The "Files to Update" section is collapsed since it has 0 files
      // Tap to expand it
      await tester.tap(find.textContaining('Files to Update'));
      await tester.pumpAndSettle();

      expect(find.text('No files'), findsAtLeastNWidgets(1));
    });
  });

  group('DryRunResultsScreen.formatSize', () {
    test('formats bytes correctly', () {
      expect(DryRunResultsScreen.formatSize(0), '0 B');
      expect(DryRunResultsScreen.formatSize(512), '512 B');
      expect(DryRunResultsScreen.formatSize(1023), '1023 B');
    });

    test('formats kilobytes correctly', () {
      expect(DryRunResultsScreen.formatSize(1024), '1.0 KB');
      expect(DryRunResultsScreen.formatSize(1536), '1.5 KB');
    });

    test('formats megabytes correctly', () {
      expect(DryRunResultsScreen.formatSize(1048576), '1.0 MB');
      expect(DryRunResultsScreen.formatSize(5242880), '5.0 MB');
    });

    test('formats gigabytes correctly', () {
      expect(DryRunResultsScreen.formatSize(1073741824), '1.0 GB');
    });
  });
}
