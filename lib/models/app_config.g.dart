// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
  themeMode: AppConfig._themeModeFromJson(json['themeMode'] as String),
  launchAtLogin: json['launchAtLogin'] as bool,
  showInMenuBar: json['showInMenuBar'] as bool,
  showNotifications: json['showNotifications'] as bool,
  rcPort: (json['rcPort'] as num?)?.toInt() ?? 5572,
  skippedVersion: json['skippedVersion'] as String?,
);

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
  'themeMode': AppConfig._themeModeToJson(instance.themeMode),
  'launchAtLogin': instance.launchAtLogin,
  'showInMenuBar': instance.showInMenuBar,
  'showNotifications': instance.showNotifications,
  'rcPort': instance.rcPort,
  'skippedVersion': instance.skippedVersion,
};
