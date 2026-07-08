import 'package:bwthw_project/models.2/enums.dart';
import 'food_item.dart';

class FoodCatalog {
  static const List<FoodItem> foods = [

    //  DAIRY 
    FoodItem(
      name: 'Whole Milk', calories: 64, proteins: 3.3, carbs: 4.9, fats: 3.6,
      calcium: 120, vitaminD: 0.1, iron: 0.0,
      category: FoodCategory.dairy,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Semi-Skimmed Milk', calories: 46, proteins: 3.5, carbs: 5.0, fats: 1.5,
      calcium: 120, vitaminD: 0.1,
      category: FoodCategory.dairy,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Whole Yogurt', calories: 66, proteins: 3.8, carbs: 4.3, fats: 3.9,
      calcium: 110,
      category: FoodCategory.dairy,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Low-Fat Yogurt', calories: 36, proteins: 3.3, carbs: 4.0, fats: 0.9,
      calcium: 130,
      category: FoodCategory.dairy,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Fruit Low-Fat Yogurt', calories: 53.6, proteins: 4.4, carbs: 7.46, fats: 0.1,
      calcium: 120, vitaminC: 2,
      category: FoodCategory.dairy,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Cereal Yogurt', calories: 113, proteins: 3.01, carbs: 16.5, fats: 3.5,
      calcium: 100, iron: 1.0, fiber: 1.0, phytates: 30,
      category: FoodCategory.dairy,
      suitableMeals: [MealType.breakfast, MealType.morningSnack],
    ),

    
    FoodItem(
      name: 'Fruit Juice', calories: 56, proteins: 0.3, carbs: 14.5, fats: 0.1,
      vitaminC: 30,
      category: FoodCategory.juicesAndSweeteners,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Orange Juice', calories: 33, proteins: 0.5, carbs: 8.2, fats: 0,
      vitaminC: 45,
      category: FoodCategory.juicesAndSweeteners,
      suitableMeals: [MealType.breakfast, MealType.morningSnack],
    ),
    FoodItem(
      name: 'Jam', calories: 222, proteins: 0.5, carbs: 58.7, fats: 0,
      category: FoodCategory.juicesAndSweeteners,
      suitableMeals: [MealType.breakfast],
    ),
    FoodItem(
      name: 'Sugar', calories: 392, proteins: 0, carbs: 104.5, fats: 0,
      category: FoodCategory.juicesAndSweeteners,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Honey', calories: 304, proteins: 0.6, carbs: 80.3, fats: 0.6,
      category: FoodCategory.juicesAndSweeteners,
      suitableMeals: [MealType.breakfast, MealType.morningSnack],
    ),

    // ── BAKERY & CEREALS ────────────────────────────────────────
    FoodItem(
      name: 'Shortbread Biscuit', calories: 429, proteins: 7.2, carbs: 73.7, fats: 13.8,
      iron: 1.5, calcium: 50, phytates: 20,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Dry Biscuit', calories: 416, proteins: 6.6, carbs: 84.8, fats: 7.9,
      iron: 1.2, fiber: 1.5,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.breakfast, MealType.morningSnack],
    ),
    FoodItem(
      name: 'Croissant', calories: 358, proteins: 8.3, carbs: 38.0, fats: 20.0,
      calcium: 30,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.breakfast, MealType.morningSnack],
    ),
    FoodItem(
      name: 'Wholegrain Rusks', calories: 379, proteins: 14.2, carbs: 62.0, fats: 10.0,
      iron: 3.5, fiber: 6.5, phytates: 200, calcium: 60,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.breakfast, MealType.morningSnack],
    ),
    FoodItem(
      name: 'Muesli', calories: 364, proteins: 9.7, carbs: 72.2, fats: 6.0,
      iron: 4.5, fiber: 7.0, phytates: 250, calcium: 80,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.breakfast],
    ),
    FoodItem(
      name: 'Wholegrain Bread', calories: 224, proteins: 7.5, carbs: 48.5, fats: 1.3,
      iron: 2.5, fiber: 5.0, phytates: 180, calcium: 40,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.breakfast, MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'White Bread', calories: 265, proteins: 8.0, carbs: 49.0, fats: 3.2,
      iron: 1.5, calcium: 35, fiber: 1.5,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.breakfast, MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Pasta', calories: 353, proteins: 10.9, carbs: 79.1, fats: 1.4,
      iron: 1.8, fiber: 2.5, phytates: 60,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Rice', calories: 332, proteins: 6.7, carbs: 80.4, fats: 0.4,
      iron: 0.8, fiber: 0.4,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Potatoes', calories: 85, proteins: 2.1, carbs: 17.9, fats: 1.0,
      vitaminC: 20, iron: 0.8, fiber: 1.8,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Oats', calories: 389, proteins: 16.9, carbs: 66.3, fats: 6.9,
      iron: 4.7, fiber: 10.6, phytates: 300, calcium: 54,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.breakfast, MealType.morningSnack],
    ),
    FoodItem(
      name: 'Corn Flakes', calories: 357, proteins: 8.0, carbs: 84.0, fats: 0.4,
      iron: 8.0, fiber: 1.0,
      category: FoodCategory.bakeryAndCereals,
      suitableMeals: [MealType.breakfast],
    ),

   
    FoodItem(
      name: 'Chicken Breast', calories: 165, proteins: 31.0, carbs: 0, fats: 3.6,
      iron: 0.9,
      category: FoodCategory.meat,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Turkey Breast', calories: 135, proteins: 29.0, carbs: 0, fats: 1.0,
      iron: 0.8,
      category: FoodCategory.meat,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Beef', calories: 250, proteins: 26.0, carbs: 0, fats: 15.0,
      iron: 2.6,
      category: FoodCategory.meat,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Meat (Average Values)', calories: 127.7, proteins: 20.63, carbs: 0.06, fats: 5.02,
      iron: 1.8,
      category: FoodCategory.meat,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),

   
    FoodItem(
      name: 'Fish (Average Values)', calories: 97.1, proteins: 16.67, carbs: 1.17, fats: 2.89,
      iron: 0.9, omega3: 400, vitaminD: 5.0,
      category: FoodCategory.fish,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Salmon', calories: 208, proteins: 20.0, carbs: 0, fats: 13.0,
      iron: 0.8, omega3: 2200, vitaminD: 11.0,
      category: FoodCategory.fish,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Tuna', calories: 144, proteins: 23.0, carbs: 0, fats: 4.9,
      iron: 1.0, omega3: 1300, vitaminD: 5.5,
      category: FoodCategory.fish,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),

    
    FoodItem(
      name: 'Whole Egg', calories: 128, proteins: 12.4, carbs: 0, fats: 8.7,
      iron: 1.8, vitaminD: 2.0, calcium: 50,
      category: FoodCategory.eggs,
      suitableMeals: [MealType.breakfast, MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Egg White', calories: 52, proteins: 11.0, carbs: 0.7, fats: 0.2,
      iron: 0.1,
      category: FoodCategory.eggs,
      suitableMeals: [MealType.breakfast, MealType.lunch, MealType.dinner],
    ),

   
    FoodItem(
      name: 'Cured Meats (Average Values)', calories: 144.6, proteins: 27.56, carbs: 0.2, fats: 3.74,
      iron: 1.2,
      category: FoodCategory.curedMeats,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Lean Cooked Ham', calories: 132, proteins: 22.2, carbs: 1.0, fats: 4.4,
      iron: 0.8,
      category: FoodCategory.curedMeats,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Parma Ham', calories: 147.5, proteins: 28.05, carbs: 0, fats: 3.9,
      iron: 0.9,
      category: FoodCategory.curedMeats,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),

    
    FoodItem(
      name: 'Fresh Cheese (Average Values)', calories: 271.33, proteins: 18.78, carbs: 1.05, fats: 21.35,
      calcium: 250,
      category: FoodCategory.cheese,
      suitableMeals: [MealType.lunch, MealType.dinner, MealType.morningSnack],
    ),
    FoodItem(
      name: 'Parmesan', calories: 398, proteins: 33.0, carbs: 0, fats: 29.0,
      calcium: 1160,
      category: FoodCategory.cheese,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Ricotta', calories: 146, proteins: 8.8, carbs: 3.5, fats: 10.9,
      calcium: 207,
      category: FoodCategory.cheese,
      suitableMeals: [MealType.breakfast, MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Mozzarella', calories: 253, proteins: 18.7, carbs: 0.7, fats: 19.5,
      calcium: 505,
      category: FoodCategory.cheese,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Scamorza Cheese', calories: 334, proteins: 25.0, carbs: 1.0, fats: 25.4,
      calcium: 500,
      category: FoodCategory.cheese,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Cheddar Cheese', calories: 402, proteins: 25.0, carbs: 1.3, fats: 33.0,
      calcium: 720,
      category: FoodCategory.cheese,
      suitableMeals: [MealType.lunch, MealType.dinner, MealType.morningSnack],
    ),

    
    FoodItem(
      name: 'Fruit (Average Values)', calories: 35.39, proteins: 0.68, carbs: 8.28, fats: 0.18,
      vitaminC: 15, fiber: 2.0,
      category: FoodCategory.fruit,
      suitableMeals: [MealType.morningSnack, MealType.afternoonSnack, MealType.breakfast],
    ),
    FoodItem(
      name: 'Apple', calories: 52, proteins: 0.3, carbs: 14.0, fats: 0.2,
      vitaminC: 5, fiber: 2.4,
      category: FoodCategory.fruit,
      suitableMeals: [MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Banana', calories: 89, proteins: 1.1, carbs: 22.8, fats: 0.3,
      vitaminC: 9, fiber: 2.6, iron: 0.3,
      category: FoodCategory.fruit,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Orange', calories: 47, proteins: 0.9, carbs: 11.8, fats: 0.1,
      vitaminC: 53, fiber: 2.4, calcium: 40,
      category: FoodCategory.fruit,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Strawberries', calories: 32, proteins: 0.7, carbs: 7.7, fats: 0.3,
      vitaminC: 59, fiber: 2.0, iron: 0.4,
      category: FoodCategory.fruit,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),

    FoodItem(
      name: 'Vegetables (Average Values)', calories: 20.13, proteins: 1.74, carbs: 3.01, fats: 0.2,
      vitaminC: 20, iron: 1.0, calcium: 40, fiber: 2.5,
      category: FoodCategory.vegetables,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Tomato', calories: 18, proteins: 0.9, carbs: 3.9, fats: 0.2,
      vitaminC: 14, iron: 0.3, fiber: 1.2,
      category: FoodCategory.vegetables,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Lettuce', calories: 15, proteins: 1.4, carbs: 2.9, fats: 0.2,
      vitaminC: 9, iron: 0.9, calcium: 35, fiber: 1.3,
      category: FoodCategory.vegetables,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Zucchini', calories: 17, proteins: 1.2, carbs: 3.1, fats: 0.3,
      vitaminC: 17, iron: 0.4, fiber: 1.0,
      category: FoodCategory.vegetables,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Carrots', calories: 41, proteins: 0.9, carbs: 9.6, fats: 0.2,
      vitaminC: 6, iron: 0.3, calcium: 33, fiber: 2.8,
      category: FoodCategory.vegetables,
      suitableMeals: [MealType.lunch, MealType.dinner, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Spinach', calories: 23, proteins: 2.9, carbs: 3.6, fats: 0.4,
      iron: 2.7, calcium: 99, vitaminC: 28,
      oxalates: 970, phytates: 50,
      category: FoodCategory.vegetables,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),

   
    FoodItem(
      name: 'Dry Legumes (Average Values)', calories: 295.7, proteins: 22.09, carbs: 49.39, fats: 2.0,
      iron: 5.0, calcium: 80, fiber: 12.0, phytates: 400,
      category: FoodCategory.legumes,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Fresh Peas', calories: 52, proteins: 7.6, carbs: 12.4, fats: 0.2,
      iron: 1.5, vitaminC: 40, fiber: 5.0,
      category: FoodCategory.legumes,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Beans', calories: 127, proteins: 8.7, carbs: 22.8, fats: 0.5,
      iron: 2.2, calcium: 50, fiber: 7.4, phytates: 300,
      category: FoodCategory.legumes,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Chickpeas', calories: 164, proteins: 8.9, carbs: 27.4, fats: 2.6,
      iron: 2.9, calcium: 49, fiber: 7.6, phytates: 350,
      category: FoodCategory.legumes,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Lentils', calories: 116, proteins: 9.0, carbs: 20.1, fats: 0.4,
      iron: 3.3, calcium: 19, fiber: 7.9, phytates: 280,
      category: FoodCategory.legumes,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),

   
    FoodItem(
      name: 'Extra Virgin Olive Oil', calories: 899, proteins: 0, carbs: 0, fats: 99.9,
      omega3: 760,
      category: FoodCategory.fatsAndSpreads,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Butter', calories: 758, proteins: 0.8, carbs: 1.1, fats: 83.4,
      category: FoodCategory.fatsAndSpreads,
      suitableMeals: [MealType.breakfast],
    ),
    FoodItem(
      name: 'Peanut Butter', calories: 588, proteins: 25.0, carbs: 20.0, fats: 50.0,
      iron: 1.7, fiber: 6.0, phytates: 200,
      category: FoodCategory.fatsAndSpreads,
      suitableMeals: [MealType.breakfast, MealType.morningSnack, MealType.afternoonSnack],
    ),

    
    FoodItem(
      name: 'Almonds', calories: 579, proteins: 21.0, carbs: 22.0, fats: 50.0,
      calcium: 264, iron: 3.7, fiber: 12.5,
      phytates: 180, oxalates: 460,
      category: FoodCategory.nuts,
      suitableMeals: [MealType.morningSnack, MealType.afternoonSnack],
    ),
    FoodItem(
      name: 'Walnuts', calories: 654, proteins: 15.0, carbs: 14.0, fats: 65.0,
      omega3: 9080, iron: 2.9, calcium: 98, fiber: 6.7, phytates: 160,
      category: FoodCategory.nuts,
      suitableMeals: [MealType.morningSnack, MealType.afternoonSnack],
    ),

  
    FoodItem(
      name: 'Pizza Margherita', calories: 270, proteins: 11.0, carbs: 33.0, fats: 10.0,
      calcium: 200, iron: 1.5,
      category: FoodCategory.preparedFoods,
      suitableMeals: [MealType.lunch, MealType.dinner],
    ),
    FoodItem(
      name: 'Dark Chocolate', calories: 546, proteins: 4.9, carbs: 61.0, fats: 31.0,
      iron: 11.9, calcium: 73, oxalates: 117, phytates: 80, fiber: 10.9,
      category: FoodCategory.preparedFoods,
      suitableMeals: [MealType.morningSnack, MealType.afternoonSnack],
    ),
  ];
}