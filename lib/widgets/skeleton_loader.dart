import 'package:flutter/material.dart';

/// A shimmer-animated skeleton placeholder widget for loading states.
///
/// Use [SkeletonLine] for single placeholder lines, or compose multiple
/// skeleton elements inside a [SkeletonCard] for card-shaped loading states.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    required this.child,
    this.enabled = true,
  });

  /// The skeleton content tree to animate.
  final Widget child;

  /// Whether the shimmer animation is active. Set to false to show
  /// a static placeholder (useful for reduced-motion preferences).
  final bool enabled;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _SkeletonScope(
          opacity: 0.3 + (_animation.value * 0.4),
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

/// Provides the current shimmer opacity to descendant skeleton elements.
class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({
    required this.opacity,
    required super.child,
  });

  final double opacity;

  static double of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_SkeletonScope>();
    return scope?.opacity ?? 0.5;
  }

  @override
  bool updateShouldNotify(_SkeletonScope oldWidget) {
    return opacity != oldWidget.opacity;
  }
}

/// A single rectangular skeleton placeholder line.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  /// Width of the placeholder. Defaults to full available width.
  final double? width;

  /// Height of the placeholder.
  final double height;

  /// Corner radius.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final opacity = _SkeletonScope.of(context);
    final color = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: opacity);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A skeleton placeholder shaped like a circle (for avatars / icons).
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final opacity = _SkeletonScope.of(context);
    final color = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: opacity);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A card-shaped skeleton with shimmer animation, matching the layout of
/// profile cards on the dashboard.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row
            Row(
              children: [
                Expanded(child: SkeletonLine(width: 120, height: 20)),
                SizedBox(width: 8),
                SkeletonCircle(size: 12),
              ],
            ),
            SizedBox(height: 12),
            // Sync mode
            SkeletonLine(width: 100, height: 14),
            SizedBox(height: 12),
            // Paths
            SkeletonLine(height: 14),
            SizedBox(height: 6),
            SkeletonLine(width: 180, height: 14),
            SizedBox(height: 16),
            // Last sync
            SkeletonLine(width: 80, height: 12),
            SizedBox(height: 16),
            // Buttons
            SkeletonLine(height: 36, borderRadius: 8),
          ],
        ),
      ),
    );
  }
}

/// A skeleton list tile for history entries.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SkeletonCircle(size: 36),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 160, height: 14),
                SizedBox(height: 6),
                SkeletonLine(width: 100, height: 12),
              ],
            ),
          ),
          SkeletonLine(width: 60, height: 12),
        ],
      ),
    );
  }
}
