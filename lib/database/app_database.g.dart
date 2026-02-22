// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppConfigsTable extends AppConfigs
    with TableInfo<$AppConfigsTable, AppConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _launchAtLoginMeta = const VerificationMeta(
    'launchAtLogin',
  );
  @override
  late final GeneratedColumn<bool> launchAtLogin = GeneratedColumn<bool>(
    'launch_at_login',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("launch_at_login" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _showInMenuBarMeta = const VerificationMeta(
    'showInMenuBar',
  );
  @override
  late final GeneratedColumn<bool> showInMenuBar = GeneratedColumn<bool>(
    'show_in_menu_bar',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_in_menu_bar" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showNotificationsMeta = const VerificationMeta(
    'showNotifications',
  );
  @override
  late final GeneratedColumn<bool> showNotifications = GeneratedColumn<bool>(
    'show_notifications',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_notifications" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _rcPortMeta = const VerificationMeta('rcPort');
  @override
  late final GeneratedColumn<int> rcPort = GeneratedColumn<int>(
    'rc_port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5572),
  );
  static const VerificationMeta _skippedVersionMeta = const VerificationMeta(
    'skippedVersion',
  );
  @override
  late final GeneratedColumn<String> skippedVersion = GeneratedColumn<String>(
    'skipped_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bandwidthLimitMeta = const VerificationMeta(
    'bandwidthLimit',
  );
  @override
  late final GeneratedColumn<String> bandwidthLimit = GeneratedColumn<String>(
    'bandwidth_limit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    launchAtLogin,
    showInMenuBar,
    showNotifications,
    rcPort,
    skippedVersion,
    bandwidthLimit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('launch_at_login')) {
      context.handle(
        _launchAtLoginMeta,
        launchAtLogin.isAcceptableOrUnknown(
          data['launch_at_login']!,
          _launchAtLoginMeta,
        ),
      );
    }
    if (data.containsKey('show_in_menu_bar')) {
      context.handle(
        _showInMenuBarMeta,
        showInMenuBar.isAcceptableOrUnknown(
          data['show_in_menu_bar']!,
          _showInMenuBarMeta,
        ),
      );
    }
    if (data.containsKey('show_notifications')) {
      context.handle(
        _showNotificationsMeta,
        showNotifications.isAcceptableOrUnknown(
          data['show_notifications']!,
          _showNotificationsMeta,
        ),
      );
    }
    if (data.containsKey('rc_port')) {
      context.handle(
        _rcPortMeta,
        rcPort.isAcceptableOrUnknown(data['rc_port']!, _rcPortMeta),
      );
    }
    if (data.containsKey('skipped_version')) {
      context.handle(
        _skippedVersionMeta,
        skippedVersion.isAcceptableOrUnknown(
          data['skipped_version']!,
          _skippedVersionMeta,
        ),
      );
    }
    if (data.containsKey('bandwidth_limit')) {
      context.handle(
        _bandwidthLimitMeta,
        bandwidthLimit.isAcceptableOrUnknown(
          data['bandwidth_limit']!,
          _bandwidthLimitMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      launchAtLogin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}launch_at_login'],
      )!,
      showInMenuBar: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_in_menu_bar'],
      )!,
      showNotifications: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_notifications'],
      )!,
      rcPort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rc_port'],
      )!,
      skippedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skipped_version'],
      ),
      bandwidthLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bandwidth_limit'],
      ),
    );
  }

  @override
  $AppConfigsTable createAlias(String alias) {
    return $AppConfigsTable(attachedDatabase, alias);
  }
}

class AppConfig extends DataClass implements Insertable<AppConfig> {
  final int id;
  final String themeMode;
  final bool launchAtLogin;
  final bool showInMenuBar;
  final bool showNotifications;
  final int rcPort;
  final String? skippedVersion;
  final String? bandwidthLimit;
  const AppConfig({
    required this.id,
    required this.themeMode,
    required this.launchAtLogin,
    required this.showInMenuBar,
    required this.showNotifications,
    required this.rcPort,
    this.skippedVersion,
    this.bandwidthLimit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['launch_at_login'] = Variable<bool>(launchAtLogin);
    map['show_in_menu_bar'] = Variable<bool>(showInMenuBar);
    map['show_notifications'] = Variable<bool>(showNotifications);
    map['rc_port'] = Variable<int>(rcPort);
    if (!nullToAbsent || skippedVersion != null) {
      map['skipped_version'] = Variable<String>(skippedVersion);
    }
    if (!nullToAbsent || bandwidthLimit != null) {
      map['bandwidth_limit'] = Variable<String>(bandwidthLimit);
    }
    return map;
  }

  AppConfigsCompanion toCompanion(bool nullToAbsent) {
    return AppConfigsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      launchAtLogin: Value(launchAtLogin),
      showInMenuBar: Value(showInMenuBar),
      showNotifications: Value(showNotifications),
      rcPort: Value(rcPort),
      skippedVersion: skippedVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(skippedVersion),
      bandwidthLimit: bandwidthLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(bandwidthLimit),
    );
  }

  factory AppConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppConfig(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      launchAtLogin: serializer.fromJson<bool>(json['launchAtLogin']),
      showInMenuBar: serializer.fromJson<bool>(json['showInMenuBar']),
      showNotifications: serializer.fromJson<bool>(json['showNotifications']),
      rcPort: serializer.fromJson<int>(json['rcPort']),
      skippedVersion: serializer.fromJson<String?>(json['skippedVersion']),
      bandwidthLimit: serializer.fromJson<String?>(json['bandwidthLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'launchAtLogin': serializer.toJson<bool>(launchAtLogin),
      'showInMenuBar': serializer.toJson<bool>(showInMenuBar),
      'showNotifications': serializer.toJson<bool>(showNotifications),
      'rcPort': serializer.toJson<int>(rcPort),
      'skippedVersion': serializer.toJson<String?>(skippedVersion),
      'bandwidthLimit': serializer.toJson<String?>(bandwidthLimit),
    };
  }

  AppConfig copyWith({
    int? id,
    String? themeMode,
    bool? launchAtLogin,
    bool? showInMenuBar,
    bool? showNotifications,
    int? rcPort,
    Value<String?> skippedVersion = const Value.absent(),
    Value<String?> bandwidthLimit = const Value.absent(),
  }) => AppConfig(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    launchAtLogin: launchAtLogin ?? this.launchAtLogin,
    showInMenuBar: showInMenuBar ?? this.showInMenuBar,
    showNotifications: showNotifications ?? this.showNotifications,
    rcPort: rcPort ?? this.rcPort,
    skippedVersion: skippedVersion.present
        ? skippedVersion.value
        : this.skippedVersion,
    bandwidthLimit: bandwidthLimit.present
        ? bandwidthLimit.value
        : this.bandwidthLimit,
  );
  AppConfig copyWithCompanion(AppConfigsCompanion data) {
    return AppConfig(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      launchAtLogin: data.launchAtLogin.present
          ? data.launchAtLogin.value
          : this.launchAtLogin,
      showInMenuBar: data.showInMenuBar.present
          ? data.showInMenuBar.value
          : this.showInMenuBar,
      showNotifications: data.showNotifications.present
          ? data.showNotifications.value
          : this.showNotifications,
      rcPort: data.rcPort.present ? data.rcPort.value : this.rcPort,
      skippedVersion: data.skippedVersion.present
          ? data.skippedVersion.value
          : this.skippedVersion,
      bandwidthLimit: data.bandwidthLimit.present
          ? data.bandwidthLimit.value
          : this.bandwidthLimit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppConfig(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('launchAtLogin: $launchAtLogin, ')
          ..write('showInMenuBar: $showInMenuBar, ')
          ..write('showNotifications: $showNotifications, ')
          ..write('rcPort: $rcPort, ')
          ..write('skippedVersion: $skippedVersion, ')
          ..write('bandwidthLimit: $bandwidthLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    launchAtLogin,
    showInMenuBar,
    showNotifications,
    rcPort,
    skippedVersion,
    bandwidthLimit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppConfig &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.launchAtLogin == this.launchAtLogin &&
          other.showInMenuBar == this.showInMenuBar &&
          other.showNotifications == this.showNotifications &&
          other.rcPort == this.rcPort &&
          other.skippedVersion == this.skippedVersion &&
          other.bandwidthLimit == this.bandwidthLimit);
}

class AppConfigsCompanion extends UpdateCompanion<AppConfig> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<bool> launchAtLogin;
  final Value<bool> showInMenuBar;
  final Value<bool> showNotifications;
  final Value<int> rcPort;
  final Value<String?> skippedVersion;
  final Value<String?> bandwidthLimit;
  const AppConfigsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.launchAtLogin = const Value.absent(),
    this.showInMenuBar = const Value.absent(),
    this.showNotifications = const Value.absent(),
    this.rcPort = const Value.absent(),
    this.skippedVersion = const Value.absent(),
    this.bandwidthLimit = const Value.absent(),
  });
  AppConfigsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.launchAtLogin = const Value.absent(),
    this.showInMenuBar = const Value.absent(),
    this.showNotifications = const Value.absent(),
    this.rcPort = const Value.absent(),
    this.skippedVersion = const Value.absent(),
    this.bandwidthLimit = const Value.absent(),
  });
  static Insertable<AppConfig> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<bool>? launchAtLogin,
    Expression<bool>? showInMenuBar,
    Expression<bool>? showNotifications,
    Expression<int>? rcPort,
    Expression<String>? skippedVersion,
    Expression<String>? bandwidthLimit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (launchAtLogin != null) 'launch_at_login': launchAtLogin,
      if (showInMenuBar != null) 'show_in_menu_bar': showInMenuBar,
      if (showNotifications != null) 'show_notifications': showNotifications,
      if (rcPort != null) 'rc_port': rcPort,
      if (skippedVersion != null) 'skipped_version': skippedVersion,
      if (bandwidthLimit != null) 'bandwidth_limit': bandwidthLimit,
    });
  }

  AppConfigsCompanion copyWith({
    Value<int>? id,
    Value<String>? themeMode,
    Value<bool>? launchAtLogin,
    Value<bool>? showInMenuBar,
    Value<bool>? showNotifications,
    Value<int>? rcPort,
    Value<String?>? skippedVersion,
    Value<String?>? bandwidthLimit,
  }) {
    return AppConfigsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      showInMenuBar: showInMenuBar ?? this.showInMenuBar,
      showNotifications: showNotifications ?? this.showNotifications,
      rcPort: rcPort ?? this.rcPort,
      skippedVersion: skippedVersion ?? this.skippedVersion,
      bandwidthLimit: bandwidthLimit ?? this.bandwidthLimit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (launchAtLogin.present) {
      map['launch_at_login'] = Variable<bool>(launchAtLogin.value);
    }
    if (showInMenuBar.present) {
      map['show_in_menu_bar'] = Variable<bool>(showInMenuBar.value);
    }
    if (showNotifications.present) {
      map['show_notifications'] = Variable<bool>(showNotifications.value);
    }
    if (rcPort.present) {
      map['rc_port'] = Variable<int>(rcPort.value);
    }
    if (skippedVersion.present) {
      map['skipped_version'] = Variable<String>(skippedVersion.value);
    }
    if (bandwidthLimit.present) {
      map['bandwidth_limit'] = Variable<String>(bandwidthLimit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppConfigsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('launchAtLogin: $launchAtLogin, ')
          ..write('showInMenuBar: $showInMenuBar, ')
          ..write('showNotifications: $showNotifications, ')
          ..write('rcPort: $rcPort, ')
          ..write('skippedVersion: $skippedVersion, ')
          ..write('bandwidthLimit: $bandwidthLimit')
          ..write(')'))
        .toString();
  }
}

