import 'package:flutter/material.dart';

import '../models/sync_profile.dart';
import '../theme/color_schemes.dart';

enum SyncStatus { idle, syncing, success, error, warning }

class StatusIndicator extends StatefulWidget {
  const StatusIndicator({
    super.key,
    required this.status,
    this.size = 12,
  });

  final SyncStatus status;
  final double size;

  static SyncStatus fromProfile(SyncProfile profile) {
    if (profile.lastSyncStatus == 'running') return SyncStatus.syncing;
    if (profile.lastSyncStatus == 'error') return SyncStatus.error;
    if (profile.lastSyncStatus == 'success') return SyncStatus.success;
    return SyncStatus.idle;
  }

  static Color colorForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return AppColors.idle;
      case SyncStatus.syncing:
        return AppColors.syncing;
      case SyncStatus.success:
        return AppColors.success;
      case SyncStatus.error:
        return AppColors.error;
      case SyncStatus.warning:
        return AppColors.warning;
    }
  }

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.status == SyncStatus.syncing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == SyncStatus.syncing) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = StatusIndicator.colorForStatus(widget.status);

    if (widget.status == SyncStatus.syncing) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return _buildDot(color.withValues(alpha: _animation.value));
        },
      );
    }

    return _buildDot(color);
  }

  Widget _buildDot(Color color) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
