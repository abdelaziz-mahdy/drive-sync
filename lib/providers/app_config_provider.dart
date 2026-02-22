import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_config.dart';
import '../services/config_store.dart';

/// Provides the ConfigStore singleton.
/// Uses path_provider to get app support directory.
final configStoreProvider = Provider<ConfigStore>((ref) {
  // This will be overridden in main.dart with actual path
  throw UnimplementedError('configStoreProvider must be overridden');
});

/// Manages app configuration state.
class AppConfigNotifier extends AsyncNotifier<AppConfig> {
  @override
  Future<AppConfig> build() async {
    final store = ref.read(configStoreProvider);
    return store.loadAppConfig();
  }

  Future<void> updateConfig(AppConfig Function(AppConfig) updater) async {
    final current = state.value ?? AppConfig.defaults();
    final updated = updater(current);
    final store = ref.read(configStoreProvider);
    await store.saveAppConfig(updated);
    state = AsyncData(updated);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await updateConfig((config) => config.copyWith(themeMode: mode));
  }

  Future<void> skipVersion(String version) async {
    await updateConfig((config) => config.copyWith(skippedVersion: version));
  }
}

final appConfigProvider = AsyncNotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);
