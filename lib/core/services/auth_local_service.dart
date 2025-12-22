import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalService {
  final _storage = const FlutterSecureStorage();

  // Save Token
  Future<void> saveToken(String token) async =>
      await _storage.write(key: 'jwt_token', value: token);

  // Get Token
  Future<String?> getToken() async => await _storage.read(key: 'jwt_token');

  // Save Role (to know whether to show Home-Patient or Home-Doctor)
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  // Clear everything on Logout
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
  }
}
