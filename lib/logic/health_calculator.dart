import 'package:bwthw_project/models.2/daily_health_data.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/models.2/patient.dart';
import 'package:bwthw_project/models.2/recommendation_summary.dart';

class HealthCalculator {
  static double calculateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    final heightMeters = heightCm / 100;
    if (heightMeters <= 0) {
      return 0;
    }
    return weightKg / (heightMeters * heightMeters);
  }

  static double calculateBmr(Patient patient) {
    final base =
        (10 * patient.weightKg) + (6.25 * patient.heightCm) - (5 * patient.age);

    switch (patient.gender) {
      case Gender.female:
        return base - 161;
      case Gender.male:
        return base + 5;
      case Gender.other:
        return base - 78;
    }
  }

  static double calculateTdee(Patient patient) {
    return calculateBmr(patient) * patient.activityLevel.multiplier;
  }

  static double calculateDailyCaloriesTarget(Patient patient) {
    return calculateTdee(patient) + patient.goal.calorieAdjustment;
  }

  static ({double minKg, double maxKg}) calculateHealthyWeightRange(
    double heightCm,
  ) {
    final heightMeters = heightCm / 100;
    final minKg = 18.5 * heightMeters * heightMeters;
    final maxKg = 24.9 * heightMeters * heightMeters;
    return (minKg: minKg, maxKg: maxKg);
  }

  static RecommendationSummary buildDailyRecommendation({
    required Patient patient,
    required double consumedCalories,
    required DailyHealthData dailyHealthData,
  }) {
    final baseTarget = calculateDailyCaloriesTarget(patient);
    final adaptiveTarget = baseTarget + (dailyHealthData.activeCaloriesBurned * 0.6);
    final caloriesRemaining = adaptiveTarget - consumedCalories;

    String message;
    if (caloriesRemaining > 350) {
      message =
          'You still have room for a balanced meal today. Focus on protein and fiber.';
    } else if (caloriesRemaining >= 0) {
      message =
          'You are close to your target. A light dinner or snack would keep you on track.';
    } else if (dailyHealthData.steps >= 10000) {
      message =
          'You went above your base target, but your activity was strong today. Keep dinner lighter.';
    } else {
      message =
          'You are above today\'s target. More movement or a lighter next meal would help.';
    }

    return RecommendationSummary(
      targetCalories: adaptiveTarget,
      caloriesRemaining: caloriesRemaining,
      message: message,
    );
  }
}

