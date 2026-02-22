import 'package:flutter/material.dart';

import '../models/sync_mode.dart';

class SyncModeIcon extends StatelessWidget {
  const SyncModeIcon({
    super.key,
    required this.mode,
    this.size = 24,
    this.color,
  });

  final SyncMode mode;
  final double size;
  final Color? color;

  static IconData iconForMode(SyncMode mode) {
    switch (mode) {
      case SyncMode.backup:
        return Icons.cloud_upload_outlined;
      case SyncMode.mirror:
        return Icons.sync;
      case SyncMode.download:
        return Icons.cloud_download_outlined;
      case SyncMode.bisync:
        return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconForMode(mode),
      size: size,
      color: color,
    );
  }
}
