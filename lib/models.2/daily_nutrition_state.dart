import 'package:flutter/material.dart';
import 'package:bwthw_project/models.2/food_models/food_entry.dart';
import 'package:bwthw_project/models.2/food_models/food_item.dart';
import 'package:bwthw_project/models.2/food_models/food_catalog.dart';

class DailyNutritionState extends ChangeNotifier {
  // Valori giornalieri raccomandati (RDA)
  static const double ironTarget = 18.0;
  static const double calciumTarget = 1000.0;
  static const double vitaminDTarget = 15.0;
  static const double omega3Target = 1600.0;
  static const double fiberTarget = 25.0;

  // Totali consumi giornalieri
  double _totalCalories = 0.0;
  double _totalProteins = 0.0;
  double _totalCarbs = 0.0;
  double _totalFats = 0.0;
  double _totalIron = 0.0;
  double _totalCalcium = 0.0;
  double _totalVitaminD = 0.0;
  double _totalOmega3 = 0.0;
  double _totalFiber = 0.0;

  // Getters
  double get totalCalories => _totalCalories;
  double get totalProteins => _totalProteins;
  double get totalCarbs => _totalCarbs;
  double get totalFats => _totalFats;
  double get totalIron => _totalIron;
  double get totalCalcium => _totalCalcium;
  double get totalVitaminD => _totalVitaminD;
  double get totalOmega3 => _totalOmega3;
  double get totalFiber => _totalFiber;

  void calculateTotals(List<FoodEntry> entries, {List<FoodItem>? catalog}) {
    final foodCatalog = catalog ?? FoodCatalog.foods;

    _resetTotals();

    // Calcola macro dai FoodEntry
    for (final entry in entries) {
      _totalCalories += entry.calories;
      _totalProteins += entry.proteins;
      _totalCarbs += entry.carbs;
      _totalFats += entry.fats;
    }

    // Calcola micro dai FoodItem associati
    final consumedMap = _buildConsumedMap(entries, foodCatalog);
    for (final entry in consumedMap.entries) {
      final food = entry.key;
      final grams = entry.value;
      final scale = grams / 100.0;

      _totalIron += food.iron * scale;
      _totalCalcium += food.calcium * scale;
      _totalVitaminD += food.vitaminD * scale;
      _totalOmega3 += food.omega3 * scale;
      _totalFiber += food.fiber * scale;
    }

    notifyListeners();
  }

  Map<FoodItem, double> _buildConsumedMap(
    List<FoodEntry> entries,
    List<FoodItem> catalog,
  ) {
    final map = <FoodItem, double>{};
    
    for (final entry in entries) {
      final item = catalog.cast<FoodItem?>().firstWhere(
        (f) => f?.name == entry.foodName,
        orElse: () => null,
      );
      
      if (item != null) {
        map[item] = (map[item] ?? 0) + entry.grams;
      }
    }
    
    return map;
  }

  void _resetTotals() {
    _totalCalories = 0.0;
    _totalProteins = 0.0;
    _totalCarbs = 0.0;
    _totalFats = 0.0;
    _totalIron = 0.0;
    _totalCalcium = 0.0;
    _totalVitaminD = 0.0;
    _totalOmega3 = 0.0;
    _totalFiber = 0.0;
  }

  void reset() {
    _resetTotals();
    notifyListeners();
  }
}

// comment: This class manages the daily nutrition state, calculating total macro and micronutrients based on food entries and a food catalog. It provides getters for the totals and methods to calculate and reset them.
