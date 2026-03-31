// This is a subclass of the user for the patient, it will have all the information of the user and than specific information for the patient, such as weight and height and activity level and goal
import 'user_model.dart';

class PatientUser extends UserMode {
  double height;
  double weight;
  String activityLevel;
  String goal; // lose weight, maintain weight, gain weight

  PatientUser({
    required super.name,
    required super.surname,
    required super.age,
    required super.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal
  });
}
