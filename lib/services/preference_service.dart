// This is the file for the preference service, it will be used to save the user's preferences and settings, such as the theme and the language
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bwthw_project/models.2/user.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/blood_test.dart';  
import 'package:bwthw_project/models.2/input_mesearument_models/weight_entry.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/body_measurement_entry.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'dart:convert';
class PreferenceService {
  // keys
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _onboardingDoneKey = 'onboardingDone';
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';
  static const String _nameKey = 'name';
  static const String _surnameKey = 'surname';
  static const String _birthDateKey = 'birthDate';
  static const String _weightKey = 'weight';
  static const String _heightKey = 'height';
  static const String _idealWeightKey = 'idealWeight';
  static const String _bloodTestsKey = 'blood_tests';
  static const String _weightEntriesKey = 'weight_entries';
  static const String _bodyMeasurementEntriesKey = 'body_measurement_entries';
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';

  // helper method to get shared preferences instance
  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  // Authentication -------------------------------------------------------------------------
  // This is the method to save if user is logged in
  static Future<void> saveLogin(bool value) async =>
    (await _prefs()).setBool(_isLoggedInKey, value);

  // This is the method to get if user is logged in
  static Future<bool> getLogin() async =>
    (await _prefs()).getBool(_isLoggedInKey) ?? false;

  // This is the method to save the log out
  static Future<void> logout() async =>
    (await _prefs()).setBool(_isLoggedInKey, false);

  // This is the method to save user login
  static Future<void> saveUserLogin(String email, String password) async {
    final prefs = await _prefs();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  } 

