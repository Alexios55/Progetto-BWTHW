import 'package:bwthw_project/models/enums/activity_level.dart';
import 'package:bwthw_project/models/enums/gender.dart';
import 'package:bwthw_project/models/enums/goal.dart';

import 'user_model.dart';

class PatientUser extends UserModel {
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final Goal goal;
  final double? targetWeightKg;

  const PatientUser({
    required super.name,
    required super.surname,
    required super.age,
    required super.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.goal,
    this.targetWeightKg,
  });

  PatientUser copyWith({
    String? name,
    String? surname,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    Goal? goal,
    double? targetWeightKg,
  }) {
    return PatientUser(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    );
  }
}
