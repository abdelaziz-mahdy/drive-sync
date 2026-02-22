import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/widgets/progress_bar.dart';

void main() {
  group('SyncProgressBar', () {
    testWidgets('renders with zero progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 0.0),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, 0.0);
    });

    testWidgets('renders with full progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 1.0),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, 1.0);
    });

    testWidgets('renders with partial progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 0.65),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, closeTo(0.65, 0.001));
    });

    testWidgets('clamps progress above 1.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 1.5),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, 1.0);
    });

    testWidgets('clamps progress below 0.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: -0.5),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, 0.0);
    });

    testWidgets('shows label when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(
              progress: 0.65,
              label: '65% - 2.3 MB/s',
            ),
          ),
        ),
      );

      expect(find.text('65% - 2.3 MB/s'), findsOneWidget);
    });

    testWidgets('hides label when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 0.5),
          ),
        ),
      );

      // Only the progress indicator, no text
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('uses custom color when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncProgressBar(progress: 0.5, color: Colors.red),
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      final valueColor = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, Colors.red);
    });
  });
}
