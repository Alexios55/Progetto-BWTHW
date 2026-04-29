// This is the data model of a food diary entry.
class FoodEntry {
  // The name of the selected food
  String foodName;

  // The meal type: Breakfast, Snack, Lunch, Dinner
  String mealType;

  // Amount selected by the user
  double grams;

  // Nutritional values per 100 g
  double caloriesPer100g;
  double proteinsPer100g;
  double carbsPer100g;
  double fatsPer100g;

  // Constructor
  FoodEntry({
    required this.foodName,
    required this.mealType,
    required this.grams,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
  });

  // Computed nutritional values based on the selected grams
  double get calories => (caloriesPer100g * grams) / 100;
  double get proteins => (proteinsPer100g * grams) / 100;
  double get carbs => (carbsPer100g * grams) / 100;
  double get fats => (fatsPer100g * grams) / 100;
}