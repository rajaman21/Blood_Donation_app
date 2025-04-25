import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyUserType = "Donor";

  // Save user type
  static Future<void> setUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserType, userType);
  }

  // Get user type
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserType);
  }

  // Remove user type (if needed)
  static Future<void> clearUserType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserType);
  }
}
