import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/rclone_provider.dart';

/// Modal dialog for browsing folders on an rclone remote.
///
/// Returns the selected folder path as a String, or null if cancelled.
Future<String?> showCloudFolderBrowser(
  BuildContext context, {
  required String remoteName,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => CloudFolderBrowser(remoteName: remoteName),
  );
}

class CloudFolderBrowser extends ConsumerStatefulWidget {
  const CloudFolderBrowser({super.key, required this.remoteName});

  final String remoteName;

  @override
  ConsumerState<CloudFolderBrowser> createState() => _CloudFolderBrowserState();
}

class _CloudFolderBrowserState extends ConsumerState<CloudFolderBrowser> {
  /// Current path segments, e.g. ['Documents', 'Work']
  final List<String> _pathSegments = [];

  /// Cache: path string -> list of folder entries
  final Map<String, List<_FolderEntry>> _cache = {};

  /// Currently loading path
  String? _loadingPath;

  /// Error message if any
  String? _error;

  /// Expanded folders (for tree-like UI at current level)
  final Set<String> _expanded = {};

  String get _currentPath => _pathSegments.join('/');

  @override
  void initState() {
    super.initState();
    _loadFolders('');
  }

  Future<void> _loadFolders(String path) async {
    if (_cache.containsKey(path)) return;

    setState(() {
      _loadingPath = path;
      _error = null;
    });

    try {
      final service = ref.read(rcloneServiceProvider);
      final results = await service.listFolders(widget.remoteName, path);
      final entries = results
          .where((e) => e['IsDir'] == true)
          .map((e) => _FolderEntry(
                name: e['Name'] as String? ?? '',
                path: e['Path'] as String? ?? '',
              ))
          .toList();

      if (mounted) {
        setState(() {
          _cache[path] = entries;
          _loadingPath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load folders: $e';
          _loadingPath = null;
        });
      }
    }
  }

  void _navigateTo(int segmentIndex) {
    setState(() {
      _pathSegments.removeRange(segmentIndex, _pathSegments.length);
      _expanded.clear();
    });
    _loadFolders(_currentPath);
  }

  void _openFolder(String folderName) {
    setState(() {
      _pathSegments.add(folderName);
      _expanded.clear();
    });
    _loadFolders(_currentPath);
  }

  void _toggleExpand(String folderPath) {
    setState(() {
      if (_expanded.contains(folderPath)) {
        _expanded.remove(folderPath);
      } else {
        _expanded.add(folderPath);
        _loadFolders(folderPath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folders = _cache[_currentPath] ?? [];
    final isLoading = _loadingPath == _currentPath;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Browse ${widget.remoteName}',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              // Breadcrumb
              _buildBreadcrumb(theme),
              const Divider(),

              // Folder list
              Expanded(
                child: _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                color: theme.colorScheme.error, size: 48),
                            const SizedBox(height: 8),
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: theme.colorScheme.error)),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _loadFolders(_currentPath),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : folders.isEmpty
                            ? Center(
                                child: Text(
                                  'No subfolders',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: folders.length,
                                itemBuilder: (_, i) {
                                  final folder = folders[i];
                                  return _buildFolderTile(folder, theme);
                                },
                              ),
              ),

              const Divider(),

              // Current selection display
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Selected: /${_currentPath.isEmpty ? '' : _currentPath}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_currentPath),
                    child: const Text('Select'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(
            onTap: () => _navigateTo(0),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud, size: 16),
                  const SizedBox(width: 4),
                  Text(widget.remoteName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          for (int i = 0; i < _pathSegments.length; i++) ...[
            const Icon(Icons.chevron_right, size: 16),
            InkWell(
              onTap: () => _navigateTo(i + 1),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  _pathSegments[i],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: i == _pathSegments.length - 1
                        ? FontWeight.w600
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFolderTile(_FolderEntry folder, ThemeData theme) {
    final fullPath =
        _currentPath.isEmpty ? folder.name : '$_currentPath/${folder.name}';
    final isExpanded = _expanded.contains(fullPath);
    final subFolders = _cache[fullPath];
    final isSubLoading = _loadingPath == fullPath;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(folder.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(isExpanded
                    ? Icons.expand_less
                    : Icons.expand_more),
                onPressed: () => _toggleExpand(fullPath),
                tooltip: 'Preview subfolders',
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _openFolder(folder.name),
                tooltip: 'Open folder',
              ),
            ],
          ),
          dense: true,
        ),
        if (isExpanded) ...[
          if (isSubLoading)
            const Padding(
              padding: EdgeInsets.only(left: 48, top: 4, bottom: 4),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (subFolders != null && subFolders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 4, bottom: 4),
              child: Text(
                'No subfolders',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else if (subFolders != null)
            ...subFolders.map((sub) => Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: ListTile(
                    leading: const Icon(Icons.folder_outlined, size: 20),
                    title: Text(sub.name,
                        style: theme.textTheme.bodyMedium),
                    onTap: () {
                      _openFolder(folder.name);
                      // After navigating into parent, the subfolder loads
                    },
                    dense: true,
                  ),
                )),
        ],
      ],
    );
  }
}

class _FolderEntry {
  final String name;
  final String path;

  const _FolderEntry({required this.name, required this.path});
}
