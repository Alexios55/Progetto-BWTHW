import 'dart:math';
import 'package:bwthw_project/logic/blood_test_analyzer.dart';
import 'package:bwthw_project/models.2/input_mesearument_models/blood_test.dart';
import 'package:bwthw_project/models.2/food_models/food_item.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/logic/nutrient_interaction_graph.dart';

//  NUTRITION ENGINE  —  Multi-Objective Nutritional Scoring (MONS)
//
//  Integrates four modules:
//
//  [A] Priority Pipeline
//      Ranks nutrient deficiencies combining blood deficit + dietary gap, producing a priority vector.
//
//  [B] Nutrient Interaction Graph 
//      Propagates food contributions through synergy/antagonism edges before scoring.
//
//  [C] MONS adaptive scoring
//      score(food) = α·scoreMacro + β·scoreBlood + γ·scoreActivity
//      with dynamic weights (α, β, γ) driven by context.
//
//  [D] Excess penalty
//      Foods providing already-excess nutrients are penalised.
//
//  Final food score formula 
//
//    score(f) = α · scoreMacro(f)
//             + β · scoreBlood(f)       <- graph-propagated
//             + γ · scoreActivity(f)
//             - δ · penaltyExcess(f)
//             + ε · preferenceBonus(f)
//
//  where α + β + γ = 1 and δ, ε are fixed penalty/bonus weights.

// Scored result for a single food item.
class FoodScore {
  final FoodItem food;

  // Total composite score (higher = better recommendation).
  final double totalScore;

  // Breakdown for transparency / UI display.
  final double macroScore;
  final double bloodScore;
  final double activityScore;
  final double excessPenalty;

  // Which deficient parameters this food helps with (for UI labels).
  final List<String> addressedDeficiencies;

  const FoodScore({
    required this.food,
    required this.totalScore,
    required this.macroScore,
    required this.bloodScore,
    required this.activityScore,
    required this.excessPenalty,
    required this.addressedDeficiencies,
  });
}

// Daily nutritional targets for macro scoring.
class DailyTargets {
  final double calories;
  final double proteins;  // g
  final double carbs;     // g
  final double fats;      // g

  const DailyTargets({
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
  });

  // Compute targets from patient profile using Mifflin-St Jeor.
  factory DailyTargets.fromPatient(Patient patient) {
    // Basal Metabolic Rate (Mifflin-St Jeor, kcal/day)
    final double bmr = patient.gender == Gender.male
        ? 10 * patient.weightKg + 6.25 * patient.heightCm - 5 * patient.age + 5
        : 10 * patient.weightKg + 6.25 * patient.heightCm - 5 * patient.age - 161;

    // Activity multiplier
    final double activityFactor = switch (patient.activityLevel) {
      ActivityLevel.sedentary        => 1.2,
      ActivityLevel.lightlyActive    => 1.375,
      ActivityLevel.moderatelyActive => 1.55,
      ActivityLevel.veryActive       => 1.725,
      ActivityLevel.athlete          => 1.9,
    };

    // Goal adjustment
    final double goalAdjustment = switch (patient.goal ?? Goal.maintainWeight) {
      Goal.loseWeight      => -300,
      Goal.gainWeight      => 300,
      Goal.maintainWeight  => 0,
    };

    final double tdee = bmr * activityFactor + goalAdjustment;

    // Macro split: 30% protein, 45% carbs, 25% fat
    return DailyTargets(
      calories: tdee,
      proteins: (tdee * 0.30) / 4,
      carbs:    (tdee * 0.45) / 4,
      fats:     (tdee * 0.25) / 9,
    );
  }
}

class NutritionEngine {
  // Fixed weights 
  static const double _penaltyWeight    = 0.15; // δ
  static const double _preferenceWeight = 0.05; // ε (reserved for future use)
  static const double _minBloodWeight   = 0.20; // β floor
  static const double _maxBloodWeight   = 0.55; // β ceiling

  // Engine entry point 