  // This is the method to get user login
  static Future<Map<String, String>?> getUserLogin() async {
    final prefs = await _prefs();
    String? email = prefs.getString(_emailKey);
    String? password = prefs.getString(_passwordKey);
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  // This is the method to clear user login
  static Future<void> clearUserLogin() async {
    final prefs = await _prefs();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }

  // Onboarding ------------------------------------------------------------------
  // This is the method to save if user has completed the onboarding
  static Future<void> saveOnboardingCompleted(bool value) async =>
    (await _prefs()).setBool(_onboardingDoneKey, value); 

  // This is the method to get if user has completed the onboarding
  static Future<bool> getOnboardingCompleted() async =>
     (await _prefs()).getBool(_onboardingDoneKey) ?? false;

  // User data ----------------------------------------------------------------------
  // This is the method to save user data, such as name, age, weight and height
  static Future<void> saveUser(User user) async {
    final prefs = await _prefs();
    await prefs.setString(_nameKey, user.name);
    await prefs.setString(_surnameKey, user.surname);
    await prefs.setString(_birthDateKey, user.birthDate.toIso8601String());
    await prefs.setDouble(_weightKey, user.weight);
    await prefs.setDouble(_heightKey, user.height);
    await prefs.setDouble(_idealWeightKey, user.idealWeight);
  }

  // This is the method to get user data
  static Future<User ?> getUserData() async {
    final prefs = await _prefs();
    final name = prefs.getString(_nameKey);
    final surname = prefs.getString(_surnameKey);
    final birthDate = DateTime.tryParse(prefs.getString(_birthDateKey) ?? '');
    final weight = prefs.getDouble(_weightKey);
    final height = prefs.getDouble(_heightKey);
    final idealWeight = prefs.getDouble(_idealWeightKey);

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

  // Update the user weight only if the new record is more recent than the existing one
  static Future<void> updateUserWeightIfMostRecent(WeightEntry entry) async {
    final entries = await getWeightEntries();
    if (entries.isEmpty) return;

    final mostRecent = entries.last;
    if (mostRecent.date == entry.date && mostRecent.weight == entry.weight) {
      final prefs = await _prefs();
      await prefs.setDouble(_weightKey, entry.weight);
    }
  }

  // Patient data ----------------------------------------------------------------------
  // Method to save patient data
  static Future<void> savePatient(Patient patient) async {
    final prefs = await _prefs();
    await prefs.setString('patient', jsonEncode(patient.toMap()));
  }

  // Method to get patient data
  static Future<Patient?> getPatient() async {
    final prefs = await _prefs();
    final json = prefs.getString('patient');
    if (json == null) return null;
    try {
      return Patient.fromMap(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  // Method for clearing all preferences, useful for debugging or resetting the app
  static Future<void> clearAll() async => (await _prefs()).clear();

  // Blood tests ----------------------------------------------------------------------------
  // Method to save blood tests, it will save a list of blood tests as a JSON string in shared preferences
  static Future<void> saveBloodTests(List<BloodTest> tests) async {
    final prefs = await _prefs();
    await prefs.setStringList(_bloodTestsKey, tests.map((t) => jsonEncode(t.toMap())).toList());
  }

  // Method to get blood tests, it will return a list of blood tests by decoding the JSON string from shared preferences
  static Future<List<BloodTest>> getBloodTests() async {
    final prefs = await _prefs();
    return (prefs.getStringList(_bloodTestsKey) ?? [])
        .map((e) => BloodTest.fromMap(jsonDecode(e)))
        .toList();
  }

  // Weight entries ----------------------------------------------------------------------
  // Method to save weight entries, it will save a list of weight entries as a JSON string in shared preferences
  static Future<void> saveWeightEntries(List<WeightEntry> entries) async {
    final prefs = await _prefs();
    await prefs.setStringList(_weightEntriesKey, entries.map((e) => jsonEncode(e.toMap())).toList());
    }

  // Method to get weight entries, it will return a list of weight entries by decoding the JSON string from shared preferences
  static Future<List<WeightEntry>> getWeightEntries() async {
    final prefs = await _prefs();
    return (prefs.getStringList(_weightEntriesKey) ?? [])
        .map((e) => WeightEntry.fromMap(jsonDecode(e)))
        .toList();
  }

  // Method to add a weight entry, it will get the existing entries, add the new entry, sort them by date and save them back to shared preferences
  static Future<void> addWeightEntry(WeightEntry entry) async {
    final currentEntries = await getWeightEntries();
    currentEntries.add(entry);

    currentEntries.sort((a, b) => a.date.compareTo(b.date));

    await saveWeightEntries(currentEntries);
    await updateUserWeightIfMostRecent(entry);
  }

  // Body measurement entries ----------------------------------------------------------------------
  // Method to save body measurement entries, it will save a list of body measurement entries as a JSON string in shared preferences
  static Future<void> saveBodyMeasurementEntries(List<BodyMeasurementEntry> entries) async {
    final prefs = await _prefs();
    await prefs.setStringList(_bodyMeasurementEntriesKey, entries.map((e) => jsonEncode(e.toMap())).toList());
  }

  // Method to get body measurement entries, it will return a list of body measurement entries by decoding the JSON string from shared preferences
  static Future<List<BodyMeasurementEntry>> getBodyMeasurementEntries() async {
    final prefs = await _prefs();
    return (prefs.getStringList(_bodyMeasurementEntriesKey) ?? [])
        .map((e) => BodyMeasurementEntry.fromMap(jsonDecode(e)))
        .toList();
  }

  // Method to add a body measurement entry, it will get the existing entries, add the new entry, sort them by date and save them back to shared preferences
  static Future<void> addBodyMeasurementEntry(BodyMeasurementEntry entry) async {
    final currentEntries = await getBodyMeasurementEntries();
    currentEntries.add(entry);

    currentEntries.sort((a, b) => b.date.compareTo(a.date));

    await saveBodyMeasurementEntries(currentEntries);
  }

  // User preferences ----------------------------------------------------------------------
  // This is the method to save user preferences, such as theme and language
  Future<void> saveThemeMode(String themeMode) async => 
     (await _prefs()).setString(_themeModeKey, themeMode);
     
  Future<String?> getThemeMode() async => 
      (await _prefs()).getString(_themeModeKey);

  Future<void> saveLanguage(String language) async => 
      (await _prefs()).setString(_languageKey, language);

  Future<String?> getLanguage() async => 
      (await _prefs()).getString(_languageKey);
}