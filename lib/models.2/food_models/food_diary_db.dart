import 'package:flutter/material.dart';

import 'food_entry.dart';

class FoodDiaryDB extends ChangeNotifier {
  final List<FoodEntry> entries = [];

  void addEntry(FoodEntry toAdd) {
    entries.add(toAdd);
    notifyListeners();
  }

  void editEntry(int index, FoodEntry newEntry) {
    entries[index] = newEntry;
    notifyListeners();
  }

  void deleteEntry(int index) {
    entries.removeAt(index);
    notifyListeners();
  }
}