class $SyncProfilesTable extends SyncProfiles
    with TableInfo<$SyncProfilesTable, SyncProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteNameMeta = const VerificationMeta(
    'remoteName',
  );
  @override
  late final GeneratedColumn<String> remoteName = GeneratedColumn<String>(
    'remote_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cloudFolderMeta = const VerificationMeta(
    'cloudFolder',
  );
  @override
  late final GeneratedColumn<String> cloudFolder = GeneratedColumn<String>(
    'cloud_folder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncModeMeta = const VerificationMeta(
    'syncMode',
  );
  @override
  late final GeneratedColumn<String> syncMode = GeneratedColumn<String>(
    'sync_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('backup'),
  );
  static const VerificationMeta _scheduleMinutesMeta = const VerificationMeta(
    'scheduleMinutes',
  );
  @override
  late final GeneratedColumn<int> scheduleMinutes = GeneratedColumn<int>(
    'schedule_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _respectGitignoreMeta = const VerificationMeta(
    'respectGitignore',
  );
  @override
  late final GeneratedColumn<bool> respectGitignore = GeneratedColumn<bool>(
    'respect_gitignore',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("respect_gitignore" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _excludeGitDirsMeta = const VerificationMeta(
    'excludeGitDirs',
  );
  @override
  late final GeneratedColumn<bool> excludeGitDirs = GeneratedColumn<bool>(
    'exclude_git_dirs',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exclude_git_dirs" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _preserveSourceDirMeta = const VerificationMeta(
    'preserveSourceDir',
  );
  @override
  late final GeneratedColumn<bool> preserveSourceDir = GeneratedColumn<bool>(
    'preserve_source_dir',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("preserve_source_dir" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _useIncludeModeMeta = const VerificationMeta(
    'useIncludeMode',
  );
  @override
  late final GeneratedColumn<bool> useIncludeMode = GeneratedColumn<bool>(
    'use_include_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use_include_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _bandwidthLimitMeta = const VerificationMeta(
    'bandwidthLimit',
  );
  @override
  late final GeneratedColumn<String> bandwidthLimit = GeneratedColumn<String>(
    'bandwidth_limit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxTransfersMeta = const VerificationMeta(
    'maxTransfers',
  );
  @override
  late final GeneratedColumn<int> maxTransfers = GeneratedColumn<int>(
    'max_transfers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _checkFirstMeta = const VerificationMeta(
    'checkFirst',
  );
  @override
  late final GeneratedColumn<bool> checkFirst = GeneratedColumn<bool>(
    'check_first',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("check_first" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncTimeMeta = const VerificationMeta(
    'lastSyncTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncTime = GeneratedColumn<DateTime>(
    'last_sync_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncStatusMeta = const VerificationMeta(
    'lastSyncStatus',
  );
  @override
  late final GeneratedColumn<String> lastSyncStatus = GeneratedColumn<String>(
    'last_sync_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncErrorMeta = const VerificationMeta(
    'lastSyncError',
  );
  @override
  late final GeneratedColumn<String> lastSyncError = GeneratedColumn<String>(
    'last_sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    remoteName,
    cloudFolder,
    syncMode,
    scheduleMinutes,
    enabled,
    respectGitignore,
    excludeGitDirs,
    preserveSourceDir,
    useIncludeMode,
    bandwidthLimit,
    maxTransfers,
    checkFirst,
    lastSyncTime,
    lastSyncStatus,
    lastSyncError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('remote_name')) {
      context.handle(
        _remoteNameMeta,
        remoteName.isAcceptableOrUnknown(data['remote_name']!, _remoteNameMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteNameMeta);
    }
    if (data.containsKey('cloud_folder')) {
      context.handle(
        _cloudFolderMeta,
        cloudFolder.isAcceptableOrUnknown(
          data['cloud_folder']!,
          _cloudFolderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cloudFolderMeta);
    }
    if (data.containsKey('sync_mode')) {
      context.handle(
        _syncModeMeta,
        syncMode.isAcceptableOrUnknown(data['sync_mode']!, _syncModeMeta),
      );
    }
    if (data.containsKey('schedule_minutes')) {
      context.handle(
        _scheduleMinutesMeta,
        scheduleMinutes.isAcceptableOrUnknown(
          data['schedule_minutes']!,
          _scheduleMinutesMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('respect_gitignore')) {
      context.handle(
        _respectGitignoreMeta,
        respectGitignore.isAcceptableOrUnknown(
          data['respect_gitignore']!,
          _respectGitignoreMeta,
        ),
      );
    }
    if (data.containsKey('exclude_git_dirs')) {
      context.handle(
        _excludeGitDirsMeta,
        excludeGitDirs.isAcceptableOrUnknown(
          data['exclude_git_dirs']!,
          _excludeGitDirsMeta,
        ),
      );
    }
    if (data.containsKey('preserve_source_dir')) {
      context.handle(
        _preserveSourceDirMeta,
        preserveSourceDir.isAcceptableOrUnknown(
          data['preserve_source_dir']!,
          _preserveSourceDirMeta,
        ),
      );
    }
    if (data.containsKey('use_include_mode')) {
      context.handle(
        _useIncludeModeMeta,
        useIncludeMode.isAcceptableOrUnknown(
          data['use_include_mode']!,
          _useIncludeModeMeta,
        ),
      );
    }
    if (data.containsKey('bandwidth_limit')) {
      context.handle(
        _bandwidthLimitMeta,
        bandwidthLimit.isAcceptableOrUnknown(
          data['bandwidth_limit']!,
          _bandwidthLimitMeta,
        ),
      );
    }
    if (data.containsKey('max_transfers')) {
      context.handle(
        _maxTransfersMeta,
        maxTransfers.isAcceptableOrUnknown(
          data['max_transfers']!,
          _maxTransfersMeta,
        ),
      );
    }
    if (data.containsKey('check_first')) {
      context.handle(
        _checkFirstMeta,
        checkFirst.isAcceptableOrUnknown(data['check_first']!, _checkFirstMeta),
      );
    }
    if (data.containsKey('last_sync_time')) {
      context.handle(
        _lastSyncTimeMeta,
        lastSyncTime.isAcceptableOrUnknown(
          data['last_sync_time']!,
          _lastSyncTimeMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_status')) {
      context.handle(
        _lastSyncStatusMeta,
        lastSyncStatus.isAcceptableOrUnknown(
          data['last_sync_status']!,
          _lastSyncStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_error')) {
      context.handle(
        _lastSyncErrorMeta,
        lastSyncError.isAcceptableOrUnknown(
          data['last_sync_error']!,
          _lastSyncErrorMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      remoteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_name'],
      )!,
      cloudFolder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_folder'],
      )!,
      syncMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_mode'],
      )!,
      scheduleMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_minutes'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      respectGitignore: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}respect_gitignore'],
      )!,
      excludeGitDirs: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exclude_git_dirs'],
      )!,
      preserveSourceDir: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}preserve_source_dir'],
      )!,
      useIncludeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use_include_mode'],
      )!,
      bandwidthLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bandwidth_limit'],
      ),
      maxTransfers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_transfers'],
      )!,
      checkFirst: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}check_first'],
      )!,
      lastSyncTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_time'],
      ),
      lastSyncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_status'],
      ),
      lastSyncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncProfilesTable createAlias(String alias) {
    return $SyncProfilesTable(attachedDatabase, alias);
  }
}

class SyncProfile extends DataClass implements Insertable<SyncProfile> {
  final String id;
  final String name;
  final String remoteName;
  final String cloudFolder;
  final String syncMode;
  final int scheduleMinutes;
  final bool enabled;
  final bool respectGitignore;
  final bool excludeGitDirs;
  final bool preserveSourceDir;
  final bool useIncludeMode;
  final String? bandwidthLimit;
  final int maxTransfers;
  final bool checkFirst;
  final DateTime? lastSyncTime;
  final String? lastSyncStatus;
  final String? lastSyncError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SyncProfile({
    required this.id,
    required this.name,
    required this.remoteName,
    required this.cloudFolder,
    required this.syncMode,
    required this.scheduleMinutes,
    required this.enabled,
    required this.respectGitignore,
    required this.excludeGitDirs,
    required this.preserveSourceDir,
    required this.useIncludeMode,
    this.bandwidthLimit,
    required this.maxTransfers,
    required this.checkFirst,
    this.lastSyncTime,
    this.lastSyncStatus,
    this.lastSyncError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['remote_name'] = Variable<String>(remoteName);
    map['cloud_folder'] = Variable<String>(cloudFolder);
    map['sync_mode'] = Variable<String>(syncMode);
    map['schedule_minutes'] = Variable<int>(scheduleMinutes);
    map['enabled'] = Variable<bool>(enabled);
    map['respect_gitignore'] = Variable<bool>(respectGitignore);
    map['exclude_git_dirs'] = Variable<bool>(excludeGitDirs);
    map['preserve_source_dir'] = Variable<bool>(preserveSourceDir);
    map['use_include_mode'] = Variable<bool>(useIncludeMode);
    if (!nullToAbsent || bandwidthLimit != null) {
      map['bandwidth_limit'] = Variable<String>(bandwidthLimit);
    }
    map['max_transfers'] = Variable<int>(maxTransfers);
    map['check_first'] = Variable<bool>(checkFirst);
    if (!nullToAbsent || lastSyncTime != null) {
      map['last_sync_time'] = Variable<DateTime>(lastSyncTime);
    }
    if (!nullToAbsent || lastSyncStatus != null) {
      map['last_sync_status'] = Variable<String>(lastSyncStatus);
    }
    if (!nullToAbsent || lastSyncError != null) {
      map['last_sync_error'] = Variable<String>(lastSyncError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncProfilesCompanion toCompanion(bool nullToAbsent) {
    return SyncProfilesCompanion(
      id: Value(id),
      name: Value(name),
      remoteName: Value(remoteName),
      cloudFolder: Value(cloudFolder),
      syncMode: Value(syncMode),
      scheduleMinutes: Value(scheduleMinutes),
      enabled: Value(enabled),
      respectGitignore: Value(respectGitignore),
      excludeGitDirs: Value(excludeGitDirs),
      preserveSourceDir: Value(preserveSourceDir),
      useIncludeMode: Value(useIncludeMode),
      bandwidthLimit: bandwidthLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(bandwidthLimit),
      maxTransfers: Value(maxTransfers),
      checkFirst: Value(checkFirst),
      lastSyncTime: lastSyncTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncTime),
      lastSyncStatus: lastSyncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncStatus),
      lastSyncError: lastSyncError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      remoteName: serializer.fromJson<String>(json['remoteName']),
      cloudFolder: serializer.fromJson<String>(json['cloudFolder']),
      syncMode: serializer.fromJson<String>(json['syncMode']),
      scheduleMinutes: serializer.fromJson<int>(json['scheduleMinutes']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      respectGitignore: serializer.fromJson<bool>(json['respectGitignore']),
      excludeGitDirs: serializer.fromJson<bool>(json['excludeGitDirs']),
      preserveSourceDir: serializer.fromJson<bool>(json['preserveSourceDir']),
      useIncludeMode: serializer.fromJson<bool>(json['useIncludeMode']),
      bandwidthLimit: serializer.fromJson<String?>(json['bandwidthLimit']),
      maxTransfers: serializer.fromJson<int>(json['maxTransfers']),
      checkFirst: serializer.fromJson<bool>(json['checkFirst']),
      lastSyncTime: serializer.fromJson<DateTime?>(json['lastSyncTime']),
      lastSyncStatus: serializer.fromJson<String?>(json['lastSyncStatus']),
      lastSyncError: serializer.fromJson<String?>(json['lastSyncError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'remoteName': serializer.toJson<String>(remoteName),
      'cloudFolder': serializer.toJson<String>(cloudFolder),
      'syncMode': serializer.toJson<String>(syncMode),
      'scheduleMinutes': serializer.toJson<int>(scheduleMinutes),
      'enabled': serializer.toJson<bool>(enabled),
      'respectGitignore': serializer.toJson<bool>(respectGitignore),
      'excludeGitDirs': serializer.toJson<bool>(excludeGitDirs),
      'preserveSourceDir': serializer.toJson<bool>(preserveSourceDir),
      'useIncludeMode': serializer.toJson<bool>(useIncludeMode),
      'bandwidthLimit': serializer.toJson<String?>(bandwidthLimit),
      'maxTransfers': serializer.toJson<int>(maxTransfers),
      'checkFirst': serializer.toJson<bool>(checkFirst),
      'lastSyncTime': serializer.toJson<DateTime?>(lastSyncTime),
      'lastSyncStatus': serializer.toJson<String?>(lastSyncStatus),
      'lastSyncError': serializer.toJson<String?>(lastSyncError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncProfile copyWith({
    String? id,
    String? name,
    String? remoteName,
    String? cloudFolder,
    String? syncMode,
    int? scheduleMinutes,
    bool? enabled,
    bool? respectGitignore,
    bool? excludeGitDirs,
    bool? preserveSourceDir,
    bool? useIncludeMode,
    Value<String?> bandwidthLimit = const Value.absent(),
    int? maxTransfers,
    bool? checkFirst,
    Value<DateTime?> lastSyncTime = const Value.absent(),
    Value<String?> lastSyncStatus = const Value.absent(),
    Value<String?> lastSyncError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SyncProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    remoteName: remoteName ?? this.remoteName,
    cloudFolder: cloudFolder ?? this.cloudFolder,
    syncMode: syncMode ?? this.syncMode,
    scheduleMinutes: scheduleMinutes ?? this.scheduleMinutes,
    enabled: enabled ?? this.enabled,
    respectGitignore: respectGitignore ?? this.respectGitignore,
    excludeGitDirs: excludeGitDirs ?? this.excludeGitDirs,
    preserveSourceDir: preserveSourceDir ?? this.preserveSourceDir,
    useIncludeMode: useIncludeMode ?? this.useIncludeMode,
    bandwidthLimit: bandwidthLimit.present
        ? bandwidthLimit.value
        : this.bandwidthLimit,
    maxTransfers: maxTransfers ?? this.maxTransfers,
    checkFirst: checkFirst ?? this.checkFirst,
    lastSyncTime: lastSyncTime.present ? lastSyncTime.value : this.lastSyncTime,
    lastSyncStatus: lastSyncStatus.present
        ? lastSyncStatus.value
        : this.lastSyncStatus,
    lastSyncError: lastSyncError.present
        ? lastSyncError.value
        : this.lastSyncError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncProfile copyWithCompanion(SyncProfilesCompanion data) {
    return SyncProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      remoteName: data.remoteName.present
          ? data.remoteName.value
          : this.remoteName,
      cloudFolder: data.cloudFolder.present
          ? data.cloudFolder.value
          : this.cloudFolder,
      syncMode: data.syncMode.present ? data.syncMode.value : this.syncMode,
      scheduleMinutes: data.scheduleMinutes.present
          ? data.scheduleMinutes.value
          : this.scheduleMinutes,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      respectGitignore: data.respectGitignore.present
          ? data.respectGitignore.value
          : this.respectGitignore,
      excludeGitDirs: data.excludeGitDirs.present
          ? data.excludeGitDirs.value
          : this.excludeGitDirs,
      preserveSourceDir: data.preserveSourceDir.present
          ? data.preserveSourceDir.value
          : this.preserveSourceDir,
      useIncludeMode: data.useIncludeMode.present
          ? data.useIncludeMode.value
          : this.useIncludeMode,
      bandwidthLimit: data.bandwidthLimit.present
          ? data.bandwidthLimit.value
          : this.bandwidthLimit,
      maxTransfers: data.maxTransfers.present
          ? data.maxTransfers.value
          : this.maxTransfers,
      checkFirst: data.checkFirst.present
          ? data.checkFirst.value
          : this.checkFirst,
      lastSyncTime: data.lastSyncTime.present
          ? data.lastSyncTime.value
          : this.lastSyncTime,
      lastSyncStatus: data.lastSyncStatus.present
          ? data.lastSyncStatus.value
          : this.lastSyncStatus,
      lastSyncError: data.lastSyncError.present
          ? data.lastSyncError.value
          : this.lastSyncError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('remoteName: $remoteName, ')
          ..write('cloudFolder: $cloudFolder, ')
          ..write('syncMode: $syncMode, ')
          ..write('scheduleMinutes: $scheduleMinutes, ')
          ..write('enabled: $enabled, ')
          ..write('respectGitignore: $respectGitignore, ')
          ..write('excludeGitDirs: $excludeGitDirs, ')
          ..write('preserveSourceDir: $preserveSourceDir, ')
          ..write('useIncludeMode: $useIncludeMode, ')
          ..write('bandwidthLimit: $bandwidthLimit, ')
          ..write('maxTransfers: $maxTransfers, ')
          ..write('checkFirst: $checkFirst, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    remoteName,
    cloudFolder,
    syncMode,
    scheduleMinutes,
    enabled,
    respectGitignore,
    excludeGitDirs,
    preserveSourceDir,
    useIncludeMode,
    bandwidthLimit,
    maxTransfers,
    checkFirst,
    lastSyncTime,
    lastSyncStatus,
    lastSyncError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.remoteName == this.remoteName &&
          other.cloudFolder == this.cloudFolder &&
          other.syncMode == this.syncMode &&
          other.scheduleMinutes == this.scheduleMinutes &&
          other.enabled == this.enabled &&
          other.respectGitignore == this.respectGitignore &&
          other.excludeGitDirs == this.excludeGitDirs &&
          other.preserveSourceDir == this.preserveSourceDir &&
          other.useIncludeMode == this.useIncludeMode &&
          other.bandwidthLimit == this.bandwidthLimit &&
          other.maxTransfers == this.maxTransfers &&
          other.checkFirst == this.checkFirst &&
          other.lastSyncTime == this.lastSyncTime &&
          other.lastSyncStatus == this.lastSyncStatus &&
          other.lastSyncError == this.lastSyncError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SyncProfilesCompanion extends UpdateCompanion<SyncProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> remoteName;
  final Value<String> cloudFolder;
  final Value<String> syncMode;
  final Value<int> scheduleMinutes;
  final Value<bool> enabled;
  final Value<bool> respectGitignore;
  final Value<bool> excludeGitDirs;
  final Value<bool> preserveSourceDir;
  final Value<bool> useIncludeMode;
  final Value<String?> bandwidthLimit;
  final Value<int> maxTransfers;
  final Value<bool> checkFirst;
  final Value<DateTime?> lastSyncTime;
  final Value<String?> lastSyncStatus;
  final Value<String?> lastSyncError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.remoteName = const Value.absent(),
    this.cloudFolder = const Value.absent(),
    this.syncMode = const Value.absent(),
    this.scheduleMinutes = const Value.absent(),
    this.enabled = const Value.absent(),
    this.respectGitignore = const Value.absent(),
    this.excludeGitDirs = const Value.absent(),
    this.preserveSourceDir = const Value.absent(),
    this.useIncludeMode = const Value.absent(),
    this.bandwidthLimit = const Value.absent(),
    this.maxTransfers = const Value.absent(),
    this.checkFirst = const Value.absent(),
    this.lastSyncTime = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncProfilesCompanion.insert({
    required String id,
    required String name,
    required String remoteName,
    required String cloudFolder,
    this.syncMode = const Value.absent(),
    this.scheduleMinutes = const Value.absent(),
    this.enabled = const Value.absent(),
    this.respectGitignore = const Value.absent(),
    this.excludeGitDirs = const Value.absent(),
    this.preserveSourceDir = const Value.absent(),
    this.useIncludeMode = const Value.absent(),
    this.bandwidthLimit = const Value.absent(),
    this.maxTransfers = const Value.absent(),
    this.checkFirst = const Value.absent(),
    this.lastSyncTime = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       remoteName = Value(remoteName),
       cloudFolder = Value(cloudFolder);
  static Insertable<SyncProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? remoteName,
    Expression<String>? cloudFolder,
    Expression<String>? syncMode,
    Expression<int>? scheduleMinutes,
    Expression<bool>? enabled,
    Expression<bool>? respectGitignore,
    Expression<bool>? excludeGitDirs,
    Expression<bool>? preserveSourceDir,
    Expression<bool>? useIncludeMode,
    Expression<String>? bandwidthLimit,
    Expression<int>? maxTransfers,
    Expression<bool>? checkFirst,
    Expression<DateTime>? lastSyncTime,
    Expression<String>? lastSyncStatus,
    Expression<String>? lastSyncError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (remoteName != null) 'remote_name': remoteName,
      if (cloudFolder != null) 'cloud_folder': cloudFolder,
      if (syncMode != null) 'sync_mode': syncMode,
      if (scheduleMinutes != null) 'schedule_minutes': scheduleMinutes,
      if (enabled != null) 'enabled': enabled,
      if (respectGitignore != null) 'respect_gitignore': respectGitignore,
      if (excludeGitDirs != null) 'exclude_git_dirs': excludeGitDirs,
      if (preserveSourceDir != null) 'preserve_source_dir': preserveSourceDir,
      if (useIncludeMode != null) 'use_include_mode': useIncludeMode,
      if (bandwidthLimit != null) 'bandwidth_limit': bandwidthLimit,
      if (maxTransfers != null) 'max_transfers': maxTransfers,
      if (checkFirst != null) 'check_first': checkFirst,
      if (lastSyncTime != null) 'last_sync_time': lastSyncTime,
      if (lastSyncStatus != null) 'last_sync_status': lastSyncStatus,
      if (lastSyncError != null) 'last_sync_error': lastSyncError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? remoteName,
    Value<String>? cloudFolder,
    Value<String>? syncMode,
    Value<int>? scheduleMinutes,
    Value<bool>? enabled,
    Value<bool>? respectGitignore,
    Value<bool>? excludeGitDirs,
    Value<bool>? preserveSourceDir,
    Value<bool>? useIncludeMode,
    Value<String?>? bandwidthLimit,
    Value<int>? maxTransfers,
    Value<bool>? checkFirst,
    Value<DateTime?>? lastSyncTime,
    Value<String?>? lastSyncStatus,
    Value<String?>? lastSyncError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      remoteName: remoteName ?? this.remoteName,
      cloudFolder: cloudFolder ?? this.cloudFolder,
      syncMode: syncMode ?? this.syncMode,
      scheduleMinutes: scheduleMinutes ?? this.scheduleMinutes,
      enabled: enabled ?? this.enabled,
      respectGitignore: respectGitignore ?? this.respectGitignore,
      excludeGitDirs: excludeGitDirs ?? this.excludeGitDirs,
      preserveSourceDir: preserveSourceDir ?? this.preserveSourceDir,
      useIncludeMode: useIncludeMode ?? this.useIncludeMode,
      bandwidthLimit: bandwidthLimit ?? this.bandwidthLimit,
      maxTransfers: maxTransfers ?? this.maxTransfers,
      checkFirst: checkFirst ?? this.checkFirst,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (remoteName.present) {
      map['remote_name'] = Variable<String>(remoteName.value);
    }
    if (cloudFolder.present) {
      map['cloud_folder'] = Variable<String>(cloudFolder.value);
    }
    if (syncMode.present) {
      map['sync_mode'] = Variable<String>(syncMode.value);
    }
    if (scheduleMinutes.present) {
      map['schedule_minutes'] = Variable<int>(scheduleMinutes.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (respectGitignore.present) {
      map['respect_gitignore'] = Variable<bool>(respectGitignore.value);
    }
    if (excludeGitDirs.present) {
      map['exclude_git_dirs'] = Variable<bool>(excludeGitDirs.value);
    }
    if (preserveSourceDir.present) {
      map['preserve_source_dir'] = Variable<bool>(preserveSourceDir.value);
    }
    if (useIncludeMode.present) {
      map['use_include_mode'] = Variable<bool>(useIncludeMode.value);
    }
    if (bandwidthLimit.present) {
      map['bandwidth_limit'] = Variable<String>(bandwidthLimit.value);
    }
    if (maxTransfers.present) {
      map['max_transfers'] = Variable<int>(maxTransfers.value);
    }
    if (checkFirst.present) {
      map['check_first'] = Variable<bool>(checkFirst.value);
    }
    if (lastSyncTime.present) {
      map['last_sync_time'] = Variable<DateTime>(lastSyncTime.value);
    }
    if (lastSyncStatus.present) {
      map['last_sync_status'] = Variable<String>(lastSyncStatus.value);
    }
    if (lastSyncError.present) {
      map['last_sync_error'] = Variable<String>(lastSyncError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('remoteName: $remoteName, ')
          ..write('cloudFolder: $cloudFolder, ')
          ..write('syncMode: $syncMode, ')
          ..write('scheduleMinutes: $scheduleMinutes, ')
          ..write('enabled: $enabled, ')
          ..write('respectGitignore: $respectGitignore, ')
          ..write('excludeGitDirs: $excludeGitDirs, ')
          ..write('preserveSourceDir: $preserveSourceDir, ')
          ..write('useIncludeMode: $useIncludeMode, ')
          ..write('bandwidthLimit: $bandwidthLimit, ')
          ..write('maxTransfers: $maxTransfers, ')
          ..write('checkFirst: $checkFirst, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileLocalPathsTable extends ProfileLocalPaths
    with TableInfo<$ProfileLocalPathsTable, ProfileLocalPath> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileLocalPathsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_profiles (id)',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, profileId, path];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_local_paths';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileLocalPath> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileLocalPath map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileLocalPath(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
    );
  }

  @override
  $ProfileLocalPathsTable createAlias(String alias) {
    return $ProfileLocalPathsTable(attachedDatabase, alias);
  }
}

class ProfileLocalPath extends DataClass
    implements Insertable<ProfileLocalPath> {
  final int id;
  final String profileId;
  final String path;
  const ProfileLocalPath({
    required this.id,
    required this.profileId,
    required this.path,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['path'] = Variable<String>(path);
    return map;
  }

  ProfileLocalPathsCompanion toCompanion(bool nullToAbsent) {
    return ProfileLocalPathsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      path: Value(path),
    );
  }

  factory ProfileLocalPath.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileLocalPath(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      path: serializer.fromJson<String>(json['path']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'path': serializer.toJson<String>(path),
    };
  }

  ProfileLocalPath copyWith({int? id, String? profileId, String? path}) =>
      ProfileLocalPath(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        path: path ?? this.path,
      );
  ProfileLocalPath copyWithCompanion(ProfileLocalPathsCompanion data) {
    return ProfileLocalPath(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      path: data.path.present ? data.path.value : this.path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLocalPath(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, path);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileLocalPath &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.path == this.path);
}

class ProfileLocalPathsCompanion extends UpdateCompanion<ProfileLocalPath> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> path;
  const ProfileLocalPathsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.path = const Value.absent(),
  });
  ProfileLocalPathsCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String path,
  }) : profileId = Value(profileId),
       path = Value(path);
  static Insertable<ProfileLocalPath> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? path,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (path != null) 'path': path,
    });
  }

  ProfileLocalPathsCompanion copyWith({
    Value<int>? id,
    Value<String>? profileId,
    Value<String>? path,
  }) {
    return ProfileLocalPathsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      path: path ?? this.path,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileLocalPathsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }
}

class $ProfileFilterTypesTable extends ProfileFilterTypes
    with TableInfo<$ProfileFilterTypesTable, ProfileFilterType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileFilterTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_profiles (id)',
    ),
  );
  static const VerificationMeta _typeValueMeta = const VerificationMeta(
    'typeValue',
  );
  @override
  late final GeneratedColumn<String> typeValue = GeneratedColumn<String>(
    'type_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isIncludeMeta = const VerificationMeta(
    'isInclude',
  );
  @override
  late final GeneratedColumn<bool> isInclude = GeneratedColumn<bool>(
    'is_include',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_include" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, profileId, typeValue, isInclude];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_filter_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileFilterType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('type_value')) {
      context.handle(
        _typeValueMeta,
        typeValue.isAcceptableOrUnknown(data['type_value']!, _typeValueMeta),
      );
    } else if (isInserting) {
      context.missing(_typeValueMeta);
    }
    if (data.containsKey('is_include')) {
      context.handle(
        _isIncludeMeta,
        isInclude.isAcceptableOrUnknown(data['is_include']!, _isIncludeMeta),
      );
    } else if (isInserting) {
      context.missing(_isIncludeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileFilterType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileFilterType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      typeValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_value'],
      )!,
      isInclude: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_include'],
      )!,
    );
  }

  @override
  $ProfileFilterTypesTable createAlias(String alias) {
    return $ProfileFilterTypesTable(attachedDatabase, alias);
  }
}

class ProfileFilterType extends DataClass
    implements Insertable<ProfileFilterType> {
  final int id;
  final String profileId;
  final String typeValue;
  final bool isInclude;
  const ProfileFilterType({
    required this.id,
    required this.profileId,
    required this.typeValue,
    required this.isInclude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['type_value'] = Variable<String>(typeValue);
    map['is_include'] = Variable<bool>(isInclude);
    return map;
  }

  ProfileFilterTypesCompanion toCompanion(bool nullToAbsent) {
    return ProfileFilterTypesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      typeValue: Value(typeValue),
      isInclude: Value(isInclude),
    );
  }

  factory ProfileFilterType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileFilterType(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      typeValue: serializer.fromJson<String>(json['typeValue']),
      isInclude: serializer.fromJson<bool>(json['isInclude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'typeValue': serializer.toJson<String>(typeValue),
      'isInclude': serializer.toJson<bool>(isInclude),
    };
  }

  ProfileFilterType copyWith({
    int? id,
    String? profileId,
    String? typeValue,
    bool? isInclude,
  }) => ProfileFilterType(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    typeValue: typeValue ?? this.typeValue,
    isInclude: isInclude ?? this.isInclude,
  );
  ProfileFilterType copyWithCompanion(ProfileFilterTypesCompanion data) {
    return ProfileFilterType(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      typeValue: data.typeValue.present ? data.typeValue.value : this.typeValue,
      isInclude: data.isInclude.present ? data.isInclude.value : this.isInclude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileFilterType(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('typeValue: $typeValue, ')
          ..write('isInclude: $isInclude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, typeValue, isInclude);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileFilterType &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.typeValue == this.typeValue &&
          other.isInclude == this.isInclude);
}

class ProfileFilterTypesCompanion extends UpdateCompanion<ProfileFilterType> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> typeValue;
  final Value<bool> isInclude;
  const ProfileFilterTypesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.typeValue = const Value.absent(),
    this.isInclude = const Value.absent(),
  });
  ProfileFilterTypesCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String typeValue,
    required bool isInclude,
  }) : profileId = Value(profileId),
       typeValue = Value(typeValue),
       isInclude = Value(isInclude);
  static Insertable<ProfileFilterType> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? typeValue,
    Expression<bool>? isInclude,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (typeValue != null) 'type_value': typeValue,
      if (isInclude != null) 'is_include': isInclude,
    });
  }

  ProfileFilterTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? profileId,
    Value<String>? typeValue,
    Value<bool>? isInclude,
  }) {
    return ProfileFilterTypesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      typeValue: typeValue ?? this.typeValue,
      isInclude: isInclude ?? this.isInclude,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (typeValue.present) {
      map['type_value'] = Variable<String>(typeValue.value);
    }
    if (isInclude.present) {
      map['is_include'] = Variable<bool>(isInclude.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileFilterTypesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('typeValue: $typeValue, ')
          ..write('isInclude: $isInclude')
          ..write(')'))
        .toString();
  }
}

class $ProfileCustomExcludesTable extends ProfileCustomExcludes
    with TableInfo<$ProfileCustomExcludesTable, ProfileCustomExclude> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileCustomExcludesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_profiles (id)',
    ),
  );
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, profileId, pattern];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_custom_excludes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileCustomExclude> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileCustomExclude map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileCustomExclude(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
    );
  }

  @override
  $ProfileCustomExcludesTable createAlias(String alias) {
    return $ProfileCustomExcludesTable(attachedDatabase, alias);
  }
}

