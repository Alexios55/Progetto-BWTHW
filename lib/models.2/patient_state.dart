import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'patient.dart';
import 'package:bwthw_project/models.2/enums.dart';
import 'package:bwthw_project/services/impact.dart';
import 'package:bwthw_project/models.2/werable_data_models/hourly_wearable_data.dart';

class PatientState extends ChangeNotifier {
  Patient? patient;

  double consumedCalories = 0;
  double burnedCalories = 0;
  int steps = 0;
  int sleepMinutes = 0;
  int heartRate = 0;
  double distanceKm = 0;

  List<HourlyWearableData> hourlyWearableData = [];

  double get distance => distanceKm;

  void setPatient(Patient newPatient) {
    patient = newPatient;
    notifyListeners();
  }

  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final patientJson = prefs.getString('patient');

    if (patientJson == null) {
      print('No patient data found in SharedPreferences');
      return;
    }

    try {
      final loaded = Patient.fromMap(jsonDecode(patientJson));
      final user = prefs.getString('user');
      final password = prefs.getString('password');

      patient = (user != null && password != null)
          ? loaded.copyWith(user: user, password: password)
          : loaded;

      notifyListeners();
    } catch (e) {
      print('Errore loadFromPreferences PatientState: $e');
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

  DateTime? _readTimestamp(dynamic entry) {
    try {
      final value = entry.timestamp;
      if (value is DateTime) return value;
    } catch (_) {}

    try {
      final value = entry.time;
      if (value is DateTime) return value;
    } catch (_) {}

    return null;
  }

  double _readNumericValue(dynamic entry) {
    try {
      final value = entry.value;

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
    } catch (_) {}

    return 0.0;
  }

  bool _isFromStartOfDayToNow(DateTime entryTime, DateTime now) {
    final entryMinutes = entryTime.hour * 60 + entryTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    return entryMinutes <= nowMinutes;
  }

  double _cmToKm(double cm) {
    return cm / 100000.0;
  }

  Future<void> loadDistance() async {
    try {
      final now = DateTime.now();
      final distanceData = await Impact().getDistanceData(now);

      double totalDistanceCm = 0.0;

      for (final entry in distanceData) {
        final timestamp = _readTimestamp(entry);
        if (timestamp == null) continue;

        if (_isFromStartOfDayToNow(timestamp, now)) {
          totalDistanceCm += _readNumericValue(entry);
        }
      }

      distanceKm = _cmToKm(totalDistanceCm);

      print('DISTANCE punti ricevuti: ${distanceData.length}');
      print('DISTANCE totale cm fino ad ora: $totalDistanceCm');
      print('DISTANCE km fino ad ora: $distanceKm');

      notifyListeners();
    } catch (e) {
      print('Errore loadDistance: $e');
    }
  }

  Future<void> refreshWearableData() async {
    try {
      final now = DateTime.now();

      final stepsData = await Impact().getStepsData(now);
      final caloriesData = await Impact().getCaloriesData(now);
      final distanceData = await Impact().getDistanceData(now);

      final List<int> stepsByHour = List<int>.filled(24, 0);
      final List<double> caloriesByHour = List<double>.filled(24, 0.0);

      // IMPACT manda la distanza in centimetri.
      final List<double> distanceCmByHour = List<double>.filled(24, 0.0);

      for (final entry in stepsData) {
        final timestamp = _readTimestamp(entry);
        if (timestamp == null) continue;

        if (_isFromStartOfDayToNow(timestamp, now)) {
          final hour = timestamp.hour;
          final value = _readNumericValue(entry);

          stepsByHour[hour] += value.round();
        }
      }

      for (final entry in caloriesData) {
        final timestamp = _readTimestamp(entry);
        if (timestamp == null) continue;

        if (_isFromStartOfDayToNow(timestamp, now)) {
          final hour = timestamp.hour;
          final value = _readNumericValue(entry);

          caloriesByHour[hour] += value;
        }
      }

      for (final entry in distanceData) {
        final timestamp = _readTimestamp(entry);
        if (timestamp == null) continue;

        if (_isFromStartOfDayToNow(timestamp, now)) {
          final hour = timestamp.hour;
          final value = _readNumericValue(entry);

          distanceCmByHour[hour] += value;
        }
      }

      hourlyWearableData = List.generate(24, (hour) {
        return HourlyWearableData(
          hour: hour,
          steps: stepsByHour[hour],
          burnedCalories: caloriesByHour[hour],
          distanceKm: _cmToKm(distanceCmByHour[hour]),
        );
      });

      steps = stepsByHour.fold<int>(0, (sum, value) => sum + value);

      burnedCalories =
          caloriesByHour.fold<double>(0.0, (sum, value) => sum + value);

      final totalDistanceCm =
          distanceCmByHour.fold<double>(0.0, (sum, value) => sum + value);

      distanceKm = _cmToKm(totalDistanceCm);

      print('REFRESH WEARABLE DATA DA INIZIO GIORNATA FINO AD ORA');
      print('Ora attuale dispositivo: ${now.hour}:${now.minute}');
      print('Steps punti ricevuti: ${stepsData.length}');
      print('Calories punti ricevuti: ${caloriesData.length}');
      print('Distance punti ricevuti: ${distanceData.length}');
      print('Steps totali fino ad ora: $steps');
      print('Calories bruciate fino ad ora: $burnedCalories');
      print('Distance totale cm fino ad ora: $totalDistanceCm');
      print('Distance km fino ad ora: $distanceKm');
      print('Dati orari: $hourlyWearableData');

      notifyListeners();
    } catch (e) {
      print('Errore refreshWearableData: $e');
    }
  }

  void resetDailyData() {
    consumedCalories = 0;
    burnedCalories = 0;
    steps = 0;
    sleepMinutes = 0;
    heartRate = 0;
    distanceKm = 0;
    hourlyWearableData = [];
    notifyListeners();
  }
}