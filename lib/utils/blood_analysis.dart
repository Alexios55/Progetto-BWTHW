import 'package:bwthw_project/models/blood_test.dart';  

class BloodAnalysisResult {
  final String status;
  final String message;

  BloodAnalysisResult(this.status, this.message);
}

class BloodAnalysis {
  static BloodAnalysisResult analyzeIron(double value) {
    if (value < 60) {
      return BloodAnalysisResult(
        'LOW',
        'Low iron: increase spinach, legumes, red meat.',
      );
    } else if (value > 170) {
      return BloodAnalysisResult(
        'HIGH',
        'High iron: avoid excessive red meat and supplements.',
      );
    } else {
      return BloodAnalysisResult(
        'NORMAL',
        'Iron level is normal. Keep balanced diet.',
      );
    }
  }

  static BloodAnalysisResult analyzeCalcium(double value) {
    if (value < 8.5) {
      return BloodAnalysisResult(
        'LOW',
        'Low calcium: increase dairy products.',
      );
    } else if (value > 10.5) {
      return BloodAnalysisResult(
        'HIGH',
        'High calcium: reduce supplements, check hydration.',
      );
    } else {
      return BloodAnalysisResult(
        'NORMAL',
        'Calcium level is normal.',
      );
    }
  }

  static BloodAnalysisResult analyzeGlucose(double value) {
    if (value < 70) {
      return BloodAnalysisResult(
        'LOW',
        'Low glucose: increase complex carbs.',
      );
    } else if (value > 100) {
      return BloodAnalysisResult(
        'HIGH',
        'High glucose: reduce sugars and refined carbs.',
      );
    } else {
      return BloodAnalysisResult(
        'NORMAL',
        'Glucose level is normal.',
      );
    }
  }

  static BloodAnalysisResult analyzeCholesterol(double value) {
    if (value > 200) {
      return BloodAnalysisResult(
        'HIGH',
        'High cholesterol: reduce saturated fats.',
      );
    } else {
      return BloodAnalysisResult(
        'NORMAL',
        'Cholesterol is within healthy range.',
      );
    }
  }

  static BloodAnalysisResult analyzeVitaminD(double value) {
    if (value < 20) {
      return BloodAnalysisResult(
        'LOW',
        'Low vitamin D: increase fish, eggs, sunlight.',
      );
    } else if (value > 50) {
      return BloodAnalysisResult(
        'HIGH',
        'High vitamin D: avoid excessive supplements.',
      );
    } else {
      return BloodAnalysisResult(
        'NORMAL',
        'Vitamin D level is normal.',
      );
    }
  }

  static String fullAnalysis(BloodTest t) {
    final results = [
      analyzeIron(t.iron),
      analyzeCalcium(t.calcium),
      analyzeGlucose(t.glucose),
      analyzeCholesterol(t.cholesterol),
      analyzeVitaminD(t.vitaminD),
    ];

    final issues = results.where((r) => r.status != 'NORMAL').toList();

    if (issues.isEmpty) {
      return 'All your values are within the normal range. Keep maintaining a balanced diet and healthy lifestyle.';
    }

    return issues.map((e) => e.message).join('\n');
  }
}