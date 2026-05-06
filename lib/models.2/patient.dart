import 'enums.dart';
import 'user.dart';

//This class represents a patient of the application.
class Patient extends User {
  int age;
  double weightKg;
  double heightCm;
  Gender gender;
  Goal goal;
  ActivityLevel activityLevel;

  Patient({
    required super.id,
    required super.name,
    required super.email,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.goal,
    required this.activityLevel,
  });
}//Patient