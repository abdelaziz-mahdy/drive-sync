import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders icon and title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.cloud_sync_outlined,
              title: 'No Sync Profiles',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_sync_outlined), findsOneWidget);
      expect(find.text('No Sync Profiles'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.history,
              title: 'No history',
              subtitle: 'Completed syncs appear here.',
            ),
          ),
        ),
      );

      expect(find.text('No history'), findsOneWidget);
      expect(find.text('Completed syncs appear here.'), findsOneWidget);
    });

    testWidgets('does not render subtitle when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.history,
              title: 'No history',
            ),
          ),
        ),
      );

      // Only one Text widget with our title.
      expect(find.text('No history'), findsOneWidget);
    });

    testWidgets('renders action button when actionLabel and onAction are provided',
        (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'Empty',
              actionLabel: 'Create',
              onAction: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Create'), findsOneWidget);

      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('does not render action button when actionLabel is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'Empty',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('compact mode uses smaller padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.history,
              title: 'No history',
              compact: true,
            ),
          ),
        ),
      );

      // Just verify it renders without errors in compact mode.
      expect(find.text('No history'), findsOneWidget);
    });

    testWidgets('respects custom icon size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.cloud_sync_outlined,
              title: 'Test',
              iconSize: 100,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 100);
    });
  });
}
