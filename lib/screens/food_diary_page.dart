import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models/food_diary_db.dart';
import 'package:bwthw_project/models/food_entry.dart';
import 'package:bwthw_project/screens/food_search_page.dart';

// Homepage screen. It shows the food diary divided by meal type.
class FoodDiaryPage extends StatelessWidget {
  const FoodDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
          );
        },
      ),
    );
  }

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
      ),
    );
  }

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
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}