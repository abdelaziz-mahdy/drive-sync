import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/daos/app_config_dao.dart';
import '../models/app_config.dart';
import 'database_provider.dart';

/// Manages app configuration state.
class AppConfigNotifier extends AsyncNotifier<AppConfig> {
  @override
  Future<AppConfig> build() async {
    final dao = AppConfigDao(ref.read(appDatabaseProvider));
    return dao.load();
  }

  Future<void> updateConfig(AppConfig Function(AppConfig) updater) async {
    final current = state.value ?? AppConfig.defaults();
    final updated = updater(current);
    final dao = AppConfigDao(ref.read(appDatabaseProvider));
    await dao.save(updated);
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
