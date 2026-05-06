import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/models.2/patient.dart';

//This function calculates the BMR of a patient.
double calculateBmr(Patient patient) {
  double base = 10 * patient.weightKg +
      6.25 * patient.heightCm -
      5 * patient.age;

  if (patient.gender == Gender.male) {
    return base + 5;
  }

  return base - 161;
}//calculateBmr

//This function returns the multiplier based on the activity level.
double activityMultiplier(ActivityLevel activityLevel) {
  switch (activityLevel) {
    case ActivityLevel.sedentary:
      return 1.2;
    case ActivityLevel.light:
      return 1.375;
    case ActivityLevel.moderate:
      return 1.55;
    case ActivityLevel.active:
      return 1.725;
    case ActivityLevel.veryActive:
      return 1.9;
  }
}//activityMultiplier

//This function calculates the TDEE of a patient.
double calculateTdee(Patient patient) {
  return calculateBmr(patient) * activityMultiplier(patient.activityLevel);
}//calculateTdee

//This function calculates the daily calorie goal based on the patient goal.
double calculateDailyCalorieGoal(Patient patient) {
  double tdee = calculateTdee(patient);

  switch (patient.goal) {
    case Goal.loseWeight:
      return tdee - 500;
    case Goal.maintainWeight:
      return tdee;
    case Goal.gainWeight:
      return tdee + 300;
  }
}//calculateDailyCalorieGoal