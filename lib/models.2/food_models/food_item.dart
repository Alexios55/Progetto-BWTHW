import 'package:bwthw_project/models.2/enums.dart';
import 'package:flutter/material.dart';

// Represents a food item with full nutritional profile.
//
// Macro fields (calories, proteins, carbs, fats) are per 100g.
// Micro fields (iron, calcium, vitaminC, vitaminD, omega3, phytates, oxalates) are in mg per 100g unless noted.

class FoodItem {
  final String name;

  // ── Macronutrients (per 100 g) 
  final double calories;   // kcal
  final double proteins;   // g
  final double carbs;      // g
  final double fats;       // g

  // ── Micronutrients relevant to blood parameters (mg/100g) ───
  final double iron;        // mg -> ferritin proxy  
  final double calcium;     // mg -> serum calcium proxy
  final double vitaminC;    // mg -> synergist for iron absorption
  final double vitaminD;    // µg -> vitamin D (25-OH) proxy
  final double omega3;      // mg -> LDL-cholesterol modulator
  final double fiber;       // g  -> glucose modulator

  // ── Absorption modulators
  final double phytates; // Phytates reduce absorption of Fe, Zn, Ca (mg/100g).
  final double oxalates; // Oxalates reduce absorption of Ca and Fe (mg/100g).

  final FoodCategory category;

  // Meal suitability (which meals this food is tipically consumed in) to filter suggestions
  final List<MealType> suitableMeals;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.iron      = 0,
    this.calcium   = 0,
    this.vitaminC  = 0,
    this.vitaminD  = 0,
    this.omega3    = 0,
    this.fiber     = 0,
    this.phytates  = 0,
    this.oxalates  = 0,
    required this.category,
    this.suitableMeals = MealType.values, // For default a food is suitable for all meals
  });

  // Return the Material Design ico associated with the food's category
  IconData get categoryIcon {
    switch (category) {
      case FoodCategory.dairy:
        return Icons.egg_alt_outlined;
      case FoodCategory.bakeryAndCereals:
        return Icons.breakfast_dining_outlined;
      case FoodCategory.meat:
        return Icons.set_meal_outlined;
      case FoodCategory.fish:
        return Icons.set_meal_outlined;
      case FoodCategory.eggs:
        return Icons.egg_outlined;
      case FoodCategory.curedMeats:
        return Icons.lunch_dining_outlined;
      case FoodCategory.cheese:
        return Icons.kitchen_outlined;
      case FoodCategory.fruit:
        return Icons.apple_outlined;
      case FoodCategory.vegetables:
        return Icons.eco_outlined;
      case FoodCategory.legumes:
        return Icons.grass_outlined;
      case FoodCategory.fatsAndSpreads:
        return Icons.opacity_outlined;
      case FoodCategory.nuts:
        return Icons.spa_outlined;
      case FoodCategory.preparedFoods:
        return Icons.fastfood_outlined;
      case FoodCategory.juicesAndSweeteners:
        return Icons.local_drink_outlined;
    }
  }

  // Returns a map from nutrient name -> contribution value.
  // Used by the engine to look up how this food contributes to each blood parameter target.
  Map<String, double> get nutrientMap => {
    'iron':     iron,
    'calcium':  calcium,
    'vitaminC': vitaminC,
    'vitaminD': vitaminD,
    'omega3':   omega3,
    'fiber':    fiber,
    'phytates': phytates,
    'oxalates': oxalates,
    'proteins': proteins,
    'carbs':    carbs,
    'fats':     fats,
  };
}