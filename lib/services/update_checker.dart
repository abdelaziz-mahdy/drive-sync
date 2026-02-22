import 'dart:io';

import 'package:dio/dio.dart';

import '../models/app_release.dart';

/// Checks GitHub releases for application updates.
class UpdateChecker {
  final Dio _dio;
  final String repoOwner;
  final String repoName;

  UpdateChecker({
    Dio? dio,
    this.repoOwner = 'abdelaziz-mahdy',
    this.repoName = 'drive-sync',
  }) : _dio = dio ?? Dio();

  /// Checks if a newer release is available compared to [currentVersion].
  /// Returns the [AppRelease] if an update is available, or null otherwise.
  /// Returns null on network errors or if the latest release is a pre-release.
  Future<AppRelease?> checkForUpdate(String currentVersion) async {
    try {
      final resp = await _dio.get(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
      );
      final release = AppRelease.fromGitHubJson(
        resp.data as Map<String, dynamic>,
      );
      if (release.isPreRelease) return null;
      if (release.isNewerThan(currentVersion)) return release;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns the download URL for the current platform from the release assets,
  /// or null if no matching asset is found.
  String? getPlatformDownloadUrl(AppRelease release) {
    for (final entry in release.downloadUrls.entries) {
      if (Platform.isMacOS && entry.key.endsWith('.dmg')) return entry.value;
      if (Platform.isWindows &&
          (entry.key.endsWith('.exe') || entry.key.endsWith('.msix'))) {
        return entry.value;
      }
      if (Platform.isLinux &&
          (entry.key.endsWith('.deb') || entry.key.endsWith('.AppImage'))) {
        return entry.value;
      }
    }
    return null;
  }
}
