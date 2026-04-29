import 'package:flutter/material.dart';
import 'package:bwthw_project/models/food_entry.dart';

// This class extends ChangeNotifier

// It is a data repository for the food diary entries
// and will be shared through the application
class FoodDiaryDB extends ChangeNotifier {
  // The diary is represented as a list of food entries.
  List<FoodEntry> entries = [];

  // Method used to add a new entry
  void addEntry(FoodEntry toAdd) {
    entries.add(toAdd);
    notifyListeners();
  }

  // Method used to edit an existing entry
  void editEntry(int index, FoodEntry newEntry) {
    entries[index] = newEntry;
    notifyListeners();
  }

  // Method used to delete an entry
  void deleteEntry(int index) {
    entries.removeAt(index);
    notifyListeners();
  }
}