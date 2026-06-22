
import 'package:bwthw_project/screens/inside_dashboard/suggested_food_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/food_models/food_diary_db.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/services/calorie_calculator.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/widgets/navigation_card.dart';
import 'package:bwthw_project/screens/inside_dashboard/weight_health_screens/health_screen.dart';
import 'package:bwthw_project/widgets/calorie_balance_bar.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/models.2/food_models/food_item.dart';
import 'package:bwthw_project/logic/nutrition_engine.dart';
import 'package:bwthw_project/models.2/food_models/food_catalog.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // final loadedEntries = await PreferenceService.getWeightEntries();
    final loadedUser = await PreferenceService.getUserData();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    // update the weigth in patient for the calculation of calories
    context.read<PatientState>().updateWeight(loadedUser!.weight);
    await PreferenceService.savePatient(
      context.read<PatientState>().patient!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: Consumer<FoodDiaryDB>(
        builder: (context, foodDiaryDB, child) {
          final patient = context.watch<PatientState>().patient;
          if (patient == null) {
            return const Center(
              child: Text('No user data found. Please complete your profile.'),
            );
          }

          double baseGoal = calculateDailyCalorieGoal(patient);
          final exerciseCalories = context.watch<PatientState>().burnedCalories;

          double foodCalories = 0;
          for (final entry in foodDiaryDB.entries) {
            foodCalories += entry.calories;
          }

          // Build the map for nutrition engine
          final Map<FoodItem, double> consumedMap = {};
          for (final entry in foodDiaryDB.entries) {
            final catalogItem = FoodCatalog.foods.cast<FoodItem?>().firstWhere(
              (f) => f?.name == entry.foodName,
              orElse: () => null,
            );
            if (catalogItem != null) {
              consumedMap[catalogItem] = (consumedMap[catalogItem] ?? 0) + entry.grams;
            }
          }

          // Get the top 3 suggested foods filtered by the current time (meals)
          final currentMeal = MealTypeExtension.current();
          final allScores = NutritionEngine.rankFoods(
            patient: patient, 
            catalog: FoodCatalog.foods,
            consumed: consumedMap,
            caloriesBurned: exerciseCalories,
            stepsToday: context.watch<PatientState>().steps
          );
          final topSuggestions = allScores.where((s) => s.food.suitableMeals.contains(currentMeal)).take(3).toList();

          return RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCalorieBalanceCard(
                    context,
                    colorScheme,
                    textTheme,
                    baseGoal.toInt(),
                    foodCalories,
                    exerciseCalories,
                  ),

                  // Suggested food Widget
                  if (topSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSuggestedFoodCard(
                      context,
                      colorScheme,
                      textTheme,
                      topSuggestions,
                      currentMeal,
                    ),
                  ],

                // Navigation cards
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      NavCard(
                        label: 'Weight\n& Health',
                        icon: Icons.monitor_weight_outlined,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const HealthScreen(),
                          ));
                          // ricarica i dati del paziente al ritorno
                          if (mounted) setState(() {});
                        },
                      ),
                      const SizedBox(width: 10),
                      NavCard(
                        label: 'Blood\nTests',
                        icon: Icons.bloodtype_outlined,
                        onTap: () => Navigator.pushNamed(context, '/blood-tests'),
                      ),
                      const SizedBox(width: 10),
                      NavCard(
                        label: 'Body\nMeasures',
                        icon: Icons.straighten_outlined,
                        onTap: () => Navigator.pushNamed(context, '/body-measurements'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Suggested food widget
  Widget _buildSuggestedFoodCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<FoodScore> suggestions,
    MealType currentMeal,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SuggestedFoodsScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Food suggested for ${currentMeal.label.toLowerCase()} meal',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),

          ...suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final score = entry.value;
            return Column(
              children: [
                _buildSuggestionTile(context, colorScheme, textTheme, score),
                if (index < suggestions.length - 1)
                Divider(height: 16, color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildSuggestionTile(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    FoodScore score,
  ) {
    final food = score.food;
    final labels = _buildReasonLabels(score, colorScheme);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category icon
        Container(width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Icon(food.categoryIcon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        
        // Name and labels
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                food.name,
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // Macro quick info for label
              Text(
                '${food.calories.toStringAsFixed(0)} kcal · '
                'P ${food.proteins.toStringAsFixed(1)}g · '
                'C ${food.carbs.toStringAsFixed(1)}g · '
                'G ${food.fats.toStringAsFixed(1)}g',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (labels.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: labels,
                ),
              ],
            ],
          ),
        ),

        // Score badge
                Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _scoreColor(score.totalScore, colorScheme).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _scoreColor(score.totalScore, colorScheme).withOpacity(0.4),
            ),
          ),
          child: Text(
            '${(score.totalScore * 100).toStringAsFixed(0)}',
            style: textTheme.labelMedium?.copyWith(
              color: _scoreColor(score.totalScore, colorScheme),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Build the "why suggested" label
  List<Widget> _buildReasonLabels(FoodScore score, ColorScheme colorScheme) {
    final labels = <_ReasonLabel>[];
    final food = score.food;
 
    // Macro-based labels
    if (score.macroScore > 0.55) {
      if (food.proteins > 15) {
        labels.add(_ReasonLabel('High in protein', Icons.fitness_center, Colors.blue));
      }
      if (food.carbs > 30 && food.carbs < 70) {
        labels.add(_ReasonLabel('Balanced carbohydrates', Icons.bolt, Colors.amber.shade700));
      }
      if (food.fats < 5 && food.calories < 200) {
        labels.add(_ReasonLabel('Light', Icons.air, Colors.teal));
      }
    }
 
    // Blood/micronutrient labels
    for (final def in score.addressedDeficiencies) {
      switch (def) {
        case 'ferritin':
        case 'iron':
          labels.add(_ReasonLabel('Ricco di ferro', Icons.bloodtype_outlined, Colors.red));
          break;
        case 'calcium':
          labels.add(_ReasonLabel('Fonte di calcio', Icons.science_outlined, Colors.indigo));
          break;
        case 'vitaminD':
          labels.add(_ReasonLabel('Vitamina D', Icons.wb_sunny_outlined, Colors.orange));
          break;
        case 'cholesterol':
        case 'omega3':
          labels.add(_ReasonLabel('Omega-3', Icons.water_drop_outlined, Colors.cyan));
          break;
        case 'glucose':
        case 'fiber':
          labels.add(_ReasonLabel('Ricco di fibre', Icons.grass_outlined, Colors.green));
          break;
      }
    }
 
    // Activity label
    if (score.activityScore > 0.4) {
      labels.add(_ReasonLabel('Post-allenamento', Icons.directions_run, Colors.deepOrange));
    }
 
    // Cap at 2 labels to keep UI clean
    final shown = labels.take(2).toList();
 
    return shown.map((l) => _buildChip(l, colorScheme)).toList();
  }
 
  Widget _buildChip(_ReasonLabel label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: label.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: label.color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(label.icon, size: 11, color: label.color),
          const SizedBox(width: 4),
          Text(
            label.text,
            style: TextStyle(
              fontSize: 11,
              color: label.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

    Color _scoreColor(double score, ColorScheme colorScheme) {
    if (score >= 0.65) return Colors.green.shade600;
    if (score >= 0.40) return Colors.orange.shade600;
    return colorScheme.onSurfaceVariant;
  }
 
 

  Widget _buildCalorieBalanceCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    int baseGoal,
    double foodCalories,
    double exerciseCalories,
  ) {
    // balance: positive = surplus, negative = deficit
    final double balance = foodCalories - exerciseCalories - baseGoal;
    final patient = context.watch<PatientState>().patient;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
        ),   
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title row 
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${patient?.name ?? 'Patient'}'s calories balance",
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Daily goal: ${_formatNumber(baseGoal.toDouble())} kcal',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),

                      CalorieBalanceBar(
                        consumed: foodCalories - exerciseCalories,
                        goal: baseGoal.toDouble(),
                        maxRange: 1000,
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),

          // Two info cards
          Row(
            children: [
              // Consumed card
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: navigate to food diary
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer
                                .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: Icon(Icons.restaurant_outlined,
                              size: 18, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatNumber(foodCalories)} kcal',
                                style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'consumed',
                                style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            size: 16,
                            color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
 
              const SizedBox(width: 10),
 
              // Burned card
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/burned-calories'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: const Icon(Icons.local_fire_department_outlined,
                              size: 18, color: Colors.orange),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatNumber(exerciseCalories)} kcal',
                                style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'burned',
                                style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            size: 16,
                            color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.titleLarge),
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatNumber(double value) {
    return value.toStringAsFixed(0);
  }
}

// Internal model for reason labels
class _ReasonLabel {
  final String text;
  final IconData icon;
  final Color color;
  const _ReasonLabel(this.text, this.icon, this.color);
}

