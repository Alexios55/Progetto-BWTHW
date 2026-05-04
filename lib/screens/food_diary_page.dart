import 'package:flutter/material.dart';
import 'package:bwthw_project/models/food_item.dart';
import 'package:bwthw_project/services/user_service.dart';

// This page shows the daily food diary and allows the user
// to search and add a food to a specific meal.
class FoodDiaryPage extends StatefulWidget {
  const FoodDiaryPage({super.key});

  @override
  State<FoodDiaryPage> createState() => _FoodDiaryPageState();
}

class _FoodDiaryPageState extends State<FoodDiaryPage> {
  bool isSearching = false;
  String selectedMeal = '';
  String searchText = '';

  final Map<String, FoodItem?> selectedFoods = {
    'Breakfast': null,
    'Snack': null,
    'Lunch': null,
    'Dinner': null,
  };

  final List<FoodItem> foods = const [
    FoodItem(name: 'Whole bread', calories: 250, proteins: 8, carbs: 45, fats: 3),
    FoodItem(name: 'Grilled chicken', calories: 165, proteins: 31, carbs: 0, fats: 3.6),
    FoodItem(name: 'Basmati rice', calories: 130, proteins: 2.7, carbs: 28, fats: 0.3),
    FoodItem(name: 'Apple', calories: 95, proteins: 0.5, carbs: 25, fats: 0.3),
    FoodItem(name: 'Greek yogurt', calories: 97, proteins: 10, carbs: 3.6, fats: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return isSearching ? _buildSearchView(context) : _buildDiaryView(context);
  }

  // ---------------- DIARY VIEW ----------------
  Widget _buildDiaryView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userService = UserService();
    final consumedCalories = getTotalCalories();
    final targetCalories = userService.dailyCaloriesTarget;
    final smartwatchData = userService.dailyHealthData;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Diary',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '24 April 2026',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              userService.getDailyFeedback(),
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today overview',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Consumed: ${consumedCalories.toStringAsFixed(0)} kcal'),
                    Text('Target: ${targetCalories.toStringAsFixed(0)} kcal'),
                    Text('Steps: ${smartwatchData.steps}'),
                    Text(
                      'Watch calories burned: ${smartwatchData.activeCaloriesBurned.toStringAsFixed(0)} kcal',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildMealCard(context, 'Breakfast'),
            const SizedBox(height: 20),
            _buildMealCard(context, 'Snack'),
            const SizedBox(height: 20),
            _buildMealCard(context, 'Lunch'),
            const SizedBox(height: 20),
            _buildMealCard(context, 'Dinner'),
          ],
        ),
      ),
    );
  }

  // ---------------- SEARCH VIEW ----------------
  Widget _buildSearchView(BuildContext context) {
    final filteredFoods = foods
        .where((food) =>
            food.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search food...',
              ),
            ),
            const SizedBox(height: 20),

            ...filteredFoods.map((food) {
              return ListTile(
                title: Text(food.name),
                subtitle: Text('${food.calories} kcal'),
                onTap: () {
                  setState(() {
                    selectedFoods[selectedMeal] = food;
                    UserService().setMealCalories(selectedMeal, food.calories);
                    isSearching = false;
                    searchText = '';
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------- MEAL CARD ----------------
  Widget _buildMealCard(BuildContext context, String mealTitle) {
    final food = selectedFoods[mealTitle];

    return Card(
      child: ListTile(
        title: Text(mealTitle),
        subtitle: food == null
            ? const Text('No food added')
            : Text('${food.name} - ${food.calories} kcal'),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              selectedMeal = mealTitle;
              isSearching = true;
            });
          },
        ),
      ),
    );
  }

  // ---------------- CALCULATION LOGIC ----------------
  double getTotalCalories() {
    double total = 0;

    for (final food in selectedFoods.values) {
      if (food != null) {
        total += food.calories;
      }
    }

    return total;
  }
}
