import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfig {
  @JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
  final ThemeMode themeMode;
  final bool launchAtLogin;
  final bool showInMenuBar;
  final bool showNotifications;
  final int rcPort;
  final String? skippedVersion;

  const AppConfig({
    required this.themeMode,
    required this.launchAtLogin,
    required this.showInMenuBar,
    required this.showNotifications,
    this.rcPort = 5572,
    this.skippedVersion,
  });

  factory AppConfig.defaults() => const AppConfig(
        themeMode: ThemeMode.system,
        launchAtLogin: false,
        showInMenuBar: true,
        showNotifications: true,
        rcPort: 5572,
      );

  static ThemeMode _themeModeFromJson(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToJson(ThemeMode mode) => mode.name;

  AppConfig copyWith({
    ThemeMode? themeMode,
    bool? launchAtLogin,
    bool? showInMenuBar,
    bool? showNotifications,
    int? rcPort,
    String? skippedVersion,
  }) {
    return AppConfig(
      themeMode: themeMode ?? this.themeMode,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      showInMenuBar: showInMenuBar ?? this.showInMenuBar,
      showNotifications: showNotifications ?? this.showNotifications,
      rcPort: rcPort ?? this.rcPort,
      skippedVersion: skippedVersion ?? this.skippedVersion,
    );
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}
