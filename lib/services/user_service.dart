import 'package:bwthw_project/logic/health_calculator.dart';
import 'package:bwthw_project/models/daily_health_data.dart';
import 'package:bwthw_project/models/enums/activity_level.dart';
import 'package:bwthw_project/models/enums/gender.dart';
import 'package:bwthw_project/models/enums/goal.dart';
import 'package:bwthw_project/models/users/patient_user.dart';
import 'package:flutter/foundation.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  PatientUser? _currentPatient;
  DailyHealthData _dailyHealthData = const DailyHealthData(
    steps: 8200,
    activeCaloriesBurned: 320,
    heartRate: 76,
    systolicPressure: 118,
    diastolicPressure: 76,
  );

  final Map<String, double> _mealCalories = {
    'Breakfast': 0,
    'Snack': 0,
    'Lunch': 0,
    'Dinner': 0,
  };

  PatientUser? get currentPatient => _currentPatient;
  DailyHealthData get dailyHealthData => _dailyHealthData;
  double get weight => _currentPatient?.weightKg ?? 0;
  double get height => _currentPatient?.heightCm ?? 0;
  int get age => _currentPatient?.age ?? 0;
  double get dailyCaloriesTarget =>
      _currentPatient == null
          ? 0
          : HealthCalculator.calculateDailyCaloriesTarget(_currentPatient!);

  Map<String, double> get mealCalories => Map.unmodifiable(_mealCalories);

  void setUserData({
    required double weight,
    required double height,
    required int age,
    Gender gender = Gender.male,
    ActivityLevel activityLevel = ActivityLevel.moderatelyActive,
    Goal goal = Goal.loseWeight,
  }) {
    _currentPatient = PatientUser(
      name: '',
      surname: '',
      age: age,
      gender: gender,
      heightCm: height,
      weightKg: weight,
      activityLevel: activityLevel,
      goal: goal,
    );
    notifyListeners();
  }

  double calculateBMI() {
    return HealthCalculator.calculateBmi(weightKg: weight, heightCm: height);
  }

  double calculateBmr() {
    if (_currentPatient == null) {
      return 0;
    }
    return HealthCalculator.calculateBmr(_currentPatient!);
  }

  double calculateTdee() {
    if (_currentPatient == null) {
      return 0;
    }
    return HealthCalculator.calculateTdee(_currentPatient!);
  }

  void setMealCalories(String mealName, double calories) {
    _mealCalories[mealName] = calories;
    notifyListeners();
  }

  double getConsumedCalories() {
    return _mealCalories.values.fold(0, (sum, value) => sum + value);
  }

  void updateSmartwatchData(DailyHealthData data) {
    _dailyHealthData = data;
    notifyListeners();
  }

  String getDailyFeedback() {
    if (_currentPatient == null) {
      return 'Complete your profile to receive personalized feedback.';
    }

    final summary = HealthCalculator.buildDailyRecommendation(
      patient: _currentPatient!,
      consumedCalories: getConsumedCalories(),
      dailyHealthData: _dailyHealthData,
    );

    return summary.message;
  }
}
