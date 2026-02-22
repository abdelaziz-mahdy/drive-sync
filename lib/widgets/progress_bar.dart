import 'package:flutter/material.dart';

import '../theme/color_schemes.dart';

class SyncProgressBar extends StatelessWidget {
  const SyncProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.color,
  });

  /// Progress value from 0.0 to 1.0.
  final double progress;

  /// Optional label displayed below the bar, e.g. "65% - 2.3 MB/s".
  final String? label;

  /// Override color for the progress indicator.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.primary;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: LinearProgressIndicator(
                value: clampedProgress,
                backgroundColor: effectiveColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ],
    );
  }
}
