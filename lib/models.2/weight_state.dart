import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/weight_entry.dart';

class WeightState extends ChangeNotifier {
  List<WeightEntry> _entries = [];
  
  List<WeightEntry> get entries => List.unmodifiable(_entries);
  
  WeightEntry? get latestEntry => _entries.isNotEmpty ? _entries.first : null;
  
  double get latestWeight => _entries.isNotEmpty ? _entries.first.weight : 0.0;

  Future<void> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loaded = prefs.getStringList('weightHistory') ?? [];
      
      _entries = loaded
          .map((e) => WeightEntry.fromMap(jsonDecode(e) as Map<String, dynamic>))
          .toList();
      
      _entries.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      print('Errore caricamento storico pesi: $e');
      _entries = [];
      notifyListeners();
    }
  }

  Future<void> addEntry(WeightEntry entry) async {
    _entries.add(entry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> deleteEntry(WeightEntry entry) async {
    _entries.remove(entry);
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> deleteLatestEntry() async {
    if (_entries.isNotEmpty) {
      _entries.removeAt(0);
      await _saveToPreferences();
      notifyListeners();
    }
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'weightHistory',
      _entries.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }
}
