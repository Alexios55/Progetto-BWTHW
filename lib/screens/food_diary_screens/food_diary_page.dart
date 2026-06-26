
import 'package:bwthw_project/models.2/food_models/food_diary_db.dart';
import 'package:bwthw_project/models.2/food_models/food_entry.dart';
import 'package:bwthw_project/screens/food_diary_screens/food_search_page.dart';
import 'package:bwthw_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Homepage screen. It shows the food diary divided by meal type.
class FoodDiaryPage extends StatelessWidget {
  const FoodDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userService = UserService();

    return SafeArea(
      child: Consumer<FoodDiaryDB>(
        builder: (context, foodDiaryDB, child) {
          final consumedCalories = _totalCalories(foodDiaryDB.entries);
          final targetCalories = userService.dailyCaloriesTarget;
          final smartwatchData = userService.dailyHealthData;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Food Diary',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _buildOverviewCard(
                  context,
                  consumedCalories: consumedCalories,
                  targetCalories: targetCalories,
                  steps: smartwatchData.steps,
                  activeCaloriesBurned: smartwatchData.activeCaloriesBurned,
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
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required double consumedCalories,
    required double targetCalories,
    required int steps,
    required double activeCaloriesBurned,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
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
            Text('Steps: $steps'),
            Text(
              'Watch calories burned: ${activeCaloriesBurned.toStringAsFixed(0)} kcal',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    FoodDiaryDB foodDiaryDB,
    String mealTitle,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mealEntries = foodDiaryDB.entries
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
                    _buildMealHeader(context, mealTitle),
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
                  _buildMealHeader(context, mealTitle),
                  const SizedBox(height: 16),
                  Column(
                    children: mealEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final foodEntry = entry.value;

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

  Widget _buildMealHeader(BuildContext context, String mealTitle) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
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
                builder: (context) => FoodSearchPage(mealType: mealTitle),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildFoodEntryCard(
    BuildContext context,
    FoodDiaryDB foodDiaryDB,
    FoodEntry foodEntry,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  final index = foodDiaryDB.entries.indexOf(foodEntry);
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
      ),
    );
  }

  Widget _buildNutritionBox(
    BuildContext context,
    String label,
    String value,
    Color backgroundColor,
  ) {
    final textTheme = Theme.of(context).textTheme;

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
      ),
    );
  }

  double _totalCalories(List<FoodEntry> entries) {
    return entries.fold(0, (total, entry) => total + entry.calories);
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

