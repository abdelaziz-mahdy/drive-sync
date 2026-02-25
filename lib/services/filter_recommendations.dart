import 'package:flutter/material.dart';

/// A single filter recommendation generated from detected file patterns.
class FilterRecommendation {
  final IconData icon;
  final String label;
  final String description;

  /// The exclude patterns this recommendation would add to customExcludes.
  final List<String> excludePatterns;

  /// Whether this recommendation toggles excludeGitDirs instead.
  final bool setsExcludeGitDirs;

  /// Whether this recommendation toggles respectGitignore instead.
  final bool setsRespectGitignore;

  const FilterRecommendation({
    required this.icon,
    required this.label,
    required this.description,
    this.excludePatterns = const [],
    this.setsExcludeGitDirs = false,
    this.setsRespectGitignore = false,
  });
}

/// Definition for a directory/file pattern that should trigger a recommendation.
class _PatternDef {
  final String id;
  final IconData icon;
  final String label;
  final String description;
  final List<String> excludePatterns;
  final bool Function(String path, String name, bool isDir) matches;

  /// Returns true if the current config already covers this recommendation.
  final bool Function(List<String> customExcludes) isAlreadyApplied;

  const _PatternDef({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    required this.excludePatterns,
    required this.matches,
    required this.isAlreadyApplied,
  });
}

/// Generates filter recommendations based on detected file/directory patterns.
///
/// This is a pure-logic class with no Flutter widget dependencies (beyond
/// IconData), making it fully unit-testable.
class FilterRecommendationService {
  FilterRecommendationService._();

