class FoodEntry {
  final String foodName;
  final String mealType;
  final double grams;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double carbsPer100g;
  final double fatsPer100g;

  const FoodEntry({
    required this.foodName,
    required this.mealType,
    required this.grams,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
  });

  double get calories => caloriesPer100g * grams / 100;
  double get proteins => proteinsPer100g * grams / 100;
  double get carbs => carbsPer100g * grams / 100;
  double get fats => fatsPer100g * grams / 100;
}

