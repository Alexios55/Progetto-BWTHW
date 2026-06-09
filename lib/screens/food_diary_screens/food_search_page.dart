import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/food_catalog.dart';
import 'package:bwthw_project/models.2/food_diary_db.dart';
import 'package:bwthw_project/models.2/food_entry.dart';
import 'package:bwthw_project/models.2/food_item.dart';

// This page allows the user to search a food and add it to the diary.
class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({
    super.key,
    required this.mealType,
  });

  final String mealType;

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final FoodCatalog foodCatalog = FoodCatalog();
  String searchText = '';

  Future<void> _selectFood(BuildContext context, FoodItem food) async {
    final TextEditingController gramsController =
        TextEditingController(text: '100');

    final double? grams = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Insert grams'),
          content: TextField(
            controller: gramsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Grams',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final double? parsedValue =
                    double.tryParse(gramsController.text.replaceAll(',', '.'));

                if (parsedValue == null || parsedValue <= 0) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Grams must be a valid number'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  return;
                }

                Navigator.pop(dialogContext, parsedValue);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    gramsController.dispose();

    if (grams == null) return;

    final FoodEntry newEntry = FoodEntry(
      foodName: food.name,
      mealType: widget.mealType,
      grams: grams,
      caloriesPer100g: food.calories,
      proteinsPer100g: food.proteins,
      carbsPer100g: food.carbs,
      fatsPer100g: food.fats,
    );

    Provider.of<FoodDiaryDB>(context, listen: false).addEntry(newEntry);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<FoodItem> filteredFoods = FoodCatalog.foods.where((food) {
      return food.name.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      body: SafeArea(
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
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.search, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search food for ${widget.mealType}',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search a food...',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: filteredFoods.map((food) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _selectFood(context, food),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Per 100g: ${_formatNumber(food.calories)} kcal | '
                                      'Proteins: ${_formatNumber(food.proteins)}g | '
                                      'Carbs: ${_formatNumber(food.carbs)}g | '
                                      'Fats: ${_formatNumber(food.fats)}g',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
