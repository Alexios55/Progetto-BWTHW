// This is the file for the preference service, it will be used to save the user's preferences and settings, such as the theme and the language
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  // This is the method to save if user is logged in
  static Future<void> saveLogin(bool value) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('isLoggedIn', value);
  }

  // This is the method to get if user is logged in
  static Future<bool> getLogin() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getBool('isLoggedIn') ?? false;
  }

  // This is the method to save the log out
  static Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('isLoggedIn', false);
  }

  // This is the method to save user login
  static Future<void> saveUserLogin(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  } 

  // This is the method to get user login
  static Future<Map<String, String>?> getUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  // This is the method to clear user login
  static Future<void> clearUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
  }

  // This is the method to save user preferences, such as theme and language

  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey);
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }
}