import 'package:flutter/material.dart';

class SidebarLayout extends StatelessWidget {
  const SidebarLayout({
    super.key,
    required this.sidebar,
    required this.content,
    this.sidebarWidth = 280,
    this.breakpoint = 720,
  });

  /// The sidebar widget shown on the left (or in a drawer on narrow screens).
  final Widget sidebar;

  /// The main content area.
  final Widget content;

  /// Width of the sidebar when displayed inline.
  final double sidebarWidth;

  /// Below this width the sidebar becomes a drawer.
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= breakpoint;

        if (isWide) {
          return Row(
            children: [
              SizedBox(width: sidebarWidth, child: sidebar),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: content),
            ],
          );
        }

        return Scaffold(
          drawer: Drawer(
            width: sidebarWidth,
            child: sidebar,
          ),
          body: content,
        );
      },
    );
  }
}
