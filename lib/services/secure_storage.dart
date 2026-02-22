import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Thin wrapper around FlutterSecureStorage for RC credentials
/// and rclone config encryption password.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveRcCredentials(String user, String pass) async {
    await _storage.write(key: 'rc_user', value: user);
    await _storage.write(key: 'rc_pass', value: pass);
  }

  Future<({String user, String pass})?> loadRcCredentials() async {
    final user = await _storage.read(key: 'rc_user');
    final pass = await _storage.read(key: 'rc_pass');
    if (user == null || pass == null) return null;
    return (user: user, pass: pass);
  }

  Future<void> saveConfigPass(String pass) async {
    await _storage.write(key: 'config_pass', value: pass);
  }

  Future<String?> loadConfigPass() async {
    return await _storage.read(key: 'config_pass');
  }

  static String generateCredential() => const Uuid().v4().substring(0, 16);
}
