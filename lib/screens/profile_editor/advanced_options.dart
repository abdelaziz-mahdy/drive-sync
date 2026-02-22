import 'package:flutter/material.dart';

/// Widget for configuring advanced sync options: bandwidth, transfers, check-first.
class AdvancedOptions extends StatelessWidget {
  const AdvancedOptions({
    super.key,
    required this.bandwidthLimit,
    required this.maxTransfers,
    required this.checkFirst,
    required this.onBandwidthLimitChanged,
    required this.onMaxTransfersChanged,
    required this.onCheckFirstChanged,
  });

  final String? bandwidthLimit;
  final int maxTransfers;
  final bool checkFirst;
  final ValueChanged<String?> onBandwidthLimitChanged;
  final ValueChanged<int> onMaxTransfersChanged;
  final ValueChanged<bool> onCheckFirstChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bandwidth limit
        TextField(
          decoration: const InputDecoration(
            labelText: 'Bandwidth Limit',
            hintText: 'e.g., 1M, 500K, off',
          ),
          controller: TextEditingController(text: bandwidthLimit ?? ''),
          onChanged: (v) =>
              onBandwidthLimitChanged(v.trim().isEmpty ? null : v.trim()),
        ),
        const SizedBox(height: 16),

        // Max transfers slider
        Text('Max Transfers: $maxTransfers', style: theme.textTheme.titleSmall),
        Slider(
          value: maxTransfers.toDouble(),
          min: 1,
          max: 32,
          divisions: 31,
          label: maxTransfers.toString(),
          onChanged: (v) => onMaxTransfersChanged(v.round()),
        ),
        const SizedBox(height: 8),

        // Check-first toggle
        SwitchListTile(
          title: const Text('Check First'),
          subtitle: const Text('Compare all files before transferring'),
          value: checkFirst,
          onChanged: (v) => onCheckFirstChanged(v),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
