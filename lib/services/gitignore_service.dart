import 'dart:io';

class GitignoreService {
  /// Scan a directory tree for .gitignore files and produce rclone filter rules.
  Future<List<String>> generateRcloneFilters(String rootPath) async {
    final rules = <String>[];
    final root = Directory(rootPath);

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.gitignore')) {
        final relativeDir = _relativePath(rootPath, entity.parent.path);
        final gitignoreRules = await _parseGitignore(entity);

        for (final rule in gitignoreRules) {
          final rcloneRule = convertRule(rule, relativeDir);
          if (rcloneRule != null) rules.add(rcloneRule);
        }
      }
    }
    return rules;
  }

  /// Parse a .gitignore file, returning non-empty, non-comment lines.
  Future<List<String>> _parseGitignore(File file) async {
    final lines = await file.readAsLines();
    return lines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();
  }

  /// Convert a single .gitignore rule to an rclone filter rule.
  /// Returns null for comments and blank lines.
  ///
  /// Conversion rules:
  /// - `*.pyc` -> `- *.pyc` (exclude glob)
  /// - `node_modules/` -> `- node_modules/**` (directory pattern)
  /// - `!important.pyc` -> `+ important.pyc` (negation = include)
  /// - `/dist` -> `- /dist/**` (root-anchored, scoped to dir)
  /// - In subdirectory: `/dist` with scopeDir='backend' -> `- /backend/dist/**`
  /// - `# comment` -> null (skip)
  /// - blank -> null (skip)
  String? convertRule(String gitRule, String scopeDir) {
    var rule = gitRule.trim();
    if (rule.isEmpty || rule.startsWith('#')) return null;

    var prefix = '-'; // exclude by default

    // Handle negation
    if (rule.startsWith('!')) {
      prefix = '+';
      rule = rule.substring(1);
    }

    // Handle directory-only patterns (trailing slash)
    final dirOnly = rule.endsWith('/');
    if (dirOnly) rule = rule.substring(0, rule.length - 1);

    // Scope to the directory containing this .gitignore
    String scopedRule;
    if (rule.startsWith('/')) {
      // Root-anchored: scope to directory
      scopedRule = scopeDir.isEmpty ? rule : '/$scopeDir$rule';
    } else {
      // Unanchored: apply globally
      scopedRule = rule;
    }

    // Directory patterns get /** suffix
    if (dirOnly) {
      scopedRule = '$scopedRule/**';
    }
    // Root-anchored non-glob non-directory patterns also get /** (they reference dirs)
    else if (rule.startsWith('/') &&
        !rule.contains('*') &&
        !rule.contains('?')) {
      scopedRule = '$scopedRule/**';
    }

    return '$prefix $scopedRule';
  }

  /// Get relative path from root to dir.
  String _relativePath(String rootPath, String dirPath) {
    if (rootPath == dirPath) return '';
    final root = rootPath.endsWith('/') ? rootPath : '$rootPath/';
    if (dirPath.startsWith(root)) return dirPath.substring(root.length);
    return '';
  }

  /// Write filter rules to a file for rclone --filter-from.
  Future<String> writeFilterFile(
    String profileId,
    List<String> rules,
    String filterDir,
  ) async {
    final dir = Directory(filterDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File('$filterDir/$profileId.rules');
    await file.writeAsString(rules.join('\n'));
    return file.path;
  }

  /// Common quick-exclude patterns that users can toggle.
  static const Map<String, List<String>> quickExcludes = {
    '.git directories': ['.git/**'],
    'node_modules': ['node_modules/**'],
    'Python virtualenvs': ['.venv/**', 'venv/**'],
    'Build artifacts': ['build/**', 'dist/**'],
    'macOS system files': ['.DS_Store', '._*'],
    'IDE configs': ['.idea/**', '.vscode/**'],
  };
}
