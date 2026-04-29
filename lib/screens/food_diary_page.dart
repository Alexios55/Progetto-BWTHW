import 'package:flutter/material.dart';

// This page shows the daily food diary and allows the user
// to search and add a food to a specific meal.
class FoodDiaryPage extends StatefulWidget {
  const FoodDiaryPage({super.key});

  @override
  State<FoodDiaryPage> createState() => _FoodDiaryPageState();
}

class _FoodDiaryPageState extends State<FoodDiaryPage> {
  // Controls whether the food search panel is visible.
  bool isSearching = false;

  // Stores the current meal selected by the user.
  String selectedMeal = '';

  // Stores the search text.
  String searchText = '';

  // Stores the selected food for each meal.
  final Map<String, FoodItem?> selectedFoods = {
    'Breakfast': null,
    'Snack': null,
    'Lunch': null,
    'Dinner': null,
  };

  // Local mock list of foods with nutritional values per 100g.
  final List<FoodItem> foods = const [
    FoodItem(
      name: 'Whole bread',
      calories: 250,
      proteins: 8,
      carbs: 45,
      fats: 3,
    ),
    FoodItem(
      name: 'Grilled chicken',
      calories: 165,
      proteins: 31,
      carbs: 0,
      fats: 3.6,
    ),
    FoodItem(
      name: 'Basmati rice',
      calories: 130,
      proteins: 2.7,
      carbs: 28,
      fats: 0.3,
    ),
    FoodItem(
      name: 'Apple',
      calories: 95,
      proteins: 0.5,
      carbs: 25,
      fats: 0.3,
    ),
    FoodItem(
      name: 'Greek yogurt',
      calories: 97,
      proteins: 10,
      carbs: 3.6,
      fats: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return isSearching ? _buildSearchView(context) : _buildDiaryView(context);
  }

  Widget _buildDiaryView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
            const SizedBox(height: 24),
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

  Widget _buildSearchView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final List<FoodItem> filteredFoods =
        foods
            .where(
              (food) =>
                  food.name.toLowerCase().contains(searchText.toLowerCase()),
            )
            .toList();

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
                            'Search food for $selectedMeal',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isSearching = false;
                              searchText = '';
                            });
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
                      children:
                          filteredFoods
                              .map(
                                (food) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      setState(() {
                                        selectedFoods[selectedMeal] = food;
                                        isSearching = false;
                                        searchText = '';
                                      });
                                    },
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            food.name,
                                            style: textTheme.titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Per 100g: ${food.calories} kcal | '
                                            'Proteins: ${food.proteins}g | '
                                            'Carbs: ${food.carbs}g | '
                                            'Fats: ${food.fats}g',
                                            style: textTheme.titleMedium
                                                ?.copyWith(
                                                  color:
                                                      colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, String mealTitle) {
    final FoodItem? selectedFood = selectedFoods[mealTitle];

    if (selectedFood == null) {
      return _buildEmptyMealCard(context, mealTitle);
    }

    return _buildFilledMealCard(context, mealTitle, selectedFood);
  }

  Widget _buildEmptyMealCard(BuildContext context, String mealTitle) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
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
                      setState(() {
                        selectedMeal = mealTitle;
                        isSearching = true;
                      });
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Text(
                  'No food added',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilledMealCard(
    BuildContext context,
    String mealTitle,
    FoodItem food,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
                    setState(() {
                      selectedMeal = mealTitle;
                      isSearching = true;
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    food.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedFoods[mealTitle] = null;
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Per 100g: ${food.calories} kcal | '
                'Proteins: ${food.proteins}g | '
                'Carbs: ${food.carbs}g | '
                'Fats: ${food.fats}g',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple local model for food data.
class FoodItem {
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
  });
}