import 'package:flutter/material.dart';
import 'patient.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/models.2/enums.dart';

class PatientState extends ChangeNotifier {
  Patient? patient;

  double consumedCalories = 0;
  double burnedCalories = 0;
  int steps = 0;
  int sleepMinutes = 0;
  int heartRate = 0;

  void setPatient(Patient newPatient) {
    patient = newPatient;
    notifyListeners();
  }

  Future<void> loadFromPreferences() async {
    final loaded = await PreferenceService.getPatient();
    if (loaded != null) {
      patient = loaded;
      notifyListeners();
    }
  }

  void updateWeight(double newWeight) {
    if (patient == null) return;
    patient = patient!.copyWith(weightKg: newWeight);
    notifyListeners();
  }

  void updateGoal(Goal newGoal) {
    if (patient == null) return;
    patient = patient!.copyWith(goal: newGoal);
    notifyListeners();
  }

  void addConsumedCalories(double calories) {
    consumedCalories += calories;
    notifyListeners();
  }

  void addBurnedCalories(double calories) {
    burnedCalories += calories;
    notifyListeners();
  }

  void updateSteps(int newSteps) {
    steps = newSteps;
    notifyListeners();
  }

  void updateSleepMinutes(int newSleepMinutes) {
    sleepMinutes = newSleepMinutes;
    notifyListeners();
  }

  void updateHeartRate(int newHeartRate) {
    heartRate = newHeartRate;
    notifyListeners();
  }

  void resetDailyData() {
    consumedCalories = 0;
    burnedCalories = 0;
    steps = 0;
    sleepMinutes = 0;
    heartRate = 0;
    notifyListeners();
  }
}

