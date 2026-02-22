import 'package:flutter/material.dart';

/// Section for configuring gitignore and common directory exclusions.
class GitExcludesSection extends StatefulWidget {
  const GitExcludesSection({
    super.key,
    required this.respectGitignore,
    required this.excludeGitDirs,
    required this.customExcludes,
    required this.onRespectGitignoreChanged,
    required this.onExcludeGitDirsChanged,
    required this.onCustomExcludesChanged,
  });

  final bool respectGitignore;
  final bool excludeGitDirs;
  final List<String> customExcludes;
  final ValueChanged<bool> onRespectGitignoreChanged;
  final ValueChanged<bool> onExcludeGitDirsChanged;
  final ValueChanged<List<String>> onCustomExcludesChanged;

  @override
  State<GitExcludesSection> createState() => _GitExcludesSectionState();
}

class _GitExcludesSectionState extends State<GitExcludesSection> {
  final _controller = TextEditingController();

  static const _quickExcludes = <String, String>{
    'node_modules': 'node_modules/**',
    '.venv': '.venv/**',
    'build/dist': '{build,dist}/**',
    '.DS_Store': '.DS_Store',
    '.idea/.vscode': '{.idea,.vscode}/**',
  };

  void _addPattern(String pattern) {
    final cleaned = pattern.trim();
    if (cleaned.isEmpty) return;
    if (widget.customExcludes.contains(cleaned)) return;
    widget.onCustomExcludesChanged([...widget.customExcludes, cleaned]);
    _controller.clear();
  }

  void _removePattern(String pattern) {
    widget.onCustomExcludesChanged(
      widget.customExcludes.where((e) => e != pattern).toList(),
    );
  }

  void _toggleQuickExclude(String pattern, bool add) {
    if (add) {
      if (!widget.customExcludes.contains(pattern)) {
        widget.onCustomExcludesChanged([...widget.customExcludes, pattern]);
      }
    } else {
      _removePattern(pattern);
    }
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
        // Git checkboxes
        CheckboxListTile(
          title: const Text('Respect .gitignore files'),
          value: widget.respectGitignore,
          onChanged: (v) => widget.onRespectGitignoreChanged(v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Exclude .git directories'),
          value: widget.excludeGitDirs,
          onChanged: (v) => widget.onExcludeGitDirsChanged(v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 8),
        Text('Quick Excludes', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),

        // Quick exclude checkboxes
        ..._quickExcludes.entries.map((entry) {
          final isChecked = widget.customExcludes.contains(entry.value);
          return CheckboxListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            value: isChecked,
            onChanged: (v) => _toggleQuickExclude(entry.value, v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),

        const SizedBox(height: 12),
        Text('Custom Exclude Patterns', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),

        // Custom pattern input
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Add exclude pattern (e.g., *.log)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addPattern(_controller.text),
            ),
          ),
          onSubmitted: _addPattern,
        ),
        const SizedBox(height: 8),

        // Custom pattern chips
        if (widget.customExcludes
            .where((e) => !_quickExcludes.containsValue(e))
            .isEmpty)
          Text(
            'No custom exclude patterns',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.customExcludes
                .where((e) => !_quickExcludes.containsValue(e))
                .map((pattern) {
              return Chip(
                label: Text(pattern),
                onDeleted: () => _removePattern(pattern),
                deleteIcon: const Icon(Icons.close, size: 16),
              );
            }).toList(),
          ),
      ],
    );
  }
}