class ProfileCustomExclude extends DataClass
    implements Insertable<ProfileCustomExclude> {
  final int id;
  final String profileId;
  final String pattern;
  const ProfileCustomExclude({
    required this.id,
    required this.profileId,
    required this.pattern,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['pattern'] = Variable<String>(pattern);
    return map;
  }

  ProfileCustomExcludesCompanion toCompanion(bool nullToAbsent) {
    return ProfileCustomExcludesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      pattern: Value(pattern),
    );
  }

  factory ProfileCustomExclude.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileCustomExclude(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      pattern: serializer.fromJson<String>(json['pattern']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'pattern': serializer.toJson<String>(pattern),
    };
  }

  ProfileCustomExclude copyWith({
    int? id,
    String? profileId,
    String? pattern,
  }) => ProfileCustomExclude(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    pattern: pattern ?? this.pattern,
  );
  ProfileCustomExclude copyWithCompanion(ProfileCustomExcludesCompanion data) {
    return ProfileCustomExclude(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCustomExclude(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('pattern: $pattern')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileId, pattern);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileCustomExclude &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.pattern == this.pattern);
}

class ProfileCustomExcludesCompanion
    extends UpdateCompanion<ProfileCustomExclude> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> pattern;
  const ProfileCustomExcludesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.pattern = const Value.absent(),
  });
  ProfileCustomExcludesCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String pattern,
  }) : profileId = Value(profileId),
       pattern = Value(pattern);
  static Insertable<ProfileCustomExclude> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? pattern,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (pattern != null) 'pattern': pattern,
    });
  }

  ProfileCustomExcludesCompanion copyWith({
    Value<int>? id,
    Value<String>? profileId,
    Value<String>? pattern,
  }) {
    return ProfileCustomExcludesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      pattern: pattern ?? this.pattern,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCustomExcludesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('pattern: $pattern')
          ..write(')'))
        .toString();
  }
}

