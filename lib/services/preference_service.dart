// This is the file for the preference service, it will be used to save the user's preferences and settings, such as the theme and the language
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bwthw_project/models/user.dart';
import 'package:bwthw_project/models/blood_test.dart';  
import 'dart:convert';
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

// This is the method to save if user has completed the onboarding
static Future<void> saveOnboardingCompleted(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboardingDone', value);
}

// This is the method to get if user has completed the onboarding
static Future<bool> getOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboardingDone') ?? false;
}

// DATI UTENTE
// This is the method to save user data, such as name, age, weight and height
static Future<void> saveUser(User user) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString('name', user.name);
  await prefs.setString('surname', user.surname);
  await prefs.setString('birthDate', user.birthDate.toIso8601String());
  await prefs.setDouble('weight', user.weight);
  await prefs.setDouble('height', user.height);
  await prefs.setDouble('idealWeight', user.idealWeight);
}


// This is the method to get user data
static Future<User ?> getUserData() async {
  final prefs = await SharedPreferences.getInstance();
  String? name = prefs.getString('name');
  String? surname = prefs.getString('surname');
  DateTime? birthDate = DateTime.parse(prefs.getString('birthDate') ?? DateTime.now().toIso8601String());
  double? weight = prefs.getDouble('weight');
  double? height = prefs.getDouble('height');
  double? idealWeight = prefs.getDouble('idealWeight');

  if (name != null && surname != null && birthDate != null && weight != null && height != null && idealWeight != null ) {
    return User( 
      name: name,
      surname: surname,
      birthDate: birthDate,
      weight: weight,
      height: height,
      idealWeight: idealWeight,
    );
  }
  return null;

}

static Future<void> clearAll() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}


static Future<void> saveBloodTests(List<BloodTest> tests) async {
  final prefs = await SharedPreferences.getInstance();

  List<String> jsonList =
      tests.map((t) => jsonEncode(t.toMap())).toList();

  await prefs.setStringList('blood_tests', jsonList);
}

static Future<List<BloodTest>> getBloodTests() async {
  final prefs = await SharedPreferences.getInstance();

  final list = prefs.getStringList('blood_tests') ?? [];

  return list
      .map((e) => BloodTest.fromMap(jsonDecode(e)))
      .toList();
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