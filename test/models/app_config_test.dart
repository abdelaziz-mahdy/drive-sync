import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_sync/models/app_config.dart';

void main() {
  group('AppConfig', () {
    test('defaults() has correct values', () {
      final config = AppConfig.defaults();
      expect(config.themeMode, ThemeMode.system);
      expect(config.launchAtLogin, false);
      expect(config.showInMenuBar, true);
      expect(config.showNotifications, true);
      expect(config.rcPort, 5572);
      expect(config.skippedVersion, isNull);
    });

    group('serialization', () {
      test('round-trip fromJson/toJson', () {
        final config = AppConfig.defaults();
        final json = config.toJson();
        final config2 = AppConfig.fromJson(json);
        expect(config2.themeMode, config.themeMode);
        expect(config2.launchAtLogin, config.launchAtLogin);
        expect(config2.showInMenuBar, config.showInMenuBar);
        expect(config2.showNotifications, config.showNotifications);
        expect(config2.rcPort, config.rcPort);
        expect(config2.skippedVersion, config.skippedVersion);
      });

      test('ThemeMode serializes as string', () {
        final config = AppConfig.defaults();
        final json = config.toJson();
        expect(json['themeMode'], 'system');
      });

      test('ThemeMode.dark round-trips', () {
        final config = AppConfig.defaults().copyWith(themeMode: ThemeMode.dark);
        final json = config.toJson();
        expect(json['themeMode'], 'dark');
        final config2 = AppConfig.fromJson(json);
        expect(config2.themeMode, ThemeMode.dark);
      });

      test('ThemeMode.light round-trips', () {
        final config =
            AppConfig.defaults().copyWith(themeMode: ThemeMode.light);
        final json = config.toJson();
        expect(json['themeMode'], 'light');
        final config2 = AppConfig.fromJson(json);
        expect(config2.themeMode, ThemeMode.light);
      });
    });

    group('copyWith', () {
      test('changes specified fields', () {
        final config = AppConfig.defaults();
        final config2 = config.copyWith(
          launchAtLogin: true,
          rcPort: 8080,
          skippedVersion: '1.0.0',
        );
        expect(config2.launchAtLogin, true);
        expect(config2.rcPort, 8080);
        expect(config2.skippedVersion, '1.0.0');
        expect(config2.themeMode, config.themeMode);
        expect(config2.showInMenuBar, config.showInMenuBar);
      });

      test('preserves all fields when no args', () {
        final config = AppConfig(
          themeMode: ThemeMode.dark,
          launchAtLogin: true,
          showInMenuBar: false,
          showNotifications: false,
          rcPort: 9999,
          skippedVersion: '2.0.0',
        );
        final config2 = config.copyWith();
        expect(config2.themeMode, ThemeMode.dark);
        expect(config2.launchAtLogin, true);
        expect(config2.showInMenuBar, false);
        expect(config2.showNotifications, false);
        expect(config2.rcPort, 9999);
        expect(config2.skippedVersion, '2.0.0');
      });
    });
  });
}