class $SyncHistoryEntriesTable extends SyncHistoryEntries
    with TableInfo<$SyncHistoryEntriesTable, SyncHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_profiles (id)',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filesTransferredMeta = const VerificationMeta(
    'filesTransferred',
  );
  @override
  late final GeneratedColumn<int> filesTransferred = GeneratedColumn<int>(
    'files_transferred',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bytesTransferredMeta = const VerificationMeta(
    'bytesTransferred',
  );
  @override
  late final GeneratedColumn<int> bytesTransferred = GeneratedColumn<int>(
    'bytes_transferred',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    timestamp,
    status,
    filesTransferred,
    bytesTransferred,
    durationMs,
    error,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('files_transferred')) {
      context.handle(
        _filesTransferredMeta,
        filesTransferred.isAcceptableOrUnknown(
          data['files_transferred']!,
          _filesTransferredMeta,
        ),
      );
    }
    if (data.containsKey('bytes_transferred')) {
      context.handle(
        _bytesTransferredMeta,
        bytesTransferred.isAcceptableOrUnknown(
          data['bytes_transferred']!,
          _bytesTransferredMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      filesTransferred: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}files_transferred'],
      )!,
      bytesTransferred: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_transferred'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
    );
  }

  @override
  $SyncHistoryEntriesTable createAlias(String alias) {
    return $SyncHistoryEntriesTable(attachedDatabase, alias);
  }
}

