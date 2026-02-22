import 'package:flutter/material.dart';

/// Widget for managing include/exclude file type extensions as chips.
class FileTypeChips extends StatefulWidget {
  const FileTypeChips({
    super.key,
    required this.useIncludeMode,
    required this.onIncludeModeChanged,
    required this.includeTypes,
    required this.excludeTypes,
    required this.onIncludeTypesChanged,
    required this.onExcludeTypesChanged,
  });

  final bool useIncludeMode;
  final ValueChanged<bool> onIncludeModeChanged;
  final List<String> includeTypes;
  final List<String> excludeTypes;
  final ValueChanged<List<String>> onIncludeTypesChanged;
  final ValueChanged<List<String>> onExcludeTypesChanged;

  @override
  State<FileTypeChips> createState() => _FileTypeChipsState();
}

class _FileTypeChipsState extends State<FileTypeChips> {
  final _controller = TextEditingController();

  static const _presets = <String, List<String>>{
    'Documents': ['pdf', 'docx', 'xlsx', 'pptx'],
    'Code': ['py', 'js', 'ts', 'dart', 'go', 'rs'],
    'Images': ['jpg', 'png', 'gif', 'svg', 'webp'],
  };

  List<String> get _activeTypes =>
      widget.useIncludeMode ? widget.includeTypes : widget.excludeTypes;

  void _onActiveTypesChanged(List<String> types) {
    if (widget.useIncludeMode) {
      widget.onIncludeTypesChanged(types);
    } else {
      widget.onExcludeTypesChanged(types);
    }
  }

  void _addExtension(String ext) {
    final cleaned = ext.trim().toLowerCase().replaceAll('.', '');
    if (cleaned.isEmpty) return;
    if (_activeTypes.contains(cleaned)) return;
    _onActiveTypesChanged([..._activeTypes, cleaned]);
    _controller.clear();
  }

  void _removeExtension(String ext) {
    _onActiveTypesChanged(
      _activeTypes.where((e) => e != ext).toList(),
    );
  }

  void _applyPreset(String presetName) {
    final preset = _presets[presetName]!;
    final merged = {..._activeTypes, ...preset}.toList();
    _onActiveTypesChanged(merged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Include / Exclude toggle
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Include')),
            ButtonSegment(value: false, label: Text('Exclude')),
          ],
          selected: {widget.useIncludeMode},
          onSelectionChanged: (sel) => widget.onIncludeModeChanged(sel.first),
        ),
        const SizedBox(height: 12),

        // Preset buttons
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _presets.keys.map((name) {
            return OutlinedButton(
              onPressed: () => _applyPreset(name),
              child: Text(name),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Text field + enter to add
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Add extension (e.g., pdf)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addExtension(_controller.text),
            ),
          ),
          onSubmitted: _addExtension,
        ),
        const SizedBox(height: 12),

        // Chips
        if (_activeTypes.isEmpty)
          Text(
            widget.useIncludeMode
                ? 'No include filters (all files synced)'
                : 'No exclude filters (all files synced)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _activeTypes.map((ext) {
              return Chip(
                label: Text('.$ext'),
                onDeleted: () => _removeExtension(ext),
                deleteIcon: const Icon(Icons.close, size: 16),
              );
            }).toList(),
          ),
      ],
    );
  }
}
