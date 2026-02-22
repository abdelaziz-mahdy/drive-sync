import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/widgets/sidebar_layout.dart';

void main() {
  group('SidebarLayout', () {
    final sidebar = Container(
      key: const Key('sidebar'),
      color: Colors.blue,
      child: const Text('Sidebar'),
    );
    final content = Container(
      key: const Key('content'),
      color: Colors.white,
      child: const Text('Content'),
    );

    testWidgets('shows sidebar and content side by side on wide screens',
        (tester) async {
      // Set a wide screen size
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SidebarLayout(
              sidebar: sidebar,
              content: content,
            ),
          ),
        ),
      );

      // Both sidebar and content should be visible
      expect(find.text('Sidebar'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);

      // Should use Row layout
      expect(find.byType(Row), findsOneWidget);

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('uses drawer on narrow screens', (tester) async {
      // Set a narrow screen size
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SidebarLayout(
              sidebar: sidebar,
              content: content,
            ),
          ),
        ),
      );

      // Content should be visible, sidebar should not (it's in the drawer)
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Sidebar'), findsNothing);

      // Should have a Drawer
      expect(find.byType(Drawer), findsNothing); // Drawer not opened yet

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('respects custom sidebarWidth', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SidebarLayout(
              sidebar: sidebar,
              content: content,
              sidebarWidth: 350,
            ),
          ),
        ),
      );

      // Find the SizedBox wrapping the sidebar
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byKey(const Key('sidebar')),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 350);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('respects custom breakpoint', (tester) async {
      // Set size between default breakpoint (720) and custom breakpoint (1000)
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SidebarLayout(
              sidebar: sidebar,
              content: content,
              breakpoint: 1000,
            ),
          ),
        ),
      );

      // At 800px with breakpoint 1000, should use drawer layout
      // So sidebar text should not be visible
      expect(find.text('Sidebar'), findsNothing);
      expect(find.text('Content'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
