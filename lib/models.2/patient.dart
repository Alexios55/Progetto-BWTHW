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

  // Let's make weight from user and weight from patient the same thing, so we can use the weight from user to calculate the BMI and other things, but we can also use the weight from patient to save the weight entries and other things related to the weight.
  @override
  double get weight => weightKg;

  Patient({
    required String id,
    required String name,
    String surname = '',
    required String user,
    String password = '',
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    this.goal,
    required this.activityLevel,
    this.targetWeightKg,
    DateTime? birthDate,

  }) : super(
          id: id,
          name: name,
          surname: surname,
          user: user,
          password: password,
          weight: weightKg,
          height: heightCm,
          idealWeight: targetWeightKg ?? 0,
          birthDate: birthDate,
        );

  Patient copyWith({
    String? id,
    String? name,
    String? surname,
    String? user,
    String? password,
    int? age,
    double? weightKg,
    double? heightCm,
    Gender? gender,
    Goal? goal,
    ActivityLevel? activityLevel,
    double? targetWeightKg,
    DateTime? birthDate,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      user: user ?? this.user,
      password: password ?? this.password,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'surname': surname,
    'user': user,
    'password': password,
    'age': age,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'gender': gender.name,
    'goal': goal?.name,
    'activityLevel': activityLevel.name,
    'targetWeightKg': targetWeightKg,
    'birthDate': birthDate.toIso8601String(),
  };
}

factory Patient.fromMap(Map<String, dynamic> map) {
  return Patient(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    surname: map['surname'] ?? '',
    user: map['user'] ?? '',
    password: map['password'] ?? '',
    age: map['age'] ?? 0,
    weightKg: (map['weightKg'] ?? 0).toDouble(),
    heightCm: (map['heightCm'] ?? 0).toDouble(),
    gender: Gender.values.byName(map['gender'] ?? 'male'),
    goal: map['goal'] != null ? Goal.values.byName(map['goal']) : null,
    activityLevel: ActivityLevel.values.byName(
      map['activityLevel'] ?? 'moderatelyActive',
    ),
    targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble(),
    birthDate: DateTime.tryParse(map['birthDate'] ?? ''),
  );
}
}