  // Scores and ranks all foods in [catalog] given the current patient context.
  //
  // Parameters:
  // - [patient]        Patient profile (for BMR, goal, activity)
  // - [targets]        Daily macro targets (pass pre-computed or null)
  // - [consumed]       Map of food → grams already eaten today
  // - [bloodTest]      Most recent blood test (may be null)
  // - [stepsToday]     Steps recorded by wearable today
  // - [caloriesBurned] Active calories from wearable today
  static List<FoodScore> rankFoods({
    required Patient patient,
    required List<FoodItem> catalog,
    DailyTargets? targets,
    Map<FoodItem, double> consumed = const {},
    BloodTest? bloodTest,
    int stepsToday = 0,
    double caloriesBurned = 0,
  }) {
    final dailyTargets = targets ?? DailyTargets.fromPatient(patient);

    // A. Remaining macro budget 
    final remainingCalories = _remainingMacro(
        dailyTargets.calories, consumed, (f) => f.calories);
    final remainingProteins  = _remainingMacro(
        dailyTargets.proteins, consumed, (f) => f.proteins);
    final remainingCarbs     = _remainingMacro(
        dailyTargets.carbs,    consumed, (f) => f.carbs);
    final remainingFats      = _remainingMacro(
        dailyTargets.fats,     consumed, (f) => f.fats);

    // B. Blood deficit priority ranking 
    final deficits = bloodTest != null
        ? BloodTestAnalyzer.computeDeficits(bloodTest)
        : <String, ParameterDeficit>{};

    // C. Adaptive weights α, β, γ 
    final weights = _computeWeights(
      deficits: deficits,
      stepsToday: stepsToday,
      caloriesBurned: caloriesBurned,
    );

    // D. Score every food 
    final scores = catalog.map((food) {
      return _scoreFood(
        food: food,
        remainingCalories: remainingCalories,
        remainingProteins: remainingProteins,
        remainingCarbs: remainingCarbs,
        remainingFats: remainingFats,
        deficits: deficits,
        weights: weights,
        stepsToday: stepsToday,
        caloriesBurned: caloriesBurned,
      );
    }).toList();

    // Sort descending by total score
    scores.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return scores;
  }

  //  ADAPTIVE WEIGHT COMPUTATION

  // Computes (α, β, γ) dynamically.
  //
  //  β (blood weight) increases proportionally to the severity of blood deficiencies (clamped to [_minBloodWeight, _maxBloodWeight]).
  //
  //  γ (activity weight) increases proportionally to exertion (post-workout the body needs more protein and fast carbs).
  //
  //  α = 1 - β - γ  (macro weight is the remainder).
  static ({double alpha, double beta, double gamma}) _computeWeights({
    required Map<String, ParameterDeficit> deficits,
    required int stepsToday,
    required double caloriesBurned,
  }) {
    // Average deficit severity across all parameters
    final avgDeficit = deficits.isEmpty
        ? 0.0
        : deficits.values.map((d) => d.deficit).reduce((a, b) => a + b) /
          deficits.length;

    // β: linearly interpolated between min and max blood weight
    final beta = (_minBloodWeight +
        avgDeficit * (_maxBloodWeight - _minBloodWeight))
        .clamp(_minBloodWeight, _maxBloodWeight);

    // γ: activity factor — 10k steps or 500 kcal burned → γ = 0.20
    final activityFactor =
        min(1.0, (stepsToday / 10000 + caloriesBurned / 500) / 2);
    final gamma = (activityFactor * 0.20).clamp(0.0, 0.25);

    // α: remainder
    final alpha = (1.0 - beta - gamma).clamp(0.0, 1.0);

    return (alpha: alpha, beta: beta, gamma: gamma);
  }

