import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:bwthw_project/models/food_item.dart';
import 'package:bwthw_project/services/user_service.dart';
=======
import 'package:provider/provider.dart';
import 'package:bwthw_project/models/food_diary_db.dart';
import 'package:bwthw_project/models/food_entry.dart';
import 'package:bwthw_project/screens/food_search_page.dart';
>>>>>>> e252fe7ba4837894bba4189c90128fdc1797365f

// Homepage screen. It shows the food diary divided by meal type.
class FoodDiaryPage extends StatelessWidget {
  const FoodDiaryPage({super.key});

  @override
<<<<<<< HEAD
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
=======
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
>>>>>>> e252fe7ba4837894bba4189c90128fdc1797365f

    return SafeArea(
      child: Consumer<FoodDiaryDB>(
        builder: (context, foodDiaryDB, child) {
          return SingleChildScrollView(
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
                _buildMealSection(context, foodDiaryDB, 'Breakfast'),
                const SizedBox(height: 20),
                _buildMealSection(context, foodDiaryDB, 'Snack'),
                const SizedBox(height: 20),
                _buildMealSection(context, foodDiaryDB, 'Lunch'),
                const SizedBox(height: 20),
                _buildMealSection(context, foodDiaryDB, 'Dinner'),
              ],
            ),
<<<<<<< HEAD
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
=======
          );
        },
>>>>>>> e252fe7ba4837894bba4189c90128fdc1797365f
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildMealSection(
    BuildContext context,
    FoodDiaryDB foodDiaryDB,
    String mealTitle,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<FoodEntry> mealEntries = foodDiaryDB.entries
        .where((entry) => entry.mealType == mealTitle)
        .toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: mealEntries.isEmpty
            ? SizedBox(
                height: 180,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mealTitle,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FoodSearchPage(mealType: mealTitle),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Text(
                        'No food added',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mealTitle,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FoodSearchPage(mealType: mealTitle),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: mealEntries.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final FoodEntry foodEntry = entry.value;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == mealEntries.length - 1 ? 0 : 12,
                        ),
                        child: _buildFoodEntryCard(
                          context,
                          foodDiaryDB,
                          foodEntry,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFoodEntryCard(
    BuildContext context,
    FoodDiaryDB foodDiaryDB,
    FoodEntry foodEntry,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  foodEntry.foodName,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final int index = foodDiaryDB.entries.indexOf(foodEntry);
                  if (index != -1) {
                    foodDiaryDB.deleteEntry(index);
                  }
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _formatNumber(foodEntry.grams),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'grams',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildNutritionBox(
                  context,
                  'Calories:',
                  _formatNumber(foodEntry.calories),
                  const Color(0xFFF4EBDD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionBox(
                  context,
                  'Proteins:',
                  '${_formatNumber(foodEntry.proteins)}g',
                  const Color(0xFFDDE6F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNutritionBox(
                  context,
                  'Carbs:',
                  '${_formatNumber(foodEntry.carbs)}g',
                  const Color(0xFFF2EFD9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionBox(
                  context,
                  'Fats:',
                  '${_formatNumber(foodEntry.fats)}g',
                  const Color(0xFFF4E3E6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Per 100g: ${_formatNumber(foodEntry.caloriesPer100g)} kcal | '
            'P: ${_formatNumber(foodEntry.proteinsPer100g)}g | '
            'C: ${_formatNumber(foodEntry.carbsPer100g)}g | '
            'F: ${_formatNumber(foodEntry.fatsPer100g)}g',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
>>>>>>> e252fe7ba4837894bba4189c90128fdc1797365f
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildNutritionBox(
    BuildContext context,
    String label,
    String value,
    Color backgroundColor,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.titleMedium,
            ),
          ),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
>>>>>>> e252fe7ba4837894bba4189c90128fdc1797365f
      ),
    );
  }

<<<<<<< HEAD
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
=======
  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
>>>>>>> e252fe7ba4837894bba4189c90128fdc1797365f
