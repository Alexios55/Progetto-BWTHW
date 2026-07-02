
import 'package:bwthw_project/models.2/food_models/food_diary_db.dart';
import 'package:bwthw_project/models.2/food_models/food_entry.dart';
import 'package:bwthw_project/screens/food_diary_screens/food_search_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Homepage screen. It shows the food diary divided by meal type.
class FoodDiaryPage extends StatelessWidget {
  const FoodDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Consumer<FoodDiaryDB>(
        builder: (context, foodDiaryDB, child) {
          const meals = ['Breakfast', 'Snack', 'Lunch', 'Dinner'];
          const headerHeight = 34.0 + 16.0 + 16.0; // title + spacing
          const gapHeight = 5.0 * 3;               // 3 gaps between 4 tiles
          const padding = 16.0 * 2;                // vertical padding

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              // Height available for the 4 tiles combined
              final tilesHeight =
                  availableHeight - headerHeight - gapHeight - padding;
              // Each tile gets an equal share as its minimum collapsed height
              final tileMinHeight = (tilesHeight / meals.length).clamp(64.0, 200.0);

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
                    ...meals.expand((meal) => [
                      _buildMealSection(
                        context,
                        foodDiaryDB,
                        meal,
                        minCollapsedHeight: tileMinHeight,
                      ),
                      if (meal != meals.last) const SizedBox(height: 5),
                    ]),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _mealIcon(String mealTitle) {
    switch (mealTitle) {
      case 'Breakfast':
        return Icons.free_breakfast;
      case 'Snack':
        return Icons.cookie;
      case 'Lunch':
        return Icons.dinner_dining;
      case 'Dinner':
        return Icons.local_dining;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildMealSection(
    BuildContext context,
    FoodDiaryDB foodDiaryDB,
    String mealTitle, {
    double minCollapsedHeight = 64,}
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mealEntries = foodDiaryDB.entries
        .where((entry) => entry.mealType == mealTitle)
        .toList();

    final mealKcal = mealEntries.fold<double>(0, (s, e) => s + e.calories);

    return SizedBox(
      width: double.infinity,
      height: null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minCollapsedHeight),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colorScheme.outlineVariant),
        ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 24,
            ),
        visualDensity: VisualDensity(vertical: 2,),
        title: Text(
          mealTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${mealKcal.toStringAsFixed(0)} kcal',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            _mealIcon(mealTitle),
            color: colorScheme.primary,
            size: 28,
          ),
        ),
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,),
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide.none,),
        childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        children: [
          const SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
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
                      ...mealEntries.asMap().entries.map((entry) {
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildMealHeader(BuildContext context, String mealTitle) {
  
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FoodSearchPage(
                    mealType: mealTitle,
                  ),
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
                  '${_formatNumber(foodEntry.calories)} kcal',
                  const Color(0xFFF4EBDD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionBox(
                  context,
                  'Proteins:',
                  '${_formatNumber(foodEntry.proteins)} g',
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
                  '${_formatNumber(foodEntry.carbs)} g',
                  const Color(0xFFF2EFD9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionBox(
                  context,
                  'Fats:',
                  '${_formatNumber(foodEntry.fats)} g',
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

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