  /// All known directory/file patterns that warrant exclusion.
  static final List<_PatternDef> _patterns = [
    // ── Version Control ──────────────────────────────────────────────────
    _PatternDef(
      id: 'gitignore',
      icon: Icons.description,
      label: 'Use .gitignore',
      description: '.gitignore found – apply its rules',
      excludePatterns: [],
      matches: (path, name, isDir) =>
          name == '.gitignore' || path.endsWith('.gitignore'),
      isAlreadyApplied: (_) => false, // handled by respectGitignore flag
    ),

    // ── JavaScript / Node ────────────────────────────────────────────────
    _PatternDef(
      id: 'node_modules',
      icon: Icons.folder_delete,
      label: 'Exclude node_modules',
      description: 'Node.js dependency directory',
      excludePatterns: ['**/node_modules/**'],
      matches: (path, name, isDir) =>
          _isDirNamed(path, name, isDir, 'node_modules'),
      isAlreadyApplied: (exc) => _anyContains(exc, 'node_modules'),
    ),
    _PatternDef(
      id: 'bower_components',
      icon: Icons.folder_delete,
      label: 'Exclude bower_components',
      description: 'Bower dependency directory',
      excludePatterns: ['**/bower_components/**'],
      matches: (path, name, isDir) =>
          _isDirNamed(path, name, isDir, 'bower_components'),
      isAlreadyApplied: (exc) => _anyContains(exc, 'bower_components'),
    ),

    // ── Flutter / Dart ───────────────────────────────────────────────────
    _PatternDef(
      id: 'dart_tool',
      icon: Icons.build,
      label: 'Exclude .dart_tool',
      description: 'Dart internal tool cache',
      excludePatterns: ['**/.dart_tool/**'],
      matches: (path, name, isDir) =>
          _isDirNamed(path, name, isDir, '.dart_tool'),
      isAlreadyApplied: (exc) => _anyContains(exc, '.dart_tool'),
    ),
    _PatternDef(
      id: 'flutter_build',
      icon: Icons.construction,
      label: 'Exclude build/',
      description: 'Flutter / Gradle build output',
      excludePatterns: ['**/build/**'],
      matches: (path, name, isDir) => _isDirNamed(path, name, isDir, 'build'),
      isAlreadyApplied: (exc) => _anyContains(exc, 'build'),
    ),

    // ── Python ───────────────────────────────────────────────────────────
    _PatternDef(
      id: 'pycache',
      icon: Icons.cached,
      label: 'Exclude __pycache__',
      description: 'Python bytecode cache',
      excludePatterns: ['**/__pycache__/**'],
      matches: (path, name, isDir) =>
          _isDirNamed(path, name, isDir, '__pycache__'),
      isAlreadyApplied: (exc) => _anyContains(exc, '__pycache__'),
    ),
    _PatternDef(
      id: 'python_venv',
      icon: Icons.folder_delete,
      label: 'Exclude virtualenv',
      description: 'Python virtual environment',
      excludePatterns: ['**/venv/**', '**/.venv/**', '**/env/**', '**/.env/**'],
      matches: (path, name, isDir) =>
          _isDirNamed(path, name, isDir, 'venv') ||
          _isDirNamed(path, name, isDir, '.venv') ||
          _isDirNamed(path, name, isDir, 'env') ||
          _isDirNamed(path, name, isDir, '.env'),
      isAlreadyApplied: (exc) =>
          _anyContains(exc, 'venv') || _anyContains(exc, '.venv'),
    ),
    _PatternDef(
      id: 'egg_info',
      icon: Icons.folder_delete,
      label: 'Exclude .egg-info',
      description: 'Python package metadata',
      excludePatterns: ['**/*.egg-info/**'],
      matches: (path, name, isDir) =>
          name.endsWith('.egg-info') || path.contains('.egg-info/'),
      isAlreadyApplied: (exc) => _anyContains(exc, '.egg-info'),
    ),
    _PatternDef(
      id: 'python_dist',
      icon: Icons.folder_delete,
      label: 'Exclude dist/',
      description: 'Python distribution output',
      excludePatterns: ['**/dist/**'],
      matches: (path, name, isDir) => _isDirNamed(path, name, isDir, 'dist'),
      isAlreadyApplied: (exc) => _anyContains(exc, 'dist'),
    ),

    // ── Rust ─────────────────────────────────────────────────────────────
    _PatternDef(
      id: 'rust_target',
      icon: Icons.construction,
      label: 'Exclude target/',
      description: 'Rust / Cargo build output',
      excludePatterns: ['**/target/**'],
      matches: (path, name, isDir) => _isDirNamed(path, name, isDir, 'target'),
      isAlreadyApplied: (exc) => _anyContains(exc, 'target'),
    ),

    // ── Go ───────────────────────────────────────────────────────────────
    _PatternDef(
      id: 'go_vendor',
      icon: Icons.folder_delete,
      label: 'Exclude vendor/',
      description: 'Go vendored dependencies',
      excludePatterns: ['**/vendor/**'],
      matches: (path, name, isDir) => _isDirNamed(path, name, isDir, 'vendor'),
      isAlreadyApplied: (exc) => _anyContains(exc, 'vendor'),
    ),

    // ── .NET / C# ────────────────────────────────────────────────────────
    _PatternDef(
      id: 'dotnet_bin_obj',
      icon: Icons.construction,
      label: 'Exclude bin/ & obj/',
      description: '.NET build output',
      excludePatterns: ['**/bin/**', '**/obj/**'],
      matches: (path, name, isDir) =>
          _isDirNamed(path, name, isDir, 'bin') ||
          _isDirNamed(path, name, isDir, 'obj'),
      isAlreadyApplied: (exc) =>
          _anyContains(exc, 'bin') && _anyContains(exc, 'obj'),
    ),

    // ── IDE / Editor configs ─────────────────────────────────────────────
    _PatternDef(
      id: 'idea',
      icon: Icons.settings,
      label: 'Exclude .idea/',
      description: 'JetBrains IDE config',
      excludePatterns: ['**/.idea/**'],
      matches: (path, name, isDir) => _isDirNamed(path, name, isDir, '.idea'),
      isAlreadyApplied: (exc) => _anyContains(exc, '.idea'),
    ),
    _PatternDef(
      id: 'vscode',
      icon: Icons.settings,
      label: 'Exclude .vscode/',
      description: 'VS Code config',
      excludePatterns: ['**/.vscode/**'],
      matches: (path, name, isDir) => _isDirNamed(path, name, isDir, '.vscode'),
      isAlreadyApplied: (exc) => _anyContains(exc, '.vscode'),
    ),

    // ── OS metadata ──────────────────────────────────────────────────────
    _PatternDef(
      id: 'ds_store',
      icon: Icons.hide_source,
      label: 'Exclude .DS_Store',
      description: 'macOS metadata files',
      excludePatterns: ['.DS_Store'],
      matches: (path, name, isDir) => name == '.DS_Store',
      isAlreadyApplied: (exc) => _anyContains(exc, '.DS_Store'),
    ),
    _PatternDef(
      id: 'thumbs_db',
      icon: Icons.hide_source,
      label: 'Exclude Thumbs.db',
      description: 'Windows thumbnail cache',
      excludePatterns: ['Thumbs.db'],
      matches: (path, name, isDir) => name == 'Thumbs.db',
      isAlreadyApplied: (exc) => _anyContains(exc, 'Thumbs.db'),
    ),

    // ── Generic caches ───────────────────────────────────────────────────
    _PatternDef(
      id: 'cache_dir',
      icon: Icons.cached,
      label: 'Exclude .cache/',
      description: 'Generic cache directory',
      excludePatterns: ['**/.cache/**'],
      matches: (path, name, isDir) => _isDirNamed(path, name, isDir, '.cache'),
      isAlreadyApplied: (exc) => _anyContains(exc, '.cache'),
    ),

    // ── Coverage / test output ───────────────────────────────────────────
    _PatternDef(
      id: 'coverage',
      icon: Icons.assessment,
      label: 'Exclude coverage/',
      description: 'Code coverage output',
      excludePatterns: ['**/coverage/**'],
      matches: (path, name, isDir) =>
          _isDirNamed(path, name, isDir, 'coverage'),
      isAlreadyApplied: (exc) => _anyContains(exc, 'coverage'),
    ),
  ];

