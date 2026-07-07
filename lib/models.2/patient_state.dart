import 'package:flutter/material.dart';
import 'patient.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/models.2/werable_data_models/distance.dart' as distance_model;
import 'package:bwthw_project/models.2/werable_data_models/steps.dart' as steps_model;
import 'package:bwthw_project/models.2/werable_data_models/calories.dart' as calories_model;
import 'package:bwthw_project/services/impact.dart';

class PatientState extends ChangeNotifier {
  Patient? patient;

  double consumedCalories = 0;
  double burnedCalories = 0;
  int steps = 0;
  int sleepMinutes = 0;
  int heartRate = 0;
  double distanceKm = 0;

  double get distance => distanceKm;

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

  void updateDistance(double km) {
    distanceKm = km;
    notifyListeners();
  }

  Future<void> loadDistance() async {
    final data = await Impact().getDistanceData(DateTime.now());
    print('Punti ricevuti: ${data.length}');
    if (data.isNotEmpty) print('Primo timestamp: ${data.first.timestamp}');
    final grouped = distance_model.groupStepsByDay(data);
    final totalMeters = distance_model.totalDistanceUpToNow(grouped, DateTime.now());
    distanceKm = totalMeters / 100000.0;
    notifyListeners();

    print('distance km:$distanceKm');
  }

  Future<void> refreshWearableData() async {
  final now = DateTime.now();

  final stepsData = await Impact().getStepsData(now);
  final caloriesData = await Impact().getCaloriesData(now);
  final distanceData = await Impact().getDistanceData(now);

  // steps
  steps = steps_model.totalStepsUpToNow(steps_model.groupStepsByDay(stepsData), now);

  // calories
  final groupedCalories = calories_model.groupCaloriesByDay(caloriesData);
  burnedCalories = calories_model.totalCaloriesUpToNow(groupedCalories, now).toDouble();

  // distanza — raw dal wearable
  final groupedDistance = distance_model.groupStepsByDay(distanceData);
  distanceKm = distance_model.totalDistanceUpToNow(groupedDistance, now) / 1000.0;

  notifyListeners();
}

  void resetDailyData() {
    consumedCalories = 0;
    burnedCalories = 0;
    steps = 0;
    sleepMinutes = 0;
    heartRate = 0;
    distanceKm = 0;
    notifyListeners();
  }
}

