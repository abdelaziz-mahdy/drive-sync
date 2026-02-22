enum SyncMode {
  backup(
    rcloneCommand: 'copy',
    rcEndpoint: '/sync/copy',
    direction: 'Local \u2192 Cloud',
    label: 'Backup',
    description:
        'Push local files to cloud. Deleting locally does NOT delete from cloud.',
    deletesOnDest: false,
  ),
  mirror(
    rcloneCommand: 'sync',
    rcEndpoint: '/sync/sync',
    direction: 'Cloud \u2192 Local',
    label: 'Mirror',
    description:
        'Local folder becomes exact copy of cloud. Files not on cloud WILL be deleted locally.',
    deletesOnDest: true,
  ),
  download(
    rcloneCommand: 'copy',
    rcEndpoint: '/sync/copy',
    direction: 'Cloud \u2192 Local',
    label: 'Download',
    description:
        'Pull new files from cloud. Keeps local files even if deleted from cloud.',
    deletesOnDest: false,
  ),
  bisync(
    rcloneCommand: 'bisync',
    rcEndpoint: '/sync/bisync',
    direction: 'Bidirectional',
    label: 'Bidirectional',
    description:
        'Changes sync both ways. Experimental \u2014 conflicts may need manual resolution.',
    deletesOnDest: true,
  );

  const SyncMode({
    required this.rcloneCommand,
    required this.rcEndpoint,
    required this.direction,
    required this.label,
    required this.description,
    required this.deletesOnDest,
  });

  final String rcloneCommand;
  final String rcEndpoint;
  final String direction;
  final String label;
  final String description;
  final bool deletesOnDest;

  String toJson() => name;

  static SyncMode fromJson(String value) =>
      SyncMode.values.firstWhere((e) => e.name == value);
}
