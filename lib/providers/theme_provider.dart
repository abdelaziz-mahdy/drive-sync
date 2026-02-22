import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_config_provider.dart';

/// Exposes the current ThemeMode from app config.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final configAsync = ref.watch(appConfigProvider);
  return configAsync.value?.themeMode ?? ThemeMode.system;
});