  //  INDIVIDUAL FOOD SCORING
  static FoodScore _scoreFood({
    required FoodItem food,
    required double remainingCalories,
    required double remainingProteins,
    required double remainingCarbs,
    required double remainingFats,
    required Map<String, ParameterDeficit> deficits,
    required ({double alpha, double beta, double gamma}) weights,
    required int stepsToday,
    required double caloriesBurned,
  }) {
    // scoreMacro 
    // How well does a 100g serving of this food cover remaining needs?
    // Each macro contributes proportionally; caloric fit has highest weight.
    final macroScore = _normalisedMacroScore(
      food: food,
      remainingCalories: remainingCalories,
      remainingProteins: remainingProteins,
      remainingCarbs: remainingCarbs,
      remainingFats: remainingFats,
    );

    // scoreBlood 
    // Weighted sum of graph-propagated contributions to each
    // deficient parameter, weighted by deficit severity.
    double bloodScore = 0.0;
    double totalDeficit = 0.0;
    final addressedDeficiencies = <String>[];

    for (final entry in deficits.entries) {
      final param   = entry.key;
      final deficit = entry.value.deficit;

      if (deficit == 0.0) continue;
      totalDeficit += deficit;

      // Graph-propagated effective contribution of this food
      final effectiveContrib = NutrientInteractionGraph.propagatedScore(
        targetNutrient: _paramToNutrient(param),
        foodNutrients: food.nutrientMap,
      );

      bloodScore += deficit * effectiveContrib;

      if (effectiveContrib > 0.05) {
        addressedDeficiencies.add(param);
      }
    }

    // Normalise bloodScore to [0, 1]
    if (totalDeficit > 0) bloodScore = (bloodScore / totalDeficit).clamp(0.0, 1.0);

    // scoreActivity 
    // After exertion, prioritise protein (muscle repair) and
    // carbohydrates (glycogen replenishment).
    final activityFactor =
        min(1.0, (stepsToday / 10000 + caloriesBurned / 500) / 2);
    final activityScore = (food.proteins / 30 * 0.6 + food.carbs / 60 * 0.4)
        .clamp(0.0, 1.0) * activityFactor;

    // penaltyExcess 
    // Penalise foods that contain nutrients already in excess.
    double penalty = 0.0;
    for (final entry in deficits.entries) {
      if (!entry.value.isExcess) continue;
      final nutrient = _paramToNutrient(entry.key);
      final contrib  = food.nutrientMap[nutrient] ?? 0.0;
      penalty += (contrib / 50.0).clamp(0.0, 1.0) * entry.value.deficit;
    }
    penalty = penalty.clamp(0.0, 1.0);

    // Composite score 
    final total = (weights.alpha * macroScore
                 + weights.beta  * bloodScore
                 + weights.gamma * activityScore
                 - _penaltyWeight * penalty)
        .clamp(0.0, 1.0);

    return FoodScore(
      food:                 food,
      totalScore:           total,
      macroScore:           macroScore,
      bloodScore:           bloodScore,
      activityScore:        activityScore,
      excessPenalty:        penalty,
      addressedDeficiencies: addressedDeficiencies,
    );
  }

  // MACRO SCORE

  // Returns a score in [0, 1] for how well 100g of [food] covers the remaining macro budget.
  //
  // A food that exactly covers the caloric remainder scores 1.0;
  // overshooting is penalised with a soft sigmoid falloff.
  static double _normalisedMacroScore({
    required FoodItem food,
    required double remainingCalories,
    required double remainingProteins,
    required double remainingCarbs,
    required double remainingFats,
  }) {
    if (remainingCalories <= 0) return 0.0;

    // Caloric fit: ratio of food calories to remaining budget
    // Score peaks at ~0.5 of remaining (a single food shouldn't fill everything)
    final calRatio = food.calories / remainingCalories;
    final calScore = _bellCurve(calRatio, peak: 0.35, width: 0.30);

    // Protein fit
    final protRatio  = remainingProteins > 0
        ? (food.proteins / remainingProteins).clamp(0.0, 1.0) : 0.0;
    final carbRatio  = remainingCarbs > 0
        ? (food.carbs   / remainingCarbs).clamp(0.0, 1.0) : 0.0;
    final fatRatio   = remainingFats > 0
        ? (food.fats    / remainingFats).clamp(0.0, 1.0) : 0.0;

    // Weighted combination (calories dominant)
    return (calScore * 0.50 + protRatio * 0.25 + carbRatio * 0.15 + fatRatio * 0.10)
        .clamp(0.0, 1.0);
  }

  // Gaussian bell curve centred at [peak] with standard deviation [width].
  static double _bellCurve(double x, {required double peak, required double width}) {
    return exp(-pow(x - peak, 2) / (2 * pow(width, 2)));
  }

  //  HELPERS

  static double _remainingMacro(
    double target,
    Map<FoodItem, double> consumed,
    double Function(FoodItem) getter,
  ) {
    double eaten = 0.0;
    consumed.forEach((food, grams) {
      eaten += getter(food) * (grams / 100);
    });
    return (target - eaten).clamp(0, double.infinity);
  }

  // Maps a blood parameter name to the food micronutrient field
  // that most directly drives it.
  static String _paramToNutrient(String param) =>
      BloodTestAnalyzer.parameterToNutrient[param] ?? param;
}