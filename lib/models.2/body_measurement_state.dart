import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/body_measurement_entry.dart';

class BodyMeasurementState extends ChangeNotifier {
  List<BodyMeasurementEntry> _entries = [];
  
  List<BodyMeasurementEntry> get entries => List.unmodifiable(_entries);
  
  BodyMeasurementEntry? get latestEntry => _entries.isNotEmpty ? _entries.first : null;

  Future<void> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loaded = prefs.getStringList('bodyMeasurementEntries') ?? [];
      
      _entries = loaded
          .map((e) => BodyMeasurementEntry.fromMap(jsonDecode(e) as Map<String, dynamic>))
          .toList();
      
      _entries.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      print('Errore caricamento misure corporee: $e');
      _entries = [];
      notifyListeners();
    }
  }

  Future<void> addEntry(BodyMeasurementEntry entry) async {
    _entries.add(entry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> deleteEntry(BodyMeasurementEntry entry) async {
    _entries.remove(entry);
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'bodyMeasurementEntries',
      _entries.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }
}
