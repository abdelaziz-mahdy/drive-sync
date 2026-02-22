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
}
