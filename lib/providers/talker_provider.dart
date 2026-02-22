import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';

/// Global Talker instance for app-wide logging.
final talker = Talker(
  settings: TalkerSettings(
    maxHistoryItems: 1000,
  ),
);

/// Riverpod provider for accessing the global Talker instance.
final talkerProvider = Provider<Talker>((ref) => talker);
