import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/widgets/skeleton_loader.dart';

void main() {
  group('SkeletonLine', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              child: SkeletonLine(width: 120, height: 20),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLine), findsOneWidget);
    });

    testWidgets('renders at full width when width is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: SkeletonLoader(
                child: SkeletonLine(height: 16),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLine), findsOneWidget);
    });
  });

  group('SkeletonCircle', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              child: SkeletonCircle(size: 36),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonCircle), findsOneWidget);
    });
  });

  group('SkeletonCard', () {
    testWidgets('renders a Card with skeleton children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              child: SkeletonCard(),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(SkeletonLine), findsAtLeast(3));
      expect(find.byType(SkeletonCircle), findsOneWidget);
    });
  });

  group('SkeletonListTile', () {
    testWidgets('renders circle and lines', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              child: SkeletonListTile(),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonCircle), findsOneWidget);
      expect(find.byType(SkeletonLine), findsAtLeast(2));
    });
  });

  group('SkeletonLoader', () {
    testWidgets('renders child content with animation builder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              child: SkeletonLine(width: 100, height: 16),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLine), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsAtLeast(1));
    });

    testWidgets('renders when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              enabled: false,
              child: SkeletonLine(width: 100, height: 16),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLine), findsOneWidget);
    });

    testWidgets('animates over time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              child: SkeletonLine(width: 100, height: 16),
            ),
          ),
        ),
      );

      // Pump a few frames to verify animation runs without error.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SkeletonLine), findsOneWidget);
    });
  });
}
