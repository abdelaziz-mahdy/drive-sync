import 'package:drive_sync/models/sync_mode.dart';
import 'package:drive_sync/providers/rclone_provider.dart';
import 'package:drive_sync/screens/profile_editor/file_type_chips.dart';
import 'package:drive_sync/screens/profile_editor/sync_mode_selector.dart';
import 'package:drive_sync/screens/profile_editor/profile_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncModeSelector', () {
    Future<void> pumpSelector(
      WidgetTester tester, {
      required SyncMode selected,
      ValueChanged<SyncMode>? onChanged,
    }) async {
      // Use a large surface to prevent overflow errors in wide card layouts.
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SyncModeSelector(
                selected: selected,
                onChanged: onChanged ?? (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders all sync modes', (tester) async {
      await pumpSelector(tester, selected: SyncMode.backup);

      // All mode labels should be visible
      expect(find.text('Backup'), findsOneWidget);
      expect(find.text('Mirror'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      // 'Bidirectional' appears twice: as label and as direction text
      expect(find.text('Bidirectional'), findsAtLeastNWidgets(1));

      // Direction texts should be visible
      expect(find.textContaining('Local'), findsWidgets);
      expect(find.textContaining('Cloud'), findsWidgets);
    });

    testWidgets('shows warning badge on mirror mode', (tester) async {
      await pumpSelector(tester, selected: SyncMode.backup);

      expect(
        find.text('Deletes local files not on cloud'),
        findsOneWidget,
      );
    });

    testWidgets('shows experimental badge on bisync mode', (tester) async {
      await pumpSelector(tester, selected: SyncMode.backup);

      expect(find.text('Experimental'), findsOneWidget);
    });

    testWidgets('calls onChanged when mode is tapped', (tester) async {
      SyncMode? lastChanged;

      await pumpSelector(
        tester,
        selected: SyncMode.backup,
        onChanged: (m) => lastChanged = m,
      );

      // Tap on the Download card text
      await tester.tap(find.text('Download'));
      await tester.pump();

      expect(lastChanged, SyncMode.download);
    });
  });

  group('FileTypeChips', () {
    testWidgets('adds chip via text field and Enter', (tester) async {
      List<String> includeTypes = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FileTypeChips(
                useIncludeMode: true,
                onIncludeModeChanged: (_) {},
                includeTypes: includeTypes,
                excludeTypes: const [],
                onIncludeTypesChanged: (v) => includeTypes = v,
                onExcludeTypesChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Enter an extension
      await tester.enterText(
        find.byType(TextField),
        'pdf',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(includeTypes, contains('pdf'));
    });

    testWidgets('removes chip when delete is tapped', (tester) async {
      List<String> includeTypes = ['pdf', 'docx'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: FileTypeChips(
                    useIncludeMode: true,
                    onIncludeModeChanged: (_) {},
                    includeTypes: includeTypes,
                    excludeTypes: const [],
                    onIncludeTypesChanged: (v) {
                      setState(() => includeTypes = v);
                    },
                    onExcludeTypesChanged: (_) {},
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Both chips should be visible
      expect(find.text('.pdf'), findsOneWidget);
      expect(find.text('.docx'), findsOneWidget);

      // Tap the delete icon on the pdf chip
      final pdfChip = find.ancestor(
        of: find.text('.pdf'),
        matching: find.byType(Chip),
      );
      final deleteIcon = find.descendant(
        of: pdfChip,
        matching: find.byIcon(Icons.close),
      );
      await tester.tap(deleteIcon);
      await tester.pump();

      expect(includeTypes, isNot(contains('pdf')));
      expect(includeTypes, contains('docx'));
    });

    testWidgets('applies preset adds all extensions', (tester) async {
      List<String> includeTypes = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: FileTypeChips(
                    useIncludeMode: true,
                    onIncludeModeChanged: (_) {},
                    includeTypes: includeTypes,
                    excludeTypes: const [],
                    onIncludeTypesChanged: (v) {
                      setState(() => includeTypes = v);
                    },
                    onExcludeTypesChanged: (_) {},
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap the "Documents" preset button
      await tester.tap(find.text('Documents'));
      await tester.pump();

      expect(includeTypes, containsAll(['pdf', 'docx', 'xlsx', 'pptx']));
    });

    testWidgets('toggles between include and exclude mode', (tester) async {
      bool useInclude = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FileTypeChips(
                useIncludeMode: useInclude,
                onIncludeModeChanged: (v) => useInclude = v,
                includeTypes: const [],
                excludeTypes: const [],
                onIncludeTypesChanged: (_) {},
                onExcludeTypesChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Both segment labels should be visible
      expect(find.text('Include'), findsOneWidget);
      expect(find.text('Exclude'), findsOneWidget);

      // Tap Exclude
      await tester.tap(find.text('Exclude'));
      await tester.pump();

      expect(useInclude, false);
    });
  });

  group('ProfileEditorScreen', () {
    testWidgets('renders create mode with all sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remotesProvider.overrideWith(
              (ref) => Future.value(['gdrive', 'onedrive']),
            ),
          ],
          child: const MaterialApp(
            home: ProfileEditorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title for create mode
      expect(find.text('New Profile'), findsOneWidget);

      // Section headers
      expect(find.text('Basic Info'), findsOneWidget);
      expect(find.text('Sync Mode'), findsOneWidget);
      expect(find.text('Paths'), findsOneWidget);
      expect(find.text('File Types'), findsOneWidget);
    });

    testWidgets('validates name is required', (tester) async {
      // Use a very tall surface so all form content and Save button are visible
      await tester.binding.setSurfaceSize(const Size(1200, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            remotesProvider.overrideWith(
              (ref) => Future.value(['gdrive']),
            ),
          ],
          child: const MaterialApp(
            home: ProfileEditorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Save FilledButton and tap it
      final saveButton = find.widgetWithText(FilledButton, 'Save');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
    });
  });
}
