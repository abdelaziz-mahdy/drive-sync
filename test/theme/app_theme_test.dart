import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drive_sync/theme/app_theme.dart';
import 'package:drive_sync/theme/color_schemes.dart';

void main() {
  group('AppColors', () {
    test('seedColor is Blue Grey', () {
      expect(AppColors.seedColor, const Color(0xFF607D8B));
    });

    test('lightScheme has light brightness', () {
      expect(AppColors.lightScheme.brightness, Brightness.light);
    });

    test('darkScheme has dark brightness', () {
      expect(AppColors.darkScheme.brightness, Brightness.dark);
    });

    test('status colors are defined', () {
      expect(AppColors.success, const Color(0xFF4CAF50));
      expect(AppColors.error, const Color(0xFFE53935));
      expect(AppColors.syncing, const Color(0xFF2196F3));
      expect(AppColors.warning, const Color(0xFFFFA726));
      expect(AppColors.idle, const Color(0xFF9E9E9E));
    });
  });

  group('AppTheme', () {
    test('light theme has light brightness', () {
      expect(AppTheme.light.brightness, Brightness.light);
    });

    test('dark theme has dark brightness', () {
      expect(AppTheme.dark.brightness, Brightness.dark);
    });

    test('both themes use Material 3', () {
      expect(AppTheme.light.useMaterial3, true);
      expect(AppTheme.dark.useMaterial3, true);
    });

    test('status colors are defined', () {
      expect(AppTheme.successColor, isNotNull);
      expect(AppTheme.errorColor, isNotNull);
      expect(AppTheme.syncingColor, isNotNull);
      expect(AppTheme.warningColor, isNotNull);
    });

    test('status colors match AppColors', () {
      expect(AppTheme.successColor, AppColors.success);
      expect(AppTheme.errorColor, AppColors.error);
      expect(AppTheme.syncingColor, AppColors.syncing);
      expect(AppTheme.warningColor, AppColors.warning);
    });

    test('light theme has card theme with no elevation', () {
      expect(AppTheme.light.cardTheme.elevation, 0);
    });

    test('dark theme has card theme with no elevation', () {
      expect(AppTheme.dark.cardTheme.elevation, 0);
    });

    test('dark theme has custom scaffold background', () {
      expect(AppTheme.dark.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    test('light theme appBar has no elevation', () {
      expect(AppTheme.light.appBarTheme.elevation, 0);
    });

    test('dark theme appBar has no elevation', () {
      expect(AppTheme.dark.appBarTheme.elevation, 0);
    });
  });
}
