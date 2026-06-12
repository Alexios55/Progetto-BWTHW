import 'package:bwthw_project/models.2/input_mesearument_models/blood_test.dart';
import 'package:bwthw_project/models.2/food_models/food_item.dart';

//  BLOOD TEST ANALYZER
//  Three responsibilities:
//
//  1. DEFICIT NORMALISATION
//     Converts raw blood values into normalised deficit scores in [0, 1], where 0 = optimal and 1 = severely deficient.
///
//  2. KINETIC PREDICTOR
//     Uses a first-order pharmacokinetic model to estimate how each blood parameter will change after N days of a given
//     dietary intake pattern.
//
//     Model (discrete, daily steps):
//       P(t+1) = P(t)
//              + k_abs(p) × intake(p, t)      ← absorption term
//              - k_elim(p) × P(t)             ← elimination term
//
//     k_abs and k_elim are parameter-specific constants derived
//     from clinical literature on nutrient kinetics.
//
//  3. NUTRITIONAL RECOVERY INDEX  (NRI)
//     Measures how effectively the recent diet is correcting blood anomalies.
//
//     NRI ∈ [0, 1]:
//       0 = diet is not addressing any deficiency
//       1 = diet is perfectly targeting all deficiencies

// Reference ranges for each blood parameter.
// Values are [min, optimal, max] in the same units as [BloodTest].
//   iron        µg/dL  (ferritin proxy — simplified)
//   calcium     mg/dL
//   glucose     mg/dL  (fasting)
//   cholesterol mg/dL  (LDL)
//   vitaminD    ng/mL  (25-OH)

class BloodParameterReference {
  final double min;
  final double optimal;
  final double max;

  const BloodParameterReference({
    required this.min,
    required this.optimal,
    required this.max,
  });
}

// Normalised deficit for a single blood parameter.
class ParameterDeficit {
  final String parameter;

  // Raw value from the blood test.
  final double rawValue;

  // Deficit in [0, 1]:  0 = at or above optimal, 1 = at or below min.
  final double deficit;

  // True if the parameter is ABOVE max (excess, not deficiency).
  final bool isExcess;

  const ParameterDeficit({
    required this.parameter,
    required this.rawValue,
    required this.deficit,
    required this.isExcess,
  });
}

class BloodTestAnalyzer {
  // Reference ranges and kinetic constants are defined as static maps for easy access and tuning.
  static const Map<String, BloodParameterReference> references = {
    'iron': BloodParameterReference(
      min: 60,  optimal: 110, max: 170,   // µg/dL (serum iron)
    ),
    'calcium': BloodParameterReference(
      min: 8.5, optimal: 9.5, max: 10.5,  // mg/dL
    ),
    'glucose': BloodParameterReference(
      min: 70,  optimal: 90,  max: 100,   // mg/dL fasting
    ),
    'cholesterol': BloodParameterReference(
      min: 0,   optimal: 100, max: 130,   // mg/dL LDL
    ),
    'vitaminD': BloodParameterReference(
      min: 20,  optimal: 40,  max: 80,    // ng/mL
    ),
  };

  // Kinetic constants 
  // k_abs: fraction of dietary intake absorbed per day (dimensionless, tuned to approximate clinical correction rates)
  static const Map<String, double> kAbsorption = {
    'iron':        0.12,  // ~12% of dietary iron absorbed
    'calcium':     0.30,  // ~30% of dietary calcium absorbed
    'glucose':     0.80,  // glucose absorbed rapidly
    'cholesterol': 0.05,  // dietary influence on LDL is slow
    'vitaminD':    0.60,  // fat-soluble, slower equilibrium
  };

  // k_elim: daily fractional elimination / turnover rate
  static const Map<String, double> kElimination = {
    'iron':        0.005, // iron turns over very slowly
    'calcium':     0.010, // renal + fecal losses
    'glucose':     0.050, // glucose cleared quickly
    'cholesterol': 0.008, // LDL turns over in weeks
    'vitaminD':    0.007, // fat-soluble, slow elimination
  };

  // Dietary intake multipliers 
  // Maps blood parameter -> food micronutrient field that drives it.
  static const Map<String, String> parameterToNutrient = {
    'iron':        'iron',
    'calcium':     'calcium',
    'glucose':     'fiber',   // fiber intake inversely modulates glucose
    'cholesterol': 'omega3',  // omega-3 inversely modulates LDL
    'vitaminD':    'vitaminD',
  };

  
  //  1. DEFICIT NORMALISATION

  // Computes a [ParameterDeficit] for every parameter in [test].
  //
  // Normalisation formula for deficiency:
  //   deficit(p) = clamp((optimal - value) / (optimal - min), 0, 1)
  //
  // For excess parameters (glucose, cholesterol):
  //   deficit(p) = clamp((value - optimal) / (max - optimal), 0, 1)
  static Map<String, ParameterDeficit> computeDeficits(BloodTest test) {
    final values = _testToMap(test);
    final result = <String, ParameterDeficit>{};

    for (final entry in references.entries) {
      final param = entry.key;
      final ref   = entry.value;
      final value = values[param] ?? ref.optimal;

      double deficit;
      bool isExcess;

      // Glucose and cholesterol: higher = worse
      if (param == 'glucose' || param == 'cholesterol') {
        isExcess = value > ref.optimal;
        deficit  = isExcess
            ? ((value - ref.optimal) / (ref.max - ref.optimal)).clamp(0.0, 1.0)
            : 0.0;
      } else {
        // Iron, calcium, vitaminD: lower = worse
        isExcess = value > ref.max;
        deficit  = value < ref.optimal
            ? ((ref.optimal - value) / (ref.optimal - ref.min)).clamp(0.0, 1.0)
            : 0.0;
      }

      result[param] = ParameterDeficit(
        parameter: param,
        rawValue:  value,
        deficit:   deficit,
        isExcess:  isExcess,
      );
    }
    return result;
  }

