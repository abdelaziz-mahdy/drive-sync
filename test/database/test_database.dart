import 'package:drift/native.dart';
import 'package:drive_sync/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
