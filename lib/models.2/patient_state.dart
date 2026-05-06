import 'package:flutter/material.dart';
import 'patient.dart';

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