  // Returns parameters sorted from highest to lowest deficit.
  // This is the **priority ranking** fed into the nutrition engine.
  static List<ParameterDeficit> priorityRanking(BloodTest test) {
    final deficits = computeDeficits(test);
    final list = deficits.values.toList()
      ..sort((a, b) => b.deficit.compareTo(a.deficit));
    return list;
  }

  
  //  2. KINETIC PREDICTOR

  // Predicts blood parameter values after [days] days of the given [dailyFoodIntake] 
  // (list of foods consumed per day, each with an associated gram quantity).
  //
  // Returns a map: parameter → predicted value.
  //
  // Model:
  //   For parameters where higher intake is beneficial
  //   (iron, calcium, vitaminD):
  //     P(t+1) = P(t) + k_abs × nutrientIntake(t) - k_elim × P(t)
  //
  //   For inverse parameters (glucose, cholesterol):
  //     P(t+1) = P(t) - k_abs × modulatorIntake(t) - k_elim × (P(t) - P_baseline)
  //   where the modulator is fiber (for glucose) or omega-3 (for cholesterol).
  static Map<String, double> predictBloodValues({
    required BloodTest initialTest,
    required List<Map<FoodItem, double>> dailyFoodIntake,
    int days = 30,
  }) {
    // Initialise current values from the blood test
    final current = Map<String, double>.from(_testToMap(initialTest));

    for (int day = 0; day < days && day < dailyFoodIntake.length; day++) {
      final dayIntake = dailyFoodIntake[day];

      // Compute total nutrient intake for this day (per 100g basis)
      final totalNutrients = <String, double>{};
      dayIntake.forEach((food, grams) {
        food.nutrientMap.forEach((nutrient, valuePer100g) {
          totalNutrients[nutrient] =
              (totalNutrients[nutrient] ?? 0) + valuePer100g * (grams / 100);
        });
      });

      // Update each parameter with kinetic model
      for (final param in references.keys) {
        final kAbs  = kAbsorption[param]  ?? 0.0;
        final kElim = kElimination[param] ?? 0.0;
        final nutrient = parameterToNutrient[param] ?? param;
        final intake = totalNutrients[nutrient] ?? 0.0;
        final ref = references[param]!;

        if (param == 'glucose' || param == 'cholesterol') {
          // Inverse relationship: more modulator → parameter decreases
          final baselineReduction = kAbs * intake;
          final reversion = kElim * (current[param]! - ref.optimal);
          current[param] = (current[param]! - baselineReduction - reversion)
              .clamp(ref.min, ref.max * 1.5);
        } else {
          // Direct relationship: more nutrient → parameter increases
          current[param] = (current[param]!
              + kAbs * intake
              - kElim * current[param]!)
              .clamp(ref.min * 0.5, ref.max * 1.5);
        }
      }
    }
    return current;
  }

  //  3. NUTRITIONAL RECOVERY INDEX (NRI)

  // Computes NRI ∈ [0, 1] measuring how well the recent diet
  // is targeting the detected deficiencies.
  //
  // Formula:
  //   For each deficient parameter p:
  //     contribution(p) = deficit(p) × dailyNutrientScore(p)
  //   NRI = Σ contribution(p) / Σ deficit(p)
  //
  // where dailyNutrientScore(p) ∈ [0,1] is how well the day's
  // diet covered the nutritional target for parameter p.
  static double computeRecoveryIndex({
    required BloodTest test,
    required Map<FoodItem, double> todayIntake,
  }) {
    final deficits   = computeDeficits(test);
    double weightedScore = 0.0;
    double totalWeight   = 0.0;

    for (final entry in deficits.entries) {
      final param   = entry.key;
      final deficit = entry.value.deficit;

      if (deficit == 0.0) continue; // no deficiency, skip

      final nutrient = parameterToNutrient[param] ?? param;
      final ref      = references[param]!;

      // Compute how much of the target nutrient was consumed today
      double intakeAmount = 0.0;
      todayIntake.forEach((food, grams) {
        intakeAmount += (food.nutrientMap[nutrient] ?? 0) * (grams / 100);
      });

      // Normalise against optimal daily target (ref.optimal used as proxy)
      final score = (intakeAmount / (ref.optimal * 0.1)).clamp(0.0, 1.0);

      weightedScore += deficit * score;
      totalWeight   += deficit;
    }

    return totalWeight > 0 ? weightedScore / totalWeight : 0.0;
  }

  //  HELPERS
  static Map<String, double> _testToMap(BloodTest test) => {
    'iron':        test.iron,
    'calcium':     test.calcium,
    'glucose':     test.glucose,
    'cholesterol': test.cholesterol,
    'vitaminD':    test.vitaminD,
  };
}