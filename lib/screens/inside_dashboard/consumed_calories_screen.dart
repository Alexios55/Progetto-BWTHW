import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:bwthw_project/models.2/patient_state.dart';
import 'package:bwthw_project/models.2/food_models/food_diary_db.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/blood_test.dart';
import 'package:bwthw_project/logic/nutrition_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bwthw_project/models.2/food_models/food_catalog.dart';
import 'package:bwthw_project/widgets/activity_ring.dart';

class ConsumedScreen extends StatefulWidget {
  const ConsumedScreen({super.key});
  

  @override
  State<ConsumedScreen> createState() =>
      _ConsumedScreenState();
}

class _ConsumedScreenState extends State<ConsumedScreen> {
  // store raw decoded blood test; avoid calling BloodTest.fromJson which may not exist
  Map<String, dynamic>? _latestBloodTest;

  @override
  void initState() {
    super.initState();
    _loadBloodTest();
  }

  Future<void> _loadBloodTest() async {
    final sp = await SharedPreferences.getInstance();
    final tests = sp.getStringList('bloodTests') ?? [];
    if (!mounted) return;
    setState(() {
      _latestBloodTest = tests.isNotEmpty ? (jsonDecode(tests.last) as Map<String, dynamic>) : null;
    });
  }

  Widget bulletPoint(TextTheme textTheme, ColorScheme colorScheme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
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
          "Today's nutrients consumptions",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Consumer2<PatientState, FoodDiaryDB>(
              builder: (context, patientState, foodDiaryDB, _) {
                final patient = patientState.patient;
                if (patient == null) {
                  return const Center(child: Text('User profile not found.'));
                }

                // Build consumed map
                final consumedMap = <dynamic, double>{};
                for (final entry in foodDiaryDB.entries) {
                  final item = FoodCatalog.foods.cast<dynamic>().firstWhere(
                    (f) => (f as dynamic)?.name == entry.foodName,
                    orElse: () => null,
                  );
                  if (item != null) {
                    consumedMap[item as dynamic] = (consumedMap[item as dynamic] ?? 0) + entry.grams;
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
                  final f = food as dynamic;
                  totalFiber += ((f?.fiber ?? 0) as num).toDouble() * (grams / 100);
                });

                // Macro targets
                final targets = DailyTargets.fromPatient(patient);

                // Blood micronutrients consumed
                double totalIron = 0, totalCalcium = 0,
                    totalVitaminD = 0, totalOmega3 = 0;
                consumedMap.forEach((food, grams) {
                  final f = food as dynamic;
                  final scale = grams / 100;
                  totalIron     += (((f?.iron ?? 0) as num).toDouble()) * scale;
                  totalCalcium  += (((f?.calcium ?? 0) as num).toDouble()) * scale;
                  totalVitaminD += (((f?.vitaminD ?? 0) as num).toDouble()) * scale;
                  totalOmega3   += (((f?.omega3 ?? 0) as num).toDouble()) * scale;
                });

                // Blood parameter targets (reference optimal values)
                const double ironTarget     = 18.0;   // mg/day RDA
                const double calciumTarget  = 1000.0; // mg/day RDA
                const double vitaminDTarget = 15.0;   // µg/day RDA
                const double omega3Target   = 1600.0; // mg/day RDA (ALA)
                const double fiberTarget    = 25.0;   // g/day RDA

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
                                    'Daily summary',
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
                            Card(
                              color: colorScheme.surface,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(color: colorScheme.outlineVariant),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Today's macronutrients",
                                      style: textTheme.titleSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        ActivityRing(
                                          label: 'Calories',
                                          value: totalCalories,
                                          target: targets.calories,
                                          unit: 'kcal',
                                          color: colorScheme.primary,
                                          sublabel: '~ ${targets.calories.toInt()} kcal'
                                        ),
                                        ActivityRing(
                                          label: 'Proteins',
                                          value: totalProteins,
                                          target: targets.proteins,
                                          unit: 'g',
                                          color: Colors.blue.shade500,
                                          sublabel: '~ ${targets.proteins.toInt()} g',
                                        ),
                                        ActivityRing(
                                          label: 'Carbohydrates',
                                          value: totalCarbs,
                                          target: targets.carbs,
                                          unit: 'g',
                                          color: Colors.amber.shade600,
                                          sublabel: '~ ${targets.carbs.toInt()} g',
                                        ),
                                        ActivityRing(
                                          label: 'Fats',
                                          value: totalFats,
                                          target: targets.fats,
                                          unit: 'g',
                                          color: Colors.orange.shade500,
                                          sublabel: '~ ${targets.fats.toInt()} g',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── ROW 2: Micronutrienti ─────────────
                            Card(
                              color: colorScheme.surface,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(color: colorScheme.outlineVariant),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Today's micronutrients",
                                          style: textTheme.titleSmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                            fontSize: 18,
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
                                        ActivityRing(
                                          label: 'Iron',
                                          value: totalIron,
                                          target: ironTarget,
                                          unit: 'mg',
                                          color: Colors.red.shade400,
                                          sublabel: '~ ${ironTarget.toInt()} mg',
                                        ),
                                        ActivityRing(
                                          label: 'Calcium',
                                          value: totalCalcium,
                                          target: calciumTarget,
                                          unit: 'mg',
                                          color: Colors.indigo.shade400,
                                          sublabel: '~ ${calciumTarget.toInt()} mg'
                                        ),
                                        ActivityRing(
                                          label: 'Vit. D',
                                          value: totalVitaminD,
                                          target: vitaminDTarget,
                                          unit: 'µg',
                                          color: Colors.orange.shade400,
                                          sublabel: '~ ${vitaminDTarget.toInt()} µg'
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        ActivityRing(
                                          label: 'Omega-3',
                                          value: totalOmega3,
                                          target: omega3Target,
                                          unit: 'mg',
                                          color: Colors.cyan.shade500,
                                          sublabel: '~ ${omega3Target.toInt()} mg',
                                        ),
                                        ActivityRing(
                                          label: 'Fibers',
                                          value: totalFiber,
                                          target: fiberTarget,
                                          unit: 'g',
                                          color: Colors.green.shade500,
                                          sublabel: '~ ${fiberTarget.toInt()} g',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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




  