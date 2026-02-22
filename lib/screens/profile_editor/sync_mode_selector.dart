import 'package:flutter/material.dart';

import '../../models/sync_mode.dart';
import '../../theme/color_schemes.dart';
import '../../widgets/sync_mode_icon.dart';

/// Radio card selector for choosing a SyncMode.
class SyncModeSelector extends StatelessWidget {
  const SyncModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final SyncMode selected;
  final ValueChanged<SyncMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: SyncMode.values.map((mode) {
        final isSelected = mode == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _SyncModeCard(
            mode: mode,
            isSelected: isSelected,
            onTap: () => onChanged(mode),
          ),
        );
      }).toList(),
    );
  }
}

class _SyncModeCard extends StatelessWidget {
  const _SyncModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final SyncMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : theme.cardTheme.color,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Radio<SyncMode>(
                value: mode,
                groupValue: isSelected ? mode : null,
                onChanged: (_) => onTap(),
              ),
              SyncModeIcon(mode: mode, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          mode.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mode.direction,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (mode == SyncMode.mirror) ...[
                          const SizedBox(width: 8),
                          _WarningBadge(
                            label: 'Deletes local files not on cloud',
                          ),
                        ],
                        if (mode == SyncMode.bisync) ...[
                          const SizedBox(width: 8),
                          _WarningBadge(label: 'Experimental'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningBadge extends StatelessWidget {
  const _WarningBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
