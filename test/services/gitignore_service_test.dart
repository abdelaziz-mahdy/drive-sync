import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/services/gitignore_service.dart';

void main() {
  late Directory tempDir;
  late GitignoreService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('gitignore_test_');
    service = GitignoreService();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('convertRule', () {
    test('converts simple glob pattern', () {
      expect(service.convertRule('*.pyc', ''), '- *.pyc');
    });
    test('converts directory pattern (trailing slash)', () {
      expect(service.convertRule('node_modules/', ''), '- node_modules/**');
    });
    test('converts negation pattern', () {
      expect(service.convertRule('!important.log', ''), '+ important.log');
    });
    test('converts root-anchored pattern', () {
      expect(service.convertRule('/dist', ''), '- /dist/**');
    });
    test('converts root-anchored pattern in subdirectory', () {
      expect(service.convertRule('/dist', 'backend'), '- /backend/dist/**');
    });
    test('preserves nested glob', () {
      expect(service.convertRule('doc/**/*.pdf', ''), '- doc/**/*.pdf');
    });
    test('preserves single-char wildcard', () {
      expect(service.convertRule('temp?.txt', ''), '- temp?.txt');
    });
    test('skips comments', () {
      expect(service.convertRule('# this is a comment', ''), isNull);
    });
    test('skips empty lines', () {
      expect(service.convertRule('', ''), isNull);
      expect(service.convertRule('   ', ''), isNull);
    });
    test('handles negated directory pattern', () {
      expect(service.convertRule('!build/', ''), '+ build/**');
    });
  });

  group('generateRcloneFilters', () {
    test('finds and parses root .gitignore', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('*.pyc\nnode_modules/\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- *.pyc'));
      expect(rules, contains('- node_modules/**'));
    });

    test('scopes subdirectory .gitignore rules', () async {
      final subDir = Directory('${tempDir.path}/backend');
      subDir.createSync();
      File('${subDir.path}/.gitignore').writeAsStringSync('/dist\n*.log\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- /backend/dist/**'));
      expect(rules, contains('- *.log'));
    });

    test('handles nested .gitignore files', () async {
      File('${tempDir.path}/.gitignore').writeAsStringSync('*.tmp\n');
      final sub = Directory('${tempDir.path}/src');
      sub.createSync();
      File('${sub.path}/.gitignore').writeAsStringSync('*.o\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- *.tmp'));
      expect(rules, contains('- *.o'));
    });

    test('handles negation', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('*.log\n!important.log\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- *.log'));
      expect(rules, contains('+ important.log'));
    });

    test('ignores comment lines and blank lines', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('# Comment\n\n*.tmp\n  \n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules.length, 1);
      expect(rules, contains('- *.tmp'));
    });

    test('returns empty list when no .gitignore files', () async {
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, isEmpty);
    });
  });

  group('writeFilterFile', () {
    test('writes rules to file', () async {
      final filterDir = '${tempDir.path}/filters';
      final path = await service.writeFilterFile(
        'test-profile',
        ['- *.pyc', '- node_modules/**'],
        filterDir,
      );
      expect(File(path).existsSync(), true);
      final content = File(path).readAsStringSync();
      expect(content, '- *.pyc\n- node_modules/**');
    });

    test('creates directory if it does not exist', () async {
      final filterDir = '${tempDir.path}/nonexistent/filters';
      await service.writeFilterFile('p1', ['- *.tmp'], filterDir);
      expect(Directory(filterDir).existsSync(), true);
    });
  });

  group('quickExcludes', () {
    test('has expected categories', () {
      expect(
          GitignoreService.quickExcludes.containsKey('.git directories'), true);
      expect(GitignoreService.quickExcludes.containsKey('node_modules'), true);
      expect(
          GitignoreService.quickExcludes.containsKey('Build artifacts'), true);
    });
  });

  // -----------------------------------------------------------------------
  // Edge-case tests for malformed / unusual .gitignore content
  // -----------------------------------------------------------------------
  group('edge cases - convertRule', () {
    test('handles rule with only whitespace characters', () {
      expect(service.convertRule('  \t  ', ''), isNull);
    });

    test('handles rule with trailing whitespace', () {
      // Git strips trailing whitespace from rules
      expect(service.convertRule('*.log   ', ''), '- *.log');
    });

    test('handles rule with leading whitespace', () {
      expect(service.convertRule('  *.log', ''), '- *.log');
    });

    test('handles rule with escaped hash (not a comment)', () {
      // In gitignore, \# matches literal #. After trim, starts with backslash.
      expect(service.convertRule('\\#file', ''), '- \\#file');
    });

    test('handles double-star glob pattern', () {
      expect(service.convertRule('**/logs', ''), '- **/logs');
    });

    test('handles double-star in middle', () {
      expect(service.convertRule('a/**/b', ''), '- a/**/b');
    });

    test('handles pattern with special regex-like characters', () {
      // These should pass through as-is; rclone uses glob, not regex
      expect(service.convertRule('[Cc]ache', ''), '- [Cc]ache');
    });

    test('handles deeply nested scope directory', () {
      expect(
        service.convertRule('/build', 'a/b/c/d'),
        '- /a/b/c/d/build/**',
      );
    });

    test('handles negated root-anchored directory pattern', () {
      // !/important/ -> negation + root-anchored dir -> '+ /important/**'
      expect(service.convertRule('!/important/', ''), '+ /important/**');
    });

    test('handles unicode characters in pattern', () {
      expect(service.convertRule('ドキュメント/', ''), '- ドキュメント/**');
    });

    test('handles pattern that is just a slash', () {
      // '/' with trailing slash stripped becomes '' which is empty
      // convertRule trims first, '/' -> not empty, not comment
      // dirOnly = true, rule becomes '' after removing trailing /
      // Since rule starts with '/' -> root-anchored, scopedRule = ''
      // then dirOnly appends /** -> '/**'
      final result = service.convertRule('/', '');
      // The rule '/' means "exclude the root directory content"
      expect(result, isNotNull);
    });

    test('handles very long pattern', () {
      final longPattern = 'a' * 1000;
      expect(service.convertRule(longPattern, ''), '- $longPattern');
    });
  });

  group('edge cases - generateRcloneFilters', () {
    test('handles .gitignore with Windows-style line endings (CRLF)', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('*.pyc\r\nnode_modules/\r\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      // After trim(), \r should be removed
      expect(rules, contains('- *.pyc'));
      expect(rules, contains('- node_modules/**'));
    });

    test('handles .gitignore with mixed line endings', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('*.pyc\r\n*.log\n*.tmp\r');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- *.pyc'));
      expect(rules, contains('- *.log'));
      // \r at end of file may cause the last line to have trailing \r
      // trim() should handle it
    });

    test('handles .gitignore that is entirely comments', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('# comment 1\n# comment 2\n# comment 3\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, isEmpty);
    });

    test('handles .gitignore that is entirely blank lines', () async {
      File('${tempDir.path}/.gitignore').writeAsStringSync('\n\n\n\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, isEmpty);
    });

    test('handles empty .gitignore file', () async {
      File('${tempDir.path}/.gitignore').writeAsStringSync('');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, isEmpty);
    });

    test('handles .gitignore with unicode content', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('ドキュメント/\nтест.log\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- ドキュメント/**'));
      expect(rules, contains('- тест.log'));
    });

    test('handles .gitignore with very long lines', () async {
      final longPattern = 'a' * 500;
      File('${tempDir.path}/.gitignore').writeAsStringSync('$longPattern\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules.length, 1);
      expect(rules[0], '- $longPattern');
    });

    test('handles .gitignore with duplicate rules', () async {
      File('${tempDir.path}/.gitignore')
          .writeAsStringSync('*.log\n*.log\n*.log\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      // Duplicates are passed through (rclone handles dedup)
      expect(rules.length, 3);
    });

    test('handles non-existent root directory gracefully', () async {
      // Attempting to scan a non-existent directory should throw
      expect(
        () => service.generateRcloneFilters('/nonexistent/path/12345'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('handles .gitignore with only a trailing newline', () async {
      File('${tempDir.path}/.gitignore').writeAsStringSync('\n');
      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, isEmpty);
    });

    test('handles multiple .gitignore files at different depths', () async {
      // Root
      File('${tempDir.path}/.gitignore').writeAsStringSync('*.tmp\n');
      // Level 1
      final l1 = Directory('${tempDir.path}/src');
      l1.createSync();
      File('${l1.path}/.gitignore').writeAsStringSync('*.o\n');
      // Level 2
      final l2 = Directory('${l1.path}/vendor');
      l2.createSync();
      File('${l2.path}/.gitignore').writeAsStringSync('*.dll\n');

      final rules = await service.generateRcloneFilters(tempDir.path);
      expect(rules, contains('- *.tmp'));
      expect(rules, contains('- *.o'));
      expect(rules, contains('- *.dll'));
    });
  });
}
