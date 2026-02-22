class AppRelease {
  final String version;
  final String tagName;
  final DateTime publishedAt;
  final String changelog;
  final Map<String, String> downloadUrls;
  final bool isPreRelease;

  const AppRelease({
    required this.version,
    required this.tagName,
    required this.publishedAt,
    required this.changelog,
    required this.downloadUrls,
    required this.isPreRelease,
  });

  factory AppRelease.fromGitHubJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String;
    final version =
        tagName.startsWith('v') ? tagName.substring(1) : tagName;

    final assets = json['assets'] as List<dynamic>? ?? [];
    final downloadUrls = <String, String>{};
    for (final asset in assets) {
      final assetMap = asset as Map<String, dynamic>;
      downloadUrls[assetMap['name'] as String] =
          assetMap['browser_download_url'] as String;
    }

    return AppRelease(
      version: version,
      tagName: tagName,
      publishedAt: DateTime.parse(json['published_at'] as String),
      changelog: json['body'] as String? ?? '',
      downloadUrls: downloadUrls,
      isPreRelease: json['prerelease'] as bool? ?? false,
    );
  }

  bool isNewerThan(String currentVersion) {
    final current = currentVersion.split('.').map(int.parse).toList();
    final release = version.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final r = i < release.length ? release[i] : 0;
      final c = i < current.length ? current[i] : 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }
}
