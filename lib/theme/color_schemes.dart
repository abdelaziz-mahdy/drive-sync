import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const seedColor = Color(0xFF607D8B); // Blue Grey - neutral/adaptive

  static final lightScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  static final darkScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );

  // Status colors - consistent across themes
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const syncing = Color(0xFF2196F3);
  static const warning = Color(0xFFFFA726);
  static const idle = Color(0xFF9E9E9E);
}