  /// Expensive phase: scan all files to detect which patterns are present.
  ///
  /// This is O(n × patterns) and should be run in a background isolate or
  /// cached. Returns a set of pattern IDs that were detected.
  static Set<String> detectPatterns(
      List<({String path, String name, bool isDir})> filePaths) {
    final matchedIds = <String>{};
    final patternCount = _patterns.length;
    var remainingPatterns = patternCount;

    for (final file in filePaths) {
      if (remainingPatterns == 0) break; // All patterns matched; stop early.
      for (final pattern in _patterns) {
        if (matchedIds.contains(pattern.id)) continue;
        if (pattern.matches(file.path, file.name, file.isDir)) {
          matchedIds.add(pattern.id);
          remainingPatterns--;
        }
      }
    }

    // Also check for .git dirs (uses dedicated excludeGitDirs flag).
    for (final f in filePaths) {
      if (f.name == '.git' ||
          f.path == '.git' ||
          f.path.startsWith('.git/') ||
          f.path.contains('/.git/') ||
          f.path.contains('/.git')) {
        matchedIds.add('git_dir');
        break;
      }
    }

    return matchedIds;
  }

  /// Cheap phase: build recommendations from pre-detected pattern IDs.
  ///
  /// This is O(patterns) and safe to call on every widget build.
  static List<FilterRecommendation> generateFromDetected({
    required Set<String> matchedPatternIds,
    required List<String> customExcludes,
    required bool excludeGitDirs,
    required bool respectGitignore,
  }) {
    final recommendations = <FilterRecommendation>[];
    for (final pattern in _patterns) {
      if (!matchedPatternIds.contains(pattern.id)) continue;

      // Special handling for .gitignore (uses dedicated flag).
      if (pattern.id == 'gitignore') {
        if (!respectGitignore) {
          recommendations.add(FilterRecommendation(
            icon: pattern.icon,
            label: pattern.label,
            description: pattern.description,
            setsRespectGitignore: true,
          ));
        }
        continue;
      }

      if (pattern.isAlreadyApplied(customExcludes)) continue;

      recommendations.add(FilterRecommendation(
        icon: pattern.icon,
        label: pattern.label,
        description: pattern.description,
        excludePatterns: pattern.excludePatterns,
      ));
    }

    // .git dir recommendation (uses dedicated excludeGitDirs flag).
    if (matchedPatternIds.contains('git_dir') && !excludeGitDirs) {
      recommendations.insert(
        0,
        const FilterRecommendation(
          icon: Icons.source,
          label: 'Exclude .git',
          description: '.git directories detected',
          setsExcludeGitDirs: true,
        ),
      );
    }

    return recommendations;
  }

  /// Convenience method that combines both phases.
  ///
  /// Use [detectPatterns] + [generateFromDetected] separately when you want
  /// to cache the expensive detection and only re-run the cheap generation.
  static List<FilterRecommendation> generate({
    required List<({String path, String name, bool isDir})> filePaths,
    required List<String> customExcludes,
    required bool excludeGitDirs,
    required bool respectGitignore,
  }) {
    final matchedIds = detectPatterns(filePaths);
    return generateFromDetected(
      matchedPatternIds: matchedIds,
      customExcludes: customExcludes,
      excludeGitDirs: excludeGitDirs,
      respectGitignore: respectGitignore,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns true if the given file entry represents a directory (or a path
  /// inside a directory) whose base name matches [dirName].
  static bool _isDirNamed(
      String path, String name, bool isDir, String dirName) {
    if (isDir && name == dirName) return true;
    if (path == dirName) return true;
    if (path.startsWith('$dirName/')) return true;
    if (path.contains('/$dirName/')) return true;
    if (path.endsWith('/$dirName')) return true;
    return false;
  }

  /// Returns true if any pattern in [excludes] contains [needle].
  static bool _anyContains(List<String> excludes, String needle) {
    return excludes.any((p) => p.contains(needle));
  }
}
