import 'enums.dart';
import 'user.dart';

// This class represents a patient of the application.
class Patient extends User {
  @override
  int age;
  double weightKg;
  double heightCm;
  final Gender gender;
  Goal? goal;
  ActivityLevel activityLevel;
  double? targetWeightKg;

  Patient({
    required String id,
    required String name,
    String surname = '',
    required String email,
    String password = '',
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    this.goal,
    required this.activityLevel,
    this.targetWeightKg,
  }) : super(
          id: id,
          name: name,
          surname: surname,
          email: email,
          password: password,
          weight: weightKg,
          height: heightCm,
          idealWeight: targetWeightKg ?? 0,
        );

  Patient copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? password,
    int? age,
    double? weightKg,
    double? heightCm,
    Gender? gender,
    Goal? goal,
    ActivityLevel? activityLevel,
    double? targetWeightKg,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    );
  }
}

