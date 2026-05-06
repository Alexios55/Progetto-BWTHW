import 'package:bwthw_project/models/food_item.dart';

// This class acts as a local data repository for the food catalog.
class FoodCatalog {
  List<FoodItem> foods = [
    FoodItem(name: 'Latte intero', calories: 64, proteins: 3.3, carbs: 4.9, fats: 3.6),
    FoodItem(name: 'Latte parzialmente scremato', calories: 46, proteins: 3.5, carbs: 5.0, fats: 1.5),
    FoodItem(name: 'Yogurt intero', calories: 66, proteins: 3.8, carbs: 4.3, fats: 3.9),
    FoodItem(name: 'Yogurt magro', calories: 36, proteins: 3.3, carbs: 4.0, fats: 0.9),
    FoodItem(name: 'Yogurt magro alla frutta', calories: 53.6, proteins: 4.4, carbs: 7.46, fats: 0.1),
    FoodItem(name: 'Yogurt ai cereali', calories: 113, proteins: 3.01, carbs: 16.5, fats: 3.5),
    FoodItem(name: 'Succo di frutta', calories: 56, proteins: 0.3, carbs: 14.5, fats: 0.1),
    FoodItem(name: 'Spremuta di agrumi', calories: 33, proteins: 0.5, carbs: 8.2, fats: 0.0),
    FoodItem(name: 'Marmellata', calories: 222, proteins: 0.5, carbs: 58.7, fats: 0.0),
    FoodItem(name: 'Zucchero', calories: 392, proteins: 0.0, carbs: 104.5, fats: 0.0),
    FoodItem(name: 'Miele', calories: 304, proteins: 0.6, carbs: 80.3, fats: 0.6),
    FoodItem(name: 'Biscotto frollino', calories: 429, proteins: 7.2, carbs: 73.7, fats: 13.8),
    FoodItem(name: 'Biscotto secco', calories: 416, proteins: 6.6, carbs: 84.8, fats: 7.9),
    FoodItem(name: 'Brioche', calories: 358, proteins: 8.3, carbs: 38.0, fats: 20.0),
    FoodItem(name: 'Fette biscottate integrali', calories: 379, proteins: 14.2, carbs: 62.0, fats: 10.0),
    FoodItem(name: 'Muesli', calories: 364, proteins: 9.7, carbs: 72.2, fats: 6.0),
    FoodItem(name: 'Pane integrale', calories: 224, proteins: 7.5, carbs: 48.5, fats: 1.3),
    FoodItem(name: 'Pasta', calories: 353, proteins: 10.9, carbs: 79.1, fats: 1.4),
    FoodItem(name: 'Riso', calories: 332, proteins: 6.7, carbs: 80.4, fats: 0.4),
    FoodItem(name: 'Patate', calories: 85, proteins: 2.1, carbs: 17.9, fats: 1.0),
    FoodItem(name: 'Carne (valori medi)', calories: 127.7, proteins: 20.63, carbs: 0.06, fats: 5.02),
    FoodItem(name: 'Pesce (valori medi)', calories: 97.1, proteins: 16.67, carbs: 1.17, fats: 2.89),
    FoodItem(name: 'Uovo gallina intero (60g)', calories: 128, proteins: 12.4, carbs: 0.0, fats: 8.7),
    FoodItem(name: 'Salumi (valori medi)', calories: 144.6, proteins: 27.56, carbs: 0.2, fats: 3.74),
    FoodItem(name: 'Prosciutto cotto sgrassato', calories: 132, proteins: 22.2, carbs: 1.0, fats: 4.4),
    FoodItem(name: 'Pr. Di Parma/S. Daniele sgrassato', calories: 147.5, proteins: 28.05, carbs: 0.0, fats: 3.9),
    FoodItem(name: 'Formaggi freschi (valori medi)', calories: 271.33, proteins: 18.78, carbs: 1.05, fats: 21.35),
    FoodItem(name: 'Grana Padano DOP', calories: 398, proteins: 33.0, carbs: 0.0, fats: 29.0),
    FoodItem(name: 'Ricotta vaccina', calories: 146, proteins: 8.8, carbs: 3.5, fats: 10.9),
    FoodItem(name: 'Mozzarella', calories: 253, proteins: 18.7, carbs: 0.7, fats: 19.5),
    FoodItem(name: 'Scamorza', calories: 334, proteins: 25.0, carbs: 1.0, fats: 25.4),
    FoodItem(name: 'Frutta (valori medi)', calories: 35.39, proteins: 0.68, carbs: 8.28, fats: 0.18),
    FoodItem(name: 'Verdura (valori medi)', calories: 20.13, proteins: 1.74, carbs: 3.01, fats: 0.2),
    FoodItem(name: 'Legumi secchi (valori medi)', calories: 295.7, proteins: 22.09, carbs: 49.39, fats: 2.0),
    FoodItem(name: 'Piselli freschi', calories: 52, proteins: 7.6, carbs: 12.4, fats: 0.2),
    FoodItem(name: "Olio d'oliva extravergine", calories: 899, proteins: 0.0, carbs: 0.0, fats: 99.9),
    FoodItem(name: 'Burro', calories: 758, proteins: 0.8, carbs: 1.1, fats: 83.4),
  ];
}

//Quindi:il catalogo cibi è semplice,non usa ChangeNotifier,non usa Provider
//è solo una lista locale da cui pescare