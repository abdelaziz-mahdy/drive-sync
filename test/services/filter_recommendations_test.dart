import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/services/filter_recommendations.dart';

/// Helper to create a file entry tuple.
({String path, String name, bool isDir}) _f(String path,
    {bool isDir = false}) {
  final name = path.contains('/') ? path.split('/').last : path;
  return (path: path, name: name, isDir: isDir);
}

void main() {
  group('FilterRecommendationService', () {
    // ── .git ────────────────────────────────────────────────────────────

    group('.git detection', () {
      test('recommends excluding .git when .git directory is present', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('.git', isDir: true), _f('README.md')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(
            recs.any((r) => r.label == 'Exclude .git' && r.setsExcludeGitDirs),
            isTrue);
      });

      test('detects nested .git dirs', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('submodule/.git/config')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.setsExcludeGitDirs), isTrue);
      });

      test('does NOT recommend .git when already excluded', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('.git', isDir: true)],
          customExcludes: [],
          excludeGitDirs: true,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.setsExcludeGitDirs), isFalse);
      });
    });

    // ── .gitignore ──────────────────────────────────────────────────────

    group('.gitignore detection', () {
      test('recommends using .gitignore when present', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('.gitignore')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.setsRespectGitignore), isTrue);
      });

      test('detects nested .gitignore', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('packages/core/.gitignore')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.setsRespectGitignore), isTrue);
      });

      test('does NOT recommend when respectGitignore is already true', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('.gitignore')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: true,
        );
        expect(recs.any((r) => r.setsRespectGitignore), isFalse);
      });
    });

    // ── Node.js ─────────────────────────────────────────────────────────

    group('node_modules detection', () {
      test('recommends excluding node_modules directory', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('node_modules', isDir: true),
            _f('node_modules/express/package.json'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude node_modules');
        expect(rec.excludePatterns, contains('**/node_modules/**'));
      });

      test('detects nested node_modules', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('packages/app/node_modules/lodash/index.js')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude node_modules'), isTrue);
      });

      test('does NOT recommend when already excluded', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('node_modules', isDir: true)],
          customExcludes: ['**/node_modules/**'],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude node_modules'), isFalse);
      });
    });

    // ── Flutter / Dart ──────────────────────────────────────────────────

    group('Flutter/Dart detection', () {
      test('recommends excluding build/ directory', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('build', isDir: true),
            _f('build/app/outputs/flutter-apk/app.apk'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude build/');
        expect(rec.excludePatterns, contains('**/build/**'));
      });

      test('detects nested build/ directories', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('packages/core/build/generated/source.dart')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude build/'), isTrue);
      });

      test('recommends excluding .dart_tool/ directory', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('.dart_tool', isDir: true),
            _f('.dart_tool/package_config.json'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude .dart_tool');
        expect(rec.excludePatterns, contains('**/.dart_tool/**'));
      });

      test('detects nested .dart_tool', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('packages/core/.dart_tool/package_config.json')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude .dart_tool'), isTrue);
      });

      test('does NOT recommend build/ when already excluded', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('build', isDir: true)],
          customExcludes: ['**/build/**'],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude build/'), isFalse);
      });
    });

    // ── Python ──────────────────────────────────────────────────────────

    group('Python detection', () {
      test('recommends excluding __pycache__', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('__pycache__', isDir: true),
            _f('__pycache__/module.cpython-311.pyc'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude __pycache__');
        expect(rec.excludePatterns, contains('**/__pycache__/**'));
      });

      test('detects nested __pycache__', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('src/utils/__pycache__/helper.cpython-311.pyc')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude __pycache__'), isTrue);
      });

      test('recommends excluding virtualenv directories', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('venv', isDir: true),
            _f('venv/lib/python3.11/site-packages/pip/__init__.py'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude virtualenv');
        expect(rec.excludePatterns, containsAll(['**/venv/**', '**/.venv/**']));
      });

      test('detects .venv directory', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('.venv', isDir: true)],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude virtualenv'), isTrue);
      });

      test('detects env directory', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('env/lib/python3.11/site-packages/pip/__init__.py')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude virtualenv'), isTrue);
      });

      test('recommends excluding .egg-info', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('mypackage.egg-info/PKG-INFO')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude .egg-info'), isTrue);
      });

      test('recommends excluding dist/', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('dist', isDir: true)],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude dist/');
        expect(rec.excludePatterns, contains('**/dist/**'));
      });

      test('does NOT recommend virtualenv when already excluded', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('venv', isDir: true)],
          customExcludes: ['**/venv/**'],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude virtualenv'), isFalse);
      });
    });

    // ── Rust ────────────────────────────────────────────────────────────

    group('Rust detection', () {
      test('recommends excluding target/ for Rust projects', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('target', isDir: true),
            _f('target/debug/myapp'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude target/');
        expect(rec.excludePatterns, contains('**/target/**'));
      });
    });

    // ── Go ──────────────────────────────────────────────────────────────

    group('Go detection', () {
      test('recommends excluding vendor/ for Go projects', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('vendor', isDir: true),
            _f('vendor/github.com/some/package/main.go'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude vendor/');
        expect(rec.excludePatterns, contains('**/vendor/**'));
      });
    });

    // ── .NET ────────────────────────────────────────────────────────────

    group('.NET detection', () {
      test('recommends excluding bin/ and obj/', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('bin', isDir: true),
            _f('obj', isDir: true),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude bin/ & obj/');
        expect(rec.excludePatterns, containsAll(['**/bin/**', '**/obj/**']));
      });

      test('does NOT recommend when both already excluded', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('bin', isDir: true), _f('obj', isDir: true)],
          customExcludes: ['**/bin/**', '**/obj/**'],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude bin/ & obj/'), isFalse);
      });
    });

    // ── IDE configs ─────────────────────────────────────────────────────

    group('IDE config detection', () {
      test('recommends excluding .idea/ for JetBrains IDEs', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('.idea', isDir: true),
            _f('.idea/workspace.xml'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude .idea/');
        expect(rec.excludePatterns, contains('**/.idea/**'));
      });

      test('recommends excluding .vscode/', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('.vscode', isDir: true),
            _f('.vscode/settings.json'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude .vscode/');
        expect(rec.excludePatterns, contains('**/.vscode/**'));
      });

      test('does NOT recommend .idea when already excluded', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('.idea', isDir: true)],
          customExcludes: ['**/.idea/**'],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude .idea/'), isFalse);
      });
    });

    // ── OS metadata ─────────────────────────────────────────────────────

    group('OS metadata detection', () {
      test('recommends excluding .DS_Store', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('.DS_Store'), _f('subdir/.DS_Store')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude .DS_Store');
        expect(rec.excludePatterns, contains('.DS_Store'));
      });

      test('recommends excluding Thumbs.db', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('Thumbs.db')],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude Thumbs.db');
        expect(rec.excludePatterns, contains('Thumbs.db'));
      });

      test('does NOT recommend .DS_Store when already excluded', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('.DS_Store')],
          customExcludes: ['.DS_Store'],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude .DS_Store'), isFalse);
      });
    });

    // ── Generic caches ──────────────────────────────────────────────────

    group('cache detection', () {
      test('recommends excluding .cache/', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('.cache', isDir: true)],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude .cache/');
        expect(rec.excludePatterns, contains('**/.cache/**'));
      });
    });

    // ── Coverage ────────────────────────────────────────────────────────

    group('coverage detection', () {
      test('recommends excluding coverage/', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('coverage', isDir: true),
            _f('coverage/lcov.info'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec = recs.firstWhere((r) => r.label == 'Exclude coverage/');
        expect(rec.excludePatterns, contains('**/coverage/**'));
      });
    });

    // ── bower_components ────────────────────────────────────────────────

    group('bower_components detection', () {
      test('recommends excluding bower_components/', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('bower_components', isDir: true),
            _f('bower_components/jquery/dist/jquery.min.js'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        final rec =
            recs.firstWhere((r) => r.label == 'Exclude bower_components');
        expect(rec.excludePatterns, contains('**/bower_components/**'));
      });
    });

    // ── Combined scenarios ──────────────────────────────────────────────

    group('combined scenarios', () {
      test('Flutter project detects build/, .dart_tool/, .git, .gitignore', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('.git', isDir: true),
            _f('.gitignore'),
            _f('build', isDir: true),
            _f('build/app/outputs/flutter-apk/app.apk'),
            _f('.dart_tool', isDir: true),
            _f('.dart_tool/package_config.json'),
            _f('lib/main.dart'),
            _f('pubspec.yaml'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.setsExcludeGitDirs), isTrue);
        expect(recs.any((r) => r.setsRespectGitignore), isTrue);
        expect(recs.any((r) => r.label == 'Exclude build/'), isTrue);
        expect(recs.any((r) => r.label == 'Exclude .dart_tool'), isTrue);
      });

      test('Node.js project detects node_modules, .DS_Store, .git', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('.git', isDir: true),
            _f('node_modules', isDir: true),
            _f('node_modules/express/index.js'),
            _f('.DS_Store'),
            _f('package.json'),
            _f('src/index.js'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.setsExcludeGitDirs), isTrue);
        expect(recs.any((r) => r.label == 'Exclude node_modules'), isTrue);
        expect(recs.any((r) => r.label == 'Exclude .DS_Store'), isTrue);
      });

      test('Python project detects venv, __pycache__, .git', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('.git', isDir: true),
            _f('.gitignore'),
            _f('venv', isDir: true),
            _f('venv/lib/python3.11/site-packages/pip/__init__.py'),
            _f('src/__pycache__/main.cpython-311.pyc'),
            _f('src/main.py'),
            _f('requirements.txt'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.setsExcludeGitDirs), isTrue);
        expect(recs.any((r) => r.setsRespectGitignore), isTrue);
        expect(recs.any((r) => r.label == 'Exclude virtualenv'), isTrue);
        expect(recs.any((r) => r.label == 'Exclude __pycache__'), isTrue);
      });

      test('Rust project detects target/, .git, .gitignore', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('.git', isDir: true),
            _f('.gitignore'),
            _f('target', isDir: true),
            _f('target/debug/myapp'),
            _f('src/main.rs'),
            _f('Cargo.toml'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.setsExcludeGitDirs), isTrue);
        expect(recs.any((r) => r.label == 'Exclude target/'), isTrue);
      });

      test('.NET project detects bin/, obj/', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('bin', isDir: true),
            _f('bin/Debug/net8.0/MyApp.dll'),
            _f('obj', isDir: true),
            _f('obj/Debug/net8.0/MyApp.dll'),
            _f('Program.cs'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude bin/ & obj/'), isTrue);
      });
    });

    // ── Edge cases ──────────────────────────────────────────────────────

    group('edge cases', () {
      test('empty file list returns no recommendations', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs, isEmpty);
      });

      test('files without any pattern match return no recommendations', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('src/main.dart'),
            _f('lib/utils.dart'),
            _f('pubspec.yaml'),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs, isEmpty);
      });

      test('all patterns already applied returns no recommendations', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('.git', isDir: true),
            _f('.gitignore'),
            _f('node_modules', isDir: true),
            _f('build', isDir: true),
            _f('.DS_Store'),
          ],
          customExcludes: [
            '**/node_modules/**',
            '**/build/**',
            '.DS_Store',
          ],
          excludeGitDirs: true,
          respectGitignore: true,
        );
        expect(recs, isEmpty);
      });

      test('.git recommendation appears first', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [
            _f('.DS_Store'),
            _f('.git', isDir: true),
            _f('node_modules', isDir: true),
          ],
          customExcludes: [],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.first.setsExcludeGitDirs, isTrue);
      });

      test('partial custom exclude match still suppresses recommendation', () {
        final recs = FilterRecommendationService.generate(
          filePaths: [_f('node_modules', isDir: true)],
          customExcludes: ['node_modules/'],
          excludeGitDirs: false,
          respectGitignore: false,
        );
        expect(recs.any((r) => r.label == 'Exclude node_modules'), isFalse);
      });
    });
  });
}
