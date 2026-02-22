import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

/// The app-wide Drift database instance.
/// Overridden in main.dart with the real database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden');
});
