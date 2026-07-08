import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/blood_test.dart';

class BloodTestState extends ChangeNotifier {
  List<BloodTest> _tests = [];
  
  List<BloodTest> get tests => List.unmodifiable(_tests);
  
  BloodTest? get latestTest => _tests.isNotEmpty ? _tests.first : null;

  Future<void> loadTests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loaded = prefs.getStringList('bloodTests') ?? [];
      
      _tests = loaded
          .map((e) => BloodTest.fromMap(jsonDecode(e) as Map<String, dynamic>))
          .toList();
      
      _tests.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      print('Errore caricamento esami del sangue: $e');
      _tests = [];
      notifyListeners();
    }
  }

  Future<void> addTest(BloodTest test) async {
    _tests.add(test);
    _tests.sort((a, b) => b.date.compareTo(a.date));
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> deleteTest(BloodTest test) async {
    _tests.remove(test);
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'bloodTests',
      _tests.map((t) => jsonEncode(t.toMap())).toList(),
    );
  }
}
