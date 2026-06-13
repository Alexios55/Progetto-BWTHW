import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/food_models/food_diary_db.dart';
import 'package:bwthw_project/models.2/food_models/food_item.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/logic/nutrition_engine.dart';
import 'package:bwthw_project/logic/blood_test_analyzer.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/blood_test.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/services/calorie_calculator.dart';
import 'package:bwthw_project/models.2/food_models/food_catalog.dart';

class SuggestedFoodsScreen extends StatefulWidget {
  const SuggestedFoodsScreen({super.key});

  @override
  State<SuggestedFoodsScreen> createState() => _SuggestedFoodsScreenState();
}

class _SuggestedFoodsScreenState extends State<SuggestedFoodsScreen> {
  BloodTest? _latestBloodTest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBloodTest();
  }

  Future<void> _loadBloodTest() async {
    final tests = await PreferenceService.getBloodTests();
    if (!mounted) return;
    setState(() {
      _latestBloodTest = tests.isNotEmpty ? tests.last : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Nutritional suggestions',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<FoodDiaryDB>(
              builder: (context, foodDiaryDB, _) {
                final patient = context.watch<PatientState>().patient;
                if (patient == null) {
                  return const Center(child: Text('Profilo utente non trovato.'));
                }

                final exerciseCalories =
                    context.watch<PatientState>().burnedCalories;
                final steps = context.watch<PatientState>().steps;

                // Build consumed map
                final Map<FoodItem, double> consumedMap = {};
                for (final entry in foodDiaryDB.entries) {
                  final item = FoodCatalog.foods.cast<FoodItem?>().firstWhere(
                    (f) => f?.name == entry.foodName,
                    orElse: () => null,
                  );
                  if (item != null) {
                    consumedMap[item] = (consumedMap[item] ?? 0) + entry.grams;
                  }
                }

                // Totals consumed today
                final double totalCalories = foodDiaryDB.entries
                    .fold(0, (s, e) => s + e.calories);
                final double totalProteins = foodDiaryDB.entries
                    .fold(0, (s, e) => s + e.proteins);
                final double totalCarbs = foodDiaryDB.entries
                    .fold(0, (s, e) => s + e.carbs);
                final double totalFats = foodDiaryDB.entries
                    .fold(0, (s, e) => s + e.fats);

                // Fiber from catalog items
                double totalFiber = 0;
                consumedMap.forEach((food, grams) {
                  totalFiber += food.fiber * (grams / 100);
                });

                // Macro targets
                final targets = DailyTargets.fromPatient(patient);

                // Blood micronutrients consumed
                double totalIron = 0, totalCalcium = 0,
                    totalVitaminD = 0, totalOmega3 = 0;
                consumedMap.forEach((food, grams) {
                  final scale = grams / 100;
                  totalIron     += food.iron     * scale;
                  totalCalcium  += food.calcium  * scale;
                  totalVitaminD += food.vitaminD * scale;
                  totalOmega3   += food.omega3   * scale;
                });

                // Blood parameter targets (reference optimal values)
                const double ironTarget     = 18.0;   // mg/day RDA
                const double calciumTarget  = 1000.0; // mg/day RDA
                const double vitaminDTarget = 15.0;   // µg/day RDA
                const double omega3Target   = 1600.0; // mg/day RDA (ALA)
                const double fiberTarget    = 25.0;   // g/day RDA

                // Ranked suggestions for current meal
                final currentMeal = MealTypeExtension.current();
                final allScores = NutritionEngine.rankFoods(
                  patient: patient,
                  catalog: FoodCatalog.foods,
                  consumed: consumedMap,
                  bloodTest: _latestBloodTest,
                  caloriesBurned: exerciseCalories,
                  stepsToday: steps,
                );
                final mealSuggestions = allScores
                    .where((s) => s.food.suitableMeals.contains(currentMeal))
                    .toList();

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Meal label ──────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.schedule_outlined,
                                      size: 14, color: colorScheme.primary),
                                  const SizedBox(width: 5),
                                  Text(
                                    currentMeal.label,
                                    style: textTheme.labelMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── ROW 1: Macros ────────────────────
                            Text(
                              "Today's macronutrients",
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _NutrientRing(
                                  label: 'Calories',
                                  value: totalCalories,
                                  target: targets.calories,
                                  unit: 'kcal',
                                  color: colorScheme.primary,
                                ),
                                _NutrientRing(
                                  label: 'Proteins',
                                  value: totalProteins,
                                  target: targets.proteins,
                                  unit: 'g',
                                  color: Colors.blue.shade500,
                                ),
                                _NutrientRing(
                                  label: 'Carbohydrates',
                                  value: totalCarbs,
                                  target: targets.carbs,
                                  unit: 'g',
                                  color: Colors.amber.shade600,
                                ),
                                _NutrientRing(
                                  label: 'Fats',
                                  value: totalFats,
                                  target: targets.fats,
                                  unit: 'g',
                                  color: Colors.orange.shade500,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ── ROW 2: Micronutrienti ─────────────
                            Row(
                              children: [
                                Text(
                                  "Today's micronutrients",
                                  style: textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (_latestBloodTest == null)
                                  Tooltip(
                                    message: 'No blood tests recorded.\nTargets are based on standard RDA values.',
                                    child: Icon(Icons.info_outline,
                                        size: 14,
                                        color: colorScheme.onSurfaceVariant),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _NutrientRing(
                                  label: 'Iron',
                                  value: totalIron,
                                  target: ironTarget,
                                  unit: 'mg',
                                  color: Colors.red.shade400,
                                  deficit: _latestBloodTest != null
                                      ? BloodTestAnalyzer.computeDeficits(
                                              _latestBloodTest!)['iron']
                                          ?.deficit
                                      : null,
                                ),
                                _NutrientRing(
                                  label: 'Calcium',
                                  value: totalCalcium,
                                  target: calciumTarget,
                                  unit: 'mg',
                                  color: Colors.indigo.shade400,
                                  deficit: _latestBloodTest != null
                                      ? BloodTestAnalyzer.computeDeficits(
                                              _latestBloodTest!)['calcium']
                                          ?.deficit
                                      : null,
                                ),
                                _NutrientRing(
                                  label: 'Vit. D',
                                  value: totalVitaminD,
                                  target: vitaminDTarget,
                                  unit: 'µg',
                                  color: Colors.orange.shade400,
                                  deficit: _latestBloodTest != null
                                      ? BloodTestAnalyzer.computeDeficits(
                                              _latestBloodTest!)['vitaminD']
                                          ?.deficit
                                      : null,
                                ),
                                _NutrientRing(
                                  label: 'Omega-3',
                                  value: totalOmega3,
                                  target: omega3Target,
                                  unit: 'mg',
                                  color: Colors.cyan.shade500,
                                ),
                                _NutrientRing(
                                  label: 'Fibers',
                                  value: totalFiber,
                                  target: fiberTarget,
                                  unit: 'g',
                                  color: Colors.green.shade500,
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // ── Suggested list header ─────────────
                            Text(
                              'Suggested for you right now',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sorted by personalized nutritional score',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // ── Food list ────────────────────────────────
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= mealSuggestions.length) return null;
                          final score = mealSuggestions[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: _FoodSuggestionCard(
                              score: score,
                              rank: index + 1,
                              allScores: allScores,
                              bloodTest: _latestBloodTest,
                            ),
                          );
                        },
                        childCount: mealSuggestions.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                );
              },
            ),
    );
  }
}

// ── NUTRIENT RING ────────────────────────────────────────────────

class _NutrientRing extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final String unit;
  final Color color;
  // If non-null, shows a small deficit indicator dot
  final double? deficit;

  const _NutrientRing({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    required this.color,
    this.deficit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (value / target).clamp(0.0, 1.0);
    final isOver = value > target;
    final ringColor = isOver ? Colors.red.shade400 : color;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 5.5,
                backgroundColor:
                    colorScheme.outlineVariant.withOpacity(0.25),
                valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _format(value),
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                Text(
                  unit,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            // Deficit dot — top-right of ring
            if (deficit != null && deficit! > 0.2)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: deficit! > 0.6
                        ? Colors.red.shade400
                        : Colors.orange.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: colorScheme.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '/ ${_format(target)} $unit',
          style: textTheme.labelSmall?.copyWith(
            fontSize: 9,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _format(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v >= 10)   return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

// ── FOOD SUGGESTION CARD ─────────────────────────────────────────

class _FoodSuggestionCard extends StatelessWidget {
  final FoodScore score;
  final int rank;
  final List<FoodScore> allScores;
  final BloodTest? bloodTest;

  const _FoodSuggestionCard({
    required this.score,
    required this.rank,
    required this.allScores,
    required this.bloodTest,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final food = score.food;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showAlternatives(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank number
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Icon(food.categoryIcon,
                  size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Score badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _scoreColor(score.totalScore)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: _scoreColor(score.totalScore)
                                .withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          '${(score.totalScore * 100).toStringAsFixed(0)}',
                          style: textTheme.labelSmall?.copyWith(
                            color: _scoreColor(score.totalScore),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Macros
                  Text(
                    '${food.calories.toStringAsFixed(0)} kcal · '
                    'P ${food.proteins.toStringAsFixed(1)}g · '
                    'C ${food.carbs.toStringAsFixed(1)}g · '
                    'G ${food.fats.toStringAsFixed(1)}g',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Reason chips + alternatives hint
                  Row(
                    children: [
                      ..._buildChips(score, colorScheme),
                      const Spacer(),
                      Text(
                        'Alternatives →',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlternatives(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final food = score.food;

    // Alternatives: same category, not the same food, top 4 by score
    final alternatives = allScores
        .where((s) =>
            s.food.category == food.category && s.food.name != food.name)
        .take(4)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Alternatives to ${food.name}',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Same category · sorted by score',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (alternatives.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No alternatives available for this category.',
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: alternatives.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final alt = alternatives[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(alt.food.categoryIcon,
                                      size: 18,
                                      color: colorScheme.primary),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(alt.food.name,
                                          style: textTheme.titleSmall
                                              ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w600)),
                                      Text(
                                        '${alt.food.calories.toStringAsFixed(0)} kcal · '
                                        'P ${alt.food.proteins.toStringAsFixed(1)}g · '
                                        'C ${alt.food.carbs.toStringAsFixed(1)}g · '
                                        'G ${alt.food.fats.toStringAsFixed(1)}g',
                                        style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme
                                                .onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _scoreColor(alt.totalScore)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: _scoreColor(alt.totalScore)
                                            .withOpacity(0.35)),
                                  ),
                                  child: Text(
                                    '${(alt.totalScore * 100).toStringAsFixed(0)}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: _scoreColor(alt.totalScore),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildChips(FoodScore score, ColorScheme colorScheme) {
    final chips = <_Chip>[];
    final food = score.food;

    if (food.proteins > 15)
      chips.add(_Chip('Protein', Icons.fitness_center, Colors.blue));
    if (food.iron > 2)
      chips.add(_Chip('Rich in iron', Icons.bloodtype_outlined, Colors.red));
    if (food.calcium > 150)
      chips.add(_Chip('Calcium', Icons.science_outlined, Colors.indigo));
    if (food.vitaminD > 3)
      chips.add(_Chip('Vit. D', Icons.wb_sunny_outlined, Colors.orange));
    if (food.omega3 > 500)
      chips.add(_Chip('Omega-3', Icons.water_drop_outlined, Colors.cyan));
    if (food.fiber > 3)
      chips.add(_Chip('Fibers', Icons.grass_outlined, Colors.green));
    if (food.fats < 5 && food.calories < 150)
      chips.add(_Chip('Light', Icons.air, Colors.teal));
    if (score.activityScore > 0.4)
      chips.add(_Chip('Post-workout', Icons.directions_run, Colors.deepOrange));

    return chips.take(2).map((c) => Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: c.color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.color.withOpacity(0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(c.icon, size: 10, color: c.color),
            const SizedBox(width: 3),
            Text(c.label,
                style: TextStyle(
                    fontSize: 10,
                    color: c.color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    )).toList();
  }

  Color _scoreColor(double s) {
    if (s >= 0.65) return Colors.green.shade600;
    if (s >= 0.40) return Colors.orange.shade600;
    return Colors.grey.shade500;
  }
}

class _Chip {
  final String label;
  final IconData icon;
  final Color color;
  const _Chip(this.label, this.icon, this.color);
}