class SyncHistoryEntry extends DataClass
    implements Insertable<SyncHistoryEntry> {
  final int id;
  final String profileId;
  final DateTime timestamp;
  final String status;
  final int filesTransferred;
  final int bytesTransferred;
  final int durationMs;
  final String? error;
  const SyncHistoryEntry({
    required this.id,
    required this.profileId,
    required this.timestamp,
    required this.status,
    required this.filesTransferred,
    required this.bytesTransferred,
    required this.durationMs,
    this.error,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['status'] = Variable<String>(status);
    map['files_transferred'] = Variable<int>(filesTransferred);
    map['bytes_transferred'] = Variable<int>(bytesTransferred);
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  SyncHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncHistoryEntriesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      timestamp: Value(timestamp),
      status: Value(status),
      filesTransferred: Value(filesTransferred),
      bytesTransferred: Value(bytesTransferred),
      durationMs: Value(durationMs),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
    );
  }

  factory SyncHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncHistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      status: serializer.fromJson<String>(json['status']),
      filesTransferred: serializer.fromJson<int>(json['filesTransferred']),
      bytesTransferred: serializer.fromJson<int>(json['bytesTransferred']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'status': serializer.toJson<String>(status),
      'filesTransferred': serializer.toJson<int>(filesTransferred),
      'bytesTransferred': serializer.toJson<int>(bytesTransferred),
      'durationMs': serializer.toJson<int>(durationMs),
      'error': serializer.toJson<String?>(error),
    };
  }

  SyncHistoryEntry copyWith({
    int? id,
    String? profileId,
    DateTime? timestamp,
    String? status,
    int? filesTransferred,
    int? bytesTransferred,
    int? durationMs,
    Value<String?> error = const Value.absent(),
  }) => SyncHistoryEntry(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    timestamp: timestamp ?? this.timestamp,
    status: status ?? this.status,
    filesTransferred: filesTransferred ?? this.filesTransferred,
    bytesTransferred: bytesTransferred ?? this.bytesTransferred,
    durationMs: durationMs ?? this.durationMs,
    error: error.present ? error.value : this.error,
  );
  SyncHistoryEntry copyWithCompanion(SyncHistoryEntriesCompanion data) {
    return SyncHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      status: data.status.present ? data.status.value : this.status,
      filesTransferred: data.filesTransferred.present
          ? data.filesTransferred.value
          : this.filesTransferred,
      bytesTransferred: data.bytesTransferred.present
          ? data.bytesTransferred.value
          : this.bytesTransferred,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncHistoryEntry(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('filesTransferred: $filesTransferred, ')
          ..write('bytesTransferred: $bytesTransferred, ')
          ..write('durationMs: $durationMs, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    timestamp,
    status,
    filesTransferred,
    bytesTransferred,
    durationMs,
    error,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncHistoryEntry &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.timestamp == this.timestamp &&
          other.status == this.status &&
          other.filesTransferred == this.filesTransferred &&
          other.bytesTransferred == this.bytesTransferred &&
          other.durationMs == this.durationMs &&
          other.error == this.error);
}

class SyncHistoryEntriesCompanion extends UpdateCompanion<SyncHistoryEntry> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<DateTime> timestamp;
  final Value<String> status;
  final Value<int> filesTransferred;
  final Value<int> bytesTransferred;
  final Value<int> durationMs;
  final Value<String?> error;
  const SyncHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.status = const Value.absent(),
    this.filesTransferred = const Value.absent(),
    this.bytesTransferred = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.error = const Value.absent(),
  });
  SyncHistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required DateTime timestamp,
    required String status,
    this.filesTransferred = const Value.absent(),
    this.bytesTransferred = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.error = const Value.absent(),
  }) : profileId = Value(profileId),
       timestamp = Value(timestamp),
       status = Value(status);
  static Insertable<SyncHistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<DateTime>? timestamp,
    Expression<String>? status,
    Expression<int>? filesTransferred,
    Expression<int>? bytesTransferred,
    Expression<int>? durationMs,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (timestamp != null) 'timestamp': timestamp,
      if (status != null) 'status': status,
      if (filesTransferred != null) 'files_transferred': filesTransferred,
      if (bytesTransferred != null) 'bytes_transferred': bytesTransferred,
      if (durationMs != null) 'duration_ms': durationMs,
      if (error != null) 'error': error,
    });
  }

  SyncHistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? profileId,
    Value<DateTime>? timestamp,
    Value<String>? status,
    Value<int>? filesTransferred,
    Value<int>? bytesTransferred,
    Value<int>? durationMs,
    Value<String?>? error,
  }) {
    return SyncHistoryEntriesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      filesTransferred: filesTransferred ?? this.filesTransferred,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      durationMs: durationMs ?? this.durationMs,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (filesTransferred.present) {
      map['files_transferred'] = Variable<int>(filesTransferred.value);
    }
    if (bytesTransferred.present) {
      map['bytes_transferred'] = Variable<int>(bytesTransferred.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('filesTransferred: $filesTransferred, ')
          ..write('bytesTransferred: $bytesTransferred, ')
          ..write('durationMs: $durationMs, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

class $TransferredFilesTable extends TransferredFiles
    with TableInfo<$TransferredFilesTable, TransferredFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransferredFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _historyIdMeta = const VerificationMeta(
    'historyId',
  );
  @override
  late final GeneratedColumn<int> historyId = GeneratedColumn<int>(
    'history_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sync_history_entries (id)',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    historyId,
    fileName,
    fileSize,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transferred_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransferredFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('history_id')) {
      context.handle(
        _historyIdMeta,
        historyId.isAcceptableOrUnknown(data['history_id']!, _historyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_historyIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransferredFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransferredFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      historyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $TransferredFilesTable createAlias(String alias) {
    return $TransferredFilesTable(attachedDatabase, alias);
  }
}

class TransferredFile extends DataClass implements Insertable<TransferredFile> {
  final int id;
  final int historyId;
  final String fileName;
  final int fileSize;
  final String? completedAt;
  const TransferredFile({
    required this.id,
    required this.historyId,
    required this.fileName,
    required this.fileSize,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['history_id'] = Variable<int>(historyId);
    map['file_name'] = Variable<String>(fileName);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<String>(completedAt);
    }
    return map;
  }

  TransferredFilesCompanion toCompanion(bool nullToAbsent) {
    return TransferredFilesCompanion(
      id: Value(id),
      historyId: Value(historyId),
      fileName: Value(fileName),
      fileSize: Value(fileSize),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory TransferredFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransferredFile(
      id: serializer.fromJson<int>(json['id']),
      historyId: serializer.fromJson<int>(json['historyId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      completedAt: serializer.fromJson<String?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'historyId': serializer.toJson<int>(historyId),
      'fileName': serializer.toJson<String>(fileName),
      'fileSize': serializer.toJson<int>(fileSize),
      'completedAt': serializer.toJson<String?>(completedAt),
    };
  }

  TransferredFile copyWith({
    int? id,
    int? historyId,
    String? fileName,
    int? fileSize,
    Value<String?> completedAt = const Value.absent(),
  }) => TransferredFile(
    id: id ?? this.id,
    historyId: historyId ?? this.historyId,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize ?? this.fileSize,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  TransferredFile copyWithCompanion(TransferredFilesCompanion data) {
    return TransferredFile(
      id: data.id.present ? data.id.value : this.id,
      historyId: data.historyId.present ? data.historyId.value : this.historyId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransferredFile(')
          ..write('id: $id, ')
          ..write('historyId: $historyId, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, historyId, fileName, fileSize, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransferredFile &&
          other.id == this.id &&
          other.historyId == this.historyId &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.completedAt == this.completedAt);
}

class TransferredFilesCompanion extends UpdateCompanion<TransferredFile> {
  final Value<int> id;
  final Value<int> historyId;
  final Value<String> fileName;
  final Value<int> fileSize;
  final Value<String?> completedAt;
  const TransferredFilesCompanion({
    this.id = const Value.absent(),
    this.historyId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  TransferredFilesCompanion.insert({
    this.id = const Value.absent(),
    required int historyId,
    required String fileName,
    this.fileSize = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : historyId = Value(historyId),
       fileName = Value(fileName);
  static Insertable<TransferredFile> custom({
    Expression<int>? id,
    Expression<int>? historyId,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<String>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (historyId != null) 'history_id': historyId,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  TransferredFilesCompanion copyWith({
    Value<int>? id,
    Value<int>? historyId,
    Value<String>? fileName,
    Value<int>? fileSize,
    Value<String?>? completedAt,
  }) {
    return TransferredFilesCompanion(
      id: id ?? this.id,
      historyId: historyId ?? this.historyId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (historyId.present) {
      map['history_id'] = Variable<int>(historyId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransferredFilesCompanion(')
          ..write('id: $id, ')
          ..write('historyId: $historyId, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppConfigsTable appConfigs = $AppConfigsTable(this);
  late final $SyncProfilesTable syncProfiles = $SyncProfilesTable(this);
  late final $ProfileLocalPathsTable profileLocalPaths =
      $ProfileLocalPathsTable(this);
  late final $ProfileFilterTypesTable profileFilterTypes =
      $ProfileFilterTypesTable(this);
  late final $ProfileCustomExcludesTable profileCustomExcludes =
      $ProfileCustomExcludesTable(this);
  late final $SyncHistoryEntriesTable syncHistoryEntries =
      $SyncHistoryEntriesTable(this);
  late final $TransferredFilesTable transferredFiles = $TransferredFilesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appConfigs,
    syncProfiles,
    profileLocalPaths,
    profileFilterTypes,
    profileCustomExcludes,
    syncHistoryEntries,
    transferredFiles,
  ];
}

typedef $$AppConfigsTableCreateCompanionBuilder =
    AppConfigsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<bool> launchAtLogin,
      Value<bool> showInMenuBar,
      Value<bool> showNotifications,
      Value<int> rcPort,
      Value<String?> skippedVersion,
      Value<String?> bandwidthLimit,
    });
typedef $$AppConfigsTableUpdateCompanionBuilder =
    AppConfigsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<bool> launchAtLogin,
      Value<bool> showInMenuBar,
      Value<bool> showNotifications,
      Value<int> rcPort,
      Value<String?> skippedVersion,
      Value<String?> bandwidthLimit,
    });

class $$AppConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $AppConfigsTable> {
  $$AppConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showInMenuBar => $composableBuilder(
    column: $table.showInMenuBar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showNotifications => $composableBuilder(
    column: $table.showNotifications,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rcPort => $composableBuilder(
    column: $table.rcPort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skippedVersion => $composableBuilder(
    column: $table.skippedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bandwidthLimit => $composableBuilder(
    column: $table.bandwidthLimit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppConfigsTable> {
  $$AppConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showInMenuBar => $composableBuilder(
    column: $table.showInMenuBar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showNotifications => $composableBuilder(
    column: $table.showNotifications,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rcPort => $composableBuilder(
    column: $table.rcPort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skippedVersion => $composableBuilder(
    column: $table.skippedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bandwidthLimit => $composableBuilder(
    column: $table.bandwidthLimit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppConfigsTable> {
  $$AppConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showInMenuBar => $composableBuilder(
    column: $table.showInMenuBar,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showNotifications => $composableBuilder(
    column: $table.showNotifications,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rcPort =>
      $composableBuilder(column: $table.rcPort, builder: (column) => column);

  GeneratedColumn<String> get skippedVersion => $composableBuilder(
    column: $table.skippedVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bandwidthLimit => $composableBuilder(
    column: $table.bandwidthLimit,
    builder: (column) => column,
  );
}

class $$AppConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppConfigsTable,
          AppConfig,
          $$AppConfigsTableFilterComposer,
          $$AppConfigsTableOrderingComposer,
          $$AppConfigsTableAnnotationComposer,
          $$AppConfigsTableCreateCompanionBuilder,
          $$AppConfigsTableUpdateCompanionBuilder,
          (
            AppConfig,
            BaseReferences<_$AppDatabase, $AppConfigsTable, AppConfig>,
          ),
          AppConfig,
          PrefetchHooks Function()
        > {
  $$AppConfigsTableTableManager(_$AppDatabase db, $AppConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> launchAtLogin = const Value.absent(),
                Value<bool> showInMenuBar = const Value.absent(),
                Value<bool> showNotifications = const Value.absent(),
                Value<int> rcPort = const Value.absent(),
                Value<String?> skippedVersion = const Value.absent(),
                Value<String?> bandwidthLimit = const Value.absent(),
              }) => AppConfigsCompanion(
                id: id,
                themeMode: themeMode,
                launchAtLogin: launchAtLogin,
                showInMenuBar: showInMenuBar,
                showNotifications: showNotifications,
                rcPort: rcPort,
                skippedVersion: skippedVersion,
                bandwidthLimit: bandwidthLimit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> launchAtLogin = const Value.absent(),
                Value<bool> showInMenuBar = const Value.absent(),
                Value<bool> showNotifications = const Value.absent(),
                Value<int> rcPort = const Value.absent(),
                Value<String?> skippedVersion = const Value.absent(),
                Value<String?> bandwidthLimit = const Value.absent(),
              }) => AppConfigsCompanion.insert(
                id: id,
                themeMode: themeMode,
                launchAtLogin: launchAtLogin,
                showInMenuBar: showInMenuBar,
                showNotifications: showNotifications,
                rcPort: rcPort,
                skippedVersion: skippedVersion,
                bandwidthLimit: bandwidthLimit,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppConfigsTable,
      AppConfig,
      $$AppConfigsTableFilterComposer,
      $$AppConfigsTableOrderingComposer,
      $$AppConfigsTableAnnotationComposer,
      $$AppConfigsTableCreateCompanionBuilder,
      $$AppConfigsTableUpdateCompanionBuilder,
      (AppConfig, BaseReferences<_$AppDatabase, $AppConfigsTable, AppConfig>),
      AppConfig,
      PrefetchHooks Function()
    >;
typedef $$SyncProfilesTableCreateCompanionBuilder =
    SyncProfilesCompanion Function({
      required String id,
      required String name,
      required String remoteName,
      required String cloudFolder,
      Value<String> syncMode,
      Value<int> scheduleMinutes,
      Value<bool> enabled,
      Value<bool> respectGitignore,
      Value<bool> excludeGitDirs,
      Value<bool> preserveSourceDir,
      Value<bool> useIncludeMode,
      Value<String?> bandwidthLimit,
      Value<int> maxTransfers,
      Value<bool> checkFirst,
      Value<DateTime?> lastSyncTime,
      Value<String?> lastSyncStatus,
      Value<String?> lastSyncError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SyncProfilesTableUpdateCompanionBuilder =
    SyncProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> remoteName,
      Value<String> cloudFolder,
      Value<String> syncMode,
      Value<int> scheduleMinutes,
      Value<bool> enabled,
      Value<bool> respectGitignore,
      Value<bool> excludeGitDirs,
      Value<bool> preserveSourceDir,
      Value<bool> useIncludeMode,
      Value<String?> bandwidthLimit,
      Value<int> maxTransfers,
      Value<bool> checkFirst,
      Value<DateTime?> lastSyncTime,
      Value<String?> lastSyncStatus,
      Value<String?> lastSyncError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SyncProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $SyncProfilesTable, SyncProfile> {
  $$SyncProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfileLocalPathsTable, List<ProfileLocalPath>>
  _profileLocalPathsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.profileLocalPaths,
        aliasName: $_aliasNameGenerator(
          db.syncProfiles.id,
          db.profileLocalPaths.profileId,
        ),
      );

  $$ProfileLocalPathsTableProcessedTableManager get profileLocalPathsRefs {
    final manager = $$ProfileLocalPathsTableTableManager(
      $_db,
      $_db.profileLocalPaths,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileLocalPathsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProfileFilterTypesTable, List<ProfileFilterType>>
  _profileFilterTypesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.profileFilterTypes,
        aliasName: $_aliasNameGenerator(
          db.syncProfiles.id,
          db.profileFilterTypes.profileId,
        ),
      );

  $$ProfileFilterTypesTableProcessedTableManager get profileFilterTypesRefs {
    final manager = $$ProfileFilterTypesTableTableManager(
      $_db,
      $_db.profileFilterTypes,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileFilterTypesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProfileCustomExcludesTable,
    List<ProfileCustomExclude>
  >
  _profileCustomExcludesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.profileCustomExcludes,
        aliasName: $_aliasNameGenerator(
          db.syncProfiles.id,
          db.profileCustomExcludes.profileId,
        ),
      );

  $$ProfileCustomExcludesTableProcessedTableManager
  get profileCustomExcludesRefs {
    final manager = $$ProfileCustomExcludesTableTableManager(
      $_db,
      $_db.profileCustomExcludes,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _profileCustomExcludesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncHistoryEntriesTable, List<SyncHistoryEntry>>
  _syncHistoryEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.syncHistoryEntries,
        aliasName: $_aliasNameGenerator(
          db.syncProfiles.id,
          db.syncHistoryEntries.profileId,
        ),
      );

  $$SyncHistoryEntriesTableProcessedTableManager get syncHistoryEntriesRefs {
    final manager = $$SyncHistoryEntriesTableTableManager(
      $_db,
      $_db.syncHistoryEntries,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _syncHistoryEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SyncProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncProfilesTable> {
  $$SyncProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteName => $composableBuilder(
    column: $table.remoteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudFolder => $composableBuilder(
    column: $table.cloudFolder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncMode => $composableBuilder(
    column: $table.syncMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduleMinutes => $composableBuilder(
    column: $table.scheduleMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get respectGitignore => $composableBuilder(
    column: $table.respectGitignore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excludeGitDirs => $composableBuilder(
    column: $table.excludeGitDirs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get preserveSourceDir => $composableBuilder(
    column: $table.preserveSourceDir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get useIncludeMode => $composableBuilder(
    column: $table.useIncludeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bandwidthLimit => $composableBuilder(
    column: $table.bandwidthLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxTransfers => $composableBuilder(
    column: $table.maxTransfers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get checkFirst => $composableBuilder(
    column: $table.checkFirst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncTime => $composableBuilder(
    column: $table.lastSyncTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncStatus => $composableBuilder(
    column: $table.lastSyncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> profileLocalPathsRefs(
    Expression<bool> Function($$ProfileLocalPathsTableFilterComposer f) f,
  ) {
    final $$ProfileLocalPathsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileLocalPaths,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileLocalPathsTableFilterComposer(
            $db: $db,
            $table: $db.profileLocalPaths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> profileFilterTypesRefs(
    Expression<bool> Function($$ProfileFilterTypesTableFilterComposer f) f,
  ) {
    final $$ProfileFilterTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profileFilterTypes,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfileFilterTypesTableFilterComposer(
            $db: $db,
            $table: $db.profileFilterTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> profileCustomExcludesRefs(
    Expression<bool> Function($$ProfileCustomExcludesTableFilterComposer f) f,
  ) {
    final $$ProfileCustomExcludesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.profileCustomExcludes,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProfileCustomExcludesTableFilterComposer(
                $db: $db,
                $table: $db.profileCustomExcludes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> syncHistoryEntriesRefs(
    Expression<bool> Function($$SyncHistoryEntriesTableFilterComposer f) f,
  ) {
    final $$SyncHistoryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncHistoryEntries,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncHistoryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.syncHistoryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncProfilesTable> {
  $$SyncProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteName => $composableBuilder(
    column: $table.remoteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudFolder => $composableBuilder(
    column: $table.cloudFolder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncMode => $composableBuilder(
    column: $table.syncMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduleMinutes => $composableBuilder(
    column: $table.scheduleMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get respectGitignore => $composableBuilder(
    column: $table.respectGitignore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excludeGitDirs => $composableBuilder(
    column: $table.excludeGitDirs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get preserveSourceDir => $composableBuilder(
    column: $table.preserveSourceDir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useIncludeMode => $composableBuilder(
    column: $table.useIncludeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bandwidthLimit => $composableBuilder(
    column: $table.bandwidthLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxTransfers => $composableBuilder(
    column: $table.maxTransfers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get checkFirst => $composableBuilder(
    column: $table.checkFirst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncTime => $composableBuilder(
    column: $table.lastSyncTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncStatus => $composableBuilder(
    column: $table.lastSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncProfilesTable> {
  $$SyncProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get remoteName => $composableBuilder(
    column: $table.remoteName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cloudFolder => $composableBuilder(
    column: $table.cloudFolder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncMode =>
      $composableBuilder(column: $table.syncMode, builder: (column) => column);

  GeneratedColumn<int> get scheduleMinutes => $composableBuilder(
    column: $table.scheduleMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get respectGitignore => $composableBuilder(
    column: $table.respectGitignore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excludeGitDirs => $composableBuilder(
    column: $table.excludeGitDirs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get preserveSourceDir => $composableBuilder(
    column: $table.preserveSourceDir,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get useIncludeMode => $composableBuilder(
    column: $table.useIncludeMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bandwidthLimit => $composableBuilder(
    column: $table.bandwidthLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxTransfers => $composableBuilder(
    column: $table.maxTransfers,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get checkFirst => $composableBuilder(
    column: $table.checkFirst,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncTime => $composableBuilder(
    column: $table.lastSyncTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncStatus => $composableBuilder(
    column: $table.lastSyncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> profileLocalPathsRefs<T extends Object>(
    Expression<T> Function($$ProfileLocalPathsTableAnnotationComposer a) f,
  ) {
    final $$ProfileLocalPathsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.profileLocalPaths,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProfileLocalPathsTableAnnotationComposer(
                $db: $db,
                $table: $db.profileLocalPaths,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> profileFilterTypesRefs<T extends Object>(
    Expression<T> Function($$ProfileFilterTypesTableAnnotationComposer a) f,
  ) {
    final $$ProfileFilterTypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.profileFilterTypes,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProfileFilterTypesTableAnnotationComposer(
                $db: $db,
                $table: $db.profileFilterTypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> profileCustomExcludesRefs<T extends Object>(
    Expression<T> Function($$ProfileCustomExcludesTableAnnotationComposer a) f,
  ) {
    final $$ProfileCustomExcludesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.profileCustomExcludes,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProfileCustomExcludesTableAnnotationComposer(
                $db: $db,
                $table: $db.profileCustomExcludes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> syncHistoryEntriesRefs<T extends Object>(
    Expression<T> Function($$SyncHistoryEntriesTableAnnotationComposer a) f,
  ) {
    final $$SyncHistoryEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.syncHistoryEntries,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SyncHistoryEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.syncHistoryEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SyncProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncProfilesTable,
          SyncProfile,
          $$SyncProfilesTableFilterComposer,
          $$SyncProfilesTableOrderingComposer,
          $$SyncProfilesTableAnnotationComposer,
          $$SyncProfilesTableCreateCompanionBuilder,
          $$SyncProfilesTableUpdateCompanionBuilder,
          (SyncProfile, $$SyncProfilesTableReferences),
          SyncProfile,
          PrefetchHooks Function({
            bool profileLocalPathsRefs,
            bool profileFilterTypesRefs,
            bool profileCustomExcludesRefs,
            bool syncHistoryEntriesRefs,
          })
        > {
  $$SyncProfilesTableTableManager(_$AppDatabase db, $SyncProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> remoteName = const Value.absent(),
                Value<String> cloudFolder = const Value.absent(),
                Value<String> syncMode = const Value.absent(),
                Value<int> scheduleMinutes = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> respectGitignore = const Value.absent(),
                Value<bool> excludeGitDirs = const Value.absent(),
                Value<bool> preserveSourceDir = const Value.absent(),
                Value<bool> useIncludeMode = const Value.absent(),
                Value<String?> bandwidthLimit = const Value.absent(),
                Value<int> maxTransfers = const Value.absent(),
                Value<bool> checkFirst = const Value.absent(),
                Value<DateTime?> lastSyncTime = const Value.absent(),
                Value<String?> lastSyncStatus = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncProfilesCompanion(
                id: id,
                name: name,
                remoteName: remoteName,
                cloudFolder: cloudFolder,
                syncMode: syncMode,
                scheduleMinutes: scheduleMinutes,
                enabled: enabled,
                respectGitignore: respectGitignore,
                excludeGitDirs: excludeGitDirs,
                preserveSourceDir: preserveSourceDir,
                useIncludeMode: useIncludeMode,
                bandwidthLimit: bandwidthLimit,
                maxTransfers: maxTransfers,
                checkFirst: checkFirst,
                lastSyncTime: lastSyncTime,
                lastSyncStatus: lastSyncStatus,
                lastSyncError: lastSyncError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String remoteName,
                required String cloudFolder,
                Value<String> syncMode = const Value.absent(),
                Value<int> scheduleMinutes = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> respectGitignore = const Value.absent(),
                Value<bool> excludeGitDirs = const Value.absent(),
                Value<bool> preserveSourceDir = const Value.absent(),
                Value<bool> useIncludeMode = const Value.absent(),
                Value<String?> bandwidthLimit = const Value.absent(),
                Value<int> maxTransfers = const Value.absent(),
                Value<bool> checkFirst = const Value.absent(),
                Value<DateTime?> lastSyncTime = const Value.absent(),
                Value<String?> lastSyncStatus = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncProfilesCompanion.insert(
                id: id,
                name: name,
                remoteName: remoteName,
                cloudFolder: cloudFolder,
                syncMode: syncMode,
                scheduleMinutes: scheduleMinutes,
                enabled: enabled,
                respectGitignore: respectGitignore,
                excludeGitDirs: excludeGitDirs,
                preserveSourceDir: preserveSourceDir,
                useIncludeMode: useIncludeMode,
                bandwidthLimit: bandwidthLimit,
                maxTransfers: maxTransfers,
                checkFirst: checkFirst,
                lastSyncTime: lastSyncTime,
                lastSyncStatus: lastSyncStatus,
                lastSyncError: lastSyncError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SyncProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileLocalPathsRefs = false,
                profileFilterTypesRefs = false,
                profileCustomExcludesRefs = false,
                syncHistoryEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (profileLocalPathsRefs) db.profileLocalPaths,
                    if (profileFilterTypesRefs) db.profileFilterTypes,
                    if (profileCustomExcludesRefs) db.profileCustomExcludes,
                    if (syncHistoryEntriesRefs) db.syncHistoryEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (profileLocalPathsRefs)
                        await $_getPrefetchedData<
                          SyncProfile,
                          $SyncProfilesTable,
                          ProfileLocalPath
                        >(
                          currentTable: table,
                          referencedTable: $$SyncProfilesTableReferences
                              ._profileLocalPathsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileLocalPathsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (profileFilterTypesRefs)
                        await $_getPrefetchedData<
                          SyncProfile,
                          $SyncProfilesTable,
                          ProfileFilterType
                        >(
                          currentTable: table,
                          referencedTable: $$SyncProfilesTableReferences
                              ._profileFilterTypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileFilterTypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (profileCustomExcludesRefs)
                        await $_getPrefetchedData<
                          SyncProfile,
                          $SyncProfilesTable,
                          ProfileCustomExclude
                        >(
                          currentTable: table,
                          referencedTable: $$SyncProfilesTableReferences
                              ._profileCustomExcludesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).profileCustomExcludesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncHistoryEntriesRefs)
                        await $_getPrefetchedData<
                          SyncProfile,
                          $SyncProfilesTable,
                          SyncHistoryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SyncProfilesTableReferences
                              ._syncHistoryEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).syncHistoryEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SyncProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncProfilesTable,
      SyncProfile,
      $$SyncProfilesTableFilterComposer,
      $$SyncProfilesTableOrderingComposer,
      $$SyncProfilesTableAnnotationComposer,
      $$SyncProfilesTableCreateCompanionBuilder,
      $$SyncProfilesTableUpdateCompanionBuilder,
      (SyncProfile, $$SyncProfilesTableReferences),
      SyncProfile,
      PrefetchHooks Function({
        bool profileLocalPathsRefs,
        bool profileFilterTypesRefs,
        bool profileCustomExcludesRefs,
        bool syncHistoryEntriesRefs,
      })
    >;
typedef $$ProfileLocalPathsTableCreateCompanionBuilder =
    ProfileLocalPathsCompanion Function({
      Value<int> id,
      required String profileId,
      required String path,
    });
typedef $$ProfileLocalPathsTableUpdateCompanionBuilder =
    ProfileLocalPathsCompanion Function({
      Value<int> id,
      Value<String> profileId,
      Value<String> path,
    });

final class $$ProfileLocalPathsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProfileLocalPathsTable,
          ProfileLocalPath
        > {
  $$ProfileLocalPathsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SyncProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.syncProfiles.createAlias(
        $_aliasNameGenerator(
          db.profileLocalPaths.profileId,
          db.syncProfiles.id,
        ),
      );

  $$SyncProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$SyncProfilesTableTableManager(
      $_db,
      $_db.syncProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileLocalPathsTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileLocalPathsTable> {
  $$ProfileLocalPathsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncProfilesTableFilterComposer get profileId {
    final $$SyncProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableFilterComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileLocalPathsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileLocalPathsTable> {
  $$ProfileLocalPathsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncProfilesTableOrderingComposer get profileId {
    final $$SyncProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileLocalPathsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileLocalPathsTable> {
  $$ProfileLocalPathsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  $$SyncProfilesTableAnnotationComposer get profileId {
    final $$SyncProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileLocalPathsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileLocalPathsTable,
          ProfileLocalPath,
          $$ProfileLocalPathsTableFilterComposer,
          $$ProfileLocalPathsTableOrderingComposer,
          $$ProfileLocalPathsTableAnnotationComposer,
          $$ProfileLocalPathsTableCreateCompanionBuilder,
          $$ProfileLocalPathsTableUpdateCompanionBuilder,
          (ProfileLocalPath, $$ProfileLocalPathsTableReferences),
          ProfileLocalPath,
          PrefetchHooks Function({bool profileId})
        > {
  $$ProfileLocalPathsTableTableManager(
    _$AppDatabase db,
    $ProfileLocalPathsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileLocalPathsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileLocalPathsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileLocalPathsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> path = const Value.absent(),
              }) => ProfileLocalPathsCompanion(
                id: id,
                profileId: profileId,
                path: path,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String profileId,
                required String path,
              }) => ProfileLocalPathsCompanion.insert(
                id: id,
                profileId: profileId,
                path: path,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileLocalPathsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$ProfileLocalPathsTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$ProfileLocalPathsTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfileLocalPathsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileLocalPathsTable,
      ProfileLocalPath,
      $$ProfileLocalPathsTableFilterComposer,
      $$ProfileLocalPathsTableOrderingComposer,
      $$ProfileLocalPathsTableAnnotationComposer,
      $$ProfileLocalPathsTableCreateCompanionBuilder,
      $$ProfileLocalPathsTableUpdateCompanionBuilder,
      (ProfileLocalPath, $$ProfileLocalPathsTableReferences),
      ProfileLocalPath,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ProfileFilterTypesTableCreateCompanionBuilder =
    ProfileFilterTypesCompanion Function({
      Value<int> id,
      required String profileId,
      required String typeValue,
      required bool isInclude,
    });
typedef $$ProfileFilterTypesTableUpdateCompanionBuilder =
    ProfileFilterTypesCompanion Function({
      Value<int> id,
      Value<String> profileId,
      Value<String> typeValue,
      Value<bool> isInclude,
    });

final class $$ProfileFilterTypesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProfileFilterTypesTable,
          ProfileFilterType
        > {
  $$ProfileFilterTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SyncProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.syncProfiles.createAlias(
        $_aliasNameGenerator(
          db.profileFilterTypes.profileId,
          db.syncProfiles.id,
        ),
      );

  $$SyncProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$SyncProfilesTableTableManager(
      $_db,
      $_db.syncProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileFilterTypesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileFilterTypesTable> {
  $$ProfileFilterTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeValue => $composableBuilder(
    column: $table.typeValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInclude => $composableBuilder(
    column: $table.isInclude,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncProfilesTableFilterComposer get profileId {
    final $$SyncProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableFilterComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileFilterTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileFilterTypesTable> {
  $$ProfileFilterTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeValue => $composableBuilder(
    column: $table.typeValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInclude => $composableBuilder(
    column: $table.isInclude,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncProfilesTableOrderingComposer get profileId {
    final $$SyncProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileFilterTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileFilterTypesTable> {
  $$ProfileFilterTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get typeValue =>
      $composableBuilder(column: $table.typeValue, builder: (column) => column);

  GeneratedColumn<bool> get isInclude =>
      $composableBuilder(column: $table.isInclude, builder: (column) => column);

  $$SyncProfilesTableAnnotationComposer get profileId {
    final $$SyncProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileFilterTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileFilterTypesTable,
          ProfileFilterType,
          $$ProfileFilterTypesTableFilterComposer,
          $$ProfileFilterTypesTableOrderingComposer,
          $$ProfileFilterTypesTableAnnotationComposer,
          $$ProfileFilterTypesTableCreateCompanionBuilder,
          $$ProfileFilterTypesTableUpdateCompanionBuilder,
          (ProfileFilterType, $$ProfileFilterTypesTableReferences),
          ProfileFilterType,
          PrefetchHooks Function({bool profileId})
        > {
  $$ProfileFilterTypesTableTableManager(
    _$AppDatabase db,
    $ProfileFilterTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileFilterTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileFilterTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileFilterTypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> typeValue = const Value.absent(),
                Value<bool> isInclude = const Value.absent(),
              }) => ProfileFilterTypesCompanion(
                id: id,
                profileId: profileId,
                typeValue: typeValue,
                isInclude: isInclude,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String profileId,
                required String typeValue,
                required bool isInclude,
              }) => ProfileFilterTypesCompanion.insert(
                id: id,
                profileId: profileId,
                typeValue: typeValue,
                isInclude: isInclude,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileFilterTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$ProfileFilterTypesTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$ProfileFilterTypesTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfileFilterTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileFilterTypesTable,
      ProfileFilterType,
      $$ProfileFilterTypesTableFilterComposer,
      $$ProfileFilterTypesTableOrderingComposer,
      $$ProfileFilterTypesTableAnnotationComposer,
      $$ProfileFilterTypesTableCreateCompanionBuilder,
      $$ProfileFilterTypesTableUpdateCompanionBuilder,
      (ProfileFilterType, $$ProfileFilterTypesTableReferences),
      ProfileFilterType,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ProfileCustomExcludesTableCreateCompanionBuilder =
    ProfileCustomExcludesCompanion Function({
      Value<int> id,
      required String profileId,
      required String pattern,
    });
typedef $$ProfileCustomExcludesTableUpdateCompanionBuilder =
    ProfileCustomExcludesCompanion Function({
      Value<int> id,
      Value<String> profileId,
      Value<String> pattern,
    });

final class $$ProfileCustomExcludesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProfileCustomExcludesTable,
          ProfileCustomExclude
        > {
  $$ProfileCustomExcludesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SyncProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.syncProfiles.createAlias(
        $_aliasNameGenerator(
          db.profileCustomExcludes.profileId,
          db.syncProfiles.id,
        ),
      );

  $$SyncProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$SyncProfilesTableTableManager(
      $_db,
      $_db.syncProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfileCustomExcludesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileCustomExcludesTable> {
  $$ProfileCustomExcludesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncProfilesTableFilterComposer get profileId {
    final $$SyncProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableFilterComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileCustomExcludesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileCustomExcludesTable> {
  $$ProfileCustomExcludesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncProfilesTableOrderingComposer get profileId {
    final $$SyncProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileCustomExcludesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileCustomExcludesTable> {
  $$ProfileCustomExcludesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  $$SyncProfilesTableAnnotationComposer get profileId {
    final $$SyncProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfileCustomExcludesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileCustomExcludesTable,
          ProfileCustomExclude,
          $$ProfileCustomExcludesTableFilterComposer,
          $$ProfileCustomExcludesTableOrderingComposer,
          $$ProfileCustomExcludesTableAnnotationComposer,
          $$ProfileCustomExcludesTableCreateCompanionBuilder,
          $$ProfileCustomExcludesTableUpdateCompanionBuilder,
          (ProfileCustomExclude, $$ProfileCustomExcludesTableReferences),
          ProfileCustomExclude,
          PrefetchHooks Function({bool profileId})
        > {
  $$ProfileCustomExcludesTableTableManager(
    _$AppDatabase db,
    $ProfileCustomExcludesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileCustomExcludesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProfileCustomExcludesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProfileCustomExcludesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> pattern = const Value.absent(),
              }) => ProfileCustomExcludesCompanion(
                id: id,
                profileId: profileId,
                pattern: pattern,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String profileId,
                required String pattern,
              }) => ProfileCustomExcludesCompanion.insert(
                id: id,
                profileId: profileId,
                pattern: pattern,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfileCustomExcludesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$ProfileCustomExcludesTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$ProfileCustomExcludesTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfileCustomExcludesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileCustomExcludesTable,
      ProfileCustomExclude,
      $$ProfileCustomExcludesTableFilterComposer,
      $$ProfileCustomExcludesTableOrderingComposer,
      $$ProfileCustomExcludesTableAnnotationComposer,
      $$ProfileCustomExcludesTableCreateCompanionBuilder,
      $$ProfileCustomExcludesTableUpdateCompanionBuilder,
      (ProfileCustomExclude, $$ProfileCustomExcludesTableReferences),
      ProfileCustomExclude,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$SyncHistoryEntriesTableCreateCompanionBuilder =
    SyncHistoryEntriesCompanion Function({
      Value<int> id,
      required String profileId,
      required DateTime timestamp,
      required String status,
      Value<int> filesTransferred,
      Value<int> bytesTransferred,
      Value<int> durationMs,
      Value<String?> error,
    });
typedef $$SyncHistoryEntriesTableUpdateCompanionBuilder =
    SyncHistoryEntriesCompanion Function({
      Value<int> id,
      Value<String> profileId,
      Value<DateTime> timestamp,
      Value<String> status,
      Value<int> filesTransferred,
      Value<int> bytesTransferred,
      Value<int> durationMs,
      Value<String?> error,
    });

final class $$SyncHistoryEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SyncHistoryEntriesTable,
          SyncHistoryEntry
        > {
  $$SyncHistoryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SyncProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.syncProfiles.createAlias(
        $_aliasNameGenerator(
          db.syncHistoryEntries.profileId,
          db.syncProfiles.id,
        ),
      );

  $$SyncProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$SyncProfilesTableTableManager(
      $_db,
      $_db.syncProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransferredFilesTable, List<TransferredFile>>
  _transferredFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transferredFiles,
    aliasName: $_aliasNameGenerator(
      db.syncHistoryEntries.id,
      db.transferredFiles.historyId,
    ),
  );

  $$TransferredFilesTableProcessedTableManager get transferredFilesRefs {
    final manager = $$TransferredFilesTableTableManager(
      $_db,
      $_db.transferredFiles,
    ).filter((f) => f.historyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transferredFilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SyncHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncHistoryEntriesTable> {
  $$SyncHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get filesTransferred => $composableBuilder(
    column: $table.filesTransferred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesTransferred => $composableBuilder(
    column: $table.bytesTransferred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncProfilesTableFilterComposer get profileId {
    final $$SyncProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableFilterComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transferredFilesRefs(
    Expression<bool> Function($$TransferredFilesTableFilterComposer f) f,
  ) {
    final $$TransferredFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transferredFiles,
      getReferencedColumn: (t) => t.historyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransferredFilesTableFilterComposer(
            $db: $db,
            $table: $db.transferredFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncHistoryEntriesTable> {
  $$SyncHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get filesTransferred => $composableBuilder(
    column: $table.filesTransferred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesTransferred => $composableBuilder(
    column: $table.bytesTransferred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncProfilesTableOrderingComposer get profileId {
    final $$SyncProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncHistoryEntriesTable> {
  $$SyncHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get filesTransferred => $composableBuilder(
    column: $table.filesTransferred,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bytesTransferred => $composableBuilder(
    column: $table.bytesTransferred,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  $$SyncProfilesTableAnnotationComposer get profileId {
    final $$SyncProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.syncProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.syncProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transferredFilesRefs<T extends Object>(
    Expression<T> Function($$TransferredFilesTableAnnotationComposer a) f,
  ) {
    final $$TransferredFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transferredFiles,
      getReferencedColumn: (t) => t.historyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransferredFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.transferredFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SyncHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncHistoryEntriesTable,
          SyncHistoryEntry,
          $$SyncHistoryEntriesTableFilterComposer,
          $$SyncHistoryEntriesTableOrderingComposer,
          $$SyncHistoryEntriesTableAnnotationComposer,
          $$SyncHistoryEntriesTableCreateCompanionBuilder,
          $$SyncHistoryEntriesTableUpdateCompanionBuilder,
          (SyncHistoryEntry, $$SyncHistoryEntriesTableReferences),
          SyncHistoryEntry,
          PrefetchHooks Function({bool profileId, bool transferredFilesRefs})
        > {
  $$SyncHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $SyncHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncHistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncHistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> filesTransferred = const Value.absent(),
                Value<int> bytesTransferred = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => SyncHistoryEntriesCompanion(
                id: id,
                profileId: profileId,
                timestamp: timestamp,
                status: status,
                filesTransferred: filesTransferred,
                bytesTransferred: bytesTransferred,
                durationMs: durationMs,
                error: error,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String profileId,
                required DateTime timestamp,
                required String status,
                Value<int> filesTransferred = const Value.absent(),
                Value<int> bytesTransferred = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String?> error = const Value.absent(),
              }) => SyncHistoryEntriesCompanion.insert(
                id: id,
                profileId: profileId,
                timestamp: timestamp,
                status: status,
                filesTransferred: filesTransferred,
                bytesTransferred: bytesTransferred,
                durationMs: durationMs,
                error: error,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SyncHistoryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, transferredFilesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transferredFilesRefs) db.transferredFiles,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$SyncHistoryEntriesTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$SyncHistoryEntriesTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transferredFilesRefs)
                        await $_getPrefetchedData<
                          SyncHistoryEntry,
                          $SyncHistoryEntriesTable,
                          TransferredFile
                        >(
                          currentTable: table,
                          referencedTable: $$SyncHistoryEntriesTableReferences
                              ._transferredFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SyncHistoryEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transferredFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.historyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SyncHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncHistoryEntriesTable,
      SyncHistoryEntry,
      $$SyncHistoryEntriesTableFilterComposer,
      $$SyncHistoryEntriesTableOrderingComposer,
      $$SyncHistoryEntriesTableAnnotationComposer,
      $$SyncHistoryEntriesTableCreateCompanionBuilder,
      $$SyncHistoryEntriesTableUpdateCompanionBuilder,
      (SyncHistoryEntry, $$SyncHistoryEntriesTableReferences),
      SyncHistoryEntry,
      PrefetchHooks Function({bool profileId, bool transferredFilesRefs})
    >;
typedef $$TransferredFilesTableCreateCompanionBuilder =
    TransferredFilesCompanion Function({
      Value<int> id,
      required int historyId,
      required String fileName,
      Value<int> fileSize,
      Value<String?> completedAt,
    });
typedef $$TransferredFilesTableUpdateCompanionBuilder =
    TransferredFilesCompanion Function({
      Value<int> id,
      Value<int> historyId,
      Value<String> fileName,
      Value<int> fileSize,
      Value<String?> completedAt,
    });

final class $$TransferredFilesTableReferences
    extends
        BaseReferences<_$AppDatabase, $TransferredFilesTable, TransferredFile> {
  $$TransferredFilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SyncHistoryEntriesTable _historyIdTable(_$AppDatabase db) =>
      db.syncHistoryEntries.createAlias(
        $_aliasNameGenerator(
          db.transferredFiles.historyId,
          db.syncHistoryEntries.id,
        ),
      );

  $$SyncHistoryEntriesTableProcessedTableManager get historyId {
    final $_column = $_itemColumn<int>('history_id')!;

    final manager = $$SyncHistoryEntriesTableTableManager(
      $_db,
      $_db.syncHistoryEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_historyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransferredFilesTableFilterComposer
    extends Composer<_$AppDatabase, $TransferredFilesTable> {
  $$TransferredFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SyncHistoryEntriesTableFilterComposer get historyId {
    final $$SyncHistoryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.historyId,
      referencedTable: $db.syncHistoryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncHistoryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.syncHistoryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransferredFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransferredFilesTable> {
  $$TransferredFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SyncHistoryEntriesTableOrderingComposer get historyId {
    final $$SyncHistoryEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.historyId,
      referencedTable: $db.syncHistoryEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncHistoryEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.syncHistoryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransferredFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransferredFilesTable> {
  $$TransferredFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$SyncHistoryEntriesTableAnnotationComposer get historyId {
    final $$SyncHistoryEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.historyId,
          referencedTable: $db.syncHistoryEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SyncHistoryEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.syncHistoryEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TransferredFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransferredFilesTable,
          TransferredFile,
          $$TransferredFilesTableFilterComposer,
          $$TransferredFilesTableOrderingComposer,
          $$TransferredFilesTableAnnotationComposer,
          $$TransferredFilesTableCreateCompanionBuilder,
          $$TransferredFilesTableUpdateCompanionBuilder,
          (TransferredFile, $$TransferredFilesTableReferences),
          TransferredFile,
          PrefetchHooks Function({bool historyId})
        > {
  $$TransferredFilesTableTableManager(
    _$AppDatabase db,
    $TransferredFilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransferredFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransferredFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransferredFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> historyId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
              }) => TransferredFilesCompanion(
                id: id,
                historyId: historyId,
                fileName: fileName,
                fileSize: fileSize,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int historyId,
                required String fileName,
                Value<int> fileSize = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
              }) => TransferredFilesCompanion.insert(
                id: id,
                historyId: historyId,
                fileName: fileName,
                fileSize: fileSize,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransferredFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({historyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (historyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.historyId,
                                referencedTable:
                                    $$TransferredFilesTableReferences
                                        ._historyIdTable(db),
                                referencedColumn:
                                    $$TransferredFilesTableReferences
                                        ._historyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransferredFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransferredFilesTable,
      TransferredFile,
      $$TransferredFilesTableFilterComposer,
      $$TransferredFilesTableOrderingComposer,
      $$TransferredFilesTableAnnotationComposer,
      $$TransferredFilesTableCreateCompanionBuilder,
      $$TransferredFilesTableUpdateCompanionBuilder,
      (TransferredFile, $$TransferredFilesTableReferences),
      TransferredFile,
      PrefetchHooks Function({bool historyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppConfigsTableTableManager get appConfigs =>
      $$AppConfigsTableTableManager(_db, _db.appConfigs);
  $$SyncProfilesTableTableManager get syncProfiles =>
      $$SyncProfilesTableTableManager(_db, _db.syncProfiles);
  $$ProfileLocalPathsTableTableManager get profileLocalPaths =>
      $$ProfileLocalPathsTableTableManager(_db, _db.profileLocalPaths);
  $$ProfileFilterTypesTableTableManager get profileFilterTypes =>
      $$ProfileFilterTypesTableTableManager(_db, _db.profileFilterTypes);
  $$ProfileCustomExcludesTableTableManager get profileCustomExcludes =>
      $$ProfileCustomExcludesTableTableManager(_db, _db.profileCustomExcludes);
  $$SyncHistoryEntriesTableTableManager get syncHistoryEntries =>
      $$SyncHistoryEntriesTableTableManager(_db, _db.syncHistoryEntries);
  $$TransferredFilesTableTableManager get transferredFiles =>
      $$TransferredFilesTableTableManager(_db, _db.transferredFiles);
}
